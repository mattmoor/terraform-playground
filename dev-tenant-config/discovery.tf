
data "chainguard_cluster_discovery" "gotta-catch-em-all" {
  id = local.group_id
  providers = [
    "APP_RUNNER",
    "ECS",
    "CLOUD_RUN",
    "EKS",
    "GKE",
  ]
  profiles = ["enforcer"]
}

# resource "chainguard_cluster" "discovery" {
#   for_each = { for result in data.chainguard_cluster_discovery.gotta-catch-em-all.results : result.name => result }

#   parent_id = local.group_id
#   name = "${lower(each.value.provider)} ${each.key}"

#   profiles = ["enforcer"]
#   affinity = each.value.location
#   managed {
#     provider = lower(each.value.provider)
#     info {
#       server = each.value.state.0.server
#       certificate_authority_data = each.value.state.0.certificate_authority_data
#     }
#   }
# }
