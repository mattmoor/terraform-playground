# Example: Bitbucket Identity Federation

This example shows how an identity can be created via terraform and assumed in
a Bitbucket pipeline to interact with Chainguard resources via terraform.

- `sample.tf`: A sample group with a policy resource to demonstrate we can view things.
- `bitbucket.tf`: An identity that Bitbucket can assume to interact with the sample group.

For more information on Bitbucket OIDC see [the docs](https://support.atlassian.com/bitbucket-cloud/docs/integrate-pipelines-with-resource-servers-using-oidc/)!

## Letting your Chainguard build fly

To install `chainctl` and assume the identity, just add the following step to
the authorized bitbucket workflow:

```yaml
pipelines:
  default:
    - step:
        oidc: true
        max-time: 5
        script:
          - wget -O chainctl "https://dl.enforce.dev/chainctl/latest/chainctl_linux_$(uname -m)"
          - chmod +x chainctl
          - mv chainctl /usr/bin

          # Assume the bitbucket identity
          - chainctl auth login --identity-token $BITBUCKET_STEP_OIDC_TOKEN --identity ... # the output of bitbucket-identity
```

After this has run, you are free to invoke `chainctl` as the assumed identity. Keep adding lines to the `script:` after the `- chainctl auth login . . .` line like this:

```yaml
- chainctl policy ls
```


## Customizing for your own workflow

You can edit this to authorize your own bitbucket pipeline by changing the
following lines in `bitbucket.tf`:

```hcl
    issuer          = "https://api.bitbucket.org/2.0/workspaces/assumable-identities/pipelines-config/identity/oidc"
    subject_pattern = "{1d397906-81bf-459e-9a8d-eae79c0bc5f3}:.*"
    audience        = "ari:cloud:bitbucket::workspace/37f7aa0f-722b-4737-a1ba-74f42f300734"
```

If you would like to give this identity different permissions, simply change
the role data source to the role you would like to grant:
```hcl
data "chainguard_roles" "viewer" {
  name = "viewer"
}
```
