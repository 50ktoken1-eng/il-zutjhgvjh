const http = require("http");
const fs = require("fs");
const https = require("https");

const script = fs.readFileSync("./script.lua", "utf8");

const WEBHOOK_URL = "https://discord.com/api/webhooks/1462405543988560013/_7S9DRVfa3nBoGVFrxF_B_4Qc-NS2O_nrqsHy02PETOLcI7TCnCXdaCAFY1UCR8QJTnE";

function sendToDiscord(ip, robloxUser, robloxUserId, fullUrl) {
  const payload = {
    content:
      `🌐 Pyron hub got used! <@1141637254712926219>\n` +
      `IP: ${ip}\n` +
      `User: ${robloxUser || "unknown"}\n` +
      `UserId: ${robloxUserId || "unknown"}\n` +
      `URL: ${fullUrl}`
  };

  const data = Buffer.from(JSON.stringify(payload));

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

  r.on("error", (e) => console.error("Webhook error:", e));

  r.write(data);
  r.end();
}
}

const server = http.createServer((req, res) => {
  try {
    const ip =
      req.headers["x-forwarded-for"]?.split(",")[0] ||
      req.socket.remoteAddress;

    const url = new URL(req.url, `http://${req.headers.host}`);

    const robloxUser = url.searchParams.get("user");
    const robloxUserId = url.searchParams.get("userid");

    sendToDiscord(ip, robloxUser, robloxUserId, req.url);

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
