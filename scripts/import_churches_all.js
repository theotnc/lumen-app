/**
 * import_churches_all.js
 * Import complet des églises catholiques françaises depuis OpenStreetMap (Overpass API).
 *
 * Consolide import_churches.js, import_churches_part2.js et import_churches_part3.js
 * en un seul script robuste, avec mode incrémental et retry automatique.
 *
 * Usage :
 *   node scripts/import_churches_all.js              # mode incrémental (fusionne avec l'existant)
 *   node scripts/import_churches_all.js --fresh      # repart de zéro
 *   node scripts/import_churches_all.js --simplified # requête simplifiée (moins de timeouts)
 */

'use strict';

const https = require('https');
const fs    = require('fs');
const path  = require('path');

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const OUT_PATH      = path.join(__dirname, '..', 'assets', 'churches_france.json');
const OVERPASS_URL  = 'https://overpass-api.de/api/interpreter';
const DELAY_MS      = 6000;   // délai entre chaque zone (respecter le rate-limit)
const RETRY_DELAY   = 15000;  // délai sur erreur 429
const MAX_RETRIES   = 3;
const HTTP_TIMEOUT  = 70000;  // ms

const args       = process.argv.slice(2);
const FRESH_MODE = args.includes('--fresh');
const SIMPLIFIED = args.includes('--simplified');

// ---------------------------------------------------------------------------
// Zones géographiques [minLat, minLon, maxLat, maxLon]
//
// Stratégie : zones larges pour les régions peu denses, zones fines pour
// les grandes métropoles (Île-de-France, Lyon, Toulouse…) qui causent des
// timeouts 504 avec de larges bounding boxes.
// ---------------------------------------------------------------------------

const ZONES = [
  // ── Régions bien couvertes par une seule requête ─────────────────────────
  { name: 'Hauts-de-France',       bb: [49.97,  1.60, 51.09,  4.27] },
  { name: 'Nouvelle-Aquitaine',    bb: [42.77, -1.79, 46.36,  1.45] },
  { name: 'Bourgogne-Franche-Comté',bb:[46.18,  2.85, 48.41,  7.10] },
  { name: 'Provence-Alpes-Côte',   bb: [43.16,  4.23, 45.12,  7.72] },
  { name: 'Corse',                 bb: [41.33,  8.53, 43.03,  9.57] },

  // ── Île-de-France — cellules fines (Paris + départements) ────────────────
  { name: 'Paris-NW',              bb: [48.81,  2.22, 48.91,  2.35] },
  { name: 'Paris-NE',              bb: [48.81,  2.35, 48.91,  2.47] },
  { name: 'Paris-SW',              bb: [48.91,  2.22, 49.00,  2.35] },
  { name: 'Paris-SE',              bb: [48.91,  2.35, 49.00,  2.47] },
  { name: 'IDF-92 (Hauts-de-Seine)',bb:[48.72,  2.10, 48.92,  2.30] },
  { name: 'IDF-93 (Seine-Saint-Denis)',bb:[48.88,2.40, 49.00,  2.60] },
  { name: 'IDF-94 (Val-de-Marne)', bb: [48.70,  2.35, 48.85,  2.60] },
  { name: 'IDF-77 (Seine-et-Marne)',bb:[48.12,  2.50, 48.72,  3.56] },
  { name: 'IDF-78 (Yvelines)',     bb: [48.50,  1.45, 48.95,  2.10] },
  { name: 'IDF-91 (Essonne)',      bb: [48.12,  1.85, 48.50,  2.50] },
  { name: 'IDF-95 (Val-d\'Oise)', bb: [48.95,  1.85, 49.24,  2.50] },

  // ── Auvergne-Rhône-Alpes — villes principales ────────────────────────────
  { name: 'ARA-Lyon',              bb: [45.50,  4.60, 46.00,  5.20] },
  { name: 'ARA-Grenoble',          bb: [44.90,  5.20, 45.50,  6.00] },
  { name: 'ARA-Nord',              bb: [45.80,  4.00, 46.52,  5.50] },
  { name: 'ARA-Savoie',            bb: [45.30,  5.70, 46.00,  7.18] },
  { name: 'ARA-Haute-Loire',       bb: [44.50,  2.80, 45.30,  4.00] },
  { name: 'ARA-Sud-Ouest',         bb: [44.11,  2.06, 45.30,  4.50] },
  { name: 'ARA-Sud-Est',           bb: [44.11,  4.50, 45.30,  5.70] },

  // ── Occitanie ─────────────────────────────────────────────────────────────
  { name: 'Toulouse',              bb: [43.40,  1.00, 43.80,  1.80] },
  { name: 'Montpellier',           bb: [43.40,  3.40, 43.80,  4.20] },
  { name: 'Occitanie-Centre',      bb: [43.00,  1.80, 43.80,  3.40] },
  { name: 'Occitanie-Sud',         bb: [42.33,  0.50, 43.00,  3.00] },
  { name: 'Occitanie-Est',         bb: [42.33,  3.40, 44.20,  4.85] },
  { name: 'Occitanie-Nord',        bb: [44.20, -0.03, 45.05,  4.85] },

  // ── Grand-Est ─────────────────────────────────────────────────────────────
  { name: 'Strasbourg',            bb: [48.20,  7.20, 48.80,  8.24] },
  { name: 'Metz',                  bb: [48.80,  5.80, 49.40,  6.80] },
  { name: 'Nancy',                 bb: [48.20,  5.80, 48.80,  6.80] },
  { name: 'Reims',                 bb: [48.70,  3.39, 49.40,  4.80] },
  { name: 'Grand-Est-Ouest',       bb: [47.41,  3.39, 48.20,  5.00] },
  { name: 'Grand-Est-Sud',         bb: [47.41,  5.00, 48.20,  7.20] },

  // ── Normandie ─────────────────────────────────────────────────────────────
  { name: 'Rouen',                 bb: [49.20,  0.80, 49.70,  1.50] },
  { name: 'Caen',                  bb: [48.80, -0.60, 49.30,  0.20] },
  { name: 'Normandie-NO',          bb: [49.30, -1.93, 50.10, -0.60] },
  { name: 'Normandie-SO',          bb: [48.44, -1.93, 49.20,  0.00] },
  { name: 'Normandie-Est',         bb: [48.44,  0.80, 50.10,  1.93] },

  // ── Bretagne ──────────────────────────────────────────────────────────────
  { name: 'Brest',                 bb: [48.20, -4.80, 48.70, -3.50] },
  { name: 'Rennes',                bb: [47.80, -2.00, 48.30, -1.01] },
  { name: 'Bretagne-Ouest',        bb: [47.27, -5.15, 48.20, -4.80] },
  { name: 'Bretagne-Centre',       bb: [47.27, -4.80, 48.20, -2.00] },

  // ── Pays-de-la-Loire ──────────────────────────────────────────────────────
  { name: 'Nantes',                bb: [47.00, -2.59, 47.50, -1.34] },
  { name: 'Angers',                bb: [47.30, -1.00, 47.70, -0.40] },
  { name: 'PDL-Nord',              bb: [47.50, -2.59, 48.27, -0.09] },
  { name: 'PDL-Sud',               bb: [46.27, -2.59, 47.00, -0.40] },

  // ── Centre-Val-de-Loire ───────────────────────────────────────────────────
  { name: 'Orléans',               bb: [47.60,  1.50, 48.10,  2.30] },
  { name: 'Tours',                 bb: [47.10,  0.50, 47.60,  1.20] },
  { name: 'Centre-SO',             bb: [46.35,  0.05, 47.10,  1.59] },
  { name: 'Centre-Est',            bb: [46.35,  1.59, 48.36,  3.13] },
];

// ---------------------------------------------------------------------------
// Requête Overpass
// ---------------------------------------------------------------------------

function buildQuery(bb) {
  const [a, b, c, d] = bb;
  if (SIMPLIFIED) {
    // Requête courte → moins de timeouts, peut manquer quelques églises non taguées
    return `[out:json][timeout:45];(node["amenity"="place_of_worship"]["denomination"="catholic"](${a},${b},${c},${d});way["amenity"="place_of_worship"]["denomination"="catholic"](${a},${b},${c},${d}););out center;`;
  }
  // Requête complète : denomination=catholic + chrétiens hors protestants/orthodoxes
  return `[out:json][timeout:60];(node["amenity"="place_of_worship"]["denomination"="catholic"](${a},${b},${c},${d});way["amenity"="place_of_worship"]["denomination"="catholic"](${a},${b},${c},${d});node["amenity"="place_of_worship"]["religion"="christian"]["denomination"!~"protestant|reformed|lutheran|baptist|methodist|evangelical|orthodox|anglican"](${a},${b},${c},${d}););out center;`;
}

// ---------------------------------------------------------------------------
// HTTP
// ---------------------------------------------------------------------------

function httpPost(url, body) {
  return new Promise((resolve, reject) => {
    const u   = new URL(url);
    const req = https.request({
      hostname: u.hostname,
      path:     u.pathname,
      method:   'POST',
      headers: {
        'Content-Type':   'application/x-www-form-urlencoded',
        'User-Agent':     'LumenApp/1.0 (contact@lumen-app.fr)',
        'Content-Length': Buffer.byteLength(body),
      },
    }, res => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end',  ()    => resolve({ status: res.statusCode, body: data }));
    });
    req.on('error', reject);
    req.setTimeout(HTTP_TIMEOUT, () => { req.destroy(); reject(new Error('timeout HTTP')); });
    req.write(body);
    req.end();
  });
}

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

// ---------------------------------------------------------------------------
// Conversion OSM → église
// ---------------------------------------------------------------------------

function elementToChurch(el) {
  const tags = el.tags || {};
  const lat  = el.lat ?? el.center?.lat ?? 0;
  const lon  = el.lon ?? el.center?.lon ?? 0;
  if (!lat || !lon) return null;

  const church = {
    id:          `osm_${el.type}_${el.id}`,
    nom:         tags.name || tags['name:fr'] || 'Église',
    adresse:     tags['addr:street']   || '',
    ville:       tags['addr:city'] || tags['addr:town'] || tags['addr:village'] || '',
    codePostal:  tags['addr:postcode'] || '',
    departement: '',
    region:      '',
    latitude:    lat,
    longitude:   lon,
    diocese:     '',
  };
  if (tags.phone           || tags['contact:phone'])   church.telephone = tags.phone || tags['contact:phone'];
  if (tags.website         || tags['contact:website']) church.siteWeb   = tags.website || tags['contact:website'];
  return church;
}

// ---------------------------------------------------------------------------
// Import d'une zone avec retry
// ---------------------------------------------------------------------------

async function importZone(zone, all) {
  process.stdout.write(`  ${zone.name.padEnd(28)} `);
  const body = 'data=' + encodeURIComponent(buildQuery(zone.bb));

  for (let attempt = 0; attempt < MAX_RETRIES; attempt++) {
    if (attempt > 0) {
      process.stdout.write(`[retry ${attempt}] `);
      await sleep(RETRY_DELAY);
    }
    try {
      const res = await httpPost(OVERPASS_URL, body);

      if (res.status === 429) {
        process.stdout.write(`[429 rate-limit, attente ${RETRY_DELAY / 1000}s] `);
        await sleep(RETRY_DELAY);
        continue;
      }
      if (res.status !== 200) {
        console.log(`HTTP ${res.status} — zone ignorée`);
        return;
      }

      const elements = JSON.parse(res.body).elements || [];
      let added = 0;
      for (const el of elements) {
        const c = elementToChurch(el);
        if (!c || all.has(c.id)) continue;
        all.set(c.id, c);
        added++;
      }
      console.log(`+${added} (total : ${all.size})`);
      return; // succès

    } catch (err) {
      console.log(`erreur : ${err.message}`);
      if (attempt === MAX_RETRIES - 1) console.log(`  → zone abandonnée après ${MAX_RETRIES} tentatives`);
    }
  }
}

// ---------------------------------------------------------------------------
// Point d'entrée
// ---------------------------------------------------------------------------

async function main() {
  console.log('='.repeat(60));
  console.log('  Lumen — Import des églises catholiques (OpenStreetMap)');
  console.log('='.repeat(60));
  console.log(`  Mode    : ${FRESH_MODE ? 'FRESH (repart de zéro)' : 'incrémental (fusionne avec existant)'}`);
  console.log(`  Requête : ${SIMPLIFIED ? 'simplifiée (denomination=catholic uniquement)' : 'complète'}`);
  console.log(`  Zones   : ${ZONES.length}`);
  console.log('');

  // Charger les données existantes (sauf en mode FRESH)
  let existing = [];
  if (!FRESH_MODE && fs.existsSync(OUT_PATH)) {
    existing = JSON.parse(fs.readFileSync(OUT_PATH, 'utf8'));
    console.log(`Données existantes : ${existing.length} églises chargées\n`);
  }
  const all = new Map(existing.map(c => [c.id, c]));

  // Parcourir toutes les zones
  for (const zone of ZONES) {
    await importZone(zone, all);
    await sleep(DELAY_MS);
  }

  // Sauvegarder
  const churches = Array.from(all.values());
  fs.writeFileSync(OUT_PATH, JSON.stringify(churches));
  const sizeKB = Math.round(fs.statSync(OUT_PATH).size / 1024);

  console.log('\n' + '='.repeat(60));
  console.log(`  Terminé : ${churches.length} églises — ${sizeKB} KB`);
  console.log(`  Fichier : assets/churches_france.json`);
  console.log('='.repeat(60));
}

main().catch(err => {
  console.error('Erreur fatale :', err.message);
  process.exit(1);
});
