#!/usr/bin/env zx
import Configstore from "configstore";
import inquirer from "inquirer";
import clear from "clear";
import { readFile } from "node:fs/promises";
import { parse as iniParse } from "ini";
import {
  getNamespace,
  getRegions,
  searchCompartmentIdByName,
} from "./lib/oci.mjs";
import { createSSHKeyPair, createSelfSignedCert } from "./lib/crypto.mjs";

const shell = process.env.SHELL | "/bin/zsh";
$.shell = shell;
$.verbose = false;

clear();
console.log("Set up environment...");

const projectName = "fsdr";

const config = new Configstore(projectName, { projectName });

await selectProfile();
const profile = config.get("profile");
const tenancyId = config.get("tenancyId");

await selectRegion();

await setNamespaceEnv();
const namespace = config.get("namespace");

await setCompartmentEnv();
await createSSHKeys(projectName);
await createCerts();

console.log(`\nConfiguration file saved in: ${chalk.green(config.path)}`);

async function selectProfile() {
  let ociConfigFile = await readFile(`${os.homedir()}/.oci/config`, {
    encoding: "utf-8",
  });

  //  Parse text data to object

  const ociConfig = iniParse(ociConfigFile);

  const profileList = Object.keys(ociConfig);

  await inquirer
    .prompt([
      {
        type: "list",
        name: "profile",
        message: "Select the OCI Config Profile",
        choices: profileList,
      },
    ])
    .then((answers) => {
      config.set("profile", answers.profile);
      config.set("tenancyId", ociConfig[answers.profile].tenancy);
    });
}

async function selectRegion() {
  const listSubscribedRegions = (await getRegions(profile, tenancyId)).sort(
    (r1, r2) => r1.isHomeRegion > r2.isHomeRegion
  );

  await inquirer
    .prompt([
      {
        type: "list",
        name: "region",
        message: "Select the region",
        choices: listSubscribedRegions.map((r) => r.name),
        filter(val) {
          return listSubscribedRegions.find((r) => r.name === val);
        },
      },
    ])
    .then((answers) => {
      config.set("regionName", answers.region.name);
      config.set("regionKey", answers.region.key);
    });
}

async function setNamespaceEnv() {
  const namespace = await getNamespace(profile);
  config.set("namespace", namespace);
}

async function setCompartmentEnv() {
  await inquirer
    .prompt([
      {
        type: "input",
        name: "compartmentName",
        message: "Compartment Name",
        default() {
          return "root";
        },
      },
    ])
    .then(async (answers) => {
      const compartmentName = answers.compartmentName;
      const compartmentId = await searchCompartmentIdByName(
        compartmentName || "root"
      );
      config.set("compartmentName", compartmentName);
      config.set("compartmentId", compartmentId);
    });
}

async function createSSHKeys(name) {
  const sshPathParam = path.join(os.homedir(), ".ssh", name);
  const publicKeyContent = await createSSHKeyPair(sshPathParam);
  config.set("privateKeyPath", sshPathParam);
  config.set("publicKeyContent", publicKeyContent);
  config.set("publicKeyPath", `${sshPathParam}.pub`);
  console.log(`SSH key pair created: ${chalk.green(sshPathParam)}`);
}

async function createCerts() {
  const certPath = path.join(__dirname, "..", ".certs");
  await $`mkdir -p ${certPath}`;
  await createSelfSignedCert(certPath);
  config.set("certFullchain", path.join(certPath, "tls.crt"));
  config.set("certPrivateKey", path.join(certPath, "tls.key"));
}
