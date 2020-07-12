#!/usr/bin/env bash

terraform destroy
rm -rvf .terraform terraform.tfstate* ~/.ssh/known_hosts out/*
terraform init
terraform apply
