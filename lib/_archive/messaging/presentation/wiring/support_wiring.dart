import 'package:sudan_goods/messaging/data/support_repo_fs.dart';
import 'package:sudan_goods/messaging/presentation/controllers/support_controller.dart';

SupportController makeSupportControllerForUid(String uid) {
  final repo = FirestoreSupportRepo();
  return SupportController(uid: uid, supportRepo: repo);
}
