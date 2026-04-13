/**
 * import_churches_part2.js
 * Complète churches_france.json pour les régions manquantes.
 * Usage : node scripts/import_churches_part2.js
 */

const https = require('https');
const fs    = require('fs');
const path  = require('path');

// Régions manquantes, découpées en sous-zones pour éviter les timeouts 504
const REGIONS = [
  // Île-de-France — 4 quadrants
  { name: 'IDF-Nord-Ouest', bb: [48.72, 1.45, 49.24, 2.50] },
  { name: 'IDF-Nord-Est',   bb: [48.72, 2.50, 49.24, 3.56] },
  { name: 'IDF-Sud-Ouest',  bb: [48.12, 1.45, 48.72, 2.50] },
  { name: 'IDF-Sud-Est',    bb: [48.12, 2.50, 48.72, 3.56] },
  // Auvergne-Rhônes-Alpes — 4 quadrants
  { name: 'ARA-Nord-Ouest', bb: [45.30, 2.06, 46.52, 4.50] },
  { name: 'ARA-Nord-Est',   bb: [45.30, 4.50, 46.52, 7.18] },
  { name: 'ARA-Sud-Ouest',  bb: [44.11, 2.06, 45.30, 4.50] },
  { name: 'ARA-Sud-Est',    bb: [44.11, 4.50, 45.30, 7.18] },
  // Occitanie — 3 zones
  { name: 'Occitanie-Ouest',bb: [42.33, -0.03, 44.20, 1.80] },
  { name: 'Occitanie-Centre',bb:[42.33, 1.80,  44.20, 3.40] },
  { name: 'Occitanie-Est',  bb: [42.33, 3.40,  44.20, 4.85] },
  // Grand-Est
  { name: 'Grand-Est-Ouest',bb: [47.41, 3.39,  48.70, 5.80] },
  { name: 'Grand-Est-Est',  bb: [47.41, 5.80,  49.98, 8.24] },
  // Normandie
  { name: 'Normandie-Ouest',bb: [48.44, -1.93, 50.10, 0.00] },
  { name: 'Normandie-Est',  bb: [48.44, 0.00,  50.10, 1.93] },
  // Bretagne
  { name: 'Bretagne-Ouest', bb: [47.27, -5.15, 48.89, -3.08] },
  { name: 'Bretagne-Est',   bb: [47.27, -3.08, 48.89, -1.01] },
  // Pays-de-la-Loire
  { name: 'PDL-Ouest',      bb: [46.27, -2.59, 48.27, -1.34] },
  { name: 'PDL-Est',        bb: [46.27, -1.34, 48.27, -0.09] },
  // Centre-Val-de-Loire
  { name: 'Centre-Ouest',   bb: [46.35, 0.05,  47.40, 1.59] },
  { name: 'Centre-Est',     bb: [46.35, 1.59,  48.36, 3.13] },
  // Corse
  { name: 'Corse',          bb: [41.33, 8.53,  43.03, 9.57] },
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
      hostname: urlObj.hostname, path: urlObj.pathname, method: 'POST',
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
  const church = {
    id:         `osm_${el.type}_${el.id}`,
    nom:        tags.name || tags['name:fr'] || 'Église',
    adresse:    tags['addr:street'] || '',
    ville:      tags['addr:city'] || tags['addr:town'] || tags['addr:village'] || '',
    codePostal: tags['addr:postcode'] || '',
    departement:'', region:'', latitude: lat, longitude: lon, diocese:'',
  };
  if (tags.phone || tags['contact:phone'])
    church.telephone = tags.phone || tags['contact:phone'];
  if (tags.website || tags['contact:website'])
    church.siteWeb = tags.website || tags['contact:website'];
  return church;
}

async function main() {
  const outPath = path.join(__dirname, '..', 'assets', 'churches_france.json');

  // Charger les données existantes
  let existing = [];
  if (fs.existsSync(outPath)) {
    existing = JSON.parse(fs.readFileSync(outPath, 'utf8'));
    console.log(`Données existantes : ${existing.length} églises`);
  }
  const all = new Map(existing.map(c => [c.id, c]));

  for (const region of REGIONS) {
    process.stdout.write(`  ${region.name}... `);
    let retries = 2;
    while (retries >= 0) {
      try {
        const body = 'data=' + encodeURIComponent(overpassQuery(region.bb));
        const res  = await httpPost('https://overpass-api.de/api/interpreter', body);
        if (res.status === 429) {
          console.log(`429 rate-limit, attente 15s...`);
          await sleep(15000);
          retries--;
          continue;
        }
        if (res.status !== 200) {
          console.log(`HTTP ${res.status} — ignorée`);
          break;
        }
        const data = JSON.parse(res.body);
        let added  = 0;
        for (const el of (data.elements || [])) {
          const c = elementToChurch(el);
          if (!c || all.has(c.id)) continue;
          all.set(c.id, c);
          added++;
        }
        console.log(`+${added} (total : ${all.size})`);
        break;
      } catch (err) {
        console.log(`erreur : ${err.message}`);
        break;
      }
    }
    await sleep(6000); // 6s entre chaque requête
  }

  const churches = Array.from(all.values());
  fs.writeFileSync(outPath, JSON.stringify(churches));
  const sizeKB = Math.round(fs.statSync(outPath).size / 1024);
  console.log(`\nFichier mis à jour : ${churches.length} églises — ${sizeKB} KB`);
}

main().catch(console.error);
