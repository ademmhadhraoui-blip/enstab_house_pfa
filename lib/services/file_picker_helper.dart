import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:enstabhouse/constants.dart';

/// Centralized helper for picking files and images.
///
/// **Key design decisions (2024+ best practices):**
///
/// - **FilePicker** uses Android's Storage Access Framework (SAF) which
///   requires **no runtime permission**. Never gate it behind
///   `Permission.storage`.
///
/// - **ImagePicker** uses the platform's built-in photo picker (PHPicker on
///   iOS, MediaStore picker on Android 13+) which also requires **no runtime
///   permission** for gallery access.
///
/// - **Camera** is the only feature that still requires a runtime permission
///   (`Permission.camera`).
///
/// All methods include try/catch and return `null` on cancellation so callers
/// never get unhandled exceptions.
class FilePickerHelper {
  static final ImagePicker _imagePicker = ImagePicker();

  // ───────────────────────────────────────────────────────────────────────────
  //  DOCUMENT PICKING (no permission needed)
  // ───────────────────────────────────────────────────────────────────────────

  /// Pick a single PDF file.
  ///
  /// Returns the [File] or `null` if the user cancelled.
  /// On error, calls [onError] with a user-friendly message.
  static Future<File?> pickPdfFile({
    void Function(String message)? onError,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.isEmpty) return null;

      final path = result.files.single.path;
      if (path == null) {
        onError?.call('Could not access the selected file.');
        return null;
      }

      return File(path);
    } catch (e) {
      onError?.call('Failed to open file picker: $e');
      return null;
    }
  }

  /// Pick multiple documents (PDF, DOC, PPT, XLS, TXT, etc.).
  ///
  /// Returns a list of [File]s. Empty if the user cancelled.
  /// On error, calls [onError] with a user-friendly message.
  static Future<List<File>> pickDocuments({
    void Function(String message)? onError,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt',
        ],
      );

      if (result == null || result.files.isEmpty) return [];

      return result.paths
          .where((p) => p != null)
          .map((p) => File(p!))
          .toList();
    } catch (e) {
      onError?.call('Failed to open file picker: $e');
      return [];
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  //  IMAGE PICKING
  // ───────────────────────────────────────────────────────────────────────────

  /// Pick multiple images from the gallery.
  ///
  /// No runtime permission is needed — `ImagePicker` uses the platform's
  /// built-in photo picker.
  ///
  /// Returns a list of [File]s. Empty if the user cancelled.
  static Future<List<File>> pickPhotosFromGallery({
    void Function(String message)? onError,
  }) async {
    try {
      final images = await _imagePicker.pickMultiImage();
      if (images.isEmpty) return [];
      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      onError?.call('Failed to open gallery: $e');
      return [];
    }
  }

  /// Take a photo with the camera.
  ///
  /// **Requires** `Permission.camera`. Call [requestCameraPermission] first,
  /// or use [takePhotoWithCamera] which handles everything.
  ///
  /// Returns a [File] or `null` if the user cancelled.
  static Future<File?> takePhotoWithCamera(
    BuildContext context, {
    void Function(String message)? onError,
  }) async {
    final granted = await requestCameraPermission(context);
    if (!granted) return null;

    try {
      final image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      onError?.call('Failed to open camera: $e');
      return null;
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  //  CAMERA PERMISSION (the only permission still needed)
  // ───────────────────────────────────────────────────────────────────────────

  /// Request camera permission with proper user feedback.
  ///
  /// Returns `true` if granted, `false` otherwise.
  /// Shows a SnackBar on denial and an AlertDialog if permanently denied.
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.request();

    if (status.isGranted || status.isLimited) return true;

    if (!context.mounted) return false;

    if (status.isPermanentlyDenied) {
      // Show dialog directing user to app settings
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.camera_alt, color: kPrimaryColor, size: 24),
              SizedBox(width: 10),
              Text('Camera Permission'),
            ],
          ),
          content: const Text(
            'Camera access is required to take photos. '
            'Please enable it in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Open Settings',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return false;
    }

    // Simple denial — show a SnackBar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to take photos.'),
        ),
      );
    }
    return false;
  }
}
