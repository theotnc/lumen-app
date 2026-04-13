import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class PilgrimRoute {
  final String id;
  final String name;
  final String latinName;
  final String origin;
  final String end;
  final String description;
  final int distanceKm;
  final int stages;
  final IconData icon;
  final List<PilgrimStage> keyStages;

  const PilgrimRoute({
    required this.id,
    required this.name,
    required this.latinName,
    required this.origin,
    required this.end,
    required this.description,
    required this.distanceKm,
    required this.stages,
    required this.icon,
    required this.keyStages,
  });
}

class PilgrimStage {
  final String city;
  final String? detail;
  final bool isSanctuary;
  const PilgrimStage(this.city, {this.detail, this.isSanctuary = false});
}

// ── Polylignes GPS approximatives (source : connaissance OpenStreetMap) ────
// ~15-20 points par chemin — suffisant pour un tracé visuel reconnaissable.
// Pour une précision centimétrique, remplacer par les GPX officiels ACIR.
extension PilgrimRouteGeo on PilgrimRoute {
  List<LatLng> get polyline => _kPolylines[id] ?? const [];
}

// ── Section tag pour grouper les chemins dans l'UI ────────
enum PilgrimRegion { france, espagne, europe, monde }

extension PilgrimRouteRegion on PilgrimRoute {
  PilgrimRegion get region =>
      _kRegions[id] ?? PilgrimRegion.france;
}

const _kRegions = <String, PilgrimRegion>{
  'puy':            PilgrimRegion.france,
  'tours':          PilgrimRegion.france,
  'vezelay':        PilgrimRegion.france,
  'arles':          PilgrimRegion.france,
  'paris':          PilgrimRegion.france,
  'tro-breizh':     PilgrimRegion.france,
  'chartres':       PilgrimRegion.france,
  'rocamadour':     PilgrimRegion.france,
  'lourdes':        PilgrimRegion.france,
  'frances':        PilgrimRegion.espagne,
  'portugues':      PilgrimRegion.espagne,
  'norte':          PilgrimRegion.espagne,
  'primitivo':      PilgrimRegion.espagne,
  'plata':          PilgrimRegion.espagne,
  'aragon':         PilgrimRegion.espagne,
  'ingles':         PilgrimRegion.espagne,
  'finisterre':     PilgrimRegion.espagne,
  'francigena':     PilgrimRegion.europe,
  'fatima':         PilgrimRegion.europe,
  'assise':         PilgrimRegion.europe,
  'jerusalem':      PilgrimRegion.monde,
  'rome':           PilgrimRegion.monde,
};

final _kPolylines = <String, List<LatLng>>{
  'puy': [
    LatLng(45.044, 3.885),  // Le Puy-en-Velay
    LatLng(44.877, 3.268),  // Saugues
    LatLng(44.774, 3.082),  // Aumont-Aubrac
    LatLng(44.599, 2.396),  // Conques
    LatLng(44.609, 2.033),  // Figeac
    LatLng(44.519, 1.764),  // Cajarc
    LatLng(44.447, 1.442),  // Cahors
    LatLng(44.254, 1.221),  // Lauzerte
    LatLng(44.102, 1.082),  // Moissac
    LatLng(43.991, 0.853),  // Lectoure
    LatLng(43.956, 0.371),  // Condom
    LatLng(43.858, 0.104),  // Éauze
    LatLng(43.706, -0.259), // Aire-sur-l'Adour
    LatLng(43.574, -0.380), // Miramont-Sensacq
    LatLng(43.529, -0.414), // Arzacq-Arraziguet
    LatLng(43.388, -0.752), // Navarrenx
    LatLng(43.163, -1.237), // Saint-Jean-Pied-de-Port
  ],
  'tours': [
    LatLng(47.394, 0.690),  // Tours
    LatLng(46.817, 0.544),  // Châtellerault
    LatLng(46.580, 0.341),  // Poitiers
    LatLng(46.227, 0.155),  // Lusignan
    LatLng(45.746, -0.633), // Saintes
    LatLng(45.455, -0.746), // Pons
    LatLng(45.177, -0.713), // Blaye
    LatLng(44.837, -0.579), // Bordeaux
    LatLng(44.557, -0.761), // Belin-Béliet
    LatLng(44.219, -0.914), // Labouheyre
    LatLng(43.903, -0.767), // Saint-Sever
    LatLng(43.692, -0.993), // Hagetmau
    LatLng(43.527, -1.066), // Sorde-l'Abbaye
    LatLng(43.397, -1.061), // Peyrehorade
    LatLng(43.342, -1.082), // Ostabat-Asme
  ],
  'vezelay': [
    LatLng(47.467, 3.746),  // Vézelay
    LatLng(47.081, 2.398),  // Bourges
    LatLng(46.706, 2.120),  // Saint-Amand-Montrond
    LatLng(46.238, 1.487),  // La Souterraine
    LatLng(45.833, 1.261),  // Limoges
    LatLng(45.517, 1.065),  // Thiviers
    LatLng(45.185, 0.721),  // Périgueux
    LatLng(44.852, 0.484),  // Bergerac
    LatLng(44.576, -0.037), // La Réole
    LatLng(44.432, -0.215), // Bazas
    LatLng(44.052, -0.499), // Mont-de-Marsan
    LatLng(43.696, -0.780), // Saint-Sever (rejoint Via Turonensis)
    LatLng(43.527, -1.066), // Sorde-l'Abbaye
    LatLng(43.342, -1.082), // Ostabat-Asme
  ],
  'arles': [
    LatLng(43.677, 4.631),  // Arles
    LatLng(43.676, 4.432),  // Saint-Gilles
    LatLng(43.652, 4.067),  // Lunel
    LatLng(43.611, 3.877),  // Montpellier
    LatLng(43.544, 3.406),  // Clermont-l'Hérault
    LatLng(43.557, 2.878),  // Saint-Guilhem / Lodève
    LatLng(43.606, 2.241),  // Castres
    LatLng(43.605, 1.444),  // Toulouse
    LatLng(43.647, 0.586),  // Auch
    LatLng(43.107, 0.724),  // Saint-Gaudens
    LatLng(43.022, 0.357),  // Saint-Bertrand-de-Comminges
    LatLng(43.195, -0.612), // Oloron-Sainte-Marie
    LatLng(43.021, -0.568), // Bedous
    LatLng(42.798, -0.526), // Col du Somport
  ],

  // ── Caminos espagnols ──────────────────────────────────
  'frances': [
    LatLng(43.163, -1.237), // Saint-Jean-Pied-de-Port
    LatLng(43.009, -1.319), // Roncevaux
    LatLng(42.820, -1.644), // Pampelune
    LatLng(42.682, -2.134), // Logroño (approche)
    LatLng(42.466, -2.445), // Logroño
    LatLng(42.344, -3.697), // Burgos
    LatLng(42.337, -4.603), // Carrión de los Condes
    LatLng(42.598, -5.571), // León
    LatLng(42.457, -6.056), // Astorga
    LatLng(42.546, -6.591), // Ponferrada
    LatLng(42.708, -6.996), // O Cebreiro
    LatLng(42.920, -8.015), // Melide
    LatLng(42.880, -8.545), // Santiago de Compostela
  ],
  'portugues': [
    LatLng(41.149, -8.611), // Porto
    LatLng(41.367, -8.590), // Póvoa de Varzim
    LatLng(41.538, -8.618), // Barcelos
    LatLng(41.770, -8.578), // Ponte de Lima
    LatLng(41.968, -8.622), // Valença
    LatLng(42.043, -8.648), // Tui (frontière)
    LatLng(42.169, -8.638), // O Porriño
    LatLng(42.284, -8.614), // Redondela
    LatLng(42.434, -8.648), // Pontevedra
    LatLng(42.551, -8.637), // Caldas de Reis
    LatLng(42.740, -8.657), // Padrón
    LatLng(42.880, -8.545), // Santiago de Compostela
  ],
  'norte': [
    LatLng(43.338, -1.788), // Irún
    LatLng(43.322, -1.983), // Saint-Sébastien
    LatLng(43.299, -2.340), // Zarautz
    LatLng(43.263, -2.934), // Bilbao
    LatLng(43.325, -3.313), // Castro-Urdiales
    LatLng(43.463, -3.800), // Santander
    LatLng(43.392, -4.099), // Santillana del Mar
    LatLng(43.390, -5.043), // Ribadesella
    LatLng(43.362, -5.845), // Oviedo
    LatLng(43.543, -6.531), // Luarca
    LatLng(43.536, -7.040), // Ribadeo
    LatLng(43.427, -7.364), // Mondoñedo
    LatLng(43.010, -7.556), // Lugo
    LatLng(42.880, -8.545), // Santiago de Compostela
  ],
  'primitivo': [
    LatLng(43.362, -5.845), // Oviedo
    LatLng(43.389, -6.077), // Grado
    LatLng(43.331, -6.416), // Tineo
    LatLng(43.208, -6.871), // Grandas de Salime
    LatLng(43.127, -7.068), // A Fonsagrada
    LatLng(43.010, -7.556), // Lugo
    LatLng(42.979, -7.768), // Palas de Rei
    LatLng(42.920, -8.015), // Melide
    LatLng(42.880, -8.545), // Santiago de Compostela
  ],
  'plata': [
    LatLng(37.386, -5.992), // Séville
    LatLng(37.693, -5.958), // Guillena
    LatLng(38.200, -6.350), // Almendralejo
    LatLng(38.917, -6.340), // Mérida
    LatLng(39.476, -6.371), // Cáceres
    LatLng(39.860, -6.069), // Plasencia
    LatLng(40.502, -5.672), // Béjar
    LatLng(40.965, -5.664), // Salamanque
    LatLng(41.503, -5.745), // Zamora
    LatLng(41.998, -5.742), // Puebla de Sanabria
    LatLng(42.336, -7.864), // Ourense
    LatLng(42.575, -8.134), // Lalín
    LatLng(42.880, -8.545), // Santiago de Compostela
  ],

  // ── Nouveaux chemins français ──────────────────────────
  'paris': [
    LatLng(48.853, 2.349),  // Paris - Notre-Dame
    LatLng(48.434, 2.160),  // Étampes
    LatLng(47.902, 1.909),  // Orléans
    LatLng(47.794, 1.068),  // Vendôme
    LatLng(47.394, 0.690),  // Tours → continue Via Turonensis
    LatLng(46.580, 0.341),  // Poitiers
    LatLng(45.455, -0.746), // Pons
    LatLng(44.837, -0.579), // Bordeaux
    LatLng(43.163, -1.237), // Saint-Jean-Pied-de-Port
  ],
  'tro-breizh': [
    LatLng(48.514, -2.765), // Saint-Brieuc
    LatLng(48.787, -3.230), // Tréguier
    LatLng(48.681, -3.985), // Saint-Pol-de-Léon
    LatLng(48.448, -4.490), // Landerneau
    LatLng(48.017, -4.097), // Quimper
    LatLng(47.750, -3.367), // Hennebont / Vannes approche
    LatLng(47.658, -2.761), // Vannes
    LatLng(48.554, -1.753), // Dol-de-Bretagne
    LatLng(48.649, -2.024), // Saint-Malo
    LatLng(48.514, -2.765), // Saint-Brieuc (retour)
  ],
  'chartres': [
    LatLng(48.853, 2.350),  // Paris - Notre-Dame de Paris
    LatLng(48.805, 2.122),  // Versailles
    LatLng(48.645, 1.832),  // Rambouillet
    LatLng(48.526, 1.838),  // Ablis
    LatLng(48.447, 1.488),  // Chartres - Notre-Dame
  ],
  'rocamadour': [
    LatLng(44.802, 1.822),  // Figeac (départ fréquent)
    LatLng(44.710, 1.790),  // Gramat
    LatLng(44.799, 1.617),  // Rocamadour - sanctuaire
  ],
  'lourdes': [
    LatLng(43.605, 1.444),  // Toulouse
    LatLng(43.485, 1.212),  // L'Isle-en-Dodon
    LatLng(43.317, 0.929),  // Saint-Gaudens
    LatLng(43.093, 0.580),  // Montréjeau
    LatLng(43.003, 0.071),  // Lannemezan
    LatLng(43.098, -0.042), // Tarbes
    LatLng(43.097, -0.046), // Lourdes - Sanctuaire Notre-Dame
  ],

  // ── Nouveaux caminos espagnols ─────────────────────────
  'aragon': [
    LatLng(42.798, -0.526), // Col du Somport
    LatLng(42.570, -0.551), // Jaca
    LatLng(42.507, -1.005), // Ruesta
    LatLng(42.570, -1.282), // Sangüesa
    LatLng(42.690, -1.498), // Monreal
    LatLng(42.820, -1.644), // Pampelune → rejoint Camino Francés
    LatLng(42.880, -8.545), // Santiago de Compostela
  ],
  'ingles': [
    LatLng(43.483, -8.231), // Ferrol
    LatLng(43.500, -8.151), // Neda
    LatLng(43.403, -8.160), // Pontedeume
    LatLng(43.279, -8.210), // Betanzos
    LatLng(43.089, -8.127), // Bruma
    LatLng(42.929, -8.411), // Sigueiro
    LatLng(42.880, -8.545), // Santiago de Compostela
  ],
  'finisterre': [
    LatLng(42.880, -8.545), // Santiago de Compostela
    LatLng(42.898, -8.741), // Negreira
    LatLng(42.844, -9.002), // Olveiroa
    LatLng(42.961, -9.188), // Cée
    LatLng(42.906, -9.267), // Cape Finisterre
  ],

  // ── Europe ─────────────────────────────────────────────
  'francigena': [
    LatLng(51.279, 1.080),  // Canterbury
    LatLng(51.128, 1.311),  // Dover
    LatLng(50.951, 1.858),  // Calais
    LatLng(49.258, 4.032),  // Reims
    LatLng(48.770, 5.163),  // Bar-le-Duc
    LatLng(47.861, 5.333),  // Langres
    LatLng(47.238, 6.025),  // Besançon
    LatLng(46.519, 6.632),  // Lausanne
    LatLng(46.101, 7.072),  // Martigny
    LatLng(45.869, 7.171),  // Grand-Saint-Bernard
    LatLng(45.737, 7.316),  // Aoste
    LatLng(45.184, 9.158),  // Pavie
    LatLng(43.844, 10.503), // Lucques
    LatLng(43.318, 11.331), // Sienne
    LatLng(42.418, 12.103), // Viterbe
    LatLng(41.902, 12.453), // Rome
  ],
  'fatima': [
    LatLng(38.714, -9.143), // Lisbonne
    LatLng(39.235, -8.686), // Santarém
    LatLng(39.619, -8.668), // Fátima
  ],
  'assise': [
    LatLng(43.771, 11.254), // Florence
    LatLng(43.573, 12.137), // Sansepolcro (La Verna)
    LatLng(43.352, 12.576), // Gubbio
    LatLng(43.070, 12.617), // Assise
    LatLng(42.734, 12.738), // Spolète
    LatLng(42.418, 12.103), // Viterbe
    LatLng(41.902, 12.453), // Rome
  ],

  // ── Monde ──────────────────────────────────────────────
  'jerusalem': [
    LatLng(41.902, 12.453), // Rome
    LatLng(40.853, 14.268), // Naples
    LatLng(37.502, 15.091), // Catane (Sicile)
    LatLng(35.168, 33.360), // Chypre
    LatLng(32.808, 34.989), // Haïfa
    LatLng(31.768, 35.214), // Jérusalem
  ],
  'rome': [
    LatLng(48.853, 2.349),  // Paris
    LatLng(47.238, 6.025),  // Besançon
    LatLng(46.519, 6.632),  // Lausanne
    LatLng(45.869, 7.171),  // Grand-Saint-Bernard
    LatLng(45.737, 7.316),  // Aoste
    LatLng(43.318, 11.331), // Sienne
    LatLng(41.902, 12.453), // Rome
  ],
};

const List<PilgrimRoute> kPilgrimRoutes = [
  PilgrimRoute(
    id: 'puy',
    name: 'Chemin du Puy',
    latinName: 'Via Podiensis',
    origin: 'Le Puy-en-Velay',
    end: 'Saint-Jean-Pied-de-Port',
    description: 'Le plus fréquenté de France. Traverse l\'Auvergne, la Lomagne et la Gascogne depuis la cathédrale du Puy.',
    distanceKm: 750,
    stages: 33,
    icon: Icons.terrain_rounded,
    keyStages: [
      PilgrimStage('Le Puy-en-Velay', detail: 'Cathédrale Notre-Dame · Point de départ officiel', isSanctuary: true),
      PilgrimStage('Conques', detail: 'Abbatiale Sainte-Foy · Trésor carolingien', isSanctuary: true),
      PilgrimStage('Figeac', detail: 'Vieille ville médiévale, musée Champollion'),
      PilgrimStage('Cahors', detail: 'Pont Valentré, cathédrale Saint-Étienne'),
      PilgrimStage('Moissac', detail: 'Abbaye Saint-Pierre · Cloître roman exceptionnel', isSanctuary: true),
      PilgrimStage('Condom', detail: 'Cathédrale Saint-Pierre, cœur de l\'Armagnac'),
      PilgrimStage('Éauze', detail: 'Ancienne capitale de Novempopulanie'),
      PilgrimStage('Aire-sur-l\'Adour', detail: 'Cathédrale Saint-Jean · Corps de Sainte Quitterie', isSanctuary: true),
      PilgrimStage('Saint-Jean-Pied-de-Port', detail: 'Porte des Pyrénées · Confluence des chemins', isSanctuary: true),
    ],
  ),
  PilgrimRoute(
    id: 'tours',
    name: 'Chemin de Tours',
    latinName: 'Via Turonensis',
    origin: 'Tours',
    end: 'Ostabat-Asme',
    description: 'Part du tombeau de Saint-Martin, traverse la Sologne, le Poitou et longe les forêts des Landes de Gascogne.',
    distanceKm: 800,
    stages: 32,
    icon: Icons.forest_rounded,
    keyStages: [
      PilgrimStage('Tours', detail: 'Basilique Saint-Martin · Tombeau du saint évêque', isSanctuary: true),
      PilgrimStage('Poitiers', detail: 'Baptistère Saint-Jean · Notre-Dame-la-Grande', isSanctuary: true),
      PilgrimStage('Saintes', detail: 'Abbaye aux Dames, arc de Germanicus'),
      PilgrimStage('Bordeaux', detail: 'Cathédrale Saint-André · Basilique Saint-Seurin', isSanctuary: true),
      PilgrimStage('Belin-Béliet', detail: 'Forêt des Landes, nécropole médiévale'),
      PilgrimStage('Labouheyre', detail: 'Cœur des Landes de Gascogne'),
      PilgrimStage('Sorde-l\'Abbaye', detail: 'Abbaye Saint-Jean · Mosaïques romanes', isSanctuary: true),
      PilgrimStage('Ostabat-Asme', detail: 'Carrefour historique · Confluence de 3 chemins', isSanctuary: true),
    ],
  ),
  PilgrimRoute(
    id: 'vezelay',
    name: 'Chemin de Vézelay',
    latinName: 'Via Lemovicensis',
    origin: 'Vézelay',
    end: 'Ostabat-Asme',
    description: 'Depuis la basilique de la Madeleine, traverse le Berry, la Creuse et le Périgord. Le plus sauvage des grands chemins.',
    distanceKm: 900,
    stages: 36,
    icon: Icons.landscape_rounded,
    keyStages: [
      PilgrimStage('Vézelay', detail: 'Basilique Sainte-Marie-Madeleine · Patrimoine UNESCO', isSanctuary: true),
      PilgrimStage('Bourges', detail: 'Cathédrale Saint-Étienne · Vitraux gothiques', isSanctuary: true),
      PilgrimStage('La Souterraine', detail: 'Église romane Notre-Dame'),
      PilgrimStage('Limoges', detail: 'Cathédrale Saint-Étienne, porcelaine limousine'),
      PilgrimStage('Périgueux', detail: 'Cathédrale Saint-Front · Cité médiévale', isSanctuary: true),
      PilgrimStage('Bergerac', detail: 'Dordogne, vignobles du Périgord'),
      PilgrimStage('La Réole', detail: 'Prieuré bénédictin, bords de Garonne'),
      PilgrimStage('Bazas', detail: 'Cathédrale Saint-Jean-Baptiste · Remparts'),
      PilgrimStage('Ostabat-Asme', detail: 'Carrefour historique · Confluence de 3 chemins', isSanctuary: true),
    ],
  ),
  PilgrimRoute(
    id: 'arles',
    name: 'Chemin d\'Arles',
    latinName: 'Via Tolosana',
    origin: 'Arles',
    end: 'Col du Somport',
    description: 'La via méridionale traverse la Camargue, le Languedoc, la Gascogne gersoise et franchit les Pyrénées au Somport.',
    distanceKm: 750,
    stages: 30,
    icon: Icons.wb_sunny_rounded,
    keyStages: [
      PilgrimStage('Arles', detail: 'Église Saint-Trophime · Cloître roman, Patrimoine UNESCO', isSanctuary: true),
      PilgrimStage('Saint-Gilles', detail: 'Abbatiale Saint-Gilles · Façade sculptée', isSanctuary: true),
      PilgrimStage('Montpellier', detail: 'Cathédrale Saint-Pierre'),
      PilgrimStage('Toulouse', detail: 'Basilique Saint-Sernin · Plus grande église romane d\'Europe', isSanctuary: true),
      PilgrimStage('Auch', detail: 'Cathédrale Sainte-Marie · Stalles et vitraux'),
      PilgrimStage('Saint-Gaudens', detail: 'Collégiale Saint-Pierre · Premières vues des Pyrénées'),
      PilgrimStage('Oloron-Sainte-Marie', detail: 'Cathédrale Sainte-Marie · Tympan roman', isSanctuary: true),
      PilgrimStage('Col du Somport', detail: 'Franchissement des Pyrénées · Entrée en Espagne', isSanctuary: true),
    ],
  ),

  // ── Caminos espagnols ──────────────────────────────────

  PilgrimRoute(
    id: 'frances',
    name: 'Camino Francés',
    latinName: 'Via Francigena Hispanica',
    origin: 'Saint-Jean-Pied-de-Port',
    end: 'Santiago de Compostela',
    description: 'Le chemin le plus emprunté au monde. Franchit les Pyrénées, traverse la Navarre, la Castille et la Galice.',
    distanceKm: 780,
    stages: 30,
    icon: Icons.explore_rounded,
    keyStages: [
      PilgrimStage('Saint-Jean-Pied-de-Port', detail: 'Point de départ · Confluence des chemins français', isSanctuary: true),
      PilgrimStage('Roncevaux', detail: 'Collégiale royale · Premier refuge en Espagne', isSanctuary: true),
      PilgrimStage('Pampelune', detail: 'Capitale de Navarre · Cathédrale Santa María'),
      PilgrimStage('Logroño', detail: 'Cathédrale Santa María de la Redonda · La Rioja'),
      PilgrimStage('Burgos', detail: 'Cathédrale gothique UNESCO · Tombeau du Cid', isSanctuary: true),
      PilgrimStage('León', detail: 'Cathédrale aux 1 800 m² de vitraux · Basilique San Isidoro', isSanctuary: true),
      PilgrimStage('O Cebreiro', detail: 'Entrée en Galice · Église prérromane et reliques', isSanctuary: true),
      PilgrimStage('Santiago de Compostela', detail: 'Cathédrale apostolique · Tombeau de saint Jacques', isSanctuary: true),
    ],
  ),

  PilgrimRoute(
    id: 'portugues',
    name: 'Camino Portugués',
    latinName: 'Via Portuguesa',
    origin: 'Porto',
    end: 'Santiago de Compostela',
    description: 'Remonte le Portugal depuis Porto, franchit le Minho à Tui et traverse la Galice. Le 2e chemin le plus fréquenté.',
    distanceKm: 240,
    stages: 12,
    icon: Icons.water_rounded,
    keyStages: [
      PilgrimStage('Porto', detail: 'Cathédrale Sé · Départ traditionnel depuis la Tour des Clercs', isSanctuary: true),
      PilgrimStage('Barcelos', detail: 'Patrie du Coq de Barcelos · Symbole du Camino'),
      PilgrimStage('Ponte de Lima', detail: 'Plus ancienne ville du Portugal · Pont romain'),
      PilgrimStage('Valença / Tui', detail: 'Franchissement du Minho · Entrée en Espagne', isSanctuary: true),
      PilgrimStage('Pontevedra', detail: 'Vieille ville médiévale · Basilique Santa María Mayor', isSanctuary: true),
      PilgrimStage('Padrón', detail: 'Tradition apostolique · Pierre d\'amarrage de la barque de saint Jacques', isSanctuary: true),
      PilgrimStage('Santiago de Compostela', detail: 'Cathédrale apostolique · Tombeau de saint Jacques', isSanctuary: true),
    ],
  ),

  PilgrimRoute(
    id: 'norte',
    name: 'Camino del Norte',
    latinName: 'Via Costiera',
    origin: 'Irún',
    end: 'Santiago de Compostela',
    description: 'Longe la côte cantabrique de la frontière française jusqu\'en Galice. Le plus sauvage des Caminos espagnols.',
    distanceKm: 825,
    stages: 34,
    icon: Icons.waves_rounded,
    keyStages: [
      PilgrimStage('Irún', detail: 'Point de départ · Frontière franco-espagnole au Pays basque'),
      PilgrimStage('Saint-Sébastien', detail: 'Donostia · Vieille ville et baie de la Concha'),
      PilgrimStage('Bilbao', detail: 'Musée Guggenheim · Cathédrale Santiago Apóstol'),
      PilgrimStage('Santander', detail: 'Cathédrale · Plages de la Costa Verde'),
      PilgrimStage('Santillana del Mar', detail: 'Joyau médiéval · Grottes d\'Altamira', isSanctuary: true),
      PilgrimStage('Oviedo', detail: 'Cathédrale du Saint-Suaire · Point de jonction avec le Primitivo', isSanctuary: true),
      PilgrimStage('Ribadeo', detail: 'Entrée en Galice · Plage des Cathédrales'),
      PilgrimStage('Santiago de Compostela', detail: 'Cathédrale apostolique · Tombeau de saint Jacques', isSanctuary: true),
    ],
  ),

  PilgrimRoute(
    id: 'primitivo',
    name: 'Camino Primitivo',
    latinName: 'Via Antiqua',
    origin: 'Oviedo',
    end: 'Santiago de Compostela',
    description: 'Le plus ancien chemin de Compostelle, emprunté dès le IXe siècle par le roi Alphonse II. Traversée des montagnes des Asturies.',
    distanceKm: 320,
    stages: 13,
    icon: Icons.account_balance_rounded,
    keyStages: [
      PilgrimStage('Oviedo', detail: 'Cathédrale du Saint-Suaire · Le plus ancien point de départ du Camino', isSanctuary: true),
      PilgrimStage('Grado', detail: 'Première étape en Asturies · Collégiale San Juan'),
      PilgrimStage('Tineo', detail: 'Monastère de Obona · Altitude 700 m'),
      PilgrimStage('Grandas de Salime', detail: 'Col de Palo · Point culminant du chemin (1 140 m)'),
      PilgrimStage('A Fonsagrada', detail: 'Première ville de Galice · Début de la forêt de chênes'),
      PilgrimStage('Lugo', detail: 'Remparts romains UNESCO · Cathédrale Sainte-Marie', isSanctuary: true),
      PilgrimStage('Santiago de Compostela', detail: 'Cathédrale apostolique · Tombeau de saint Jacques', isSanctuary: true),
    ],
  ),

  PilgrimRoute(
    id: 'plata',
    name: 'Vía de la Plata',
    latinName: 'Via Lata',
    origin: 'Séville',
    end: 'Santiago de Compostela',
    description: 'L\'ancienne voie romaine de l\'argent traverse l\'Andalousie, l\'Estrémadure et la Castille. Le chemin le plus long et le plus solitaire.',
    distanceKm: 1000,
    stages: 40,
    icon: Icons.wb_sunny_rounded,
    keyStages: [
      PilgrimStage('Séville', detail: 'Cathédrale UNESCO · 3e plus grande église chrétienne du monde', isSanctuary: true),
      PilgrimStage('Mérida', detail: 'Ancienne Emerita Augusta · Théâtre romain UNESCO'),
      PilgrimStage('Cáceres', detail: 'Vieille ville médiévale UNESCO · Palais de la Renaissance'),
      PilgrimStage('Salamanque', detail: 'Université la plus ancienne d\'Espagne · Cathédrale baroque', isSanctuary: true),
      PilgrimStage('Zamora', detail: 'Cathédrale romane du XIIe siècle · Ceinture de remparts'),
      PilgrimStage('Puebla de Sanabria', detail: 'Château médiéval · Porte des montagnes galiciennes'),
      PilgrimStage('Ourense', detail: 'Sources thermales · Cathédrale San Martín', isSanctuary: true),
      PilgrimStage('Santiago de Compostela', detail: 'Cathédrale apostolique · Tombeau de saint Jacques', isSanctuary: true),
    ],
  ),

  // ══════════════════════════════════════════════════════
  // CHEMINS FRANÇAIS (suite)
  // ══════════════════════════════════════════════════════

  PilgrimRoute(
    id: 'paris',
    name: 'Chemin de Paris',
    latinName: 'Via Turonensis Nord',
    origin: 'Paris',
    end: 'Saint-Jean-Pied-de-Port',
    description: 'Depuis Notre-Dame de Paris, descend jusqu\'à Tours où il rejoint la Via Turonensis. La voie historique des pèlerins parisiens.',
    distanceKm: 1100,
    stages: 42,
    icon: Icons.location_city_rounded,
    keyStages: [
      PilgrimStage('Paris', detail: 'Cathédrale Notre-Dame · Point de départ symbolique', isSanctuary: true),
      PilgrimStage('Étampes', detail: 'Collégiale Notre-Dame du Fort'),
      PilgrimStage('Orléans', detail: 'Cathédrale Sainte-Croix · Ville de Jeanne d\'Arc', isSanctuary: true),
      PilgrimStage('Vendôme', detail: 'Abbatiale de la Trinité · Reliques du Saint-Larme'),
      PilgrimStage('Tours', detail: 'Basilique Saint-Martin · Jonction avec la Via Turonensis', isSanctuary: true),
      PilgrimStage('Bordeaux', detail: 'Cathédrale Saint-André · Basilique Saint-Seurin', isSanctuary: true),
      PilgrimStage('Saint-Jean-Pied-de-Port', detail: 'Porte des Pyrénées · Confluence des chemins', isSanctuary: true),
    ],
  ),

  PilgrimRoute(
    id: 'tro-breizh',
    name: 'Tro Breizh',
    latinName: 'Iter Septum Sanctorum',
    origin: 'Saint-Brieuc',
    end: 'Circuit (7 saints)',
    description: 'Le grand pèlerinage breton en circuit autour des 7 saints fondateurs de Bretagne. Une tradition millénaire qui se perpétue.',
    distanceKm: 600,
    stages: 28,
    icon: Icons.loop_rounded,
    keyStages: [
      PilgrimStage('Saint-Brieuc', detail: 'Cathédrale Saint-Étienne · Saint Brieuc', isSanctuary: true),
      PilgrimStage('Tréguier', detail: 'Cathédrale Saint-Tugdual · Tombeau de saint Yves', isSanctuary: true),
      PilgrimStage('Saint-Pol-de-Léon', detail: 'Cathédrale · Chef de saint Paul Aurélien', isSanctuary: true),
      PilgrimStage('Quimper', detail: 'Cathédrale Saint-Corentin · Cœur de la Cornouaille', isSanctuary: true),
      PilgrimStage('Vannes', detail: 'Cathédrale Saint-Pierre · Tombeau de saint Vincent Ferrier', isSanctuary: true),
      PilgrimStage('Dol-de-Bretagne', detail: 'Cathédrale Saint-Samson · Plus ancienne cathédrale bretonne', isSanctuary: true),
      PilgrimStage('Saint-Malo', detail: 'Cathédrale Saint-Vincent · Saint Aaron et saint Brendan', isSanctuary: true),
    ],
  ),

  PilgrimRoute(
    id: 'chartres',
    name: 'Paris–Chartres',
    latinName: 'Pèlerinage Notre-Dame de Chartres',
    origin: 'Paris',
    end: 'Chartres',
    description: 'Le plus grand pèlerinage à pied de France : 12 000 étudiants marchent de Paris à Chartres chaque Pentecôte depuis 1982.',
    distanceKm: 90,
    stages: 3,
    icon: Icons.school_rounded,
    keyStages: [
      PilgrimStage('Paris', detail: 'Notre-Dame de Paris · Départ du parvis', isSanctuary: true),
      PilgrimStage('Versailles', detail: 'Cathédrale Saint-Louis · Nuit en bivouac'),
      PilgrimStage('Rambouillet', detail: 'Passage par la forêt · Nuit en bivouac'),
      PilgrimStage('Chartres', detail: 'Notre-Dame de Chartres · Vierge Noire · Patrimoine UNESCO', isSanctuary: true),
    ],
  ),

  PilgrimRoute(
    id: 'rocamadour',
    name: 'Pèlerinage de Rocamadour',
    latinName: 'Via Sancti Amaduri',
    origin: 'Figeac',
    end: 'Rocamadour',
    description: 'L\'un des plus anciens pèlerinages de France. La Vierge Noire de Rocamadour attire les fidèles depuis le Moyen Âge.',
    distanceKm: 55,
    stages: 3,
    icon: Icons.vertical_align_top_rounded,
    keyStages: [
      PilgrimStage('Figeac', detail: 'Départ · Ville médiévale sur le Célé'),
      PilgrimStage('Gramat', detail: 'Causse du Quercy · Paysage de causses'),
      PilgrimStage('Rocamadour', detail: 'Sanctuaire de la Vierge Noire · 7 sanctuaires superposés', isSanctuary: true),
    ],
  ),

  PilgrimRoute(
    id: 'lourdes',
    name: 'Pèlerinage de Lourdes',
    latinName: 'Ad Aquas Luridae',
    origin: 'Toulouse',
    end: 'Lourdes',
    description: 'Lourdes est le 2e site le plus visité de France. Depuis les apparitions à Bernadette Soubirous en 1858, des millions de fidèles y viennent.',
    distanceKm: 180,
    stages: 8,
    icon: Icons.water_drop_rounded,
    keyStages: [
      PilgrimStage('Toulouse', detail: 'Basilique Saint-Sernin · Point de départ'),
      PilgrimStage('Saint-Gaudens', detail: 'Premières vues des Pyrénées'),
      PilgrimStage('Tarbes', detail: 'Cathédrale Notre-Dame de la Sède'),
      PilgrimStage('Lourdes', detail: 'Grotte de Massabielle · Sanctuaire Notre-Dame · Sources miraculeuses', isSanctuary: true),
    ],
  ),

  // ══════════════════════════════════════════════════════
  // CAMINOS ESPAGNOLS (suite)
  // ══════════════════════════════════════════════════════

  PilgrimRoute(
    id: 'aragon',
    name: 'Camino Aragonés',
    latinName: 'Via Aragoniensis',
    origin: 'Col du Somport',
    end: 'Pampelune',
    description: 'Franchit les Pyrénées au Somport et traverse le Haut-Aragon jusqu\'à Pampelune où il rejoint le Camino Francés.',
    distanceKm: 165,
    stages: 7,
    icon: Icons.terrain_rounded,
    keyStages: [
      PilgrimStage('Col du Somport', detail: 'Entrée en Espagne · Ancienne voie romaine', isSanctuary: true),
      PilgrimStage('Jaca', detail: 'Cathédrale San Pedro · Première ville d\'Aragon'),
      PilgrimStage('Sangüesa', detail: 'Église Santa María la Real · Tympan roman'),
      PilgrimStage('Monreal', detail: 'Traversée des plaines navarraises'),
      PilgrimStage('Pampelune', detail: 'Cathédrale Santa María · Jonction avec le Camino Francés', isSanctuary: true),
    ],
  ),

  PilgrimRoute(
    id: 'ingles',
    name: 'Camino Inglés',
    latinName: 'Via Anglorum',
    origin: 'Ferrol',
    end: 'Santiago de Compostela',
    description: 'La route des pèlerins anglais et irlandais qui débarquaient par mer dans les ports galiciens. Court mais authentique.',
    distanceKm: 120,
    stages: 6,
    icon: Icons.sailing_rounded,
    keyStages: [
      PilgrimStage('Ferrol', detail: 'Port historique · Débarquement des pèlerins des îles Britanniques'),
      PilgrimStage('Pontedeume', detail: 'Château médiéval sur la ria de Betanzos'),
      PilgrimStage('Betanzos', detail: 'Ville médiévale · Église San Francisco'),
      PilgrimStage('Bruma', detail: 'Croisement des pèlerins · Plateau galicien'),
      PilgrimStage('Santiago de Compostela', detail: 'Cathédrale apostolique · Tombeau de saint Jacques', isSanctuary: true),
    ],
  ),

  PilgrimRoute(
    id: 'finisterre',
    name: 'Camino Finisterre',
    latinName: 'Via ad Finem Terrae',
    origin: 'Santiago de Compostela',
    end: 'Cap Finisterre',
    description: 'Depuis Santiago, la tradition invite à marcher jusqu\'au "bout du monde" : le cap Finisterre, là où l\'Europe s\'arrête.',
    distanceKm: 90,
    stages: 4,
    icon: Icons.explore_outlined,
    keyStages: [
      PilgrimStage('Santiago de Compostela', detail: 'Point de départ · Dernier regard sur la cathédrale', isSanctuary: true),
      PilgrimStage('Negreira', detail: 'Palais de l\'archevêque · Entrée dans la campagne galicienne'),
      PilgrimStage('Olveiroa', detail: 'Village médiéval · Chapelle São Estevo'),
      PilgrimStage('Cap Finisterre', detail: '0,00 km · Bout du monde · Brûler ses chaussures, tradition millénaire', isSanctuary: true),
    ],
  ),

  // ══════════════════════════════════════════════════════
  // EUROPE
  // ══════════════════════════════════════════════════════

  PilgrimRoute(
    id: 'francigena',
    name: 'Via Francigena',
    latinName: 'Via Francigena',
    origin: 'Canterbury',
    end: 'Rome',
    description: 'La grande voie des pèlerins médiévaux vers Rome. De Canterbury à la tombe de saint Pierre en traversant l\'Angleterre, la France, la Suisse et l\'Italie.',
    distanceKm: 2000,
    stages: 80,
    icon: Icons.church_rounded,
    keyStages: [
      PilgrimStage('Canterbury', detail: 'Cathédrale · Tombeau de saint Thomas Becket · UNESCO', isSanctuary: true),
      PilgrimStage('Calais', detail: 'Traversée de la Manche · Entrée en France'),
      PilgrimStage('Reims', detail: 'Cathédrale Notre-Dame · Lieu du sacre des rois de France', isSanctuary: true),
      PilgrimStage('Besançon', detail: 'Cathédrale Saint-Jean · Entrée en Bourgogne-Franche-Comté'),
      PilgrimStage('Lausanne', detail: 'Cathédrale Notre-Dame · Traversée de la Suisse'),
      PilgrimStage('Grand-Saint-Bernard', detail: 'Hospice du col (2473 m) · Fondé au XIe siècle', isSanctuary: true),
      PilgrimStage('Sienne', detail: 'Cathédrale · Cité médiévale UNESCO · Accueil des pèlerins depuis toujours', isSanctuary: true),
      PilgrimStage('Rome', detail: 'Basilique Saint-Pierre · Tombeau de l\'apôtre Pierre · Vatican', isSanctuary: true),
    ],
  ),

  PilgrimRoute(
    id: 'fatima',
    name: 'Pèlerinage de Fátima',
    latinName: 'Ad Sanctuarium Fatimae',
    origin: 'Lisbonne',
    end: 'Fátima',
    description: 'Depuis les apparitions de 1917, Fátima est l\'un des plus grands sanctuaires marials au monde. Des millions de pèlerins y viennent chaque année.',
    distanceKm: 130,
    stages: 5,
    icon: Icons.favorite_rounded,
    keyStages: [
      PilgrimStage('Lisbonne', detail: 'Monastère des Hiéronymites · Tombe du navigateur Vasco de Gama'),
      PilgrimStage('Santarém', detail: 'Miracle eucharistique du XIIIe siècle · Cœur du Portugal', isSanctuary: true),
      PilgrimStage('Fátima', detail: 'Sanctuaire de Notre-Dame · Apparitions de 1917 · Basilique · Chapelle des Apparitions', isSanctuary: true),
    ],
  ),

  PilgrimRoute(
    id: 'assise',
    name: 'Via di Francesco',
    latinName: 'Via Sancti Francisci',
    origin: 'Florence',
    end: 'Rome',
    description: 'Les pas de saint François d\'Assise, de La Verna à Rome via Assise et Spolète. La route de la pauvreté évangélique et du Cantico delle Creature.',
    distanceKm: 550,
    stages: 22,
    icon: Icons.spa_rounded,
    keyStages: [
      PilgrimStage('Florence', detail: 'Basilique Santa Croce · Lieu de sépulture de Dante et Galilée'),
      PilgrimStage('La Verna', detail: 'Sanctuaire des Stigmates de saint François', isSanctuary: true),
      PilgrimStage('Gubbio', detail: 'Cité médiévale · François et le loup'),
      PilgrimStage('Assise', detail: 'Basilique San Francesco · Tombeau du Poverello · UNESCO', isSanctuary: true),
      PilgrimStage('Spolète', detail: 'Cathédrale · Fresques de Fra Filippo Lippi', isSanctuary: true),
      PilgrimStage('Greccio', detail: 'Sanctuaire de la crèche · François invente la crèche vivante', isSanctuary: true),
      PilgrimStage('Rome', detail: 'Basilique Saint-Pierre · Vatican · Bénédiction papale', isSanctuary: true),
    ],
  ),

  // ══════════════════════════════════════════════════════
  // MONDE
  // ══════════════════════════════════════════════════════

  PilgrimRoute(
    id: 'rome',
    name: 'Pèlerinage à Rome',
    latinName: 'Ad Limina Apostolorum',
    origin: 'Paris',
    end: 'Rome',
    description: 'Visiter "ad limina apostolorum" — le seuil des apôtres Pierre et Paul. Le pèlerinage vers le siège de l\'Église catholique depuis 2 000 ans.',
    distanceKm: 1800,
    stages: 72,
    icon: Icons.account_balance_rounded,
    keyStages: [
      PilgrimStage('Paris', detail: 'Notre-Dame · Cœur de la "fille aînée de l\'Église"', isSanctuary: true),
      PilgrimStage('Besançon', detail: 'Cathédrale Saint-Jean · Entrée en Bourgogne'),
      PilgrimStage('Grand-Saint-Bernard', detail: 'Col alpin historique · Hospice millénaire', isSanctuary: true),
      PilgrimStage('Milan', detail: 'Dôme de Milan · Dernier Souper de Léonard de Vinci'),
      PilgrimStage('Sienne', detail: 'Cathédrale · Sainte Catherine de Sienne · UNESCO', isSanctuary: true),
      PilgrimStage('Rome', detail: 'Basilique Saint-Pierre · Tombeau de Pierre · Bénédiction "Urbi et Orbi"', isSanctuary: true),
    ],
  ),

  PilgrimRoute(
    id: 'jerusalem',
    name: 'Pèlerinage à Jérusalem',
    latinName: 'Iter Hierosolymitanum',
    origin: 'Rome',
    end: 'Jérusalem',
    description: 'Le pèlerinage ultime — marcher sur les pas du Christ. De Rome à la Terre Sainte, en passant par les sanctuaires de la foi chrétienne.',
    distanceKm: 3200,
    stages: 120,
    icon: Icons.travel_explore_rounded,
    keyStages: [
      PilgrimStage('Rome', detail: 'Basilique Saint-Pierre · Tombeau de l\'apôtre Pierre', isSanctuary: true),
      PilgrimStage('Naples', detail: 'Cathédrale · Reliques de saint Janvier'),
      PilgrimStage('Catane', detail: 'Sicile · Basilique Sainte-Agathe · Traversée de la Méditerranée', isSanctuary: true),
      PilgrimStage('Chypre', detail: 'Île de l\'apôtre Barnabé · Nombreux monastères byzantins', isSanctuary: true),
      PilgrimStage('Haïfa', detail: 'Mont Carmel · Origine de l\'Ordre du Carmel', isSanctuary: true),
      PilgrimStage('Nazareth', detail: 'Basilique de l\'Annonciation · Ville d\'enfance de Jésus', isSanctuary: true),
      PilgrimStage('Jérusalem', detail: 'Saint-Sépulcre · Via Dolorosa · Mont des Oliviers · Mont Sion', isSanctuary: true),
    ],
  ),
];
