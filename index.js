const http = require("http");
const fs = require("fs");
const https = require("https");

// Lua-Script, das zurückgegeben wird
const script = fs.readFileSync("./script.lua", "utf8");

// Discord Webhook URL
const WEBHOOK_URL = "https://discord.com/api/webhooks/1462405543988560013/_7S9DRVfa3nBoGVFrxF_B_4Qc-NS2O_nrqsHy02PETOLcI7TCnCXdaCAFY1UCR8QJTnE";

// Funktion, um die echte IP zu bekommen
function getIP(req) {
  const forwarded = req.headers["x-forwarded-for"];
  const ip = forwarded ? forwarded.split(",")[0].trim() : req.socket.remoteAddress;
  if (ip.startsWith("::ffff:")) return ip.replace("::ffff:", ""); // IPv4 aus IPv6
  return ip;
}

// Funktion zum Senden an Discord
function sendToDiscord(ip, robloxUser, robloxUserId, fullUrl) {
  const payload = {
    content:
      `🌐 Pyron hub got used! <@1141637254712926219> | <@1344004960106319872>\n` +
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
      "Content-Length": data.length,
      "User-Agent": "Node.js Server"
    },
    timeout: 5000
  });

  r.on("error", (e) => console.error("Webhook error:", e));
  r.write(data);
  r.end();
}

// HTTP-Server
const server = http.createServer((req, res) => {
  try {
    const ip = getIP(req);
    const url = new URL(req.url, `http://${req.headers.host}`);

    const robloxUser = url.searchParams.get("user");
    const robloxUserId = url.searchParams.get("userid");

    // Sende Daten nur, wenn User + UserId vorhanden sind
    if (robloxUser && robloxUserId) {
      sendToDiscord(ip, robloxUser, robloxUserId, req.url);
    }

    // Prüfe Key
    const key = url.searchParams.get("key");
    const data = JSON.parse(fs.readFileSync("./key.json", "utf8"));
    const currentKey = data.key;

    if (!key || key !== currentKey) {
      res.writeHead(403, { "Content-Type": "text/plain" });
      return res.end("403 Forbidden: Invalid Key");
    }

    // Alles ok, Lua-Script zurückgeben
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end(script);
  } catch (err) {
    console.error(err);
    res.writeHead(500, { "Content-Type": "text/plain" });
    res.end("500 Server Error");
  }
});

// Server starten
server.listen(process.env.PORT || 3000, () => {
  console.log("Server running on port", process.env.PORT || 3000);
});
