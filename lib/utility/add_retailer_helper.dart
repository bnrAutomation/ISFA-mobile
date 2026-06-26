import 'package:i_densfa/module/my_schedule_module/beat_plan_model.dart';
import 'package:i_densfa/utility/app_storage.dart';

class AddRetailerHelper {
  static bool get isBrotherInternationalUser {
    final company = AppStorage().userDetail?.companyName;
    return company != null &&
        company.toLowerCase().trim() == 'brotherinternational';
  }

  static bool hasMarkInOrVisitedStore(List<BeatPlanModel> assignedStores) {
    if (AppStorage().markedInStoreId != null) return true;
    return assignedStores.any((store) =>
        store.markin || store.isAlreadyMarkin || store.campaignResponseExists);
  }

  static bool showAddNewRetailer(List<BeatPlanModel> assignedStores) {
    final user = AppStorage().userDetail;
    if (user == null) return false;
    if (!user.configuration.requiredFwpStore) return false;
    if (isBrotherInternationalUser) return hasMarkInOrVisitedStore(assignedStores);
    return true;
  }
}
