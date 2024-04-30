# OCI Full Stack Disaster Recovery

> This Solution Playbook is a WORK IN PROGRESS

Oracle Cloud Infrastructure (OCI) [Full Stack Disaster Recovery](https://www.oracle.com/cloud/full-stack-disaster-recovery/) orchestrates the transition of compute, database, and applications between OCI regions from around the globe with a single click.

## Introduction and Architecture

Businesses with existing applications using Oracle Database Cloud Services to create a Disaster Recovery plan with OCI Full Stack Disaster Recovery (FSDR).

The example is an Active-Pasive DR.

The application is composed of an **Oracle Exadata Database Dedicated** a **Java REST API** exposed through a **Load Balancer**.

![Architecture](./images/fsdr_architecture.drawio.png)

For details check [NOTES](NOTES.md)

## Deploy solution

Answer all the questions from `setenv.mjs` script:

```bash
zx scripts/setenv.mjs
```

Generate the `terraform.tfvars` file:

```bash
zx scripts/tfvars.mjs
```

Change to the terraform folder:

```bash
cd deploy/tf
```

Terraform init:

```bash
terraform init
```

Terraform Apply:

> Auto approve only for demo porpoise. Otherwise, use Terraform `plan`.

```bash
terraform apply -auto-approve
```

Come back to the root folder

```bash
cd ../..
```

## Run Disaster Recovery

> Work In Progress

## Clean up

Change to the terraform folder:

```bash
cd deploy/tf
```

Terraform destroy:

> Auto approve only for demo porpoise.

```bash
terraform destroy -auto-approve
```

Come back to the root folder

```bash
cd ../..
```

To clean config files and auxiliary files (SSH keys, certificates, etc):

```bash
zx scripts/clean.mjs
```
