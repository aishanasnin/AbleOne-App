import 'package:flutter_test/flutter_test.dart';
import 'package:ableone_app/core/router/route_names.dart';

void main() {
  group('GoRouter Configuration Route Name Unit Tests', () {
    test('Router path configurations should match release definitions', () {
      expect(RouteNames.splashPath, '/');
      expect(RouteNames.welcomePath, '/welcome');
      expect(RouteNames.loginPath, '/login');
      expect(RouteNames.signupPath, '/signup');
      expect(RouteNames.roleSelectionPath, '/role-selection');
      expect(RouteNames.studentDashboardPath, '/student-dashboard');
      expect(RouteNames.parentDashboardPath, '/parent-dashboard');
      expect(RouteNames.counselorDashboardPath, '/counselor-dashboard');
      expect(RouteNames.adminDashboardPath, '/admin-dashboard');
      expect(RouteNames.aiHomePath, '/ai-tutor');
    });
  });
}
