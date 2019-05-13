# Meta repository, manages itself!
resource "github_repository" "meta-terraform-plans" {
  name = "meta-terraform-plans"

  has_issues   = true
  has_wiki     = false

  allow_merge_commit = false
  allow_rebase_merge = true
  allow_squash_merge = true
}

# Main repository, put your cool stuff here.
resource "github_repository" "terraform-plans" {
  name = "terraform-plans"

  has_issues   = true
  has_wiki     = false

  allow_merge_commit = false
  allow_rebase_merge = true
  allow_squash_merge = true
}
