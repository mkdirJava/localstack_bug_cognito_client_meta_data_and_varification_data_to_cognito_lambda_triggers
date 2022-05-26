# LocalStack Bug Report

This repo serves as a test rig / dev fix resource to fix a bug regarding localstacks' implementation of Cognito Lmbda triggers. In short LocalStack is not forwarding the verification_data or the client_metadata (used in presign up lambda trigger, decides if the user can signup or not to cognito).

### Requirements
1. tflocal (a wrapper for terraform to deploy to localstack) to deploy
    * https://docs.localstack.cloud/integrations/terraform/
    * Still need to install terraform 
        * https://learn.hashicorp.com/tutorials/terraform/install-cli
2. aws cli as a querying tool 
    * https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
    * Note when you have it installed query the localstack by 
        ```
            aws --endpoint-url=http://localhost:<4566, whatever port localstack outputs> <command> <options>
        ``` 


Steps

1. Update the docker-compose.yaml with a "Pro" or 14 day trail token 
2. start up localstack 
    ``` 
    docker-compose up &
    ```
3. cd into deployment and run terraform 
    ```
    tflocal init && tflocal apply --auto-approve

    ```
    * Terraform will setup Cognito and also try to add in a new cognito user. When this happens, the lambda hook will take affect. Should the variables not be there Terrraform will spit out an error. Should they be there then terraform will not spit out an error
    
    * to give it another attempt stay in deployment and run 

    ```
        tflocal destroy --auto-approve && tflocal apply --auto-approve
    ```