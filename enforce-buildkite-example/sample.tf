# Create a root group with some resources to simulate a customer environment.
resource "chainguard_group" "user-group" {
  name        = "example user group"
  description = <<EOF
    This group simulates an end-user group, which the buildkite
    pipeline identity can iteract with via the identity in
    buildkite.tf.
  EOF
}

# Create a sample policy that trusts everything on CGR.
# This policy is nonsense, but something cheap we can create
# to test our viewer capabilities.
resource "chainguard_policy" "cgr-trusted" {
  parent_id   = chainguard_group.user-group.id
  document = jsonencode({
    apiVersion = "policy.sigstore.dev/v1beta1"
    kind       = "ClusterImagePolicy"
    metadata = {
      name = "yolo-cgr-trusted"
    }
    spec = {
      images = [{
        glob = "cgr.dev/**"
      }]
      authorities = [{
        static = {
          action = "pass"
        }
      }]
    }
  })
}
