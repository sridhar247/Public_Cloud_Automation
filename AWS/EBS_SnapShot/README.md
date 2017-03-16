ebs-automatic-snapshot-bash
===================================

####Bash script for Automatic EBS Snapshots and Cleanup on Amazon Web Services (AWS)


===================================

**How it works:**
ebs-snapshot.sh will:
- Determine the instance ID of the EC2 server on which the script runs
- Gather a list of all volume IDs attached to that instance
- Take a snapshot of each attached volume
- The script will then delete all associated snapshots taken by the script that are older than 7 days

Pull requests greatly welcomed!

===================================

**REQUIREMENTS**

**IAM User:** This script requires that new IAM user credentials be created, with the following IAM security policy attached:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1426256275000",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSnapshot",
                "ec2:CreateTags",
                "ec2:DeleteSnapshot",
                "ec2:DescribeSnapshots",
                "ec2:DescribeVolumes"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```
<br />

You should then setup a cron job in order to schedule a nightly backup. Example crontab jobs:
```
55 22 * * * root  AWS_CONFIG_FILE="/root/.aws/config" /opt/aws/ebs-snapshot.sh

# Or written another way:
AWS_CONFIG_FILE="/root/.aws/config" 
55 22 * * * root  /opt/aws/ebs-snapshot.sh
```

To manually test the script:
```
sudo /opt/aws/ebs-snapshot.sh
```
