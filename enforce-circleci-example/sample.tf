# Create a root group with some resources to simulate a customer environment.
resource "chainguard_group" "user-group" {
  name        = "example user group"
  description = <<EOF
    This group simulates an end-user group, which the CircleCI
    job's identity can iteract with via the identity in
    circleci.tf.
  EOF
}

# Create a sample policy that trusts everything on Quay.
# This policy is nonsense, but something cheap we can create
# to test our viewer capabilities.
resource "chainguard_policy" "quay-trusted" {
  parent_id   = chainguard_group.user-group.id
  document = jsonencode({
    apiVersion = "policy.sigstore.dev/v1beta1"
    kind       = "ClusterImagePolicy"
    metadata = {
      name = "yolo-quay-trusted"
    }
    spec = {
      images = [{
        glob = "quay.io/**"
      }]
      authorities = [{
        static = {
          action = "pass"
        }
      }]
    }
  })
}