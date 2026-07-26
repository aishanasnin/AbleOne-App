import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';
import 'package:ableone_app/features/counselor/data/repositories/counselor_repository_impl.dart';
import 'package:ableone_app/features/counselor/presentation/widgets/student_card.dart';
import 'package:ableone_app/features/counselor/presentation/pages/student_detail_page.dart';
import 'package:ableone_app/shared/widgets/premium_widgets.dart';

/// Screen listing assigned child student registry cases with simple list views.
class StudentListPage extends ConsumerWidget {
  /// Creates a [StudentListPage] instance.
  const StudentListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(counselorStudentsProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width <= 900 && size.width > 600;
    final gridCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        ProfileHeader(
          name: 'Hello, Counselor! 🧠',
          description: 'Evaluate diagnostic assessments, manage cases, and update therapy plans.',
          streakDays: 0,
        ),
        const SizedBox(height: AppConstants.md),

        const SectionTitle(title: 'Active Patient Register'),
        const SizedBox(height: AppConstants.sm),

        studentsAsync.when(
          data: (students) {
            if (students.isEmpty) {
              return const Center(child: Text('No students assigned.'));
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridCount,
                crossAxisSpacing: AppConstants.md,
                mainAxisSpacing: AppConstants.md,
                childAspectRatio: isDesktop ? 1.4 : 1.6,
              ),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return StudentCard(
                  student: student,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentDetailPage(student: student),
                      ),
                    );
                  },
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
