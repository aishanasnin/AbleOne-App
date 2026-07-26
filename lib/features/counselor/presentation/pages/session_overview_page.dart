import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';
import 'package:ableone_app/features/counselor/data/repositories/counselor_repository_impl.dart';
import 'package:ableone_app/features/counselor/presentation/widgets/session_card.dart';

/// Screen listing upcoming video consult sessions for counselor evaluation.
class SessionOverviewPage extends ConsumerWidget {
  /// Creates a [SessionOverviewPage] instance.
  const SessionOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(counselorSessionsProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        const SectionTitle(title: 'Upcoming Consultations Today'),
        const SizedBox(height: AppConstants.md),
        sessionsAsync.when(
          data: (sessions) {
            if (sessions.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.xl),
                  child: Text('No upcoming sessions scheduled.'),
                ),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 2 : 1,
                crossAxisSpacing: AppConstants.md,
                mainAxisSpacing: AppConstants.md,
                childAspectRatio: isDesktop ? 1.8 : 2.2,
              ),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return SessionCard(
                  time: session['time'] ?? '',
                  student: session['student'] ?? '',
                  type: session['type'] ?? '',
                  room: session['room'] ?? '',
                );
              },
            );
          },
          error: (err, _) => Center(child: Text('Error: $err')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}
