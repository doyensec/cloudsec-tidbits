# .: IaC Lab #1 - Data Import Vulnerability Scenario :.

**Brief lab description:** The deployed infrastructure will run a simple application designed to fetch and store data from AWS S3 Buckets. Can you leak the data stored within the internal infrastructure?

**Blog post:** [Tidbit #1 - The Danger of Falling to System Role in AWS SDK Client](https://blog.doyensec.com/2022/10/18/cloudsectidbit-dataimport.html)

<img width="1614" alt="cloudsectidbit-dataimport" src="https://github.com/doyensec/cloudsec-tidbits/assets/92733595/8a1bd75c-089b-435a-a9e2-1311f158cba8">


### Requirements
- The [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed
- [AWS account](https://aws.amazon.com/free) and [associated credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html) that allow you to create resources
- The [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)  installed and [configured](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration) to work with AWS
  
**Note:** The application runs in a container image fetched from the public Doyensec Amazon Elastic Container Registry  (ECR). The web application code is also present in this repository for an eventual local deployment.  

### Deployment

*Data Import lab deployment*

```bash
$ git clone https://github.com/doyensec/cloudsec-tidbits.git

$ cd cloudsec-tidbits/lab-dataimport/terraform/
$ bash deploy-dataimport-lab.sh
```