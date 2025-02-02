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

import '../entity/contact.dart';
import '../using.dart';
import '../init.dart';
import 'list.dart';
import 'search.dart';

class YellowPagesPage extends StatefulWidget {
  const YellowPagesPage({Key? key}) : super(key: key);

  @override
  State<YellowPagesPage> createState() => _YellowPagesPageState();
}

class _YellowPagesPageState extends State<YellowPagesPage> {
  final List<ContactData> _contactData = YellowPagesInit.contactStorageDao.getAllContacts();

  Future<List<ContactData>> _fetchContactList() async {
    final service = YellowPagesInit.contactRemoteDao;
    final contacts = await service.getAllContacts();

    YellowPagesInit.contactStorageDao.clear();
    YellowPagesInit.contactStorageDao.addAll(contacts);
    return contacts;
  }

  Widget _buildBody() {
    if (_contactData.isNotEmpty) {
      return ContactList(_contactData);
    }

    return FutureBuilder<List<ContactData>>(
      future: _fetchContactList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data;
          if (data != null) {
            _contactData.addAll(data);
          }
          return ContactList(_contactData);
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: i18n.ftype_yellowPages.txt,
        actions: [
          IconButton(
              onPressed: () => showSearch(context: context, delegate: Search(_contactData)),
              icon: const Icon(Icons.search)),
          _buildRefreshButton(),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildRefreshButton() {
    return IconButton(
      tooltip: i18n.refresh,
      icon: const Icon(Icons.refresh),
      onPressed: () {
        _contactData.clear();
        setState(() {});
      },
    );
  }
}
