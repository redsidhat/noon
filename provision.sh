#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
GRN='\033[0;32m'
YLW='\033[1;33m'
#checking machine type
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    *)          machine="UNKNOWN"
esac
if [ $machine == 'UNKNOWN' ]; then
	echo "Unknown machine type. Exiting"
	exit 1
fi
echo "Checking if terraform is present"
if [ ! -f terraform ]; then
    echo "Terraform is not present downloading."
    if [ $machine == 'Linux' ]; then
    	curl -o terraform.zip https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip
    elif [ $machine == 'Mac' ]; then
    	curl -o terraform.zip https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_darwin_amd64.zip
    fi
    unzip terraform.zip
    if [ $? -ne 0 ]; then
    	print "unzip failed"
    	exit 1
    fi
    chmod +x terraform
    if [ -f terraform ]; then
    	echo "terraform downloaded"
    fi
    echo "cleaning up"
    rm -rf terraform.zip
else
	echo "Terraform is present; proceeding"
fi
echo "Checking if the keypair exist in the directory"
if [ ! -f keyfile ] || [ ! -f keyfile.pub ]; then
	echo "Keypair not present. Generating new keypair"
	ssh-keygen -b 2048 -t rsa -f ./keyfile -q -N ""
    if [ $? -ne 0 ]; then
    	print "keyfile generation failed"
    	exit 1
    fi
else
	echo "Keypair found; proceeding"
fi
PUB_KEY=`cat keyfile.pub`

if [ ! -z $1 ]; then
	cd terraform_code
	REPLACE="    instance_type = \\\"$1\\\""
	#Did not use direct file replacement to ensure compatibility on linux and BSD based OSs
	echo `cat origin.tf |sed -e "s|.*instance_type.*|$REPLACE|g" > origin.tf.bk && mv origin.tf.bk origin.tf`
else
	cd terraform_code
fi


echo "Updating terraform keypair class with new public key"
REPLACE="  public_key = \\\"$PUB_KEY\\\""
#Following line does a simple sed replace in keypair.tf. 
echo `cat keypair.tf |sed -e "s|.*public_key.*|$REPLACE|g" > keypair.tf.bk && mv keypair.tf.bk keypair.tf`
echo "Running terraform plan"
../terraform plan
if [ $? -eq 0 ]; then
    echo -e "\n\n\"terraform plan\" ran ${GRN}OK${NC}\n"
else
	echo -e "\n\n\"terraform plan\" ${RED}failed${NC}. Check above output for more details.\n"
	exit
fi

echo -e "${YLW}Running \"terraform apply\"${NC}"
../terraform apply
if [ $? -eq 0 ]; then
    echo -e "\n\n\"terraform apply\" ran ${GRN}OK\n${NC}"
else
	echo -e "\n\n\"terraform apply\" ${RED}Failed${NC}. Check above output for more details.\n"
	exit
fi
echo -e "${YLW}Getting IP from terraform${NC}"
IP=`../terraform output |grep -A1 'origin_ip' |grep -v 'origin_ip' | awk '{print $1}'`
DNS=`../terraform output |grep -A1 'elb_dns' |grep -v 'elb_dns' | awk '{print $1}'`
echo -e "${GRN}IP: $IP ${NC}"
echo -e "${YLW}Switching directory to ansible${NC}"
cd ../ansible
echo -e "${YLW}cleaning up the hosts file if there is any old ips present in it${NC}"
#following or is for linux vs bsd
sed '/.*simple-host\]$/,/^\[.*/{//!d;}' hosts > hosts.bk || sed '/.*simple-host\]$/,/^\[.*/{//!d}' hosts>hosts.bk
mv hosts.bk hosts
LINE=`cat hosts| grep -n 'simple-host'|grep -o '^[0-9]*'`
let "LINE++"
awk -v IP="$IP" -v LN="$LINE" 'NR==LN{print IP}1' hosts > hosts.new && mv hosts.new hosts
echo -e "${GRN}Added new IP to hosts file${NC}"
echo -e "${YLW}Waiting 10 seconds and Running ansible ping\n${NC}"
sleep 10
# ansible simple-host -i hosts -m ping --key-file ../keyfile
# if [ $? -eq 0 ]; then
#     echo -e "\n\n\"ansible ping\" ran ${GRN}OK\n${NC}"
# else
# 	echo -e "\n\n\"ansible ping\" ${RED}Failed. \n${YLW}It could be becuase the aws ec2 instance is still initiating. Please retry.${NC}\nCheck above output for more details.\n"
# 	exit
# fi
echo -e "${YLW}Applying ansible play-book\n${NC}"
ansible-playbook -i hosts simple-nginx.yml
echo -e "${YLW}=======================================================================================\n${NC}"
echo -e "${GRN}Access the simple nginx website at http://$DNS\n${NC}"
echo -e "${YLW}=======================================================================================\n${NC}"
