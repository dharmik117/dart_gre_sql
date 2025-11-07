import 'dart:io';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/todos_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Method not allowed. Use POST.'},
    );
  }

  try {
    // ✅ Parse multipart form-data
    final form = await context.request.formData();

    final text = form.fields['text'];
    final userId = int.tryParse(form.fields['user_id'] ?? '');
    final color = form.fields['color'] ?? '#ffffff';
    final image = form.files['image'];

    // ✅ Validations
    if (text == null || text.trim().isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing or invalid text', 'is_success': false},
      );
    }

    if (userId == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing or invalid user_id', 'is_success': false},
      );
    }

    String? imageUrl;

    // ✅ Save image if uploaded
    if (image != null) {
      final uploadsDir = Directory('uploads');
      if (!uploadsDir.existsSync()) uploadsDir.createSync();

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.name}';

      final savedFile = File('uploads/$fileName');
      await savedFile.writeAsBytes(await image.readAsBytes());

      imageUrl = 'https://dartgresql-production.up.railway.app/uploads/$fileName';    }

    final db = TodosHelper();
    final result = await db.addTodo(
      text: text.trim(),
      id: userId,
      color: color,
      image: imageUrl ?? '',
    );

    return Response.json(
      statusCode: 201,
      body: {
        'message': 'Todo created successfully.',
        'data': result,
        'is_success': true,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'error': 'Internal server error',
        'details': e.toString(),
        'is_success': false,
      },
    );
  }
}
