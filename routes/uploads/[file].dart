import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String file) async {
  final targetFile = File('uploads/$file');

  if (!await targetFile.exists()) {
    return Response(statusCode: 404, body: 'File not found');
  }

  final bytes = await targetFile.readAsBytes();

  return Response.bytes(
    body: bytes,
    headers: {
      HttpHeaders.contentTypeHeader: _getMimeType(file),
    },
  );
}

String _getMimeType(String fileName) {
  if (fileName.endsWith('.png')) return 'image/png';
  if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) return 'image/jpeg';
  return 'application/octet-stream';
}
