import 'package:flutter/material.dart';

/// Demande une confirmation (boîte native de la plateforme) ; `true` si
/// l'utilisateur confirme.
Future<bool> confirmer(
  BuildContext context, {
  required String titre,
  required String message,
  required String libelleOk,
  bool danger = false,
}) async {
  final reponse = await showAdaptiveDialog<bool>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(titre),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: danger ? TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error) : null,
          child: Text(libelleOk),
        ),
      ],
    ),
  );
  return reponse ?? false;
}
