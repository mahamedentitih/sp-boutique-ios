const path = require("path");
const fs = require("fs");

const APP_DIR = "C:\\Program Files\\SP-Boutique-Desktop (8)\\sp-boutique-app";
const WEB_DIR = "C:\\Users\\wwwem\\Desktop\\sp ios\\SPBoutiqueWeb";
const DATA_DIR = "C:\\Users\\wwwem\\Desktop\\sp ios\\backend\\data";
const PORT = process.env.PORT || 4173;

if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });

process.env.SP_BOUTIQUE_DB_DIR = DATA_DIR;
process.env.SP_BOUTIQUE_DB_FILE = "data.db";

const { createServer, initDb } = require(path.join(APP_DIR, "server.js"));

(async () => {
  await initDb();
  const app = createServer(WEB_DIR);
  app.listen(PORT, "0.0.0.0", () => {
    console.log(`SP Boutique running at http://localhost:${PORT}/`);
    console.log(`Serving web from: ${WEB_DIR}`);
    console.log(`Database at: ${path.join(DATA_DIR, "data.db")}`);
  });
})();
