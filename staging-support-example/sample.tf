# Create a root group with some resources to simulate a customer environment.
resource "chainguard_group" "user-group" {
  name        = "example user group"
  description = <<EOF
    This group simulates an end-user group, which folks can
    assume the support identity to inspect.
  EOF
}

# Create a sample policy that trusts everything on EKS.
# This policy is nonsense, but something cheap we can create
# to test our viewer capabilities.
resource "chainguard_policy" "eks-trusted" {
  parent_id   = chainguard_group.user-group.id
  document = jsonencode({
    apiVersion = "policy.sigstore.dev/v1beta1"
    kind       = "ClusterImagePolicy"
    metadata = {
      name = "yolo-eks-trusted"
    }
    spec = {
      images = [{
        glob = "*.dkr.ecr.*.amazonaws.com/**"
      }]
      authorities = [{
        static = {
          action = "pass"
        }
      }]
    }
  })
}