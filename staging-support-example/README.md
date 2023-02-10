# Example of a Chainguard support identity

This example holds a proof of concept for how we can use Chainguard's "assumed"
identities to facilitate customer support by assuming a "support" identity.

- `sample.tf`: A sample group with a policy resource to demonstrate we can view things.
- `support.tf`: An identity that would be assumed by a support engineer with read access to the group.


## In action

Assume the support identity:

```shell
chainctl auth login --identity 4f6198e5200f97ec48ae1afe5d5a16ecf96140f4/815044763ffcec27
```

Check that you are logged in as the support identity:

```shell
# chainctl auth status
  Valid        | True
  Identity     | 4f6198e5200f97ec48ae1afe5d5a16ecf96140f4/815044763ffcec27
  Email        | ...@chainguard.dev
  ...
  Capabilities | example user group: viewer
```


List groups as the support identity:

```shell
# chainctl iam groups ls
[example user group]     This group simulates an end-user group, which folks can
    assume the support identity to inspect.

```

List policies as the support identity:

```shell
# chainctl policy ls
                             ID                             |       NAME       | DESCRIPTION
------------------------------------------------------------+------------------+--------------
  4f6198e5200f97ec48ae1afe5d5a16ecf96140f4/1575c5481f0ee2d0 | yolo-eks-trusted |
```

