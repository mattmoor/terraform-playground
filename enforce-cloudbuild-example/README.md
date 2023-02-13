# Example: Google Cloud Build Identity Federation

This example shows how an identity can be created via terraform and assumed in
a Google Cloud Build to interact with Chainguard resources via terraform.

- `sample.tf`: A sample group with a policy resource to demonstrate we can view things.
- `cloudbuild.tf`: An identity that Google Cloud Build can assume to interact with the sample group.

## Running a Cloud Build

To assume this role within Google Cloud Build, you can use a step like this:
```yaml
# Assume the identity using the appropriate google service account.
- name: us.gcr.io/prod-enforce-fabc/chainctl:v0.1.71
  env:
  # This is the google service account we create in cloudbuild.tf for GCB
  # to act as.
  - GOOGLE_SERVICE_ACCOUNT_NAME=enforce-cloudbuild-example@${PROJECT_ID}.iam.gserviceaccount.com
  # This assumes the Chainguard identity created in cloudbuild.tf using the
  # Google Service Account identity above.
  args: ["auth", "login", "--identity", "${_IDENTITY}"]
```

After logging in, we can use the same container to explore the resources created
in `sample.tf`:

```yaml
# Do stuff now that we are authenticated!
- name: us.gcr.io/prod-enforce-fabc/chainctl:v0.1.71
  args: ["policy", "ls"]
```

There is a full working example of this in [`cloudbuild.yaml`](./cloudbuild.yaml)

You can use `gcloud` (in this directory) to invoke this example directly via:

```shell
gcloud builds submit --no-source \
   --substitutions=_IDENTITY=... # The "cloudbuild-identity" output
```

## Customizing for your own workflow

To change the Google Service Account used to have a more appropriate name for
your workflow, change the following line in `cloudbuild.tf`:

```hcl
  account_id = "enforce-cloudbuild-example"
```

... and change this line in your Google Cloud Build to match:

```yaml
  - GOOGLE_SERVICE_ACCOUNT_NAME=enforce-cloudbuild-example@${PROJECT_ID}.iam.gserviceaccount.com
```

If you would like to give the Chainguard identity different permissions, simply
change the role data source to the role you would like to grant:
```hcl
data "chainguard_roles" "viewer" {
  name = "viewer"
}
```
