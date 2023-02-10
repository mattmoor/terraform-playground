# Example: Github Identity Federation

This example shows how an identity can be created via terraform and assumed in
a Github actions workflow to interact with Chainguard resources via terraform.

- `sample.tf`: A sample group with a policy resource to demonstrate we can view things.
- `actions.tf`: An identity that the actions within this repository can assume to interact with the sample group.

