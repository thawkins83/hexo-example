This repo is to be used with the following [blog entry](http://blog.hawktail.io/2019/05/04/How-I-Made-This-Blog/).

Edit the `parameters/parameters.json` file with appropriate values and run the follow command.

```bash
$ aws cloudformation create-stack --stack-name blog-test --template-body file://blog.yaml --parameters file://parameters/parameters.json --capabilities CAPABILITY_NAMED_IAM --region us-east-1 --profile myProfile 
```