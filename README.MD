# Urban technical test

During this pleasent adventure I had to run these instructions to get going
and deploy everything:

## GCP setup

```shell
# create service account credentials
$ gcloud iam service-accounts keys create tf-ubran-technical-test-credentials.json --iam-account=urban-technical-test@digital-display-357013.iam.gserviceaccount.co

# create a object storage container
$ gsutil mb -p digital-display-357013 -c regional -l europe-west9 gs://tf-state-ubran-technical-test/

# enable versionning for backup purposes
$ gsutil versioning set on gs://tf-state-ubran-technical-test/

# give enough rights to the SA
$ gsutil iam ch serviceAccount:urban-technical-test@digital-display-357013.iam.gserviceaccount.com:legacyBucketWriter gs://tf-state-ubran-technical-test/
```

## Docker

Perhaps it's a good idea to squash docker image before using it into production, I know for a fact
that using distroless base images could help us gain more space (small optimization)

```shell
# download docker-squash
$ wget -qO- https://github.com/jwilder/docker-squash/releases/download
 /v0.2.0/docker-squash-linux-amd64-v0.2.0.tar.gz | \
  tar -zxvf -  && mv docker-squash /usr/local/bin
$ docker save secret_build:latest | \
   docker-squash -t secret_build_squashed | \
   docker load
```

## Enhacement

Things to make better:

- create an organization policy and enable skip default network creation
- more firewall/NACLs rules with a fine grain control
- more restrictive roles can be used with GCS (least priviliged)
- better cost effective strategies
- usage of podSecurityPolicy to restrict communcation between pods
- add grafana dashboard to evaluate /metrics that we set
- better logging
- add Terraform's integration test using [terraform-exec](https://github.com/hashicorp/terraform-exec) (programmatically execute commands)
