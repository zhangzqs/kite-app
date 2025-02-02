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

import '../using.dart';

import '../dao/exam.dart';
import '../entity/exam.dart';

/// REAL. THE PAYLOAD IS IN PINYIN. DONT BLAME ANYONE BUT THE SCHOOL.
/// More reading: https://github.com/sunnysab/zf-tools/blob/master/TRANSLATION.md
class ExamService implements ExamDao {
  static const _examRoomUrl = 'http://jwxt.sit.edu.cn/jwglxt/kwgl/kscx_cxXsksxxIndex.html';
  final ISession session;

  const ExamService(this.session);

  /// 获取考场信息
  @override
  Future<List<ExamRoom>> getExamList(SchoolYear schoolYear, Semester semester) async {
    var response = await session.request(
      _examRoomUrl,
      ReqMethod.post,
      queryParameters: {
        'doType': 'query',
        'gnmkdm': 'N358105',
      },
      data: {
        // 学年名
        'xnm': schoolYear.toString(),
        // 学期名
        'xqm': semesterToFormField(semester),
      },
    );
    final List<dynamic> itemsData = response.data['items'];

    return itemsData.map((e) => ExamRoom.fromJson(e as Map<String, dynamic>)).toList();
  }
}
