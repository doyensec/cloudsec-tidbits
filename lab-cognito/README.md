# .: IaC Lab #2 - Vulnerable Cognito Scenario :.

**Brief lab description:** The deployed infrastructure will run a simple application designed to demonstrate users management via AWS Cognito. Can you read the registered users list?

**Blog post:** [Tidbit #2 - Tampering User Attributes In AWS Cognito User Pools](https://blog.doyensec.com/2023/01/24/tampering-unrestricted-user-attributes-aws-cognito.html)

<img width="1259" alt="cognito-app" src="https://user-images.githubusercontent.com/77505868/214042925-de819a0d-9cf8-49a0-9315-f78b70356d50.png">

### Requirements
- The [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed
- [AWS account](https://aws.amazon.com/free) and [associated credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html) that allow you to create resources
- The [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)  installed and [configured](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration) to work with AWS
  
**Note:** The application runs in a container image fetched from the public Doyensec Amazon Elastic Container Registry  (ECR). The web application code is also present in this repository for an eventual local deployment.  

### Deployment

*Cognito lab deployment*

```bash
$ git clone https://github.com/doyensec/cloudsec-tidbits.git

$ cd cloudsec-tidbits/lab-cognito/terraform/
$ bash deploy-cognito-lab.sh
```
