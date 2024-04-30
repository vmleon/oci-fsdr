# Full Stack Disaster Recovery Notes

Create two DR Protection Groups for the primary and standby.
`FRA` as primary, `LHR` as standby.

- Name: `app-fra` and `app-lhr`
- Object Storage for storing the logs
- Role: not configured
- No adding members

On `app-fra` DR Protection Group, click Associate. Select the role `primary`.

On `app-lhr` DR Protection Group, click Associate. Select the role `standby`.

---

Add members on `app-fra` DR PRotection Group. Select Resource type (Compute, Autonomous Database, Database, Volume group).

Select `database` for base DB. On Database Type, select `Oracle Base Database`. Then, select the Database System. Select the password secret.

Adding the compute member. Since we are doing a active-passive architecture. add the VMs as non-moving instances members, on both primary and standby DR Protection Group.

---

Create the plan in the standby DR Protection Group.

- Name: `app-switchover-fra-lhr`
- Plan Type: `Switchover (planned)` (other option is `Failover (unplanned)`)

In the UI, when the plan is finally created, there will be two groups.

- Built-In Prechecks
- Switchover Databases (Standby)

Add another Plan Group to stop the FRA application. Add steps to stop app, and stop Database.

- Name: `Stop Backend application`
- Enable step
- Error mode: `Stop on error`
- Timeout in seconds: `3600`
- Region: `FRA`
- `Run local script` (versus other options like `Run object storage script`, and `Invoke function`)
- Instance: `app-primary`
- Script parameters: `/path/to/script/app_shutdown.sh`
- Run as user: `psadm2`
