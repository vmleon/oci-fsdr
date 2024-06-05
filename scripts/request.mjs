#!/usr/bin/env zx
import { v4 as uuidv4 } from "uuid";
import { exitWithError } from "./lib/utils.mjs";

const shell = process.env.SHELL | "/bin/zsh";
$.shell = shell;
$.verbose = false;

const { h = "localhost", _ } = argv;

const id = uuidv4();
const creationTimestamp = Date.now();
const data = JSON.stringify({ id, creationTimestamp });
const headers = {
  "Content-Type": "application/json",
};

let serviceURL;
if (h === "localhost") {
  serviceURL = `http://localhost:8080/api/info`;
} else {
  serviceURL = `https://${h}/api/info`;
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = 0;
}

try {
  const response = await fetch(`${serviceURL}`, {
    method: "POST",
    headers,
    body: data,
  });
  const responseData = await response.json();
  console.log(JSON.stringify(responseData, null, 2));
} catch (error) {
  exitWithError(error.message);
}
