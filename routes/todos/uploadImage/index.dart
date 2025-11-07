import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Only POST allowed');
  }

  final data = await context.request.formData();
  final file = data.files['image'];

  if (file == null) {
    return Response(statusCode: 400, body: 'Image missing');
  }

  final uploadsDir = Directory('uploads');
  if (!uploadsDir.existsSync()) uploadsDir.createSync();

  final savedFile = File('uploads/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
  await savedFile.writeAsBytes(await file.readAsBytes());

  final imageUrl = 'http://localhost:8080/uploads/${savedFile.uri.pathSegments.last}';

  return Response.json(body: {
    'success': true,
    'url': imageUrl,
  });
}
