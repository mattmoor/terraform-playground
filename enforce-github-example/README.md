# Example: Github Identity Federation

This example shows how an identity can be created via terraform and assumed in
a Github actions workflow to interact with Chainguard resources via terraform.

- `sample.tf`: A sample group with a policy resource to demonstrate we can view things.
- `actions.tf`: An identity that the actions within this repository can assume to interact with the sample group.

For more information on Github OIDC see [the docs](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)!

## Seeing the identity in action(s)

To install `chainctl` and assume the identity, just add the following lines to
the actions workflow you have authorized:
```yaml
- uses: chainguard-dev/actions/setup-chainctl@main
  with:
    identity: ... # The output of actions-identity
```

To authorize actions, your workflow will need the ability to produce OIDC tokens
which is granted via:
```yaml
# https://docs.github.com/en/actions/reference/authentication-in-a-workflow
permissions:
  id-token: write
```

After `setup-chainctl` has run, you are free to invoke `chainctl` as the
assumed identity:
```yaml
# Explore what we can see!
- run: chainctl iam groups ls
```

You can see a full working example of this [here](https://github.com/mattmoor/terraform-playground/blob/main/.github/workflows/assume-and-list-stuff.yaml).


## Customizing for your own workflow

You can edit this to authorize your own github workflows by changing the
following line in `actions.tf`:

```hcl
    subject = "repo:mattmoor/terraform-playground:ref:refs/heads/main"
```

If you would like to give this identity different permissions, simply change
the role data source to the role you would like to grant:
```hcl
data "chainguard_roles" "viewer" {
  name = "viewer"
}
```
