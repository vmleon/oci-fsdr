# OCI Full Stack Disaster Recovery

> This Solution is a WORK IN PROGRESS

Oracle Cloud Infrastructure (OCI) [Full Stack Disaster Recovery](https://www.oracle.com/cloud/full-stack-disaster-recovery/) orchestrates the transition of compute, database, and storage between OCI regions from around the globe with a single click.

Visit the official Full Stack Disaster Recovery [Documentation](https://docs.oracle.com/en-us/iaas/disaster-recovery/index.html).

Full Stack Disaster Recovery (FSDR) overcome two main challenges:

- **Increasing complexity**: there is a constant increase in complexity for infrastructure, database management and application that makes Disaster Recovery difficult.
- **Manual scripts and jobs are problematic**: current manual processes are offer error-prone, unreliable, time-consuming and required specialized skill sets. More problematic if everything has to happen in the middle of a disaster.

Full Stack Disaster Recovery fits into the [Oracle Cloud Maximum Availability Architecture](https://www.oracle.com/a/tech/docs/cloud-maa-overview.pdf) based on application criticality classified in Bronze, Silver, Gold and Platinum. Find more information in [Oracle MAA Reference Architectures](https://docs.oracle.com/en/database/oracle/oracle-database/19/haiad/).

For Oracle SaaS applications check [MAA Best Practices - Oracle Applications](https://www.oracle.com/database/technologies/high-availability/oracle-applications-maa.html).

## Introduction and Architecture

Businesses with existing applications using Oracle Database Cloud Services and compute can create a Disaster Recovery plan with OCI Full Stack Disaster Recovery (FSDR).

The example is an Active-Pasive DR.

The application is composed of an **Oracle Exadata Database Dedicated** or **Autonomous Database Shared/Dedicated** and a **Java REST API** exposed through a **Load Balancer**.

![Architecture](./images/fsdr_architecture.drawio.png)

For more details check [NOTES](NOTES.md)

## TODO list

- ADB-S
- FSDR infra
- Data Guard
- Change Architecture to include ADB-S, ADB-D, or ExaDB-D, etc.
- Simulate Disaster
- Rsync
- Include constant synthetic workload
- Add Object Storage in the DR sync
- Support ADB-D
- Support ExaDB-D
- Logging Analytics
- Include OCI Notification and OCI Events to get notified by email on switchover/failover
- Vault integration
- Include OCI Vault secret for Oracle Database

## Build Application

```bash
cd src/backend
```

```bash
./gradlew clean bootJar
```

```bash
cd ../..
```

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

## Test both deployments

Execute a request in both regions (both Load Balancers IP addresses from the Terraform output)

```bash
zx scripts/request.mjs -h LOAD_BALANCER_IP_ADDRESS
```

> **Running into problems?** SSH into the machines.
>
> Run the creation of OCI Bastion Session to connect with a Managed SSH connection
>
> ```bash
> zx scripts/bastion-session.mjs
> ```
>
> Pick the region and the compute instance and copy/paste the SSH command.

```sql
SELECT
    REQ.REQUEST_DATE  "Creation Date",
    RES.REGION        "Region",
    RES.STATUS        "Status",
    RES.ERROR_MESSAGE "Error"
FROM
         RESPONSES RES
    INNER JOIN REQUESTS REQ ON RES.REQUEST_ID = REQ.ID
ORDER BY
    REQ.REQUEST_DATE DESC;
```

## Run Disaster Recovery

This project uses K6 to test the deployment.

To Install K6 follow this link [Get Started > Installation](https://k6.io/docs/get-started/installation/).

```bash
k6 run client/request.js
```

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

Clean the Java application:

```bash
cd src/backend
```

```bash
./gradlew clean
```

```bash
cd ../..
```
