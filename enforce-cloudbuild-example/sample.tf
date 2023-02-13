# Create a root group with some resources to simulate a customer environment.
resource "chainguard_group" "user-group" {
  name        = "example user group"
  description = <<EOF
    This group simulates an end-user group, which cloud build
    can iteract with via the identity in cloudbuild.tf.
  EOF
}

# Create a sample policy that blocks everything from DockerHub.
resource "chainguard_policy" "dockerhub-untrusted" {
  parent_id   = chainguard_group.user-group.id
  document = jsonencode({
    apiVersion = "policy.sigstore.dev/v1beta1"
    kind       = "ClusterImagePolicy"
    metadata = {
      name = "dockerhub-untrusted"
    }
    spec = {
      images = [{
        glob = "index.docker.io/**"
      }]
      authorities = [{
        static = {
          action = "fail"
        }
      }]
    }
  })
}