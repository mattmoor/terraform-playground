# Example: Federating a Google Service Account

This example shows how to create a Chainguard identity that can be assumed by a
Google service account.

- `sample.tf`: A sample that creates a non-trivial group hierarchy.
- `service.tf`: This creates a Google Service Account and then creates a Chainguard identity that can be assumed by that Google Service Account.  Then we create a Cloud Run service based on the `chainctl` image which when it receives an HTTP request invokes `chainctl auth login --identity {the id}` to assume the identity using the Google service account and then runs `chainctl iam group ls` to return the group hierarchy to the user.


## In action

You can see this running [here](https://staging-google-example-j2wqachcbq-uw.a.run.app/)
