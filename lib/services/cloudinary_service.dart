import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:enstabhouse/constants.dart';

/// Service responsible for uploading files to Cloudinary.
///
/// Uses **unsigned uploads** via the Cloudinary REST API.
/// The `auto` resource type auto-detects file type (image, pdf, etc.).
///
/// **Security note**: Unsigned presets only allow uploads to a
/// pre-configured folder/transformation — no API secret is needed
/// or stored in client code.
class CloudinaryService {
  static const String _baseUrl =
      'https://api.cloudinary.com/v1_1/$kCloudinaryCloudName/auto/upload';

  /// Upload a file to Cloudinary.
  ///
  /// [file]     — the local file to upload.
  /// [fileName] — used as the `public_id` prefix for readability.
  /// [folder]   — optional Cloudinary folder (e.g. `'documents'`, `'posts/photos'`).
  ///
  /// Returns the `secure_url` of the uploaded file.
  Future<String> uploadFile(
    File file,
    String fileName, {
    String? folder,
  }) async {
    final uri = Uri.parse(_baseUrl);
    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = kCloudinaryUploadPreset;
    if (folder != null) {
      request.fields['folder'] = folder;
    }

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path, filename: fileName),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['secure_url'] as String;
    } else {
      throw Exception(
        'Cloudinary upload failed (${response.statusCode}): ${response.body}',
      );
    }
  }

  /// Upload a file to Cloudinary with progress tracking.
  ///
  /// [onProgress] receives a value between 0.0 and 1.0 representing
  /// the fraction of bytes sent. Note: this tracks the *send* progress,
  /// not the server-side processing.
  ///
  /// Returns the `secure_url` of the uploaded file.
  Future<String> uploadFileWithProgress(
    File file,
    String fileName, {
    String? folder,
    void Function(double progress)? onProgress,
  }) async {
    final uri = Uri.parse(_baseUrl);

    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = kCloudinaryUploadPreset;
    if (folder != null) {
      request.fields['folder'] = folder;
    }

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path, filename: fileName),
    );

    // Send the request — progress is reported once upload completes
    final streamedResponse = await request.send();

    // Read response bytes
    final List<int> responseBytes = [];

    // MultipartRequest sends everything before we get the response,
    // so we report progress in two stages
    onProgress?.call(0.5); // Mark 50% when request is sent

    await for (final chunk in streamedResponse.stream) {
      responseBytes.addAll(chunk);
    }

    onProgress?.call(1.0); // Mark 100% when response is received

    final response = http.Response.bytes(
      responseBytes,
      streamedResponse.statusCode,
      headers: streamedResponse.headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['secure_url'] as String;
    } else {
      throw Exception(
        'Cloudinary upload failed (${response.statusCode}): ${response.body}',
      );
    }
  }
}
