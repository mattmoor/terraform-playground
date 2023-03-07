# Example: Using Actions with Chainguard's Registry

This example shows how an identity can be created via terraform and assumed in
a Github actions workflow to interact with Chainguard resources via terraform.

- `actions.tf`: A root group to host our images, and an identity that the
  actions within this repository can assume to push images there.

For more information on Github OIDC see [the docs](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)!

## Seeing the identity in action(s)

To install `chainctl`, assume the identity, and configure our credential helper,
just add the following lines to the actions workflow you have authorized:
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

After `setup-chainctl` has run, you can push and pull images rooted under the
group we created, e.g.
```yaml
- uses: sigstore/cosign-installer@main
- run: |
    export GROUP=... # The output of group-id
    cosign copy -f \
      cgr.dev/chainguard/static:latest-glibc \
      registry.enforce.dev/${GROUP}/static
```

You can see a full working example of this [here](https://github.com/mattmoor/terraform-playground/blob/main/.github/workflows/push-stuff.yaml).


## Customizing for your own workflow

You can edit this to authorize your own github workflows by changing the
following line in `actions.tf`:

```hcl
    subject = "repo:mattmoor/terraform-playground:ref:refs/heads/main"
```

If all you need to do is pull images, you can change this to use the
built-in "registry.pull" role:
```hcl
data "chainguard_roles" "pusher" {
  name = "registy.push"
}
```
