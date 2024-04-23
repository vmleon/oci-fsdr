# OCI Full Stack Disaster Recovery

## Deploy solution

Answer all the questions from `setenv.mjs` script:

```
zx scripts/setenv.mjs
```

Generate the `terraform.tfvars` file:

```
zx scripts/tfvars.mjs
```

## Clean up

To clean config files and auxiliary files (SSH keys, certificates, etc):

```
zx scripts/clean.mjs
```
