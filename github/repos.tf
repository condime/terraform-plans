resource "github_repository" "terraform-plans" {
  name = "terraform-plans"

  has_issues   = true 
  has_projects = false
  has_wiki     = false

  allow_merge_commit = false
  allow_squash_merge = true
  allow_rebase_merge = true
}

resource "github_branch_protection" "terraform-plans" {
  repository = "${github_repository.terraform-plans.name}"
  branch     = "master"

  enforce_admins = true

  required_status_checks {
    strict = true
  }
}
