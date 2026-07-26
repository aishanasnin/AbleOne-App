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
      expect(RouteNames.studentDashboardPath, '/dashboard/student');
      expect(RouteNames.parentDashboardPath, '/dashboard/parent');
      expect(RouteNames.counselorDashboardPath, '/dashboard/counselor');
      expect(RouteNames.adminDashboardPath, '/dashboard/admin');
      expect(RouteNames.aiHomePath, '/ai');
    });
  });
}
