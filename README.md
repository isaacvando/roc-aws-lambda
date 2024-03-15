# roc-aws-lambda-runtime

A custom runtime for AWS Lambda written in Roc. See also a Roc platform written in Rust for AWS Lambda: [roc-aws-lambda](https://github.com/isaacvando/roc-aws-lambda).

## Usage

`bootstrap.roc` is the main runtime file. It gets compiled to a binary called `bootstrap` which Lambda will execute to initialize the runtime that will handle future requests. You do not need to change `bootstrap.roc`, but you may want to!
To compile a function, use the included build script:
```bash
$ ./build.sh yourfunction.roc
```
Then you can deploy the Lambda to your AWS account with the deployment script:
```bash
$ ./deploy.sh yourfunction arn:aws:iam::{your_account_id}:role/{your_role_name}
```
or you can manually upload the `bootstrap.zip` output by `build.sh` to the AWS Console.

## Contributing

PRs are very welcome!

## TODO

It would be great to have all of these features eventually:

- [ ] The ability to compile Lambdas from MacOS.
- [ ] A more robust build process.
- [ ] A more robust deployment process.
- [ ] The ability to use Lambda functions with the local development server provided by the Rust runtime.
