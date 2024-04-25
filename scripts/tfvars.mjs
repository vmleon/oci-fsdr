#!/usr/bin/env zx
import Mustache from "mustache";
import Configstore from "configstore";
import clear from "clear";

const shell = process.env.SHELL | "/bin/zsh";
$.shell = shell;
$.verbose = false;

clear();
console.log("Create terraform.tfvars...");

const projectName = "fsdr";

const config = new Configstore(projectName, { projectName });

await generateTFVars();

async function generateTFVars() {
  const tenancyId = config.get("tenancyId");
  const regionName = config.get("regionName");
  const regionPeerName = config.get("regionPeerName");
  const compartmentId = config.get("compartmentId");
  const compartmentName = config.get("compartmentName");
  const publicKeyContent = config.get("publicKeyContent");
  const sshPrivateKeyPath = config.get("privateKeyPath");
  const certFullchain = config.get("certFullchain");
  const certPrivateKey = config.get("certPrivateKey");

  // const backend = config.get("backend");
  // const backendArtifactUrl = backend.fullPath;
  // const ansibleBackend = config.get("ansibleBackend");
  // const ansibleBackendArtifactUrl = ansibleBackend.fullPath;

  const tfVarsPath = "deploy/tf/terraform.tfvars";

  const tfvarsTemplate = await fs.readFile(`${tfVarsPath}.mustache`, "utf-8");

  const output = Mustache.render(tfvarsTemplate, {
    tenancy_id: tenancyId,
    region_name: regionName,
    region_peer: regionPeerName,
    compartment_id: compartmentId,
    ssh_public_key: publicKeyContent,
    ssh_private_key_path: sshPrivateKeyPath,
    cert_fullchain: certFullchain,
    cert_private_key: certPrivateKey,
    project_name: projectName,
    // backend_artifact_url: backendArtifactUrl,
    // ansible_backend_artifact_url: ansibleBackendArtifactUrl,
  });

  console.log(
    `Terraform will deploy resources in ${chalk.green(
      regionName
    )} in compartment ${
      compartmentName ? chalk.green(compartmentName) : chalk.green("root")
    }`
  );

  await fs.writeFile(tfVarsPath, output);

  console.log(`File ${chalk.green(tfVarsPath)} created`);

  console.log(`1. ${chalk.yellow("cd deploy/tf/")}`);
  console.log(`2. ${chalk.yellow("terraform init")}`);
  console.log(`3. ${chalk.yellow("terraform apply -auto-approve")}`);
}
