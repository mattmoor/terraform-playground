# Create a root group with some resources to simulate a customer environment.
resource "chainguard_group" "user-group" {
  name        = "example user group"
  description = <<EOF
    This group simulates an end-user group, which the gitlab
    CI identity can iteract with via the identity in
    gitlab.tf.
  EOF
}

# Create a sample policy that blocks everything on Quay.
resource "chainguard_policy" "gke-trusted" {
  parent_id   = chainguard_group.user-group.id
  document = jsonencode({
    apiVersion = "policy.sigstore.dev/v1beta1"
    kind       = "ClusterImagePolicy"
    metadata = {
      name = "quay-untrusted"
    }
    spec = {
      images = [{
        glob = "quay.io/**"
      }]
      authorities = [{
        static = {
          action = "fail"
        }
      }]
    }
  })
}