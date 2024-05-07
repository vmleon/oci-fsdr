#!/usr/bin/env zx
import Configstore from "configstore";
import clear from "clear";

const shell = process.env.SHELL | "/bin/zsh";
$.shell = shell;
$.verbose = false;

clear();
console.log("Clean up config files, certs, ssh keys...");

const projectName = "fsdr";

const config = new Configstore(projectName, { projectName });

const profile = config.get("profile");
const tenancyId = config.get("tenancyId");
const compartmentId = config.get("compartmentId");
const namespace = config.get("namespace");
const regionKey = config.get("regionKey");
const regionName = config.get("regionName");

await $`rm -rf ./.artifacts`;
console.log(`${chalk.green("Artifacts")} deleted`);
await $`rm -rf ./.certs`;
console.log(`${chalk.green("Certs")} deleted`);

const sshPathParam = path.join(os.homedir(), ".ssh", projectName);
await $`rm -f ${sshPathParam}*`;
console.log(`${chalk.green("SSH keys")} deleted`);

const generatedTf = path.join("deploy", "tf", "generated");
await $`rm -rf ${generatedTf}/*`;
console.log(`${chalk.green(generatedTf)} folder deleted`);

config.clear();
console.log(`${chalk.green("Config file")} deleted`);
