# only if you have an organization
resource "google_organization_policy" "skip_default_policy" {
  count      = var.gcp_enable_policies
  org_id     = var.gcp_organization_id
  constraint = "compute.skipDefaultNetworkCreation"
  boolean_policy {
    enforced = true
  }
}
