# Meta repository, manages itself!
resource "github_repository" "meta-terraform-plans" {
  name = "meta-terraform-plans"

  has_issues   = true
  has_projects = false
  has_wiki     = false

  allow_merge_commit = false
  allow_rebase_merge = false
  allow_squash_merge = false
}

# Main repository, put your cool stuff here.
resource "github_repository" "terraform-plans" {
  name = "terraform-plans"

  has_issues   = true
  has_projects = false
  has_wiki     = false

  allow_merge_commit = false
  allow_rebase_merge = false
  allow_squash_merge = false
}
