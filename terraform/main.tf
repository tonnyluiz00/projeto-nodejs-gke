terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

provider "google" {
  project = "curso-terraform-tonny" # Replace with your project ID
  region  = "us-central1"           # Replace with your desired region
}

resource "google_container_cluster" "my_autopilot_cluster" {
  name     = "cluster-us-central1-nodejs"
  location = "us-central1" # or your desired region
  enable_autopilot = true
}