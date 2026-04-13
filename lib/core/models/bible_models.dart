class BibleBook {
  final String id;
  final String name;
  final String? nameLong;
  final String testament; // OT ou NT

  const BibleBook({
    required this.id,
    required this.name,
    this.nameLong,
    required this.testament,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) => BibleBook(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        nameLong: json['nameLong'],
        testament: json['testament'] ?? 'OT',
      );

  bool get isOldTestament => testament == 'OT';
}

class BibleChapter {
  final String id;
  final String bookId;
  final String number;
  final String reference;

  const BibleChapter({
    required this.id,
    required this.bookId,
    required this.number,
    required this.reference,
  });

  factory BibleChapter.fromJson(Map<String, dynamic> json) => BibleChapter(
        id: json['id'] ?? '',
        bookId: json['bookId'] ?? '',
        number: json['number'] ?? '',
        reference: json['reference'] ?? '',
      );
}

class BiblePassage {
  final String id;
  final String reference;
  final String content;
  final String? copyright;

  const BiblePassage({
    required this.id,
    required this.reference,
    required this.content,
    this.copyright,
  });

  factory BiblePassage.fromJson(Map<String, dynamic> json) => BiblePassage(
        id: json['id'] ?? '',
        reference: json['reference'] ?? '',
        content: json['content'] ?? '',
        copyright: json['copyright'],
      );

  // Retire les balises HTML simples
  String get plainText => content
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}

class BibleSearchVerse {
  final String id;
  final String reference;
  final String text;

  const BibleSearchVerse({
    required this.id,
    required this.reference,
    required this.text,
  });

  factory BibleSearchVerse.fromJson(Map<String, dynamic> json) =>
      BibleSearchVerse(
        id: json['id'] ?? '',
        reference: json['reference'] ?? '',
        text: json['text'] ?? '',
      );
}
