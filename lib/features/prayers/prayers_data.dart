import '../../core/models/prayer.dart';

const List<Prayer> kAllPrayers = [

  // ══════════════════════════════════════════════════════
  // CLASSIQUES
  // ══════════════════════════════════════════════════════

  Prayer(
    id: 'notre-pere',
    titre: 'Notre Père',
    categorie: 'Classiques',
    description: '''La prière enseignée par Jésus lui-même à ses disciples. Le cœur de toute prière chrétienne.''',
    contenu: '''Notre Père, qui es aux cieux,
que ton nom soit sanctifié,
que ton règne vienne,
que ta volonté soit faite
sur la terre comme au ciel.

Donne-nous aujourd'hui notre pain de ce jour.
Pardonne-nous nos offenses,
comme nous pardonnons aussi
à ceux qui nous ont offensés.
Et ne nous soumets pas à la tentation,
mais délivre-nous du mal.

Amen.''',
    longueur: 1,
  ),

  Prayer(
    id: 'je-vous-salue-marie',
    titre: 'Je vous salue Marie',
    categorie: 'Classiques',
    description: '''Salutation à la Vierge Marie tirée de l'Évangile. La prière mariale la plus répandue au monde.''',
    contenu: '''Je vous salue, Marie,
pleine de grâces ;
le Seigneur est avec vous.
Vous êtes bénie entre toutes les femmes
et Jésus, le fruit de vos entrailles, est béni.

Sainte Marie, Mère de Dieu,
priez pour nous, pauvres pécheurs,
maintenant et à l'heure de notre mort.

Amen.''',
    longueur: 1,
  ),

  Prayer(
    id: 'gloire-au-pere',
    titre: 'Gloire au Père',
    categorie: 'Classiques',
    description: '''Courte louange à la Trinité. Récitée à la fin de chaque dizaine du chapelet.''',
    contenu: '''Gloire au Père, au Fils et au Saint-Esprit,
comme il était au commencement,
maintenant et toujours,
dans les siècles des siècles.

Amen.''',
    longueur: 1,
  ),

  Prayer(
    id: 'credo',
    titre: 'Credo (Symbole des Apôtres)',
    categorie: 'Classiques',
    description: '''La profession de foi catholique. Réciter le Credo, c'est affirmer publiquement ce en quoi on croit.''',
    contenu: '''Je crois en Dieu,
le Père tout-puissant,
Créateur du ciel et de la terre.

Et en Jésus-Christ,
son Fils unique, notre Seigneur,
qui a été conçu du Saint-Esprit,
est né de la Vierge Marie,
a souffert sous Ponce Pilate,
a été crucifié, est mort et a été enseveli,
est descendu aux enfers,
le troisième jour est ressuscité des morts,
est monté aux cieux,
est assis à la droite de Dieu le Père tout-puissant,
d'où il viendra juger les vivants et les morts.

Je crois en l'Esprit-Saint,
à la sainte Église catholique,
à la communion des saints,
à la rémission des péchés,
à la résurrection de la chair,
à la vie éternelle.

Amen.''',
    longueur: 2,
  ),

  Prayer(
    id: 'confiteor',
    titre: 'Confiteor',
    categorie: 'Classiques',
    description: '''Prière de pénitence récitée au début de la messe pour reconnaître ses fautes devant Dieu et l'assemblée.''',
    contenu: '''Je confesse à Dieu tout-puissant,
à la bienheureuse Vierge Marie,
à saint Michel Archange,
à saint Jean-Baptiste,
aux saints Apôtres Pierre et Paul,
à tous les saints, et à vous, mes frères,
que j'ai beaucoup péché
en pensée, en parole, par action et par omission.
Oui, c'est ma faute, c'est ma faute,
c'est ma très grande faute.
C'est pourquoi je supplie la bienheureuse Vierge Marie,
saint Michel Archange, saint Jean-Baptiste,
les saints Apôtres Pierre et Paul, tous les saints,
et vous aussi, mes frères,
de prier pour moi le Seigneur notre Dieu.''',
    longueur: 1,
  ),

  Prayer(
    id: 'acte-contrition',
    titre: 'Acte de contrition',
    categorie: 'Classiques',
    description: '''Prière pour demander pardon à Dieu après avoir péché. Se dit idéalement après la confession.''',
    contenu: '''Mon Dieu, j'ai un très grand regret
de vous avoir offensé,
parce que vous êtes infiniment bon,
infiniment aimable
et que le péché vous déplaît.

Je prends la ferme résolution,
avec le secours de votre sainte grâce,
de ne plus vous offenser
et de faire pénitence.

Amen.''',
    longueur: 1,
  ),

  Prayer(
    id: 'acte-foi',
    titre: 'Acte de foi',
    categorie: 'Classiques',
    description: '''Acte par lequel on affirme sa foi personnelle en Dieu et en tout ce que l'Église enseigne.''',
    contenu: '''Mon Dieu, je crois fermement toutes les vérités
que vous avez révélées et que l'Église nous enseigne,
parce que vous êtes la vérité même,
qui ne peut ni se tromper ni nous tromper.

Amen.''',
    longueur: 1,
  ),

  Prayer(
    id: 'acte-esperance',
    titre: 'Acte d\'espérance',
    categorie: 'Classiques',
    description: '''Acte par lequel on exprime sa confiance en la promesse du pardon et de la vie éternelle.''',
    contenu: '''Mon Dieu, j'espère avec une ferme confiance
que vous me donnerez, par les mérites de Jésus-Christ,
votre grâce en ce monde et votre gloire en l'autre,
parce que vous l'avez promis
et que vous êtes fidèle à vos promesses.

Amen.''',
    longueur: 1,
  ),

  Prayer(
    id: 'acte-charite',
    titre: 'Acte de charité',
    categorie: 'Classiques',
    description: '''Déclaration d'amour envers Dieu et le prochain, cœur du message évangélique.''',
    contenu: '''Mon Dieu, je vous aime de tout mon cœur,
et par-dessus toutes choses,
parce que vous êtes infiniment bon et infiniment aimable,
et j'aime mon prochain comme moi-même
pour l'amour de vous.

Amen.''',
    longueur: 1,
  ),

  Prayer(
    id: 'benedicite',
    titre: 'Bénédicité',
    categorie: 'Classiques',
    description: '''Courte prière avant les repas pour rendre grâce à Dieu qui nourrit ses enfants.''',
    contenu: '''Bénissez-nous, Seigneur,
ainsi que la nourriture que nous allons prendre.

Amen.''',
    longueur: 1,
  ),

  Prayer(
    id: 'salve-regina',
    titre: 'Salve Regina',
    categorie: 'Classiques',
    description: '''Antienne mariale du XIe siècle chantée à la fin des complies et du chapelet.''',
    contenu: '''Salut, ô Reine, Mère de miséricorde,
notre vie, notre douceur et notre espérance, salut.
Nous crions vers vous, pauvres exilés, enfants d'Ève.
Nous soupirons vers vous, gémissant et pleurant
dans cette vallée de larmes.
Ô vous, notre avocate,
tournez vers nous vos yeux miséricordieux.
Et après cet exil, montrez-nous Jésus,
le fruit béni de vos entrailles.
Ô clémente, ô pieuse,
ô douce Vierge Marie.''',
    longueur: 2,
  ),

  Prayer(
    id: 'regina-caeli',
    titre: 'Regina Caeli (temps pascal)',
    categorie: 'Classiques',
    description: '''Antienne de Pâques qui remplace le Salve Regina pendant tout le Temps pascal.''',
    contenu: '''Reine du ciel, réjouissez-vous, alléluia,
car Celui que vous avez mérité de porter, alléluia,
est ressuscité comme il l'avait dit, alléluia.
Priez Dieu pour nous, alléluia.

V. Réjouissez-vous et soyez dans l'allégresse, Vierge Marie, alléluia.
R. Car le Seigneur est vraiment ressuscité, alléluia.

Prions.
Ô Dieu, qui avez bien voulu réjouir le monde
par la Résurrection de votre Fils Notre-Seigneur Jésus-Christ,
faites, nous vous en prions,
que par sa Mère la Vierge Marie,
nous obtenions les joies de la vie éternelle.
Par le même Jésus-Christ, notre Seigneur.

Amen.

──────────────
Remplace le Salve Regina du dimanche de Pâques au dimanche de Pentecôte.''',
    longueur: 2,
  ),

  Prayer(
    id: 'angelus',
    titre: 'Angélus',
    categorie: 'Classiques',
    description: '''Prière méditant l'Annonciation, récitée trois fois par jour au son des cloches (6h, 12h, 18h).''',
    contenu: '''V. L'Ange du Seigneur porta l'annonce à Marie.
R. Et elle conçut du Saint-Esprit.

Je vous salue Marie...

V. Voici la servante du Seigneur.
R. Qu'il me soit fait selon votre parole.

Je vous salue Marie...

V. Et le Verbe s'est fait chair.
R. Et il a habité parmi nous.

Je vous salue Marie...

V. Priez pour nous, sainte Mère de Dieu.
R. Afin que nous devenions dignes des promesses de Jésus-Christ.

Prions.
Répandez, Seigneur, votre grâce dans nos âmes,
afin qu'ayant connu par le message de l'Ange
l'Incarnation de votre Fils Jésus-Christ,
nous arrivions par sa Passion et sa Croix
à la gloire de la Résurrection.
Par Jésus-Christ, notre Seigneur.

Amen.

Gloire au Père...

──────────────
Prière traditionnellement récitée à 7h, 12h et 19h.''',
    longueur: 5,
  ),

  Prayer(
    id: 'memorare',
    titre: 'Memorare',
    categorie: 'Classiques',
    description: '''Prière de confiance en l'intercession de Marie. Commence par : Souvenez-vous, ô très miséricordieuse Vierge Marie…''',
    contenu: '''Souvenez-vous, ô très miséricordieuse Vierge Marie,
qu'on n'a jamais entendu dire
qu'aucun de ceux qui ont eu recours à votre protection,
imploré votre assistance
ou réclamé votre intercession
ait été abandonné.

Animé d'une telle confiance,
je viens à vous, ô Vierge des vierges, ma Mère.
Je viens à vous et, gémissant sous le poids de mes péchés,
je me prosterne à vos pieds.

Ô Mère du Verbe incarné,
ne méprisez pas mes prières,
mais daignez les écouter favorablement et les exaucer.

Amen.

──────────────
Prière attribuée à saint Bernard de Clairvaux (XIIe siècle).''',
    longueur: 2,
  ),

  Prayer(
    id: 'sub-tuum',
    titre: 'Sub Tuum Praesidium',
    categorie: 'Classiques',
    description: '''La plus ancienne prière à Marie connue, retrouvée sur un papyrus copte du IIIe siècle.''',
    contenu: '''Sous l'abri de ta miséricorde,
nous nous réfugions, sainte Mère de Dieu.
Ne méprise pas nos prières
quand nous sommes dans l'épreuve,
mais de tout danger délivre-nous toujours,
Vierge glorieuse et bénie.

──────────────
La plus ancienne prière mariale connue (~IIIe siècle).
Retrouvée sur un papyrus égyptien conservé à Manchester.''',
    longueur: 1,
  ),

  Prayer(
    id: 'te-deum',
    titre: 'Te Deum',
    categorie: 'Classiques',
    description: '''Grand hymne de louange et d'action de grâces chanté aux grandes fêtes liturgiques de l'Église.''',
    contenu: '''Nous te louons, ô Dieu, nous te proclamons Seigneur.
Ô Père éternel, toute la terre t'adore.
À toi les anges et toutes les puissances des cieux,
les chérubins et les séraphins,
à toi sans cesse ils proclament :
Saint ! Saint ! Saint !
le Seigneur, le Dieu de l'univers !
Les cieux et la terre sont remplis de ta gloire.

Le chœur glorieux des apôtres,
la troupe des prophètes comblés de louanges,
la blanche armée des martyrs te chantent leur hymne.
Par toute la terre la sainte Église proclame ta gloire :
Père dont la majesté est infinie,
Fils vrai et unique, digne d'être adoré,
Esprit Saint dont le secours est réconfortant.

Toi, le Christ, tu es le Roi de gloire,
tu es le Fils éternel du Père.
Pour prendre la condition humaine afin de nous délivrer,
tu n'as pas craint le sein de la Vierge.
Tu as vaincu l'aiguillon de la mort
et tu as ouvert aux croyants le royaume des cieux.
Tu sièges à la droite de Dieu dans la gloire du Père.

Nous croyons que tu reviendras comme Juge.
Aussi nous t'en supplions,
viens en aide à tes serviteurs
que tu as rachetés de ton sang précieux.
Daigne les classer parmi tes saints dans la gloire éternelle.

Sauve ton peuple, Seigneur, bénis ton héritage.
Gouverne-les et porte-les jusqu'à toujours.
Nous bénissons ton nom jour après jour,
et nous louons ton nom à jamais.

Daigne en ce jour nous garder sans péché.
Aie pitié de nous, Seigneur, aie pitié de nous.
Que ta miséricorde, Seigneur, soit sur nous,
comme nous espérons en toi.
En toi, Seigneur, j'espère ;
je ne serai pas confondu éternellement.

──────────────
Hymne d'action de grâce attribué à saint Ambroise (IVe siècle).
Chanté aux grandes fêtes et actions de grâce.''',
    longueur: 5,
  ),

  // ══════════════════════════════════════════════════════
  // ROSAIRE
  // ══════════════════════════════════════════════════════

  Prayer(
    id: 'mysteres-joyeux',
    titre: 'Mystères joyeux (lundi · samedi)',
    categorie: 'Rosaire',
    description: '''Cinq mystères méditant la naissance et l'enfance du Christ — récités le lundi et le samedi.''',
    contenu: '''1er mystère : L'Annonciation de l'Ange Gabriel à la Vierge Marie.
    Fruit du mystère : Humilité.

2e mystère : La Visitation de la Vierge Marie à sa cousine Élisabeth.
    Fruit du mystère : Charité fraternelle.

3e mystère : La Nativité de Notre-Seigneur Jésus-Christ.
    Fruit du mystère : Détachement des biens du monde.

4e mystère : La Présentation de l'Enfant Jésus au Temple.
    Fruit du mystère : Obéissance et pureté.

5e mystère : Le Recouvrement de l'Enfant Jésus au Temple.
    Fruit du mystère : Zèle pour la maison de Dieu.

──────────────
STRUCTURE DU CHAPELET

Début : Credo, Notre Père, 3 Je vous salue Marie, Gloire au Père.

Pour chaque mystère :
• Annoncer le mystère et méditer
• Notre Père
• 10 Je vous salue Marie (en méditant le mystère)
• Gloire au Père
• Ô mon Jésus (prière de Fatima) :
  « Ô mon Jésus, pardonnez-nous nos péchés,
   préservez-nous du feu de l'enfer,
   conduisez au ciel toutes les âmes,
   surtout celles qui ont le plus besoin de votre miséricorde. »

Fin : Salve Regina.''',
    longueur: 20,
  ),

  Prayer(
    id: 'mysteres-douloureux',
    titre: 'Mystères douloureux (mardi · vendredi)',
    categorie: 'Rosaire',
    description: '''Cinq mystères méditant la Passion et la mort du Christ — récités le mardi et le vendredi.''',
    contenu: '''1er mystère : L'Agonie de Notre-Seigneur au Jardin des Oliviers.
    Fruit du mystère : Contrition des péchés.

2e mystère : La Flagellation de Notre-Seigneur à la Colonne.
    Fruit du mystère : Mortification des sens.

3e mystère : Le Couronnement d'épines.
    Fruit du mystère : Mépris du monde.

4e mystère : Le Portement de la Croix.
    Fruit du mystère : Patience dans les souffrances.

5e mystère : La Crucifixion et la Mort de Notre-Seigneur.
    Fruit du mystère : Amour de la croix.

──────────────
STRUCTURE DU CHAPELET

Début : Credo, Notre Père, 3 Je vous salue Marie, Gloire au Père.

Pour chaque mystère :
• Annoncer le mystère et méditer
• Notre Père
• 10 Je vous salue Marie
• Gloire au Père
• Ô mon Jésus (prière de Fatima)

Fin : Salve Regina.''',
    longueur: 20,
  ),

  Prayer(
    id: 'mysteres-glorieux',
    titre: 'Mystères glorieux (mercredi · dimanche)',
    categorie: 'Rosaire',
    description: '''Cinq mystères sur la Résurrection et les gloires de Marie — récités le mercredi et le dimanche.''',
    contenu: '''1er mystère : La Résurrection de Notre-Seigneur.
    Fruit du mystère : Foi.

2e mystère : L'Ascension de Notre-Seigneur aux Cieux.
    Fruit du mystère : Désir du ciel.

3e mystère : La Descente du Saint-Esprit sur les Apôtres.
    Fruit du mystère : Dons du Saint-Esprit.

4e mystère : L'Assomption de la Vierge Marie.
    Fruit du mystère : Grâce d'une bonne mort.

5e mystère : Le Couronnement de la Vierge Marie.
    Fruit du mystère : Confiance en Marie.

──────────────
STRUCTURE DU CHAPELET

Début : Credo, Notre Père, 3 Je vous salue Marie, Gloire au Père.

Pour chaque mystère :
• Annoncer le mystère et méditer
• Notre Père
• 10 Je vous salue Marie
• Gloire au Père
• Ô mon Jésus (prière de Fatima)

Fin : Salve Regina.''',
    longueur: 20,
  ),

  Prayer(
    id: 'mysteres-lumineux',
    titre: 'Mystères lumineux (jeudi)',
    categorie: 'Rosaire',
    description: '''Cinq mystères sur le ministère public de Jésus, institués par Jean-Paul II en 2002 — récités le jeudi.''',
    contenu: '''Institués par saint Jean-Paul II en 2002
dans la lettre apostolique Rosarium Virginis Mariae.

1er mystère : Le Baptême de Jésus au Jourdain.
    Fruit du mystère : Ouverture à l'Esprit-Saint.

2e mystère : Les Noces de Cana.
    Fruit du mystère : Confiance en l'intercession de Marie.

3e mystère : L'Annonce du Royaume de Dieu.
    Fruit du mystère : Conversion et confiance en Dieu.

4e mystère : La Transfiguration.
    Fruit du mystère : Désir de la sainteté.

5e mystère : L'Institution de l'Eucharistie.
    Fruit du mystère : Amour de l'Eucharistie.

──────────────
STRUCTURE DU CHAPELET

Début : Credo, Notre Père, 3 Je vous salue Marie, Gloire au Père.

Pour chaque mystère :
• Annoncer le mystère et méditer
• Notre Père
• 10 Je vous salue Marie
• Gloire au Père
• Ô mon Jésus (prière de Fatima)

Fin : Salve Regina.''',
    longueur: 20,
  ),

  // ══════════════════════════════════════════════════════
  // LITANIES
  // ══════════════════════════════════════════════════════

  Prayer(
    id: 'litanies-vierge',
    titre: 'Litanies de la Sainte Vierge',
    categorie: 'Litanies',
    description: '''Invocation de Marie sous ses nombreux titres : Reine des anges, Tour d'ivoire, Étoile du matin…''',
    contenu: '''Seigneur, ayez pitié de nous.
Jésus-Christ, ayez pitié de nous.
Seigneur, ayez pitié de nous.

Jésus-Christ, écoutez-nous.
Jésus-Christ, exaucez-nous.

Sainte Marie, priez pour nous.
Sainte Mère de Dieu, priez pour nous.
Sainte Vierge des vierges, priez pour nous.
Mère du Christ, priez pour nous.
Mère de l'Église, priez pour nous.
Mère de la grâce divine, priez pour nous.
Mère très pure, priez pour nous.
Mère très chaste, priez pour nous.
Mère sans tache, priez pour nous.
Mère aimable, priez pour nous.
Mère admirable, priez pour nous.
Mère du Créateur, priez pour nous.
Mère du Sauveur, priez pour nous.

Vierge très prudente, priez pour nous.
Vierge digne de louanges, priez pour nous.
Vierge puissante, priez pour nous.
Vierge clémente, priez pour nous.
Vierge fidèle, priez pour nous.

Miroir de justice, priez pour nous.
Siège de la sagesse, priez pour nous.
Cause de notre joie, priez pour nous.
Vase spirituel, priez pour nous.
Vase honorable, priez pour nous.
Vase insigne de dévotion, priez pour nous.
Rose mystique, priez pour nous.
Tour de David, priez pour nous.
Tour d'ivoire, priez pour nous.
Maison d'or, priez pour nous.
Arche d'alliance, priez pour nous.
Porte du ciel, priez pour nous.
Étoile du matin, priez pour nous.
Salut des infirmes, priez pour nous.
Refuge des pécheurs, priez pour nous.
Consolatrice des affligés, priez pour nous.
Secours des chrétiens, priez pour nous.

Reine des Anges, priez pour nous.
Reine des Patriarches, priez pour nous.
Reine des Prophètes, priez pour nous.
Reine des Apôtres, priez pour nous.
Reine des Martyrs, priez pour nous.
Reine des Confesseurs, priez pour nous.
Reine des Vierges, priez pour nous.
Reine de tous les Saints, priez pour nous.
Reine conçue sans péché originel, priez pour nous.
Reine élevée aux cieux, priez pour nous.
Reine du très saint Rosaire, priez pour nous.
Reine de la famille, priez pour nous.
Reine de la paix, priez pour nous.

Agneau de Dieu, qui ôtez les péchés du monde,
pardonnez-nous, Seigneur.
Agneau de Dieu, qui ôtez les péchés du monde,
exaucez-nous, Seigneur.
Agneau de Dieu, qui ôtez les péchés du monde,
ayez pitié de nous.

V. Priez pour nous, sainte Mère de Dieu.
R. Afin que nous devenions dignes des promesses de Jésus-Christ.

Prions.
Seigneur Dieu, nous vous supplions de nous accorder,
à nous vos serviteurs, de jouir d'une santé continuelle de l'âme et du corps ;
et, par la glorieuse intercession de la bienheureuse Marie toujours Vierge,
d'être délivrés de la tristesse de la vie présente
et de jouir des joies éternelles.
Par Jésus-Christ, notre Seigneur. Amen.''',
    longueur: 10,
  ),

  Prayer(
    id: 'litanies-sacre-coeur',
    titre: 'Litanies du Sacré-Cœur',
    categorie: 'Litanies',
    description: '''Série d'invocations au Cœur de Jésus, symbole de son amour infini pour l'humanité.''',
    contenu: '''Seigneur, ayez pitié de nous.
Jésus-Christ, ayez pitié de nous.
Seigneur, ayez pitié de nous.

Cœur de Jésus, Fils du Père éternel, ayez pitié de nous.
Cœur de Jésus, formé par l'Esprit-Saint dans le sein de la Vierge Mère, ayez pitié de nous.
Cœur de Jésus, uni substantiellement au Verbe de Dieu, ayez pitié de nous.
Cœur de Jésus, d'une majesté infinie, ayez pitié de nous.
Cœur de Jésus, temple saint de Dieu, ayez pitié de nous.
Cœur de Jésus, tabernacle du Très-Haut, ayez pitié de nous.
Cœur de Jésus, maison de Dieu et porte du ciel, ayez pitié de nous.
Cœur de Jésus, brûlant d'amour pour nous, ayez pitié de nous.
Cœur de Jésus, abîme de toutes les vertus, ayez pitié de nous.
Cœur de Jésus, très digne de toutes louanges, ayez pitié de nous.
Cœur de Jésus, roi et centre de tous les cœurs, ayez pitié de nous.
Cœur de Jésus, en qui se trouvent tous les trésors de la sagesse et de la science, ayez pitié de nous.
Cœur de Jésus, en qui habite toute la plénitude de la divinité, ayez pitié de nous.
Cœur de Jésus, source de toute joie et de toute sainteté, ayez pitié de nous.
Cœur de Jésus, propitiation pour nos péchés, ayez pitié de nous.
Cœur de Jésus, abreuvé d'opprobres, ayez pitié de nous.
Cœur de Jésus, brisé pour nos crimes, ayez pitié de nous.
Cœur de Jésus, obéissant jusqu'à la mort, ayez pitié de nous.
Cœur de Jésus, percé d'une lance, ayez pitié de nous.
Cœur de Jésus, source de toute consolation, ayez pitié de nous.
Cœur de Jésus, notre vie et notre résurrection, ayez pitié de nous.
Cœur de Jésus, notre paix et notre réconciliation, ayez pitié de nous.
Cœur de Jésus, victime pour les pécheurs, ayez pitié de nous.
Cœur de Jésus, salut de ceux qui espèrent en vous, ayez pitié de nous.
Cœur de Jésus, espérance de ceux qui meurent en vous, ayez pitié de nous.
Cœur de Jésus, délices de tous les saints, ayez pitié de nous.

Agneau de Dieu, qui ôtez les péchés du monde,
pardonnez-nous, Seigneur.
Agneau de Dieu, qui ôtez les péchés du monde,
exaucez-nous, Seigneur.
Agneau de Dieu, qui ôtez les péchés du monde,
ayez pitié de nous.

V. Jésus, doux et humble de cœur.
R. Rendez notre cœur semblable au vôtre.

Prions.
Dieu tout-puissant et éternel,
regardez le Cœur de votre Fils bien-aimé
et les louanges et les satisfactions
qu'il vous offre au nom des pécheurs.
Apaisez votre colère,
pardonnez-nous nos péchés,
et dans votre miséricorde,
exaucez-nous lorsque nous vous invoquons.
Par le même Jésus-Christ, votre Fils, notre Seigneur. Amen.''',
    longueur: 10,
  ),

  Prayer(
    id: 'litanies-saint-joseph',
    titre: 'Litanies de saint Joseph',
    categorie: 'Litanies',
    description: '''Invocations à saint Joseph, père nourricier de Jésus et patron de l'Église universelle.''',
    contenu: '''Seigneur, ayez pitié de nous.
Jésus-Christ, ayez pitié de nous.
Seigneur, ayez pitié de nous.

Saint Joseph, priez pour nous.
Illustre descendant de David, priez pour nous.
Lumière des patriarches, priez pour nous.
Époux de la Mère de Dieu, priez pour nous.
Gardien chaste de la Vierge, priez pour nous.
Nourricier du Fils de Dieu, priez pour nous.
Gardien vigilant du Christ, priez pour nous.
Chef de la Sainte Famille, priez pour nous.
Joseph très juste, priez pour nous.
Joseph très chaste, priez pour nous.
Joseph très prudent, priez pour nous.
Joseph très fort, priez pour nous.
Joseph très obéissant, priez pour nous.
Joseph très fidèle, priez pour nous.
Miroir de patience, priez pour nous.
Ami de la pauvreté, priez pour nous.
Modèle des artisans, priez pour nous.
Gloire de la vie de famille, priez pour nous.
Gardien des vierges, priez pour nous.
Soutien des familles, priez pour nous.
Consolation des malheureux, priez pour nous.
Espérance des malades, priez pour nous.
Patron des mourants, priez pour nous.
Terreur des démons, priez pour nous.
Protecteur de la sainte Église, priez pour nous.

Agneau de Dieu, qui ôtez les péchés du monde,
pardonnez-nous, Seigneur.
Agneau de Dieu, qui ôtez les péchés du monde,
exaucez-nous, Seigneur.
Agneau de Dieu, qui ôtez les péchés du monde,
ayez pitié de nous.

V. Il lui a donné la charge de toute sa maison.
R. Et de lui confier la garde de tous ses biens.

Prions.
Ô Dieu, qui dans votre providence ineffable
avez daigné choisir saint Joseph
pour être l'époux de votre très sainte Mère,
faites que celui que nous vénérons sur la terre comme notre protecteur
soit notre intercesseur dans les cieux.
Par le même Jésus-Christ, notre Seigneur. Amen.''',
    longueur: 10,
  ),

  Prayer(
    id: 'litanies-saints',
    titre: 'Litanies des Saints',
    categorie: 'Litanies',
    description: '''La grande prière de l'Église qui convoque tous les saints du ciel à notre secours.''',
    contenu: '''Seigneur, ayez pitié de nous.
Jésus-Christ, ayez pitié de nous.
Seigneur, ayez pitié de nous.

Sainte Marie, priez pour nous.
Saint Michel, priez pour nous.
Saints anges de Dieu, priez pour nous.

Saint Jean-Baptiste, priez pour nous.
Saint Joseph, priez pour nous.

Saints Pierre et Paul, priez pour nous.
Saint André, priez pour nous.
Saint Jean, priez pour nous.
Sainte Marie-Madeleine, priez pour nous.
Saint Étienne, priez pour nous.

Saint Grégoire, priez pour nous.
Saint Augustin, priez pour nous.
Saint Athanase, priez pour nous.
Saint Basile, priez pour nous.
Saint Martin de Tours, priez pour nous.
Saint Benoît, priez pour nous.
Saints François et Dominique, priez pour nous.
Saint François-Xavier, priez pour nous.
Saint Jean Vianney, priez pour nous.
Sainte Catherine de Sienne, priez pour nous.
Sainte Thérèse d'Avila, priez pour nous.
Sainte Thérèse de l'Enfant-Jésus, priez pour nous.
Saint Jean-Paul II, priez pour nous.

Tous les saints et saintes de Dieu,
intercédez pour nous.

De tout mal, délivrez-nous, Seigneur.
De tout péché, délivrez-nous, Seigneur.
De la mort éternelle, délivrez-nous, Seigneur.

Par votre Incarnation, délivrez-nous, Seigneur.
Par votre Nativité, délivrez-nous, Seigneur.
Par votre Passion et votre Croix, délivrez-nous, Seigneur.
Par votre mort et votre sépulture, délivrez-nous, Seigneur.
Par votre Résurrection, délivrez-nous, Seigneur.
Par votre Ascension, délivrez-nous, Seigneur.
Par la venue du Saint-Esprit, délivrez-nous, Seigneur.

Agneau de Dieu, qui ôtez les péchés du monde,
pardonnez-nous, Seigneur.
Agneau de Dieu, qui ôtez les péchés du monde,
exaucez-nous, Seigneur.
Agneau de Dieu, qui ôtez les péchés du monde,
ayez pitié de nous.

Seigneur, exaucez ma prière.
Et que mon cri parvienne jusqu'à vous.
Amen.''',
    longueur: 10,
  ),

  // ══════════════════════════════════════════════════════
  // PRIÈRES DES SAINTS
  // ══════════════════════════════════════════════════════

  Prayer(
    id: 'priere-saint-joseph',
    titre: 'Prière à saint Joseph',
    categorie: 'Prières des Saints',
    description: '''Prière de protection à saint Joseph, patron des pères, des artisans et de la bonne mort.''',
    contenu: '''Ô bienheureux saint Joseph,
à vous qui avez été donné comme gardien
et père du Seigneur Jésus-Christ
et époux de la Vierge Marie,
je m'adresse avec confiance.

Vous qui avez protégé Jésus dans son enfance,
protégez-moi tout au long de ma vie.
Intercédez pour moi auprès de votre Fils,
Jésus-Christ notre Seigneur,
afin qu'il m'accorde les grâces
dont j'ai le plus besoin.

Défendez ma famille, mon foyer,
et tous ceux que j'aime.
Dans les difficultés de la vie,
soyez mon soutien et mon guide.

Saint Joseph, patron des mourants,
assistez-moi à l'heure de ma mort,
afin que je puisse passer de cette vie
à la vie éternelle.

Amen.''',
    longueur: 3,
  ),

  Prayer(
    id: 'priere-ange-gardien',
    titre: 'Prière à l\'Ange gardien',
    categorie: 'Prières des Saints',
    description: '''Chaque baptisé a un ange gardien. Cette prière lui demande protection et guidance au quotidien.''',
    contenu: '''Ange de Dieu, qui êtes mon gardien,
éclairez, gardez, gouvernez et conduisez
ce que votre bonté céleste m'a confié.

Montrez-moi le chemin du bien,
préservez-moi du mal,
soutenez-moi dans les épreuves
et guidez mes pas vers Dieu.

Amen.''',
    longueur: 1,
  ),

  Prayer(
    id: 'priere-saint-michel',
    titre: 'Prière à saint Michel Archange',
    categorie: 'Prières des Saints',
    description: '''Prière contre le mal composée par Léon XIII en 1886. Parfois récitée à la fin de certaines messes.''',
    contenu: '''Saint Michel Archange,
défendez-nous dans le combat ;
soyez notre protecteur contre la malice
et les embûches du démon.

Que Dieu lui commande, nous vous en supplions ;
et vous, prince de la milice céleste,
précipitez en enfer, par la puissance divine,
Satan et les autres esprits mauvais
qui rôdent dans le monde pour la perte des âmes.

Amen.

──────────────
Prière ordonnée par Léon XIII en 1886 après une vision.
Traditionnellement récitée à la fin de la messe basse.''',
    longueur: 2,
  ),

  Prayer(
    id: 'priere-sainte-therese',
    titre: 'Prière de sainte Thérèse de Lisieux',
    categorie: 'Prières des Saints',
    description: '''La petite voie de Thérèse de Lisieux, docteure de l'Église : confiance et abandon à Dieu.''',
    contenu: '''Seigneur, tu le sais, je t'aime.
Je sais que tu peux tout,
et tu n'attends pour me combler de tes grâces
que l'humilité de ma demande.

Je ne te demande pas de grandes choses,
mais de te laisser aimer par moi,
aussi petite et imparfaite que je suis.

Jésus, je te demande de ne jamais
me laisser être séparée de toi.
Que ma vie soit un acte d'amour ininterrompu
jusqu'à ce que l'amour soit parfait dans le ciel.

Amen.

──────────────
Sainte Thérèse de Lisieux (1873–1897),
docteur de l'Église, patronne des missions.
Fête le 1er octobre.''',
    longueur: 2,
  ),

  Prayer(
    id: 'priere-saint-francois',
    titre: 'Prière de saint François d\'Assise',
    categorie: 'Prières des Saints',
    description: '''Seigneur, fais de moi un instrument de ta paix. L'une des prières les plus aimées au monde.''',
    contenu: '''Seigneur, fais de moi un instrument de ta paix.
Là où est la haine, que je mette l'amour.
Là où est l'offense, que je mette le pardon.
Là où est la discorde, que je mette l'union.
Là où est l'erreur, que je mette la vérité.
Là où est le doute, que je mette la foi.
Là où est le désespoir, que je mette l'espérance.
Là où sont les ténèbres, que je mette ta lumière.
Là où est la tristesse, que je mette la joie.

Ô Maître, que je ne cherche pas tant
à être consolé qu'à consoler,
à être compris qu'à comprendre,
à être aimé qu'à aimer.

Car c'est en donnant que l'on reçoit,
c'est en s'oubliant que l'on trouve,
c'est en pardonnant que l'on est pardonné,
c'est en mourant que l'on ressuscite à l'éternelle vie.

Amen.''',
    longueur: 3,
  ),

  Prayer(
    id: 'suscipe-saint-ignace',
    titre: 'Suscipe (saint Ignace de Loyola)',
    categorie: 'Prières des Saints',
    description: '''Offrande totale à Dieu, cœur des Exercices Spirituels d'Ignace de Loyola.''',
    contenu: '''Prends, Seigneur, et reçois
toute ma liberté, ma mémoire,
mon intelligence et toute ma volonté.

Tout ce que j'ai et possède,
tu me l'as donné ;
je te le rends, Seigneur,
et te le remets entièrement
pour être gouverné par ta volonté.

Donne-moi seulement ton amour
avec ta grâce,
et je suis assez riche
et ne demande rien de plus.

Amen.

──────────────
Prière de l'abandon total, tirée des Exercices Spirituels
de saint Ignace de Loyola (1491–1556),
fondateur de la Compagnie de Jésus.''',
    longueur: 2,
  ),

  Prayer(
    id: 'priere-saint-augustin',
    titre: 'Prière de saint Augustin',
    categorie: 'Prières des Saints',
    description: '''Notre cœur est sans repos jusqu'à ce qu'il trouve son repos en toi. Un texte d'une profondeur saisissante.''',
    contenu: '''Notre cœur est sans repos
jusqu'à ce qu'il se repose en toi.

Toi qui nous as faits pour toi, Seigneur,
tout notre être aspire à te rejoindre.
Tu nous appelles vers toi
et notre âme est agitée
tant qu'elle ne repose en toi.

Tard je t'ai aimé,
beauté si ancienne et si nouvelle.
Tard je t'ai aimé.

Tu étais au-dedans de moi
et j'étais moi-même en dehors de moi.
Tu m'appelais, tu criais,
et tu as brisé ma surdité.
Tu brillais, tu rayonnais,
et tu as mis en fuite ma cécité.

Amen.

──────────────
Extrait des Confessions de saint Augustin,
évêque d'Hippone (354–430), docteur de l'Église.''',
    longueur: 3,
  ),

  Prayer(
    id: 'priere-thomas-aquin',
    titre: 'Prière avant l\'étude (saint Thomas d\'Aquin)',
    categorie: 'Prières des Saints',
    description: '''Prière pour demander la sagesse, composée par le plus grand théologien du Moyen Âge.''',
    contenu: '''Créateur ineffable,
qui de vos trésors de sagesse
avez constitué trois hiérarchies d'anges
et les avez placées dans un ordre admirable,
vous qui êtes appelé la vraie source de la lumière
et de la suprême sagesse :

Veuillez répandre sur les ténèbres de mon intelligence
un rayon de votre clarté,
et éloigner de moi les doubles ténèbres
dans lesquelles je suis né :
le péché et l'ignorance.

Vous qui rendez éloquente la langue des enfants,
instruisez ma langue
et répandez sur mes lèvres la grâce de votre bénédiction.

Donnez-moi la pénétration pour comprendre,
la capacité pour retenir,
la méthode et la facilité pour apprendre,
la subtilité pour interpréter
et la grâce abondante pour parler.

Guidez le début de mon travail,
dirigez son progrès
et menez-le à bonne fin.

Amen.

──────────────
Saint Thomas d'Aquin (1225–1274),
docteur de l'Église, patron des universités et des étudiants.''',
    longueur: 3,
  ),

  Prayer(
    id: 'priere-sainte-bernadette',
    titre: 'Prière à sainte Bernadette',
    categorie: 'Prières des Saints',
    description: '''Prière de confiance et d'abandon composée par la voyante de Lourdes.''',
    contenu: '''Sainte Bernadette,
vous qui avez vu la Vierge Marie
dans la grotte de Massabielle à Lourdes,
vous qui avez gardé le secret dans votre cœur,
vous qui n'avez cherché que la prière,
la pénitence et l'humilité,

Intercédez pour nous auprès de Notre-Dame de Lourdes.
Obtenez pour nous la grâce de la foi simple
et de l'abandon confiant à la volonté de Dieu.

Dans nos souffrances physiques, morales ou spirituelles,
aidez-nous à ne jamais perdre l'espérance.
Priez pour les malades, les faibles,
ceux qui doutent et ceux qui souffrent.

Sainte Bernadette, priez pour nous.
Amen.

──────────────
Sainte Bernadette Soubirous (1844–1879).
Apparitions de Lourdes : du 11 février au 16 juillet 1858.
Fête le 16 avril.''',
    longueur: 3,
  ),

  Prayer(
    id: 'priere-saint-antoine',
    titre: 'Prière à saint Antoine de Padoue',
    categorie: 'Prières des Saints',
    description: '''Le saint patron des objets perdus, invoqué pour retrouver ce que l'on cherche.''',
    contenu: '''Saint Antoine de Padoue,
vous qui avez reçu de Dieu le don des miracles,
vous qui avec la bonté du cœur d'un père
venez en aide à ceux qui vous implorent,

Écoutez ma prière.
Vous qui avez parcouru les routes du monde
pour annoncer l'Évangile,
guidez mes pas.

Vous qui avez le don de retrouver les choses perdues,
aidez-moi à retrouver ce qui m'a été enlevé
— et par-dessus tout,
aidez-moi à ne jamais perdre la foi,
l'espérance et l'amour de Dieu.

Saint Antoine, priez pour nous.
Amen.

──────────────
Saint Antoine de Padoue (1195–1231),
franciscain, docteur de l'Église.
Fête le 13 juin.''',
    longueur: 2,
  ),

  Prayer(
    id: 'priere-sainte-rita',
    titre: 'Prière à sainte Rita',
    categorie: 'Prières des Saints',
    description: '''Patronne des causes désespérées. À prier quand une situation paraît sans issue humaine.''',
    contenu: '''Sainte Rita,
patronne des causes désespérées,
vous qui avez souffert dans votre vie
les plus grandes épreuves
avec patience et résignation,

Je vous implore avec confiance
pour cette situation que je vis
et qui me semble sans issue.

Vous qui avez reçu de Dieu
la grâce de n'avoir jamais été rejetée
dans vos demandes légitimes,
intercédez pour moi en ce moment difficile.

Donnez-moi la force d'accepter la volonté de Dieu,
la sagesse de discerner ce qui est bon pour moi,
et la grâce d'obtenir ce que je demande
si cela est conforme à sa volonté.

Sainte Rita, priez pour nous.
Amen.

──────────────
Sainte Rita de Cascia (1381–1457), augustinienne.
Fête le 22 mai.''',
    longueur: 3,
  ),

  Prayer(
    id: 'chapelet-divine-misericorde',
    titre: 'Chapelet de la Divine Miséricorde',
    categorie: 'Prières des Saints',
    description: '''Révélé à sainte Faustine. Se récite de préférence à 15h, heure de la mort du Christ.''',
    contenu: '''Chapelet révélé à sainte Faustine Kowalska, Cracovie 1935.
Se récite sur les grains du chapelet ordinaire.

──────────────
DÉBUT

Notre Père...
Je vous salue Marie... (3 fois)
Je crois en Dieu...

──────────────
SUR LES GRANDES PERLES (5 fois)

Père éternel,
j'offre à votre Très Miséricordieux Amour
le Corps et le Sang, l'Âme et la Divinité
de votre Fils bien-aimé,
Notre-Seigneur Jésus-Christ,
en expiation de nos péchés
et de ceux du monde entier.

──────────────
SUR LES PETITES PERLES (10 fois par dizaine)

Pour sa douloureuse Passion,
ayez pitié de nous et du monde entier.

──────────────
CONCLUSION (3 fois)

Saint Dieu,
Saint Tout-Puissant,
Saint Immortel,
ayez pitié de nous et du monde entier.

──────────────
Fête de la Divine Miséricorde : 2e dimanche de Pâques.
Instituée par saint Jean-Paul II en 2000.''',
    longueur: 15,
  ),

  Prayer(
    id: 'priere-saint-jacques',
    titre: 'Prière à saint Jacques (pèlerins)',
    categorie: 'Prières des Saints',
    description: '''Prière pour les pèlerins, particulièrement ceux qui cheminent vers Saint-Jacques-de-Compostelle.''',
    contenu: '''Ô saint Jacques,
apôtre du Seigneur,
qui avez parcouru les chemins du monde
pour annoncer l'Évangile de Jésus-Christ,

Bénissez tous ceux qui s'engagent
sur les chemins de Compostelle.
Qu'ils marchent dans la foi,
portés par l'espérance,
réchauffés par la charité.

Protégez-les sur la route,
éclairez leurs nuits,
consolez leurs fatigues.
Que ce pèlerinage soit pour eux
une expérience de conversion et de grâce.

Et au terme du chemin,
comme vous l'avez fait,
qu'ils rendent gloire à Dieu.

Saint Jacques, priez pour nous.
Amen.

──────────────
Saint Jacques le Majeur, apôtre, fils de Zébédée.
Martyrisé en 44 à Jérusalem.
Fête le 25 juillet. Son tombeau : Santiago de Compostela.''',
    longueur: 2,
  ),

  // ══════════════════════════════════════════════════════
  // NOVÈNES
  // ══════════════════════════════════════════════════════

  Prayer(
    id: 'novene-saint-joseph',
    titre: 'Novène à saint Joseph',
    categorie: 'Novènes',
    description: '''Neuf jours de prière à saint Joseph pour des intentions familiales, professionnelles ou de discernement.''',
    contenu: '''Novène : 9 jours consécutifs de prière.
Particulièrement récitée avant le 19 mars (fête de saint Joseph).

──────────────

Ô saint Joseph,
dont la protection est si grande, si puissante,
si prompte devant le Trône de Dieu,
je vous confie mes peines et mes désirs.

Ô saint Joseph, assistez-moi par votre puissante intercession
et obtenez en retour de votre Divin Fils
tout ce qui est nécessaire pour que mes demandes,
si elles sont en accord avec la Volonté Adorable de Dieu,
se réalisent.

En échange de vos bontés paternelles envers moi,
je désirerais pouvoir vous offrir
quelque grande offrande digne de vous,
mais je ne vous donnerai que mon cœur
et toute mon affection pour ne jamais oublier
ce que vous avez fait pour moi,
et pour vous honorer toujours comme mon père
et mon protecteur.

Amen.

──────────────
INTENTION DU JOUR :
Nommez votre intention dans votre cœur avant chaque récitation.''',
    longueur: 5,
  ),

  Prayer(
    id: 'novene-esprit-saint',
    titre: 'Novène à l\'Esprit Saint',
    categorie: 'Novènes',
    description: '''Prière de neuf jours entre l'Ascension et la Pentecôte, dans l'attente de l'Esprit Paraclet.''',
    contenu: '''À prier du lendemain de l'Ascension
jusqu'à la veille de la Pentecôte (9 jours).
C'est la novène originelle : les Apôtres et Marie ont prié 9 jours au Cénacle.

──────────────

Viens, Esprit-Saint, remplis les cœurs de tes fidèles
et allume en eux le feu de ton amour.

V. Envoyez votre Esprit et toutes choses seront créées.
R. Et vous renouvellerez la face de la terre.

Prions.
Ô Dieu qui avez instruit les cœurs de vos fidèles
par la lumière du Saint-Esprit,
donnez-nous de savoir ce qui est bien par ce même Esprit,
et de jouir toujours de ses consolations.
Par Jésus-Christ, notre Seigneur.
Amen.

──────────────

Esprit d'amour, viens habiter en moi.
Esprit de sagesse, éclaire mon intelligence.
Esprit de conseil, guide mes décisions.
Esprit de force, soutiens ma faiblesse.
Esprit de science, fais que je te connaisse.
Esprit de piété, allume ma prière.
Esprit de crainte de Dieu, purifie mon cœur.

Viens, Esprit-Saint !

──────────────
LES 7 DONS DE L'ESPRIT-SAINT
Sagesse · Intelligence · Conseil · Force
Science · Piété · Crainte de Dieu''',
    longueur: 5,
  ),

  Prayer(
    id: 'novene-notre-dame',
    titre: 'Novène à Notre-Dame',
    categorie: 'Novènes',
    description: '''Neuf jours confiés à la Vierge Marie pour une intention particulière.''',
    contenu: '''Prière pour 9 jours consécutifs.
Particulièrement fervente avant une fête mariale.

──────────────

Ô Marie, conçue sans péché,
priez pour nous qui avons recours à vous.

Notre-Dame, je vous confie cette intention :
[Nommez votre intention dans votre cœur]

Vous qui avez dit à Cana :
« Faites tout ce qu'il vous dira »,
intercédez pour moi auprès de votre Fils Jésus.

Je vous fais confiance, Marie.
Vous êtes ma Mère du ciel.
Portez ma prière au Seigneur.

Sous votre protection, nous cherchons refuge,
sainte Mère de Dieu.
Ne méprisez pas nos supplications
dans nos nécessités,
mais de tout danger délivrez-nous toujours,
Vierge glorieuse et bénie.

Amen.''',
    longueur: 5,
  ),

  Prayer(
    id: 'novene-saint-jude',
    titre: 'Novène à saint Jude Thaddée',
    categorie: 'Novènes',
    description: '''Saint patron des causes désespérées. À prier quand une situation humaine semble impossible.''',
    contenu: '''Saint Jude Thaddée est le patron des causes désespérées.
Prière pour 9 jours consécutifs.

──────────────

Glorieux apôtre saint Jude Thaddée,
fidèle serviteur et ami de Jésus,
je viens à vous pour implorer votre aide
dans ma nécessité présente.

[Nommez votre intention]

Ô bienheureux saint Jude,
l'Église vous honore et vous invoque
comme le patron des causes désespérées.
Venez à mon aide dans ma grande détresse.

Je vous promets, ô bienheureux saint Jude,
d'honorer votre souvenir avec gratitude
et de faire connaître votre intercession
à ceux qui sont dans le besoin.

Faites usage de ce privilège spécial
accordé à vous de porter aide visible et prompte
là où l'aide est presque désespérée.

Amen.

──────────────
Saint Jude Thaddée, apôtre.
Fête le 28 octobre (avec saint Simon).''',
    longueur: 5,
  ),

  Prayer(
    id: 'novene-divine-misericorde',
    titre: 'Novène de la Divine Miséricorde',
    categorie: 'Novènes',
    description: '''Dictée par Jésus à sainte Faustine, récitée du Vendredi Saint à la fête de la Divine Miséricorde.''',
    contenu: '''Novène dictée par Jésus à sainte Faustine Kowalska.
À prier du Vendredi Saint au samedi avant la fête de la Divine Miséricorde
(2e dimanche de Pâques).

Chaque jour : réciter le Chapelet de la Divine Miséricorde
+ méditation du jour.

──────────────

JOUR 1 — Toute l'humanité, surtout les pécheurs.
JOUR 2 — Les prêtres et les religieux.
JOUR 3 — Les âmes dévotes et fidèles.
JOUR 4 — Les non-croyants et ceux qui ne connaissent pas Jésus.
JOUR 5 — Les hérétiques et les schismatiques.
JOUR 6 — Les âmes douces et humbles, et les enfants.
JOUR 7 — Ceux qui honorent et propagent la Miséricorde divine.
JOUR 8 — Les âmes du Purgatoire.
JOUR 9 — Les âmes tièdes.

──────────────

Prière de chaque jour :
Père éternel,
j'offre à votre Très Miséricordieux Amour
le Corps et le Sang, l'Âme et la Divinité
de votre Fils bien-aimé Notre-Seigneur Jésus-Christ,
en expiation de nos péchés
et de ceux du monde entier.
Pour sa douloureuse Passion,
ayez pitié de nous et du monde entier.

Amen.''',
    longueur: 5,
  ),

  // ══════════════════════════════════════════════════════
  // OFFICE DIVIN
  // ══════════════════════════════════════════════════════

  Prayer(
    id: 'priere-matin',
    titre: 'Prière du matin',
    categorie: 'Office Divin',
    description: '''Consacrer sa journée à Dieu dès le réveil. Quelques minutes qui peuvent transformer toute la journée.''',
    contenu: '''Seigneur Dieu tout-puissant,
qui nous avez fait parvenir au commencement de ce jour,
sauvez-nous en ce jour par votre puissance
afin que nous ne tombions dans aucun péché,
mais que toutes nos paroles tendent vers votre justice,
et que toutes nos pensées et nos actions
soient conduites selon vos commandements.

Que votre lumière brille sur nos pas aujourd'hui.
Guidez nos pensées, nos paroles et nos actes
selon votre sainte volonté.

Par Jésus-Christ, notre Seigneur. Amen.''',
    longueur: 2,
  ),

  Prayer(
    id: 'laudes',
    titre: 'Laudes — Prière des Heures du matin',
    categorie: 'Office Divin',
    description: '''L'office du matin de l'Église. Psaumes, hymnes et lectures pour accueillir le jour nouveau avec Dieu.''',
    contenu: '''Dieu, viens à mon aide.
Seigneur, à notre secours.
Gloire au Père, au Fils et au Saint-Esprit,
comme il était au commencement,
maintenant et toujours, dans les siècles des siècles. Amen.

──────────────
HYMNE

Le soleil se lève sur ce jour que tu nous donnes.
Chaque matin est une résurrection,
une nouvelle naissance à ta grâce.
Que ce jour soit consacré à ta gloire.

Éveille mon cœur à ta louange,
ouvre mes lèvres à ta prière,
que toutes mes actions d'aujourd'hui
rayonnent de ta présence.

──────────────
PSAUME 63

Ô Dieu, tu es mon Dieu, je te cherche dès l'aurore ;
mon âme a soif de toi ;
après toi languit ma chair,
terre aride, altérée, sans eau.

C'est ainsi que je t'ai contemplé au sanctuaire,
voyant ta puissance et ta gloire.
Ton amour vaut mieux que la vie ;
mes lèvres diront ta louange.

Toute ma vie je veux te bénir,
lever les mains en invoquant ton nom.

──────────────
INTERCESSIONS DU MATIN

Seigneur, bénis ce jour qui commence.
— Que ta volonté soit faite.

Garde-moi de tout péché.
— Que ta grâce m'accompagne.

──────────────
BÉNÉDICTION FINALE

Que le Seigneur nous bénisse et nous garde.
Qu'il fasse briller son visage sur nous et nous soit favorable.
Qu'il nous montre son visage et nous donne la paix.
Amen.''',
    longueur: 10,
  ),

  Prayer(
    id: 'vepres',
    titre: 'Vêpres — Prière des Heures du soir',
    categorie: 'Office Divin',
    description: '''L'office du soir. Rendre grâce à Dieu pour la journée passée et se confier à lui pour la nuit.''',
    contenu: '''Dieu, viens à mon aide.
Seigneur, à notre secours.
Gloire au Père, au Fils et au Saint-Esprit,
comme il était au commencement,
maintenant et toujours, dans les siècles des siècles. Amen.

──────────────
HYMNE

Le soir vient doucement sur ce jour qui s'achève.
Je te rends grâce pour tout ce que tu m'as donné :
pour les joies et les peines,
pour les rencontres et les silences,
pour ta présence cachée dans chaque instant.

──────────────
PSAUME 141

Seigneur, je t'appelle : viens vite !
Écoute ma voix quand je t'appelle.
Que ma prière devant toi s'élève comme un encens,
et mes mains levées, comme l'offrande du soir.

──────────────
LE MAGNIFICAT (Luc 1, 46-55)

Mon âme exalte le Seigneur,
mon esprit exulte en Dieu, mon Sauveur.
Il s'est penché sur son humble servante ;
désormais tous les âges me diront bienheureuse.
Le Puissant fit pour moi des merveilles ;
Saint est son nom.

Il déploie la force de son bras,
il disperse les superbes.
Il renverse les puissants de leurs trônes,
il élève les humbles.
Il comble de biens les affamés,
renvoie les riches les mains vides.

Gloire au Père, au Fils et au Saint-Esprit. Amen.

──────────────
Salve Regina...''',
    longueur: 10,
  ),

  Prayer(
    id: 'complies',
    titre: 'Complies — Prière avant le coucher',
    categorie: 'Office Divin',
    description: '''La prière de nuit avant le coucher. Examen de conscience et abandon confiant à Dieu.''',
    contenu: '''Dieu, viens à mon aide.
Seigneur, à notre secours.
Gloire au Père, au Fils et au Saint-Esprit,
comme il était au commencement,
maintenant et toujours, dans les siècles des siècles. Amen.

──────────────
EXAMEN DE CONSCIENCE BREF

En ce moment de silence,
je repasse cette journée devant Dieu :
— Ai-je accompli le bien que je pouvais faire ?
— Ai-je blessé quelqu'un par mes paroles ou mes actes ?
— Me suis-je laissé porter par la peur plutôt que par l'amour ?

Seigneur, pardonne-moi ce en quoi j'ai failli.
Je confesse mes manquements et je te fais confiance.

──────────────
PSAUME 91 (extrait)

Toi qui demeures à l'abri du Très-Haut,
qui loges à l'ombre du Tout-Puissant :
« Mon refuge, ma forteresse,
mon Dieu en qui je me confie ! »

Car il te gardera de tout piège,
il te couvrira de ses ailes ;
sous ses plumes tu trouveras refuge.

──────────────
ANTIENNE DE NUIT

Protégez-nous, Seigneur, tandis que nous veillons,
gardez-nous pendant notre sommeil,
afin que nous veillions avec le Christ
et que nous reposions dans la paix.

Salve Regina...''',
    longueur: 10,
  ),

  Prayer(
    id: 'examen-conscience',
    titre: 'Examen de conscience du soir',
    categorie: 'Office Divin',
    description: '''Méditation guidée pour faire le point sur sa journée en présence de Dieu. Précède souvent la confession.''',
    contenu: '''Prière du soir pour examiner sa journée avec Dieu.
(5 à 10 minutes — méthode ignatienne)

──────────────
1. GRATITUDE

Seigneur, je te rends grâce pour ce jour.
Quelles sont les grâces que j'ai reçues aujourd'hui ?
[Un moment de silence]

──────────────
2. REGARD SUR LA JOURNÉE

Je reprends ma journée calmement, du matin au soir.
Quels moments m'ont rapproché de Dieu ?
Quels moments m'en ont éloigné ?
Y a-t-il eu une parole, un regard, un geste
dont je veux me souvenir ?

──────────────
3. CONTRITION

Y a-t-il eu des pensées, des paroles ou des actes
dont je dois me repentir ?
Seigneur, pardonne-moi.
Je prends la résolution de faire mieux demain.

Acte de contrition :
Mon Dieu, j'ai un très grand regret
de vous avoir offensé...

──────────────
4. PRIÈRE POUR DEMAIN

Seigneur, aide-moi demain à être
plus attentif, plus patient, plus aimant.
Que ta volonté soit faite.

──────────────
5. ACTE DE CONFIANCE

Je me remets entre tes mains pour cette nuit.
Garde-moi et garde ceux que j'aime.

Notre Père...
Je vous salue Marie...
Gloire au Père...

Amen.''',
    longueur: 10,
  ),

  Prayer(
    id: 'priere-soir',
    titre: 'Prière du soir',
    categorie: 'Office Divin',
    description: '''Clore la journée avec Dieu, confier ses proches à sa garde et demander pardon pour ses fautes.''',
    contenu: '''Seigneur Dieu tout-puissant,
qui nous accordez de parvenir à la fin de ce jour,
nous vous supplions de nous pardonner
toutes les fautes que nous avons commises
en pensée, en parole ou par action.

Que votre miséricorde nous accompagne cette nuit
et nous protège de tout danger.
Gardez notre sommeil sous votre protection.

Protégez ceux que nous aimons.
Soutenez ceux qui souffrent.
Éclairez les mourants de votre lumière.

Par Jésus-Christ, notre Seigneur. Amen.''',
    longueur: 2,
  ),

  // ══════════════════════════════════════════════════════
  // CLASSIQUES (suite)
  // ══════════════════════════════════════════════════════

  Prayer(
    id: 'acte-consecration-marie',
    titre: 'Acte de consécration à Marie',
    categorie: 'Classiques',
    description: 'Se confier entièrement à Marie, comme saint Louis-Marie Grignion de Montfort nous y invite.',
    contenu: '''Je vous salue, Marie, ma chère Mère.
Je vous appartiens entièrement.
Tout ce que j'ai — mon corps, mon âme,
mes pensées, mes œuvres, mes joies, mes peines —
je vous le confie et vous le consacre.

Prenez ce que vous voulez,
faites de moi ce qu'il vous plaît.
Je me donne à vous sans réserve,
pour que vous me meniez à Jésus votre Fils.

Amen.''',
    longueur: 2,
  ),

  Prayer(
    id: 'priere-jesus',
    titre: 'Prière de Jésus',
    categorie: 'Classiques',
    description: 'Courte prière du cœur, héritée de la tradition hésychaste. À répéter lentement, en rythme avec la respiration.',
    contenu: '''Seigneur Jésus-Christ,
Fils de Dieu,
ayez pitié de moi, pécheur.

──────────────
Cette prière peut se répéter en silence,
lentement, en accord avec le souffle :

— À l'inspiration : « Seigneur Jésus-Christ, Fils de Dieu… »
— À l'expiration : « …ayez pitié de moi, pécheur. »

Laissez les mots descendre du mental dans le cœur.
Amen.''',
    longueur: 5,
  ),

  // ══════════════════════════════════════════════════════
  // PRIÈRES DES SAINTS (suite)
  // ══════════════════════════════════════════════════════

  Prayer(
    id: 'priere-padre-pio',
    titre: 'Offrande du matin (Padre Pio)',
    categorie: 'Prières des Saints',
    description: 'Prière du matin inspirée de la spiritualité de Padre Pio pour offrir sa journée à Dieu.',
    contenu: '''Seigneur, je me remets ce matin entre vos mains.
Vous savez tout ce dont j'ai besoin.
Vous connaissez mes forces et mes faiblesses,
mes joies et mes peines cachées.

Guidez mes pensées, mes paroles, mes actes
afin qu'ils vous soient agréables.

Que cette journée soit vécue à votre service
et au service de mes frères.

Que votre volonté soit faite, non la mienne.
Amen.''',
    longueur: 2,
  ),

  Prayer(
    id: 'priere-notre-dame-lourdes',
    titre: 'Prière à Notre-Dame de Lourdes',
    categorie: 'Prières des Saints',
    description: 'Invocation à Marie apparue à sainte Bernadette à Lourdes, particulièrement pour les malades.',
    contenu: '''Ô Marie, conçue sans péché,
vous qui êtes apparue à Bernadette à Lourdes
pour nous ramener à votre Fils,
tournez votre regard de mère sur nous.

Nous vous supplions d'intercéder pour tous les malades,
pour ceux qui souffrent et qui cherchent la guérison —
du corps, de l'âme et du cœur.

Donnez-nous la force de porter notre croix
avec confiance et amour,
en nous souvenant que vous êtes toujours près de nous.

Notre-Dame de Lourdes, priez pour nous !
Amen.''',
    longueur: 3,
  ),

  Prayer(
    id: 'priere-sainte-anne',
    titre: 'Prière à Sainte Anne',
    categorie: 'Prières des Saints',
    description: 'Mère de la Vierge Marie et grand-mère de Jésus, sainte Anne est la patronne des familles et des grands-parents.',
    contenu: '''Sainte Anne, mère de la Vierge Marie
et grand-mère de Jésus,
vous qui avez porté dans votre cœur
les plus grandes grâces divines,

regardez avec bienveillance sur nos familles.
Obtenez pour nous la sagesse dans l'éducation,
la patience dans les épreuves,
et la joie de grandir ensemble dans la foi.

Bénissez les parents et les grands-parents.
Protégez les enfants qui nous sont confiés.

Sainte Anne, priez pour nous. Amen.''',
    longueur: 2,
  ),

  Prayer(
    id: 'priere-saint-christophe',
    titre: 'Prière à Saint Christophe',
    categorie: 'Prières des Saints',
    description: 'Patron des voyageurs, saint Christophe est invoqué pour la protection sur la route et en voyage.',
    contenu: '''Saint Christophe, patron des voyageurs,
vous qui avez porté l'Enfant-Jésus sur vos épaules,
portez-nous aussi dans votre cœur
sur les routes que nous allons parcourir.

Protégez-nous des dangers,
éclairez notre chemin,
et ramenez-nous sains et saufs
à ceux qui nous aiment.

Saint Christophe, priez pour nous. Amen.''',
    longueur: 2,
  ),

  // ══════════════════════════════════════════════════════
  // OCCASIONS
  // ══════════════════════════════════════════════════════

  Prayer(
    id: 'pour-les-malades',
    titre: 'Pour les malades',
    categorie: 'Occasions',
    description: 'Prier pour un proche malade, lui confier son épreuve et demander guérison et paix.',
    contenu: '''Seigneur Jésus, médecin des corps et des âmes,
je vous confie ceux qui souffrent en ce moment —
et en particulier ceux qui me sont chers.

Soutenez-les dans cette épreuve.
Donnez-leur la paix et la confiance en vous.
Apaisez leur douleur et consolez leur cœur.

Entourez-les de votre présence
et faites-leur sentir qu'ils ne sont pas seuls.

Et si la guérison ne vient pas,
donnez-leur la grâce de porter leur croix
avec courage et espérance.

Marie, Santé des malades, priez pour eux. Amen.''',
    longueur: 3,
  ),

  Prayer(
    id: 'pour-les-defunts',
    titre: 'Pour les défunts',
    categorie: 'Occasions',
    description: 'Confier à Dieu ceux qui nous ont quittés, dans l\'espérance de la résurrection.',
    contenu: '''Seigneur, accueillez dans votre paix
tous ceux qui nous ont quittés.

Que votre miséricorde infinie les enveloppe.
Qu'ils voient votre visage
et demeurent pour toujours dans votre lumière.

Pour ceux que nous aimons et que nous pleurons :
donnez-nous la foi en la résurrection,
l'espérance de les retrouver,
et le courage de continuer le chemin.

Éternel repos, donnez-leur, Seigneur,
et que la lumière sans fin les illumine.
Qu'ils reposent en paix.

Amen.''',
    longueur: 3,
  ),

  Prayer(
    id: 'pour-la-paix',
    titre: 'Pour la paix',
    categorie: 'Occasions',
    description: 'Intercéder pour la paix dans le monde, dans les familles et dans les cœurs.',
    contenu: '''Dieu de paix et d'amour,
vous qui avez dit : « Ma paix, je vous la donne »,
répandez votre paix sur notre monde blessé.

Arrêtez les guerres.
Consolez les victimes.
Convertissez les cœurs endurcis.

Donnez aux gouvernants la sagesse
de choisir la voie du dialogue.
Donnez aux peuples la force du pardon.

Faites que la paix commence
dans chaque cœur, dans chaque foyer,
dans chaque famille, dans chaque nation.

Amen.''',
    longueur: 2,
  ),

  Prayer(
    id: 'pour-la-france',
    titre: 'Pour la France',
    categorie: 'Occasions',
    description: 'Prière patriotique et spirituelle pour la France, fille aînée de l\'Église.',
    contenu: '''Sainte Marie, Reine de France,
vous qui avez tant aimé ce pays,
veillez sur lui.

Inspirez ses dirigeants.
Gardez ses familles.
Protégez ses enfants.

Que la France se souvienne de son baptême
et rayonne à nouveau la lumière de l'Évangile.

Saint Michel, protégez la France.
Sainte Geneviève, priez pour Paris.
Saint Rémi, saint Denis, saint Martin —
intercédez pour notre pays.

Amen.''',
    longueur: 2,
  ),

  Prayer(
    id: 'avant-examen',
    titre: 'Avant un examen',
    categorie: 'Occasions',
    description: 'Demander à Dieu la clarté, la mémoire et le calme avant une épreuve importante.',
    contenu: '''Seigneur, voici que j'affronte une épreuve importante.
Je ne suis pas seul — vous êtes avec moi.

Donnez-moi la clarté d'esprit,
la mémoire fidèle,
et le calme dans mon cœur.

Que je donne le meilleur de moi-même.
Que votre lumière m'accompagne
à chaque question, à chaque décision.

Et si le résultat n'est pas celui que j'espère,
apprenez-moi à faire confiance
à votre plan pour ma vie.

Amen.''',
    longueur: 2,
  ),

  Prayer(
    id: 'pour-son-couple',
    titre: 'Pour son couple',
    categorie: 'Occasions',
    description: 'Bénir son mariage ou sa relation et demander à Dieu d\'être au cœur de l\'amour des époux.',
    contenu: '''Seigneur Jésus,
vous qui avez béni les noces de Cana,
bénissez notre amour.

Apprenez-nous à nous aimer
comme vous nous aimez — fidèlement, gratuitement.

Dans les jours heureux comme dans les difficultés,
soyez le troisième dans notre maison.

Donnez-nous l'humilité de nous pardonner,
la patience de nous comprendre,
et la joie de construire ensemble.

Marie et Joseph, modèles des familles,
priez pour nous.

Amen.''',
    longueur: 3,
  ),

  Prayer(
    id: 'pour-naissance',
    titre: 'Pour une naissance',
    categorie: 'Occasions',
    description: 'Remercier Dieu et lui confier un enfant qui vient de naître.',
    contenu: '''Seigneur, merci pour ce miracle de vie.
Cet enfant qui vient de naître est votre don,
le plus beau des cadeaux.

Gardez-le sous votre protection.
Éclairez ses parents dans leur mission sacrée.
Entourez cette famille de votre amour.

Que cet enfant grandisse dans la foi,
l'espérance et la charité.
Qu'il apprenne à vous connaître et à vous aimer.

Ange gardien, veille sur lui.
Marie, Mère de Dieu, protège-le.

Amen.''',
    longueur: 2,
  ),

  Prayer(
    id: 'temps-epreuve',
    titre: 'Dans l\'épreuve',
    categorie: 'Occasions',
    description: 'Prier quand tout va mal, quand on ne comprend pas, quand on souffre sans savoir pourquoi.',
    contenu: '''Seigneur, je ne comprends pas ce qui m'arrive.
Je souffre et je cherche un sens à cette épreuve.

Mais je vous fais confiance.
Vous êtes là, même quand je ne vous sens pas.
Votre amour ne m'abandonne jamais.

Donnez-moi la force de tenir.
Donnez-moi la lumière pour avancer.
Ne me laissez pas tomber.

Je m'accroche à vous
comme à la seule certitude qui demeure :
vous m'aimez et votre plan est bon.

Amen.''',
    longueur: 3,
  ),
];