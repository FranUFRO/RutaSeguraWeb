import 'admin_document_service.dart';
import 'admin_user_service.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'dashboard_service.dart';

class AppServices {
  AppServices._();
  static final api = ApiClient();
  static final auth = AuthService(api);
  static final users = AdminUserService(api, auth);
  static final dashboard = DashboardService(api, auth);
  static final documents = AdminDocumentService(api, auth);

  static void initialize() {
    api.onUnauthorized = auth.expire;
  }
}
