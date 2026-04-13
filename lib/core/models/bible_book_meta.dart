import 'package:flutter/material.dart';

/// Métadonnées éditorialisées des livres bibliques.
/// Indépendant des données JSON — sert uniquement à l'affichage.
class BibleBookMeta {
  // ── Descriptions courtes ─────────────────────────────────
  static const Map<String, String> descriptions = {
    'gn':   'La création du monde, Adam et Ève, Noé, Abraham et Joseph.',
    'ex':   'Moïse libère le peuple hébreu d\'Égypte. Les Dix Commandements.',
    'lv':   'Les lois et rituels donnés à Israël par Dieu.',
    'nm':   'Quarante ans de marche dans le désert vers la Terre Promise.',
    'dt':   'Le dernier discours de Moïse avant d\'entrer en Terre Promise.',
    'js':   'La conquête de la Terre Promise sous la conduite de Josué.',
    'jg':   'Les héros (Juges) qui gouvernent Israël avant les rois.',
    'rt':   'L\'histoire touchante de Ruth, exemple de fidélité et d\'amour.',
    '1sm':  'Samuel, le premier roi Saül, et la montée en puissance de David.',
    '2sm':  'Le règne du roi David, ses victoires et ses péchés.',
    '1kgs': 'La splendeur du roi Salomon et la construction du Temple.',
    '2kgs': 'La chute des royaumes d\'Israël et de Juda.',
    '1ch':  'L\'histoire d\'Israël revue pour le peuple revenu d\'exil.',
    '2ch':  'Le règne de Salomon et des rois de Juda jusqu\'à l\'exil.',
    'ezr':  'Le retour d\'exil à Babylone et la reconstruction du Temple.',
    'ne':   'La reconstruction des remparts de Jérusalem.',
    'et':   'Esther, une femme courageuse qui sauve son peuple.',
    'jb':   'Job souffre et interroge Dieu sur le sens de la souffrance.',
    'ps':   'Les 150 prières et chants de la Bible, utilisés dans la liturgie.',
    'prv':  'Maximes de sagesse pratique pour bien vivre au quotidien.',
    'ec':   'Réflexions profondes sur le sens de la vie et de la mort.',
    'sg':   'Un poème d\'amour humain, symbole de l\'amour de Dieu.',
    'is':   'Le prophète de l\'espérance. Il annonce la venue du Messie.',
    'jr':   'Le prophète des larmes. Il appelle à la conversion.',
    'lm':   'Chants de deuil après la destruction de Jérusalem.',
    'ez':   'Visions mystiques et promesse d\'un cœur nouveau pour Israël.',
    'dn':   'Daniel dans la fosse aux lions. Visions de la fin des temps.',
    'os':   'Dieu aime Israël comme un époux fidèle malgré les infidélités.',
    'jl':   'L\'invasion de sauterelles comme signe du Jugement de Dieu.',
    'am':   'Un berger devenu prophète crie contre l\'injustice sociale.',
    'ob':   'Courte mise en garde contre la nation d\'Édom.',
    'jn':   'Jonas, avalé par un grand poisson, puis envoyé à Ninive.',
    'mi':   'Il annonce que le Messie naîtra à Bethléem.',
    'na':   'La chute annoncée de Ninive, capitale de l\'Assyrie.',
    'hb':   'Le prophète questionne Dieu face à l\'injustice du monde.',
    'zp':   'Appel à la conversion avant le Jour du Seigneur.',
    'ag':   'Il pousse le peuple à reconstruire le Temple après l\'exil.',
    'zc':   'Visions de la restauration d\'Israël et de la venue du Messie.',
    'ml':   'Dernier message prophétique avant quatre siècles de silence.',
    'mt':   'L\'Évangile pour les Juifs. Jésus accomplit les prophéties de l\'AT.',
    'mk':   'Le plus court des Évangiles. Action, guérisons, mort et résurrection.',
    'lk':   'L\'Évangile de la miséricorde. Le bon Samaritain, le fils prodigue.',
    'jo':   'L\'Évangile le plus spirituel. Jésus lumière du monde.',
    'act':  'La naissance de l\'Église. Pierre, Paul, et les premiers disciples.',
    'rm':   'Le cœur de la théologie chrétienne : la foi et la grâce.',
    '1co':  'L\'amour avant tout (ch. 13), et la résurrection du Christ.',
    '2co':  'Paul parle de sa faiblesse et de la puissance de Dieu.',
    'gl':   'La liberté chrétienne face au légalisme. Fruits de l\'Esprit.',
    'ep':   'L\'Église comme corps du Christ. L\'armure de Dieu.',
    'ph':   'La lettre de la joie, écrite depuis la prison.',
    'cl':   'Le Christ, tête de toute la création.',
    '1ts':  'La première lettre de Paul. La résurrection et le retour du Christ.',
    '2ts':  'Sur la fin des temps et le retour du Seigneur.',
    '1tm':  'Conseils de Paul à son jeune disciple Timothée sur l\'Église.',
    '2tm':  'Le testament spirituel de Paul, écrit peu avant sa mort.',
    'tt':   'Conseils pour organiser les premières communautés chrétiennes.',
    'phm':  'Paul plaide pour un esclave fugitif devenu chrétien.',
    'heb':  'Jésus, le grand prêtre unique qui accomplit tous les sacrifices.',
    'jm':   'La foi sans les œuvres est morte. L\'engagement concret.',
    '1pe':  'Encouragements aux chrétiens persécutés. L\'espérance vivante.',
    '2pe':  'Mise en garde contre les faux enseignants.',
    '1jo':  'Dieu est amour. Aimer Dieu, c\'est aimer son frère.',
    '2jo':  'Courte lettre sur l\'amour et la vérité.',
    '3jo':  'Courte lettre à un chrétien exemplaire nommé Gaïus.',
    'jd':   'Défendre la foi face aux enseignements qui la dévient.',
    'rv':   'La vision de Jean sur la victoire finale de Dieu et le ciel nouveau.',
  };

  // ── Groupes de l'Ancien Testament ───────────────────────
  static const List<BibleBookGroup> ancienTestament = [
    BibleBookGroup(
      title: 'Le Pentateuque',
      subtitle: 'Les 5 livres fondateurs, de la Création aux portes de la Terre Promise',
      icon: Icons.menu_book_rounded,
      abbrevs: ['gn', 'ex', 'lv', 'nm', 'dt'],
    ),
    BibleBookGroup(
      title: 'Livres historiques',
      subtitle: 'L\'épopée du peuple d\'Israël, de la conquête à l\'exil',
      icon: Icons.account_balance_rounded,
      abbrevs: ['js', 'jg', 'rt', '1sm', '2sm', '1kgs', '2kgs', '1ch', '2ch', 'ezr', 'ne', 'et'],
    ),
    BibleBookGroup(
      title: 'Poésie et Sagesse',
      subtitle: 'Prières, hymnes et réflexions sur le sens de la vie',
      icon: Icons.music_note_rounded,
      abbrevs: ['jb', 'ps', 'prv', 'ec', 'sg'],
    ),
    BibleBookGroup(
      title: 'Grands Prophètes',
      subtitle: 'Les messagers de Dieu face aux crises d\'Israël',
      icon: Icons.bolt_rounded,
      abbrevs: ['is', 'jr', 'lm', 'ez', 'dn'],
    ),
    BibleBookGroup(
      title: 'Petits Prophètes',
      subtitle: 'Douze voix prophétiques, courtes mais puissantes',
      icon: Icons.campaign_rounded,
      abbrevs: ['os', 'jl', 'am', 'ob', 'jn', 'mi', 'na', 'hb', 'zp', 'ag', 'zc', 'ml'],
    ),
  ];

  // ── Groupes du Nouveau Testament ─────────────────────────
  static const List<BibleBookGroup> nouveauTestament = [
    BibleBookGroup(
      title: 'Les Évangiles',
      subtitle: 'La vie, les paroles et la résurrection de Jésus-Christ',
      icon: Icons.church_rounded,
      abbrevs: ['mt', 'mk', 'lk', 'jo'],
      recommended: true,
    ),
    BibleBookGroup(
      title: 'Actes des Apôtres',
      subtitle: 'La naissance de l\'Église et la mission des premiers disciples',
      icon: Icons.groups_rounded,
      abbrevs: ['act'],
    ),
    BibleBookGroup(
      title: 'Lettres de Paul',
      subtitle: 'L\'enseignement fondateur du premier grand missionnaire',
      icon: Icons.mail_rounded,
      abbrevs: ['rm', '1co', '2co', 'gl', 'ep', 'ph', 'cl', '1ts', '2ts', '1tm', '2tm', 'tt', 'phm'],
    ),
    BibleBookGroup(
      title: 'Autres lettres',
      subtitle: 'Les lettres des autres apôtres aux premières communautés',
      icon: Icons.auto_stories_rounded,
      abbrevs: ['heb', 'jm', '1pe', '2pe', '1jo', '2jo', '3jo', 'jd'],
    ),
    BibleBookGroup(
      title: 'Apocalypse',
      subtitle: 'La vision prophétique de la victoire finale de Dieu',
      icon: Icons.star_rounded,
      abbrevs: ['rv'],
    ),
  ];

  // ── Livres "Pour commencer" ───────────────────────────────
  static const List<StarterBook> starters = [
    StarterBook(
      abbrev: 'mk',
      label: 'Évangile de Marc',
      pitch: 'Le récit le plus direct de la vie de Jésus. Court, intense, idéal pour commencer.',
      icon: Icons.church_rounded,
    ),
    StarterBook(
      abbrev: 'ps',
      label: 'Psaumes',
      pitch: 'Les prières de la Bible. Ouvrez à n\'importe quelle page et priez.',
      icon: Icons.music_note_rounded,
    ),
    StarterBook(
      abbrev: 'gn',
      label: 'Genèse',
      pitch: 'Le commencement de tout : la création, Adam et Ève, Noé, Abraham.',
      icon: Icons.public_rounded,
    ),
  ];
}

class BibleBookGroup {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> abbrevs;
  final bool recommended;

  const BibleBookGroup({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.abbrevs,
    this.recommended = false,
  });
}

class StarterBook {
  final String abbrev;
  final String label;
  final String pitch;
  final IconData icon;

  const StarterBook({
    required this.abbrev,
    required this.label,
    required this.pitch,
    required this.icon,
  });
}
