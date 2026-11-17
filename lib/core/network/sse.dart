import 'dart:convert';

/// Un événement Server-Sent Events : son nom et ses données (JSON décodé).
typedef EvenementSse = ({String nom, dynamic donnees});

/// Découpe un flux SSE (`event: …` / `data: …`, séparés par une ligne vide)
/// en événements. Les données sont décodées en JSON.
Stream<EvenementSse> lireSse(Stream<List<int>> octets) async* {
  var nom = 'message';
  final donnees = <String>[];

  await for (final ligne in octets.transform(utf8.decoder).transform(const LineSplitter())) {
    if (ligne.isEmpty) {
      if (donnees.isNotEmpty) yield (nom: nom, donnees: jsonDecode(donnees.join('\n')));
      nom = 'message';
      donnees.clear();
    } else if (ligne.startsWith('event:')) {
      nom = ligne.substring(6).trim();
    } else if (ligne.startsWith('data:')) {
      donnees.add(ligne.substring(5).trimLeft());
    }
    // Les commentaires (« : … ») et les champs inconnus sont ignorés.
  }

  // Dernier événement sans ligne vide finale.
  if (donnees.isNotEmpty) yield (nom: nom, donnees: jsonDecode(donnees.join('\n')));
}
