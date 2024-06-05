# Full Stack Disaster Recovery Notes

## IAM policies

Create a user.

Create a group `FullStackDRGroup` and add user to the group.

Policies:

```
Allow group FullStackDRGroup to manage buckets in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to manage objects in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to manage databases in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to manage autonomous-databases in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to manage instance-family in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to manage instance-agent-command-family in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to manage volume-family in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to read virtual-network-family in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to use subnets in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to use vnics in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to use network-security-groups in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to use private-ips in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to read fn-app in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to read fn-function in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to use fn-invocation in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup use tag-namespaces in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup read vaults in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup read secret-family in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to manage load-balancers in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to manage network-load-balancers in compartment COMPARTMENT_NAME
Allow group FullStackDRGroup to manage file-family in compartment COMPARTMENT_NAME
```

## Demo

Create two DR Protection Groups for the primary and standby.
`FRA` as primary, `LHR` as standby.

- Name: `app-primary` and `app-standby`
- Object Storage for storing the logs
- Role: not configured
- No adding members

On `app-primary` DR Protection Group, click Associate. Select the role `primary`.

On `app-standby` DR Protection Group, click Associate. Select the role `standby`.

---

Add members on `app-primary` DR PRotection Group. Select Resource type (Compute, Autonomous Database, Database, Volume group).

Select `database` for base DB. On Database Type, select `Oracle Base Database`. Then, select the Database System. Select the password secret.

Adding the compute member. Since we are doing a active-passive architecture. add the VMs as non-moving instances members, on both primary and standby DR Protection Group.

## Switchover Plan

Create the plan in the standby DR Protection Group.

- Name: `app-switchover-primary-standby`
- Plan Type: `Switchover (planned)` (other option is `Failover (unplanned)`)

In the UI, when the plan is finally created, there will be two groups.

- Built-In Prechecks
- Switchover Databases (Standby)

Add another Plan Group named `Stop Backend application` to stop the primary application.

Add step to stop backend:

- Name: `stop-backend-primary`.
- Enable step
- Error mode: `Stop on error`
- Timeout in seconds: `3600`
- Region: `FRA` (primary)
- `Run local script` (versus other options like `Run object storage script`, and `Invoke function`)
- Instance: `backend-primary`
- Script parameters: `/path/to/script/backend_shutdown.sh`
- Run as user: `opc`

> In case of more backend services, there would be more steps to add.

---

Add another Plan Group named `Disable Rsync Cronjobs at primary`.

---

Add steps to stop cronjob.

- Name: `disable-rsync-backend-primary`
- Enable step
- Error mode: `Stop on error`
- Timeout in seconds: `3600`
- Region: `FRA` (primary)
- `Run local script` (versus other options like `Run object storage script`, and `Invoke function`)
- Instance: `backend-primary`
- Script parameters: `/path/to/script/fsdr_rsync_psft.sh disable IP_ADDRESS`
- Run as user: `opc`

> In case of more backend applications/services, there would be more steps to add.

---

Add another Plan Group named `Start Backend at Standby`.

---

Add steps to start App in Standby.

- Name: `start-backend-standby`
- Enable step
- Error mode: `Stop on error`
- Timeout in seconds: `3600`
- Region: `LHR`
- `Run local script` (versus other options like `Run object storage script`, and `Invoke function`)
- Instance: `backend-standby`
- Script parameters: `/path/to/script/backend_boot.sh`
- Run as user: `opc`

> In case of more backend applications/services, there would be more steps to add.

---

Add another Plan Group named `Enable Rsync at Standby`.

---

Add steps to enable rsync in Standby.

- Name: `enable-rsync-backend-standby`
- Enable step
- Error mode: `Stop on error`
- Timeout in seconds: `3600`
- Region: `LHR`
- `Run local script` (versus other options like `Run object storage script`, and `Invoke function`)
- Instance: `backend-standby`
- Script parameters: `/path/to/script/fsdr_rsync_psft.sh enable IP_ADDRESS`
- Run as user: `opc`

> In case of more backend applications/services, there would be more steps to add.

---

Reorder groups.

- Built-in Prechecks
- Stop App Primary
- Disable Rsync App Primary
- Switchover Database (to standby)
- Start App Standby
- Enable Rsync at Standby

---

Run prechecks on the Plan.

- Name: `prechecks-switchover-primary-standby`

---

Execute DR Plan

- Select the DR Plan
- Enable prechecks
- Name: `Execute DR Plan`

---

Review Plan execution groups
Check the execution

## Failover Plan

On the Standby DR Protection Group.

Create a Plan.

- Name: `app-failover-standby-to-primary`
- Plan type: `Failover (unplanned)`

---

Add group `start-app-primary`

---

Add Step Group

- Name: `start-backend-primary`
- Enable step
- Error mode: `Stop on error`
- Timeout in seconds: `3600`
- Region: `LHR`
- `Run local script` (versus other options like `Run object storage script`, and `Invoke function`)
- Instance: `backend-primary`
- Script parameters: `/path/to/script/backend_boot.sh`
- Run as user: `opc`

---

Reorder groups, if needed.

- Built-in Prechecks
- Failover Database (to primary)
- Start App Primary
- Enable Rsync App Primary
- Stop App Standby **???**
- Disable Rsync at Standby **???**
