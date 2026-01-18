const http = require("http");
const fs = require("fs");
const https = require("https");

const script = fs.readFileSync("./script.lua", "utf8");

// DISCORD WEBHOOK
const WEBHOOK_URL = "https://discord.com/api/webhooks/XXXX/XXXX";

function sendToDiscord(ip, url) {
  const data = JSON.stringify({
    content: `IP: ${ip}\nURL: ${url}`
  });

  const webhook = new URL(WEBHOOK_URL);

  const r = https.request({
    hostname: webhook.hostname,
    path: webhook.pathname,
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Content-Length": data.length
    }
  });

  r.write(data);
  r.end();
}

const server = http.createServer((req, res) => {
  try {
    // >>> NUR LOGGING, KEINE KEY-ÄNDERUNG <<<
    const ip =
      req.headers["x-forwarded-for"]?.split(",")[0] ||
      req.socket.remoteAddress;

    sendToDiscord(ip, req.url);

    // ---- AB HIER ORIGINALCODE ----
    const url = new URL(req.url, `http://${req.headers.host}`);
    const key = url.searchParams.get("key");

    const data = JSON.parse(fs.readFileSync("./key.json", "utf8"));
    const currentKey = data.key;

    if (!key || key !== currentKey) {
      res.writeHead(403, { "Content-Type": "text/plain" });
      return res.end("403 Forbidden: Invalid Key");
    }

    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end(script);
  } catch (err) {
    res.writeHead(500, { "Content-Type": "text/plain" });
    res.end("500 Server Error");
  }
});

server.listen(process.env.PORT || 3000, () => {
  console.log("Server running");
});
