# Create the root group to host our images.
resource "chainguard_group" "private-repository" {
  name        = "mattmoor private images"
  description = "This group holds private images."
}

# Emit the group to make private
output "private-group" {
  value = chainguard_group.private-repository.id
}
