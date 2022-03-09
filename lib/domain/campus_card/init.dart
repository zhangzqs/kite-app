import 'package:kite/dao/index.dart';
import 'package:kite/session/abstract_session.dart';

import 'service/campus_card.dart';

class CampusCardInitializer {
  static late CampusCardDao campusCardService;
  static void init(ASession session) {
    campusCardService = CampusCardService(session);
  }
}