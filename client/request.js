import http from "k6/http";
import { check, sleep } from "k6";
import { Rate, Trend } from "k6/metrics";
import {
  uuidv4,
  randomIntBetween,
} from "https://jslib.k6.io/k6-utils/1.4.0/index.js";

const higherThan1sRate = new Rate("lower_than_1s");
const localRegion = new Trend("local_region");
const primaryRegion = new Trend("primary_region");
const standbyRegion = new Trend("standby_region");

export function setup() {
  return {};
}

export function teardown() {}

export const options = {
  vus: 2,
  duration: "5s", // 1m20s
  //   stages: [
  //     { duration: "2m", target: 400 }, // ramp up to 400 users
  //     { duration: "3h56m", target: 400 }, // stay at 400 for ~4 hours
  //     { duration: "2m", target: 0 }, // scale down. (optional)
  //   ],
};

const BASE_URL = "http://localhost:8080";

const params = { headers: { "Content-Type": "application/json" } };

export default function () {
  const user = uuidv4();
  const id = randomIntBetween(1, 999);
  const payload = { id: `${user}-${id}`, creationTimestamp: new Date() };
  const res = http.post(
    `${BASE_URL}/api/info`,
    JSON.stringify(payload),
    params
  );
  const body = JSON.parse(res.body);
  check(res, {
    "status 200": (res) => res.status === 200,
    "content OK": (res) => JSON.parse(res.body).status === "ok",
  });

  higherThan1sRate.add(res.timings.duration > 1000);
  localRegion.add(body.region === "local");
  primaryRegion.add(body.region === "primary");
  standbyRegion.add(body.region === "standby");
  sleep(3);
}
