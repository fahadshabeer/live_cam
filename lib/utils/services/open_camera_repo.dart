import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
class OpenCameraRepo
{
  static Future<void> makeApiCall() async {
    const url = 'http://gps.markongps.com:10088/api/device/sendInstruct';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: {
        'imei': '864993060098960',
        'cmdContent': 'RTMP,ON,INOUT',
        'serverFlagId': '0',
        'proNo': '128',
        'platform': 'web',
        'requestId': '6',
        'cmdType': 'normallns',
        'token': '123',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['code'] == 0 && data['data']['_msg'] == null) {
      } else {
        var errorMessage = data['data']['_msg'] ?? 'Unknown error';
        throw HttpException(errorMessage);
      }
    } else {
      var errorMessage = 'Failed to load stream';
      throw HttpException(errorMessage);
    }

  }
}