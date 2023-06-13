# 
# .: IaC Lab #3 - Vulnerable Batch Scenario :.

**Brief lab description:** The deployed infrastructure will run a simple application designed to demonstrate batch execution via AWS Batch. Can you find the pitfall in the environment and escalate your privileges in IAM?

**Blog post:** [Tidbit #3 - Messing around with AWS Batch For Privilege Escalations](https://blog.doyensec.com/2023/06/13/messing-around-with-aws-batch-for-privilege-escalations.html)

<img width="1259" alt="batch-app" src="https://github.com/doyensec/cloudsec-tidbits/assets/92733595/826719e3-f6bf-4e07-8816-c235a6489522">

### Requirements
- The [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed
- [AWS account](https://aws.amazon.com/free) and [associated credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html) that allow you to create resources
- The [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)  installed and [configured](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration) to work with AWS
  
**Note:** The application runs in a container image fetched from the public Doyensec Amazon Elastic Container Registry  (ECR). The web application code is also present in this repository for an eventual local deployment.  

### Deployment

*Batch lab deployment*

```bash
$ git clone https://github.com/doyensec/cloudsec-tidbits.git

$ cd cloudsec-tidbits/lab-batch/terraform/
$ bash deploy-batch-lab.sh
```
