/**
 * import_churches_part3.js — Zones manquantes en cellules très fines
 */
const https = require('https');
const fs    = require('fs');
const path  = require('path');

const REGIONS = [
  // Paris intra-muros + petite couronne (très petites cellules)
  { name: 'Paris-1',        bb: [48.81, 2.22, 48.91, 2.35] },
  { name: 'Paris-2',        bb: [48.81, 2.35, 48.91, 2.47] },
  { name: 'Paris-3',        bb: [48.91, 2.22, 49.00, 2.35] },
  { name: 'Paris-4',        bb: [48.91, 2.35, 49.00, 2.47] },
  { name: 'IDF-92',         bb: [48.72, 2.10, 48.92, 2.30] },
  { name: 'IDF-93',         bb: [48.88, 2.40, 49.00, 2.60] },
  { name: 'IDF-94',         bb: [48.70, 2.35, 48.85, 2.60] },
  { name: 'IDF-77',         bb: [48.12, 2.50, 48.72, 3.56] },
  { name: 'IDF-78',         bb: [48.50, 1.45, 48.95, 2.10] },
  { name: 'IDF-91',         bb: [48.12, 1.85, 48.50, 2.50] },
  { name: 'IDF-95',         bb: [48.95, 1.85, 49.24, 2.50] },
  // ARA manquants
  { name: 'ARA-Lyon',       bb: [45.50, 4.60, 46.00, 5.20] },
  { name: 'ARA-Grenoble',   bb: [44.90, 5.20, 45.50, 6.00] },
  { name: 'ARA-Nord',       bb: [45.80, 4.00, 46.52, 5.50] },
  { name: 'ARA-Savoie',     bb: [45.30, 5.70, 46.00, 7.18] },
  { name: 'ARA-Haute-Loire',bb: [44.50, 2.80, 45.30, 4.00] },
  // Occitanie manquante
  { name: 'Toulouse',       bb: [43.40, 1.00, 43.80, 1.80] },
  { name: 'Montpellier',    bb: [43.40, 3.40, 43.80, 4.20] },
  { name: 'Occ-Centre',     bb: [43.00, 1.80, 43.80, 3.40] },
  { name: 'Occ-Sud',        bb: [42.33, 0.50, 43.00, 3.00] },
  // Grand-Est
  { name: 'Strasbourg',     bb: [48.20, 7.20, 48.80, 8.24] },
  { name: 'Reims',          bb: [48.70, 3.39, 49.40, 4.80] },
  { name: 'Metz',           bb: [48.80, 5.80, 49.40, 6.80] },
  { name: 'Nancy',          bb: [48.20, 5.80, 48.80, 6.80] },
  { name: 'GE-Ouest',       bb: [47.41, 3.39, 48.20, 5.00] },
  // Normandie manquante
  { name: 'Rouen',          bb: [49.20, 0.80, 49.70, 1.50] },
  { name: 'Caen',           bb: [48.80, -0.60, 49.30, 0.20] },
  { name: 'Normandie-NW',   bb: [49.30, -1.93, 50.10, -0.60] },
  // Bretagne manquante
  { name: 'Rennes',         bb: [47.80, -2.00, 48.30, -1.01] },
  { name: 'Brest',          bb: [48.20, -4.80, 48.70, -3.50] },
  // PDL manquant
  { name: 'Nantes',         bb: [47.00, -2.59, 47.50, -1.34] },
  { name: 'Angers',         bb: [47.30, -1.00, 47.70, -0.40] },
  // Centre
  { name: 'Orleans',        bb: [47.60, 1.50, 48.10, 2.30] },
  { name: 'Tours',          bb: [47.10, 0.50, 47.60, 1.20] },
  { name: 'Centre-SO',      bb: [46.35, 0.05, 47.10, 1.59] },
];

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

// Requête simplifiée (juste denomination=catholic) pour éviter les timeouts
function overpassQuery(bb) {
  const [a, b, c, d] = bb;
  return `[out:json][timeout:45];(node["amenity"="place_of_worship"]["denomination"="catholic"](${a},${b},${c},${d});way["amenity"="place_of_worship"]["denomination"="catholic"](${a},${b},${c},${d}););out center;`;
}

function httpPost(url, body) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const req = https.request({
      hostname: u.hostname, path: u.pathname, method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'User-Agent': 'LumenApp/1.0', 'Content-Length': Buffer.byteLength(body) },
    }, res => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => resolve({ status: res.statusCode, body: data }));
    });
    req.on('error', reject);
    req.setTimeout(60000, () => { req.destroy(); reject(new Error('timeout')); });
    req.write(body); req.end();
  });
}

function elementToChurch(el) {
  const tags = el.tags || {};
  const lat  = el.lat ?? el.center?.lat ?? 0;
  const lon  = el.lon ?? el.center?.lon ?? 0;
  if (!lat || !lon) return null;
  const c = { id: `osm_${el.type}_${el.id}`, nom: tags.name || tags['name:fr'] || 'Église',
    adresse: tags['addr:street'] || '', ville: tags['addr:city'] || tags['addr:town'] || tags['addr:village'] || '',
    codePostal: tags['addr:postcode'] || '', departement:'', region:'', latitude: lat, longitude: lon, diocese:'' };
  if (tags.phone || tags['contact:phone']) c.telephone = tags.phone || tags['contact:phone'];
  if (tags.website || tags['contact:website']) c.siteWeb = tags.website || tags['contact:website'];
  return c;
}

async function main() {
  const outPath = path.join(__dirname, '..', 'assets', 'churches_france.json');
  const existing = JSON.parse(fs.readFileSync(outPath, 'utf8'));
  console.log(`Existant : ${existing.length} églises`);
  const all = new Map(existing.map(c => [c.id, c]));

  for (const region of REGIONS) {
    process.stdout.write(`  ${region.name}... `);
    let ok = false;
    for (let retry = 0; retry < 3 && !ok; retry++) {
      if (retry > 0) { process.stdout.write(`retry${retry}... `); await sleep(12000); }
      try {
        const body = 'data=' + encodeURIComponent(overpassQuery(region.bb));
        const res  = await httpPost('https://overpass-api.de/api/interpreter', body);
        if (res.status === 429) { process.stdout.write(`429 `); await sleep(20000); continue; }
        if (res.status !== 200) { console.log(`HTTP ${res.status}`); ok = true; continue; }
        const data = JSON.parse(res.body);
        let added  = 0;
        for (const el of (data.elements || [])) {
          const c = elementToChurch(el);
          if (!c || all.has(c.id)) continue;
          all.set(c.id, c); added++;
        }
        console.log(`+${added} (total : ${all.size})`);
        ok = true;
      } catch (err) { console.log(`err: ${err.message}`); ok = true; }
    }
    await sleep(5000);
  }

  const churches = Array.from(all.values());
  fs.writeFileSync(outPath, JSON.stringify(churches));
  const sizeKB = Math.round(fs.statSync(outPath).size / 1024);
  console.log(`\nTotal final : ${churches.length} églises — ${sizeKB} KB`);
}

main().catch(console.error);
