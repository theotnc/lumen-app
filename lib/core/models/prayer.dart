import 'package:flutter/material.dart';

class Prayer {
  final String id;
  final String titre;
  final String categorie;
  final String description;
  final String contenu;
  final int longueur; // minutes

  const Prayer({
    required this.id,
    required this.titre,
    required this.categorie,
    required this.description,
    required this.contenu,
    required this.longueur,
  });

  static const List<String> categories = [
    'Classiques',
    'Rosaire',
    'Litanies',
    'Prières des Saints',
    'Novènes',
    'Office Divin',
    'Occasions',
  ];

  static IconData iconForCategory(String cat) {
    switch (cat) {
      case 'Classiques':         return Icons.menu_book_rounded;
      case 'Rosaire':            return Icons.radio_button_checked_rounded;
      case 'Litanies':           return Icons.format_list_bulleted_rounded;
      case 'Prières des Saints': return Icons.star_rounded;
      case 'Novènes':            return Icons.calendar_today_rounded;
      case 'Office Divin':       return Icons.wb_sunny_rounded;
      case 'Occasions':          return Icons.volunteer_activism_rounded;
      default:                   return Icons.church_rounded;
    }
  }

  static String descriptionForCategory(String cat) {
    switch (cat) {
      case 'Classiques':
        return 'Les prières fondamentales de la foi : Notre Père, Je vous salue Marie, Credo… À connaître par cœur.';
      case 'Rosaire':
        return 'Un chapelet de prières qui médite les grands moments de la vie du Christ et de Marie. Environ 20 minutes.';
      case 'Litanies':
        return 'Des prières répétitives qui invoquent Dieu ou les saints par une série de titres. Très méditatives.';
      case 'Prières des Saints':
        return 'Des prières composées par les grands saints ou adressées à eux pour obtenir leur intercession.';
      case 'Novènes':
        return 'Une prière récitée pendant 9 jours consécutifs pour une intention précise — guérison, discernement, action de grâces.';
      case 'Office Divin':
        return 'La prière officielle de l\'Église, répartie sur les heures du jour : Laudes le matin, Vêpres le soir…';
      case 'Occasions':
        return 'Prières pour chaque moment de la vie : maladie, deuil, naissance, mariage, examens, paix…';
      default:
        return '';
    }
  }
}
