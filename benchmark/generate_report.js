const fs = require("fs");
const path = require("path");

const files = fs
  .readdirSync(__dirname)
  .filter((f) => f.startsWith("result_") && f.endsWith(".json"))
  .sort();

if (!files.length) {
  console.log("No benchmark result files found.");
  process.exit(0);
}

const latest = files[files.length - 1];
const report = JSON.parse(fs.readFileSync(path.join(__dirname, latest), "utf8"));

console.log(`Latest benchmark report: ${latest}`);
console.log(JSON.stringify(report.results, null, 2));
