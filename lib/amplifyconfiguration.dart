const amplifyconfig = ''' {
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify-cli/0.1.0",
                "Version": "0.1.0",
                "IdentityManager": {
                    "Default": {}
                },
                "CredentialsProvider": {
                    "CognitoIdentity": {
                        "Default": {
                            "PoolId": "ap-southeast-1:54b685a9-e892-41bf-91e1-8209513db5ef",
                            "Region": "ap-southeast-1"
                        }
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "ap-southeast-1_xXIEElNFP",
                        "AppClientId": "3csfrm3inp1rq3bjri88q5i51r",
                        "Region": "ap-southeast-1"
                    }
                },
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH"
                    }
                },
                "AppSync": {
                    "Default": {
                        "ApiUrl": "https://pjyi5fvkejh5vhcjkeupxyktce.appsync-api.ap-southeast-1.amazonaws.com/graphql",
                        "Region": "ap-southeast-1",
                        "AuthMode": "API_KEY",
                        "ApiKey": "da2-bgsyiz4qora4zk4tvgw7ev6dk4",
                        "ClientDatabasePrefix": "flutteramplify_API_KEY"
                    }
                },
                "S3TransferUtility": {
                    "Default": {
                        "Bucket": "flutteramplify32917a364a1942d5b5203a9c772381ec102628-dev",
                        "Region": "ap-southeast-1"
                    }
                }
            }
        }
    },
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                "flutteramplify": {
                    "endpointType": "GraphQL",
                    "endpoint": "https://pjyi5fvkejh5vhcjkeupxyktce.appsync-api.ap-southeast-1.amazonaws.com/graphql",
                    "region": "ap-southeast-1",
                    "authorizationType": "API_KEY",
                    "apiKey": "da2-bgsyiz4qora4zk4tvgw7ev6dk4"
                }
            }
        }
    },
    "storage": {
        "plugins": {
            "awsS3StoragePlugin": {
                "bucket": "flutteramplify32917a364a1942d5b5203a9c772381ec102628-dev",
                "region": "ap-southeast-1",
                "defaultAccessLevel": "guest"
            }
        }
    }
}''';