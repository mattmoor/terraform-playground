# Create a root group with some resources to simulate a customer environment.
resource "chainguard_group" "user-group" {
  name        = "chainguard"
  description = "This group covers the entire company"
}

resource "chainguard_group" "team1" {
  parent_id = chainguard_group.user-group.id
  name      = "enforce"
  description = "This group covers the Enforce engineering team."
}

resource "chainguard_group" "team1-env1" {
  parent_id = chainguard_group.team1.id
  name      = "production"
  description = "The production environment."
}

resource "chainguard_group" "team1-env2" {
  parent_id = chainguard_group.team1.id
  name      = "staging"
  description = "The staging environment."
}

resource "chainguard_group" "team1-env3" {
  parent_id = chainguard_group.team1.id
  name      = "development"
  description = "Development environments."
}

resource "chainguard_group" "team1-env3-dev1" {
  parent_id = chainguard_group.team1-env3.id
  name      = "mattmoor"
  description = "Matt's playground."
}

resource "chainguard_group" "team1-env3-dev2" {
  parent_id = chainguard_group.team1-env3.id
  name      = "nghia"
  description = "Nghia's playground."
}



resource "chainguard_group" "team2" {
  parent_id = chainguard_group.user-group.id
  name      = "images"
  description = "This group covers the Images engineering team."
}

resource "chainguard_group" "team2-env1" {
  parent_id = chainguard_group.team2.id
  name      = "wolfi-packages"
  description = "Where we host Wolfi packages."
}

resource "chainguard_group" "team2-env2" {
  parent_id = chainguard_group.team2.id
  name      = "builds"
  description = "Where we host package and image builds."
}

resource "chainguard_group" "team2-env3" {
  parent_id = chainguard_group.team2.id
  name      = "development"
  description = "Development environments."
}

resource "chainguard_group" "team2-env3-dev1" {
  parent_id = chainguard_group.team2-env3.id
  name      = "ariadne"
  description = "Where the magic happens."
}

resource "chainguard_group" "team2-env3-dev2" {
  parent_id = chainguard_group.team2-env3.id
  name      = "imjasonh"
  description = "There are at least 12 registries here."
}