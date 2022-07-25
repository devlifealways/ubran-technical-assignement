terraform {
  backend "gcs" {
    bucket      = "tf-state-ubran-technical-test"
    prefix      = "terraform/state"
    credentials = "tf-ubran-technical-test-credentials.json"
  }
}
