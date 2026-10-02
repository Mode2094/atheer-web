const axios = require("axios");
const fs = require("fs");
const path = require("path");

const CONFIG = {
  projectId: process.env.BENCHMARK_PROJECT_ID || "perfum-5b31c",
  location: process.env.BENCHMARK_LOCATION || "us-central1",
  functionName: process.env.BENCHMARK_FUNCTION || "getRecommendationV2",
  storeId: process.env.BENCHMARK_STORE_ID || "",
  gender: process.env.BENCHMARK_GENDER || "male",
  numRequests: Number(process.env.BENCHMARK_REQUESTS || 1000),
  concurrency: Number(process.env.BENCHMARK_CONCURRENCY || 10),
  timeoutMs: Number(process.env.BENCHMARK_TIMEOUT_MS || 10000),
  apiKey:
    process.env.BENCHMARK_API_KEY || "AIzaSyC6Bm7ktcwC6FyRB-D_2xdpm-VfmhlLpsE",
};

const callableUrl = `https://${CONFIG.location}-${CONFIG.projectId}.cloudfunctions.net/${CONFIG.functionName}`;

function percentile(sorted, p) {
  if (!sorted.length) return 0;
  const idx = Math.min(sorted.length - 1, Math.floor(sorted.length * p));
  return sorted[idx];
}

async function getAnonymousToken(apiKey) {
  const url = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${apiKey}`;
  const response = await axios.post(url, { returnSecureToken: true }, { timeout: 10000 });
  if (!response.data || !response.data.idToken || !response.data.localId) {
    throw new Error("Failed to get anonymous idToken");
  }
  return {
    idToken: response.data.idToken,
    uid: response.data.localId,
  };
}

async function upsertUserProfile(idToken, uid) {
  const now = new Date().toISOString();
  const userDocUrl =
    `https://firestore.googleapis.com/v1/projects/${CONFIG.projectId}` +
    `/databases/(default)/documents/users/${uid}`;

  await axios.patch(
    userDocUrl,
    {
      fields: {
        id: { stringValue: uid },
        phone: { stringValue: `benchmark_${uid}` },
        country: { stringValue: "" },
        name: { stringValue: "Benchmark User" },
        gender: { stringValue: "male" },
        personalityProfile: { mapValue: { fields: {} } },
        pastRecommendations: { arrayValue: { values: [] } },
        createdAt: { timestampValue: now },
        lastActive: { timestampValue: now },
      },
    },
    {
      timeout: 10000,
      headers: { Authorization: `Bearer ${idToken}` },
    },
  );
}

function parseBooleanField(field) {
  if (!field) return false;
  if (typeof field.booleanValue === "boolean") return field.booleanValue;
  return false;
}

async function resolveStoreId(idToken) {
  if (CONFIG.storeId) return CONFIG.storeId;

  const storesUrl =
    `https://firestore.googleapis.com/v1/projects/${CONFIG.projectId}` +
    "/databases/(default)/documents/stores?pageSize=100";

  const response = await axios.get(storesUrl, {
    timeout: 10000,
    headers: { Authorization: `Bearer ${idToken}` },
  });

  const docs = response.data?.documents || [];
  for (const doc of docs) {
    const fields = doc.fields || {};
    const active = parseBooleanField(fields.active);
    if (active) {
      const fullName = doc.name || "";
      const parts = fullName.split("/");
      return parts[parts.length - 1];
    }
  }

  throw new Error("No active store found in /stores");
}

async function sendRequest(profile, idToken) {
  const start = Date.now();
  try {
    const response = await axios.post(
      callableUrl,
      {
        data: {
          profile,
          storeId: CONFIG.storeId,
          gender: CONFIG.gender,
        },
      },
      {
        timeout: CONFIG.timeoutMs,
        headers: {
          Authorization: `Bearer ${idToken}`,
          "Content-Type": "application/json",
        },
        validateStatus: () => true,
      },
    );

    const latency = Date.now() - start;
    const payload = response.data || {};
    const result = payload.result || payload.data || payload;
    const success = response.status === 200 && result && result.success === true;

    return {
      success,
      latency,
      status: response.status,
      data: result,
      error: success ? null : JSON.stringify(payload),
    };
  } catch (error) {
    return {
      success: false,
      latency: Date.now() - start,
      status: 0,
      error: error.message,
    };
  }
}

async function runBenchmark() {
  const profilesPath = path.join(__dirname, "profiles.json");
  const testProfiles = JSON.parse(fs.readFileSync(profilesPath, "utf8"));
  if (!Array.isArray(testProfiles) || testProfiles.length === 0) {
    throw new Error("profiles.json is empty");
  }

  console.log("Starting benchmark...");
  console.log(`Function: ${CONFIG.functionName}`);
  console.log(`URL: ${callableUrl}`);
  const auth = await getAnonymousToken(CONFIG.apiKey);
  await upsertUserProfile(auth.idToken, auth.uid);
  CONFIG.storeId = await resolveStoreId(auth.idToken);

  console.log(`Store: ${CONFIG.storeId}`);
  console.log(`Requests: ${CONFIG.numRequests}, Concurrency: ${CONFIG.concurrency}`);

  const results = [];
  const startTime = Date.now();

  for (let i = 0; i < CONFIG.numRequests; i += CONFIG.concurrency) {
    const batch = [];
    const batchSize = Math.min(CONFIG.concurrency, CONFIG.numRequests - i);
    for (let j = 0; j < batchSize; j++) {
      const profile = testProfiles[(i + j) % testProfiles.length];
      batch.push(sendRequest(profile, auth.idToken));
    }

    const batchResults = await Promise.all(batch);
    results.push(...batchResults);
    process.stdout.write(
      `\rProgress: ${Math.min(i + batchSize, CONFIG.numRequests)}/${CONFIG.numRequests}`,
    );
  }

  const totalTimeMs = Date.now() - startTime;
  const successful = results.filter((r) => r.success);
  const failed = results.filter((r) => !r.success);
  const latencies = successful.map((r) => r.latency).sort((a, b) => a - b);

  const p50 = percentile(latencies, 0.5);
  const p95 = percentile(latencies, 0.95);
  const p99 = percentile(latencies, 0.99);
  const throughput = CONFIG.numRequests / (totalTimeMs / 1000);

  const report = {
    timestamp: new Date().toISOString(),
    config: CONFIG,
    results: {
      total: results.length,
      successful: successful.length,
      failed: failed.length,
      successRate: results.length ? (successful.length / results.length) * 100 : 0,
      p50,
      p95,
      p99,
      throughput,
      totalTimeMs,
    },
    sampleErrors: failed.slice(0, 5).map((f) => f.error),
  };

  const outFile = path.join(__dirname, `result_${Date.now()}.json`);
  fs.writeFileSync(outFile, JSON.stringify(report, null, 2));

  console.log("\n\n===== BENCHMARK RESULTS =====");
  console.log(`Successful: ${successful.length}`);
  console.log(`Failed: ${failed.length}`);
  console.log(`Success rate: ${report.results.successRate.toFixed(2)}%`);
  console.log(`Total time: ${(totalTimeMs / 1000).toFixed(2)}s`);
  console.log(`Throughput: ${throughput.toFixed(2)} req/s`);
  console.log(`P50: ${p50}ms`);
  console.log(`P95: ${p95}ms`);
  console.log(`P99: ${p99}ms`);

  if (failed.length) {
    console.log("First errors:");
    report.sampleErrors.forEach((e, i) => console.log(`${i + 1}. ${e}`));
  }
  console.log(`Report file: ${outFile}`);
}

runBenchmark().catch((e) => {
  console.error("Benchmark failed:", e.message);
  process.exit(1);
});
