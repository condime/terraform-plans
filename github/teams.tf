resource "github_team" "admins" {
  name    = "admins"
  privacy = "closed"
}

resource "github_team_membership" "admins_bencord0" {
  team_id  = "${github_team.admins.id}"
  username = "bencord0"
  role     = "maintainer"
}
