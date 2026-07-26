import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:ableone_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:ableone_app/features/admin/presentation/pages/admin_course_detail_page.dart';
import 'package:ableone_app/features/admin/presentation/pages/admin_course_stats_page.dart';
import 'package:ableone_app/core/constants/app_constants.dart';

class AdminCourseListPage extends ConsumerWidget {
  const AdminCourseListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(adminCoursesProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width <= 900 && size.width > 600;
    final gridCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Configuration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Course Statistics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const AdminCourseStatsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: coursesAsync.when(
        data: (courses) {
          return GridView.builder(
            padding: const EdgeInsets.all(AppConstants.md),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridCount,
              crossAxisSpacing: AppConstants.md,
              mainAxisSpacing: AppConstants.md,
              childAspectRatio: 1.45,
            ),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return CourseCard(
                title: course.title,
                category: course.category,
                difficulty: course.difficulty,
                enrolled: course.enrolledUsers,
                completionRate: course.completionRate,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => AdminCourseDetailPage(course: course),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
