# Updating Mastodon

So a new release of mastodon has been published, this document lists the steps
you need to take to get nfra.club updated.

## 1. Go to the release page

- Go to https://github.com/mastodon/mastodon/releases

- Find the latest release, and read the CHANGELOG and note any additional actions

## 2. Version bump the ebuild

- Go to a local clone of https://github.com/bencord0/portage-overlay

- Bump the version of the ebuild

$ git mv www-apps/mastodon/mastodon-{$OLD_PV,$NEW_PV}.ebuild

If necessary add a revision suffix, e.g. `-r1`. This helps force other installations
to adopt the new changes, recompiling or binpkgs as necessary.

- Update the Manifest

$ ebuild www-apps/mastodon/mastodon-$NEW_PV.ebuild digest

- Push the changes

$ git add www-apps/mastodon
$ git commit -m "www-apps/mastodon: Bump to $NEW_PV"
$ git push

## 3. Build a binpkg

- Update the overlay on aniseed

$ ssh aniseed
(aniseed) $ sudo emaint sync -r bencord0

- Log into the build-container

(aniseed) $ sudo machinectl shell build-mastodon

- Trigger a full build

(build-mastodon) # emerge -1av @profile

## 4. Build a docker image

- Go to [Github Actions](https://github.com/bencord0/portage-overlay/actions/workflows/docker-build.yml)

- Run workflow from `master`.

## 5. Update static assets

(from this repository)

- Install in the exact same version of the package, this ensures that asset
  checksums are correct.
$ sudo emerge -1av --nodeps --getbinpkgonly --binpkg-changed-deps=n www-apps/mastodon

- Login to AWS

$ cat << EOF >> ~/.aws/config
[profile condi.me_eu-west-1_admin]
sso_start_url = https://d-9c67240387.awsapps.com/start
sso_region = eu-west-2
sso_account_id = 055237546114
sso_role_name = AWSAdministratorAccess
region = eu-west-1
EOF

$ export AWS_PROFILE=condime_eu-west-1_admin
$ aws sso login

This will open your browser, and prompt you for login and 2FA.

- Sync assets with S3
$ ./scripts/sync-mastodon-s3-assets.sh

## 6. Deploy the new containers

Wait until step 4 has completed, and a new docker image is available on ghcr.

- Login to terraform

$ . <(pass condi.me/terraform-plans)

You will also need to be logged in to AWS (or can reuse the same shell).

- Tag docker images for ECR

$ ./scripts/docker_retag.sh

- Push the new task definitions to the cluster

$ cd eu-west-1
$ terraform plan
$ terraform apply

## 7. Check the deploy

- [Log in](https://d-9c67240387.awsapps.com/start) to the [ECS Console](eu-west-1.console.aws.amazon.com/ecs/v2/clusters/default/services)
- Watch the Deployment and look for errors in the logs.
- Go to https://nfra.club/about

Check the version has been updated.
