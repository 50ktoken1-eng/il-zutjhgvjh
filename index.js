const http = require("http");
const fs = require("fs");

const script = fs.readFileSync("./script.lua", "utf8");

const server = http.createServer((req, res) => {
  try {
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
