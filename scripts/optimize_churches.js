/**
 * optimize_churches.js — Réduit la taille de churches_france.json
 * Supprime les champs vides/null, garde uniquement l'essentiel
 */
const fs   = require('fs');
const path = require('path');

const inPath  = path.join(__dirname, '..', 'assets', 'churches_france.json');
const outPath = inPath;

const churches = JSON.parse(fs.readFileSync(inPath, 'utf8'));

const optimized = churches.map(c => {
  const out = {
    id:        c.id,
    nom:       c.nom,
    latitude:  Math.round(c.latitude  * 100000) / 100000,
    longitude: Math.round(c.longitude * 100000) / 100000,
  };
  if (c.ville)       out.ville       = c.ville;
  if (c.codePostal)  out.codePostal  = c.codePostal;
  if (c.adresse)     out.adresse     = c.adresse;
  if (c.telephone)   out.telephone   = c.telephone;
  if (c.siteWeb)     out.siteWeb     = c.siteWeb;
  return out;
});

fs.writeFileSync(outPath, JSON.stringify(optimized));
const sizeKB = Math.round(fs.statSync(outPath).size / 1024);
console.log(`${optimized.length} églises — ${sizeKB} KB (optimisé)`);
