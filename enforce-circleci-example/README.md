# Example: CircleCI Identity Federation

This example shows how an identity can be created via terraform and assumed in
a CircleCI job to interact with Chainguard resources via terraform.

- `sample.tf`: A sample group with a policy resource to demonstrate we can view things.
- `circleci.tf`: An identity that the job within this repository can assume to interact with the sample group.

For more information on Github OIDC see [the docs](https://circleci.com/docs/openid-connect-tokens/)!

## Assuming the identity in CircleCI

To install `chainctl` and assume the identity, just add the following lines to
the actions workflow you have authorized:
```yaml
cd $(mktemp -d)
wget -O chainctl "https://dl.enforce.dev/chainctl/latest/chainctl_linux_$(uname -m)"
chmod +x chainctl
sudo mv chainctl /usr/local/bin

chainctl auth login --identity 2c8bceb43e0d5542edabccda0a5e77667a4d6cb6/959075557dc5698f --identity-token $CIRCLE_OIDC_TOKEN
```

After the above has run, you are free to invoke `chainctl` as the assumed
identity:
```yaml
chainctl policy ls
```

You can see a full working example of this [here](https://github.com/mattmoor/terraform-playground/blob/main/.circleci/config.yml).


## Customizing for your own workflow

You can edit this to authorize your own github workflows by changing the
following lines in `circleci.tf`:

```hcl
    # Replace ORG_ID, PROJECT_ID, and USER_ID with your values!
    issuer   = "https://oidc.circleci.com/org/ORG_ID"
    subject  = "org/ORG_ID/project/PROJECT_ID/user/USER_ID"
    audience = "ORG_ID"
```

If you would like to give this identity different permissions, simply change
the role data source to the role you would like to grant:
```hcl
data "chainguard_roles" "viewer" {
  name = "viewer"
}
```
