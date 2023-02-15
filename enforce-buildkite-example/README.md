# Example: Buildkite Identity Federation

This example shows how an identity can be created via terraform and assumed in
a Buildkite pipeline to interact with Chainguard resources via terraform.

- `sample.tf`: A sample group with a policy resource to demonstrate we can view things.
- `buildkite.tf`: An identity that Buildkite can assume to interact with the sample group.

For more information on Buildkite OIDC see [the docs](https://buildkite.com/docs/agent/v3/cli-oidc)!


## Letting your Chainguard build fly

To install `chainctl` and assume the identity, just add the following step to
the authorized buildkite workflow:

```yaml
- command: |
    wget -O chainctl "https://dl.enforce.dev/chainctl/latest/chainctl_linux_$(uname -m)"
    chmod +x chainctl
    mv chainctl /usr/bin

    # Assume
    chainctl auth login \
      --identity-token $(buildkite-agent oidc request-token --audience issuer.enforce.dev) \
      --identity ... # the output of buildkite-identity
```

After this has run, you are free to invoke `chainctl` as the assumed identity:
```yaml
# Explore what we can see!
- command: chainctl policy ls
```


## Customizing for your own workflow

You can edit this to authorize your own buildkite pipeline by changing the
following lines in `actions.tf`:

```hcl
    subject_pattern = "organization:matts-fun-house:pipeline:enforce-buildkite-example:ref:refs/heads/main:commit:[0-9a-f]+:step:"
```

If you would like to give this identity different permissions, simply change
the role data source to the role you would like to grant:
```hcl
data "chainguard_roles" "viewer" {
  name = "viewer"
}
```
