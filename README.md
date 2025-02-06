# Explore Terraform remote state on s3 bucket

Use an s3 bucket on LocalStack to store Terraform's state remotely

## Create the s3 bucket using awscli

First things first. The bucket must be available for Terraform to use it to store state remotely. The bucket is named `remote-state` and referenced in `terraform.tf`.

```bash
$ aws --profile localstack s3api create-bucket --bucket remote-state
{
    "Location": "/remote-state"
}
```

Verify creation by listing buckets

```bash
$ aws --profile localstack s3api list-buckets
{
    "Buckets": [
        {
            "Name": "remote-state",
            "CreationDate": "2025-02-06T14:52:45.000Z"
        }
    ],
    "Owner": {
        "DisplayName": "webfile",
        "ID": "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a"
    },
    "Prefix": null
}
```

## init, plan and apply the Terraform configuration

### $ terraform init

 * The local provider is initialized.
 * The `.terraform` directory and the lock file `.terraform.lock.hcl` are created.
 * The "s3" backend is configured
    * Terraform uses the s3 bucket on LocalStack to store the state file

### $ terraform plan

Terraform shows what it will do

### $ terraform apply

Note the state file `terraform.tfstate` is not created locally!

Verify the state file is created in the `remote-state` s3 bucket by listing the objects in the bucket

```bash
$ aws --profile localstack s3api list-objects --bucket remote-state
{
    "Contents": [
        {
            "Key": "terraform.tfstate",
            "LastModified": "2025-02-06T14:54:33.000Z",
            "ETag": "\"726aee4a9829b007fd95ecc3bb64f2ad\"",
            "ChecksumAlgorithm": [
                "SHA256"
            ],
            "ChecksumType": "FULL_OBJECT",
            "Size": 1659,
            "StorageClass": "STANDARD",
            "Owner": {
                "DisplayName": "webfile",
                "ID": "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a"
            }
        }
    ],
    "RequestCharged": null,
    "Prefix": ""
}
```

To get the content of the state file locally in a file `the-remote-state`

```bash
$ aws --profile localstack s3api get-object --bucket remote-state --key terraform.tfstate  the-remote-state
{
    "AcceptRanges": "bytes",
    "LastModified": "Thu, 06 Feb 2025 14:54:33 GMT",
    "ContentLength": 1659,
    "ETag": "\"726aee4a9829b007fd95ecc3bb64f2ad\"",
    "ChecksumSHA256": "rxzMl3lgaRkM8lrUnmZgodEiqyLeJyIQvS4W67QABQs=",
    "ChecksumType": "FULL_OBJECT",
    "ContentType": "application/json",
    "ServerSideEncryption": "AES256",
    "Metadata": {}
}
```

Check the file `the-remote-state`

```bash
$ cat the-remote-state |jq
{
  "version": 4,
  "terraform_version": "1.10.5",
  "serial": 1,
  "lineage": "97dbb9ab-724b-29ea-30c1-477eed336e8a",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "local_file",
      "name": "local-file",
      "provider": "provider[\"registry.terraform.io/hashicorp/local\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "content": "This Terraform configuration uses an s3 bucket to store remote state on LocalStack",
            "content_base64": null,
            "content_base64sha256": "m77u845yqxXBL28XCxlIjfg5k3bPRzjNyYrR6axV2Jw=",
            "content_base64sha512": "gDUKquLdSRZlvFTigVfPdkpx+3VHt6RZBsfwiN6BORuFN0YvagFMOC4Rqp0G0+GpFRb1aLqtklO8xfKq/pu4mA==",
            "content_md5": "7f7c263bbcb3eb38ce41cd8d41ecbb6e",
            "content_sha1": "76ca4f3a71454d59d89fc4375cef599176fbf4ac",
            "content_sha256": "9bbeeef38e72ab15c12f6f170b19488df8399376cf4738cdc98ad1e9ac55d89c",
            "content_sha512": "80350aaae2dd491665bc54e28157cf764a71fb7547b7a45906c7f088de81391b8537462f6a014c382e11aa9d06d3e1a91516f568baad9253bcc5f2aafe9bb898",
            "directory_permission": "0777",
            "file_permission": "0777",
            "filename": "local-file",
            "id": "76ca4f3a71454d59d89fc4375cef599176fbf4ac",
            "sensitive_content": null,
            "source": null
          },
          "sensitive_attributes": [
            [
              {
                "type": "get_attr",
                "value": "sensitive_content"
              }
            ]
          ]
        }
      ]
    }
  ],
  "check_results": null
}
```

Check the state with Terraform cli

```bash
$ terraform show
# local_file.local-file:
resource "local_file" "local-file" {
    content              = "This Terraform configuration uses an s3 bucket to store remote state on LocalStack"
    content_base64sha256 = "m77u845yqxXBL28XCxlIjfg5k3bPRzjNyYrR6axV2Jw="
    content_base64sha512 = "gDUKquLdSRZlvFTigVfPdkpx+3VHt6RZBsfwiN6BORuFN0YvagFMOC4Rqp0G0+GpFRb1aLqtklO8xfKq/pu4mA=="
    content_md5          = "7f7c263bbcb3eb38ce41cd8d41ecbb6e"
    content_sha1         = "76ca4f3a71454d59d89fc4375cef599176fbf4ac"
    content_sha256       = "9bbeeef38e72ab15c12f6f170b19488df8399376cf4738cdc98ad1e9ac55d89c"
    content_sha512       = "80350aaae2dd491665bc54e28157cf764a71fb7547b7a45906c7f088de81391b8537462f6a014c382e11aa9d06d3e1a91516f568baad9253bcc5f2aafe9bb898"
    directory_permission = "0777"
    file_permission      = "0777"
    filename             = "local-file"
    id                   = "76ca4f3a71454d59d89fc4375cef599176fbf4ac"
}
```

The output should be in line with the content of file `the-remote-state`

## References

* [S3](https://docs.localstack.cloud/user-guide/aws/s3/)
