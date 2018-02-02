# Simple nginx website provisdion
### prerequisite:
* **`~/.aws/credentials` file should have aws access and secret keys**

content template:
```
[default]
aws_access_key_id=XXXXXXXXXXX
aws_secret_access_key=xxxxxxxxxxxx
```
* **ansible must be installed**
### how to provision the infra and deploy
Simple, run `bash provision.sh`. Thsi script can optionally take an argument for instance type. Default is t2.micro

# List ec2 and rds resources
### prerequisite:
* boto3 python package is required `pip install boto3`
* same creds at `~/.aws/credentials` should work
run `python list_resources.py`


