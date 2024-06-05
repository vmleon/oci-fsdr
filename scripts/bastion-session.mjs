#!/usr/bin/env zx
import Configstore from "configstore";
import inquirer from "inquirer";
import clear from "clear";
import {
  createManagedSSHSessionCommand,
  getBastionSessionCommand,
  listBastionSessions,
} from "./lib/oci/bastion.mjs";
import { getOutputValues } from "./lib/terraform.mjs";

$.verbose = false;

clear();
console.log("Create Bastion Session...");

const projectName = "fsdr";

const config = new Configstore(projectName, { projectName });

const regionName = config.get("regionName");
const regionPeerName = config.get("regionPeerName");
const profile = config.get("profile");
const publicKeyPath = config.get("publicKeyPath");
const privateKeyPath = config.get("privateKeyPath");

const {
  instance_app_ids,
  instance_app_stdby_ids,
  bastion_id: bastionId,
  bastion_standby_id: bastionStandbyId,
} = await getOutputValues(path.join("deploy", "tf"));

let bastionRegion;
await selectBastion();

const computes = isPrimaryRegion(bastionRegion)
  ? instance_app_ids
  : instance_app_stdby_ids;
let computeName;
let computeId;
await selectCompute(bastionRegion);

const sessionList = await listBastionSessions(
  { regionName: bastionRegion, profile },
  isPrimaryRegion(bastionRegion) ? bastionId : bastionStandbyId
);

if (sessionList.length) {
  // get session command
  const command = await getBastionSessionCommand(
    { regionName: bastionRegion, profile },
    sessionList[0].id // FIXME pick the session for the compute
  );
  const fullCommand = command.replaceAll("<privateKey>", privateKeyPath);
  console.log(chalk.yellow(fullCommand));
} else {
  const command = await createManagedSSHSessionCommand(
    {
      regionName: bastionRegion,
      profile,
    },
    isPrimaryRegion(bastionRegion) ? bastionId : bastionStandbyId,
    computeName,
    computeId,
    publicKeyPath,
    "opc"
  );
  const fullCommand = command.replaceAll("<privateKey>", privateKeyPath);
  console.log(chalk.yellow(fullCommand));
}

// functions

async function selectBastion() {
  await inquirer
    .prompt([
      {
        type: "list",
        name: "bastionRegion",
        message: "Select the OCI Bastion Region",
        choices: [regionName, regionPeerName],
      },
    ])
    .then((answers) => {
      bastionRegion = answers.bastionRegion;
    });
}

async function selectCompute(bastionRegion) {
  await inquirer
    .prompt([
      {
        type: "list",
        name: "computeName",
        message: "Select the compute",
        choices: Object.keys(computes),
      },
    ])
    .then((answers) => {
      computeId = computes[answers.computeName];
      computeName = answers.computeName;
    });
}

function isPrimaryRegion(name) {
  return name == regionName;
}
