import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../providers/calendar_provider.dart';

class CalendarConnectButton extends ConsumerWidget {
  const CalendarConnectButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Surveiller l'état de la connexion
    final connectionState = ref.watch(googleCalendarNotifierProvider);
    // Accéder au service (seulement si connecté)
    final calendarService = ref.watch(googleCalendarServiceProvider);

    return connectionState.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => Column(
        children: [
          ResponsiveText.bodySmall('Erreur de connexion : ${e.toString()}'),
          // Bouton pour réessayer
          ElevatedButton(
            onPressed: () => ref
                .read(googleCalendarNotifierProvider.notifier)
                .signInAndInit(),
            child: const Text('Réessayer'),
          ),
        ],
      ),
      data: (service) {
        if (service == null) {
          // Non connecté
          return ElevatedButton(
            onPressed: () {
              ref.read(googleCalendarNotifierProvider.notifier).signInAndInit();
            },
            child: const ResponsiveText.bodySmall('Connecter Google Calendar'),
          );
        } else {
          // Connecté et prêt à interagir
          return Column(
            children: [
              const ResponsiveText.bodySmall('✅ Connecté!'),
              ElevatedButton(
                onPressed: () async {
                  // Appel simple au service :
                  await calendarService!.createEvent(
                      summary: 'Rendez-vous Portfolio',
                      start: DateTime.now().add(const Duration(days: 1)),
                      end: DateTime.now()
                          .add(const Duration(days: 1, hours: 1)));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: ResponsiveText.bodySmall('Événement créé!')),
                    );
                  }
                },
                child: const ResponsiveText.bodySmall('Créer un RDV de Test'),
              ),
              ResponsiveButton(
                onPressed: () =>
                    ref.read(googleCalendarNotifierProvider.notifier).signOut(),
                child: const ResponsiveText.bodySmall('Déconnexion'),
              ),
            ],
          );
        }
      },
    );
  }
}
