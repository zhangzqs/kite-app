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
import 'package:flutter/material.dart';
import 'package:kite/global/global.dart';
import 'package:kite/l10n/extension.dart';
import 'package:kite/route.dart';

import 'index.dart';

class ExamArrangementItem extends StatefulWidget {
  const ExamArrangementItem({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExamArrangementItemState();
}

class _ExamArrangementItemState extends State<ExamArrangementItem> {
  String? content;

  @override
  void initState() {
    Global.eventBus.on(EventNameConstants.onHomeRefresh, (arg) {});

    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HomeFunctionButton(
      route: RouteTable.examArrangement,
      icon: 'assets/home/icon_exam.svg',
      title: i18n.ftype_examArr,
      subtitle: content ?? i18n.ftype_examArr_desc,
    );
  }
}
