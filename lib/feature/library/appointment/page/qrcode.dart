import 'package:flutter/material.dart';
import 'package:kite/component/future_builder.dart';
import 'package:kite/feature/library/appointment/init.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrcodePage extends StatelessWidget {
  final service = LibraryAppointmentInitializer.appointmentService;
  final int applyId;
  QrcodePage({
    Key? key,
    required this.applyId,
  }) : super(key: key);

  Widget buildQrcode(String data) {
    return Builder(builder: (context) {
      final width = MediaQuery.of(context).size.width;
      return QrImage(
        data: data,
        size: width * 0.8,
      );
    });
  }

  Widget buildFutureQrcode(Future<String> future) {
    return MyFutureBuilder<String>(
      future: future,
      builder: (context, data) {
        return buildQrcode(data);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('出示预约二维码'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildFutureQrcode(service.getApplicationCode(applyId)),
              ],
            ),
          ),
          Text(
            '在进入图书馆时向志愿者出示本二维码',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}