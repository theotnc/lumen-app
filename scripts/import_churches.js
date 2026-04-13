/**
 * import_churches.js
 * Génère assets/churches_france.json depuis Overpass OSM.
 * Requête par région pour éviter les timeouts.
 * Usage : node scripts/import_churches.js
 */

const https = require('https');
const fs    = require('fs');
const path  = require('path');

// Régions métropolitaines françaises (bounding boxes [minLat, minLon, maxLat, maxLon])
const REGIONS = [
  { name: 'Ile-de-France',         bb: [48.12, 1.45, 49.24, 3.56] },
  { name: 'Auvergne-Rhones-Alpes', bb: [44.11, 2.06, 46.52, 7.18] },
  { name: 'Nouvelle-Aquitaine',    bb: [42.77, -1.79, 46.36, 1.45] },
  { name: 'Occitanie',             bb: [42.33, -0.03, 45.05, 4.85] },
  { name: 'Hauts-de-France',       bb: [49.97, 1.60, 51.09, 4.27] },
  { name: 'Grand-Est',             bb: [47.41, 3.39, 49.98, 8.24] },
  { name: 'Normandie',             bb: [48.44, -1.93, 50.10, 1.93] },
  { name: 'Bretagne',              bb: [47.27, -5.15, 48.89, -1.01] },
  { name: 'Pays-de-la-Loire',      bb: [46.27, -2.59, 48.27, -0.09] },
  { name: 'Centre-Val-de-Loire',   bb: [46.35, 0.05, 48.36, 3.13] },
  { name: 'Bourgogne-Franche-Comté',bb:[46.18, 2.85, 48.41, 7.10] },
  { name: 'Provence-Alpes-Cote',   bb: [43.16, 4.23, 45.12, 7.72] },
  { name: 'Corse',                 bb: [41.33, 8.53, 43.03, 9.57] },
];

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

function overpassQuery(bb) {
  const [minLat, minLon, maxLat, maxLon] = bb;
  return `[out:json][timeout:60];(node["amenity"="place_of_worship"]["denomination"="catholic"](${minLat},${minLon},${maxLat},${maxLon});way["amenity"="place_of_worship"]["denomination"="catholic"](${minLat},${minLon},${maxLat},${maxLon});node["amenity"="place_of_worship"]["religion"="christian"]["denomination"!~"protestant|reformed|lutheran|baptist|methodist|evangelical|orthodox|anglican"](${minLat},${minLon},${maxLat},${maxLon}););out center;`;
}

function httpPost(url, body) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const options = {
      hostname: urlObj.hostname,
      path: urlObj.pathname,
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent': 'LumenApp/1.0 (contact@lumen-app.fr)',
        'Content-Length': Buffer.byteLength(body),
      },
    };
    const req = https.request(options, res => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve({ status: res.statusCode, body: data }));
    });
    req.on('error', reject);
    req.setTimeout(75000, () => { req.destroy(); reject(new Error('timeout')); });
    req.write(body);
    req.end();
  });
}

function elementToChurch(el) {
  const tags = el.tags || {};
  const lat  = el.lat ?? el.center?.lat ?? 0;
  const lon  = el.lon ?? el.center?.lon ?? 0;
  if (!lat || !lon) return null;
  return {
    id:          `osm_${el.type}_${el.id}`,
    nom:         tags.name || tags['name:fr'] || 'Église',
    adresse:     tags['addr:street'] || '',
    ville:       tags['addr:city'] || tags['addr:town'] || tags['addr:village'] || '',
    codePostal:  tags['addr:postcode'] || '',
    departement: '',
    region:      '',
    latitude:    lat,
    longitude:   lon,
    telephone:   tags.phone || tags['contact:phone'] || null,
    siteWeb:     tags.website || tags['contact:website'] || null,
    diocese:     '',
  };
}

async function main() {
  const all   = new Map(); // id → church (déduplique)
  let   total = 0;

  for (const region of REGIONS) {
    process.stdout.write(`  ${region.name}... `);
    try {
      const body = 'data=' + encodeURIComponent(overpassQuery(region.bb));
      const res  = await httpPost('https://overpass-api.de/api/interpreter', body);
      if (res.status !== 200) {
        console.log(`HTTP ${res.status} — ignorée`);
        await sleep(3000);
        continue;
      }
      const data     = JSON.parse(res.body);
      const elements = data.elements || [];
      let   added    = 0;
      for (const el of elements) {
        const c = elementToChurch(el);
        if (!c || all.has(c.id)) continue;
        all.set(c.id, c);
        added++;
      }
      total += added;
      console.log(`${added} églises (total : ${total})`);
    } catch (err) {
      console.log(`erreur : ${err.message}`);
    }
    await sleep(2000); // respecter le rate-limit Overpass
  }

  const churches = Array.from(all.values());
  const outPath  = path.join(__dirname, '..', 'assets', 'churches_france.json');
  fs.writeFileSync(outPath, JSON.stringify(churches, null, 0));
  const sizeKB = Math.round(fs.statSync(outPath).size / 1024);
  console.log(`\nFichier généré : assets/churches_france.json`);
  console.log(`${churches.length} églises — ${sizeKB} KB`);
}

main().catch(console.error);
