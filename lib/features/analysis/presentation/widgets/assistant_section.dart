import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/widgets/app_section.dart';
import '../../../../core/widgets/etats.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/assistant_bloc.dart';

/// Questions à l'assistant sur l'analyse affichée (API Claude côté serveur).
class AssistantSection extends StatefulWidget {
  const AssistantSection({super.key});

  @override
  State<AssistantSection> createState() => _AssistantSectionState();
}

class _AssistantSectionState extends State<AssistantSection> {
  final _question = TextEditingController();

  static const _suggestions = ['Pourquoi ce signal ?', 'Quels sont les risques ?', 'Que dit le RSI ?'];

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  void _envoyer(String texte) {
    if (texte.trim().isEmpty) return;
    context.read<AssistantBloc>().add(QuestionPosee(texte));
    _question.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return BlocConsumer<AssistantBloc, AssistantState>(
      // Le quota du compte (onglet Compte) suit chaque réponse.
      listenWhen: (avant, apres) => avant.quota != apres.quota,
      listener: (context, _) => context.read<AuthBloc>().add(UserRefreshRequested()),
      builder: (context, state) {
        final quota = state.quota;
        return AppSection(
          titre: 'Assistant',
          action: quota == null
              ? null
              : Text('${quota.utilisees}/${quota.limite} aujourd’hui',
                  style: AppTypo.style(taille: 13, couleur: c.texteFaible, tabulaire: true)),
          enfants: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.messages.isEmpty)
                    Wrap(
                      spacing: AppEspace.s,
                      runSpacing: AppEspace.s,
                      children: [
                        for (final s in _suggestions)
                          ActionChip(
                            label: Text(s, style: AppTypo.style(taille: 14, couleur: c.texte)),
                            onPressed: state.enCours ? null : () => _envoyer(s),
                            backgroundColor: c.fond,
                            side: BorderSide(color: c.separateur),
                            shape: const StadiumBorder(),
                          ),
                      ],
                    ),
                  for (final m in state.messages)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: m.deLUtilisateur
                          ? Text(m.contenu, style: AppTypo.style(taille: 16, graisse: FontWeight.w600, couleur: c.texte, hauteur: 1.4))
                          : Container(
                              padding: const EdgeInsets.only(left: 14),
                              decoration: BoxDecoration(border: Border(left: BorderSide(color: c.separateur, width: 2))),
                              child: Text(m.contenu, style: AppTypo.style(taille: 16, couleur: c.texte, hauteur: 1.5)),
                            ),
                    ),
                  // Jusqu'au premier morceau de la réponse.
                  if (state.enCours && (state.messages.isEmpty || state.messages.last.deLUtilisateur))
                    const TexteDiscret('Analyse en cours…'),
                ],
              ),
            ),
            MessageErreur(state.erreur),
            Container(
              margin: const EdgeInsets.fromLTRB(AppEspace.gouttiere, 14, AppEspace.gouttiere, 0),
              padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
              decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(AppRayon.l)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _question,
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 2000,
                      onChanged: (_) => setState(() {}),
                      style: AppTypo.style(taille: 16, couleur: c.texte),
                      decoration: InputDecoration(
                        hintText: 'Poser une question sur cette analyse',
                        hintStyle: AppTypo.style(taille: 16, couleur: c.texteFaible),
                        border: InputBorder.none,
                        counterText: '',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppEspace.s),
                  Opacity(
                    opacity: state.enCours || _question.text.trim().isEmpty ? 0.25 : 1,
                    child: IconButton.filled(
                      onPressed: state.enCours ? null : () => _envoyer(_question.text),
                      icon: Icon(Icons.arrow_upward, size: 18, color: c.surEncre),
                      style: IconButton.styleFrom(
                        backgroundColor: c.encre,
                        disabledBackgroundColor: c.encre,
                        minimumSize: const Size(34, 34),
                        fixedSize: const Size(34, 34),
                        padding: EdgeInsets.zero,
                      ),
                      tooltip: 'Envoyer',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
