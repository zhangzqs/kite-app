/*
 * 上应小风筝  便利校园，一步到位
 * Copyright (C) 2022 上海应用技术大学 上应小风筝团队
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:hive/hive.dart';
import 'using.dart';
import 'dao/local.dart';
import 'dao/remote.dart';
import 'service/electricity.dart';
import 'storage/electricity.dart';

class ElectricityBillInit {
  static late ElectricityStorageDao electricityStorage;
  static late ElectricityServiceDao electricityService;
  static late KiteSession kiteSession;
  static Future<void> init({
    required KiteSession kiteSession,
    required Box<dynamic> electricityBox,
  }) async {
    ElectricityBillInit.kiteSession = kiteSession;

    electricityService = ElectricityService(kiteSession);

    electricityStorage = ElectricityStorage(electricityBox);
  }
}
