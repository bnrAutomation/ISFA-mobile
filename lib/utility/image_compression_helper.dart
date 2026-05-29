import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:i_densfa/utility/app_storage.dart';

/// Centralized image compression helper to reduce code duplication
/// and provide consistent image compression across the app
class ImageCompressionHelper {
  static ImageCompressionHelper? _instance;
  static ImageCompressionHelper get instance {
    _instance ??= ImageCompressionHelper._internal();
    return _instance!;
  }

  ImageCompressionHelper._internal();

  /// Default compression quality
  static const int _defaultQuality = 90;
  
  /// Maximum file size in KB
  static const int _maxFileSizeKB = 400;
  
  /// Quality reduction step for recursive compression
  static const int _qualityReductionStep = 10;

  /// Compress image with automatic quality adjustment to meet size requirements
  /// 
  /// [filePath] - Path to the original image file
  /// [name] - Name identifier for the compressed file (e.g., 'assessment', 'markin', 'ticket')
  /// [quality] - Initial compression quality (default: 90)
  /// [addText] - Optional text to add to the image
  /// [convertToJpg] - Whether to convert to JPG format (default: false)
  /// 
  /// Returns the path to the compressed image file
  Future<String> compressImage(
    String filePath,
    String name, {
    int? quality,
    String? addText,
    bool convertToJpg = false,
  }) async {
    final userId = AppStorage().userDetail?.id ?? "unknown";
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = basename(filePath);
    
    final directory = "${await _getExternalStoragePath()}/${userId}_${name}_${timestamp}_$fileName";
    final int compressionQuality = quality ?? _defaultQuality;

    // Compress the image
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      filePath,
      directory,
      quality: compressionQuality,
    );

    if (compressedFile == null) {
      throw Exception('Failed to compress image');
    }

    // Check file size and recursively compress if needed
    final fileBytes = await compressedFile.readAsBytes();
    if ((fileBytes.lengthInBytes / 1024.0) > _maxFileSizeKB) {
      // Recursively compress with lower quality
      return await compressImage(
        filePath,
        name,
        quality: compressionQuality - _qualityReductionStep,
        addText: addText,
        convertToJpg: convertToJpg,
      );
    }

    String finalPath = compressedFile.path;

    // Convert to JPG if requested
    if (convertToJpg) {
      finalPath = await _convertToJpg(finalPath);
    }

    // Add text if provided
    if (addText != null && addText.isNotEmpty) {
      finalPath = await _addTextToImage(finalPath, addText);
    }

    return finalPath;
  }

  /// Compress image and return as XFile
  /// 
  /// [filePath] - Path to the original image file
  /// [name] - Name identifier for the compressed file
  /// [quality] - Initial compression quality (default: 90)
  /// 
  /// Returns the compressed image as XFile
  Future<XFile?> compressImageAsXFile(
    String filePath,
    String name, {
    int? quality,
  }) async {
    try {
      final compressedPath = await compressImage(filePath, name, quality: quality);
      return XFile(compressedPath);
    } catch (e) {
      return null;
    }
  }

  /// Upload compressed image to server
  /// 
  /// [filePath] - Path to the original image file
  /// [name] - Name identifier for the compressed file
  /// [uploadUrl] - URL to upload the image
  /// [activity] - Activity name for the upload
  /// [quality] - Initial compression quality (default: 90)
  /// 
  /// Returns the image URL from server response
  Future<String> uploadCompressedImage(
    String filePath,
    String name,
    String uploadUrl,
    String activity, {
    int? quality,
  }) async {
    final compressedFile = await compressImageAsXFile(filePath, name, quality: quality);
    
    if (compressedFile == null) {
      throw Exception('Failed to compress image for upload');
    }

    // Create multipart request
    final request = MultipartRequest('POST', Uri.parse(uploadUrl));
    request.headers.addAll({
      'Authorization': 'Bearer ${AppStorage().authToken}',
      'Content-Type': 'application/json',
    });

    // Add file to request
    final multipartFile = await MultipartFile.fromPath(
      'image',
      compressedFile.path,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);
    request.fields.addAll({"activity": activity});

    // Send request
    final response = await request.send();
    final body = await response.stream.transform(utf8.decoder).join();

    if (response.statusCode == 201) {
      final responseData = jsonDecode(body);
      return responseData['imageUrl'] ?? '';
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }

  /// Convert image to JPG format
  Future<String> _convertToJpg(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image for JPG conversion');
      }

      // Overwrite the existing file with JPG-encoded image
      await imageFile.writeAsBytes(img.encodeJpg(originalImage, quality: 60));
      return imageFile.path;
    } catch (e) {
      throw Exception('Failed to convert image to JPG: $e');
    }
  }

  /// Add text overlay to image
  Future<String> _addTextToImage(String imagePath, String text) async {
    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image for text overlay');
      }

      // Draw text on the image
      img.drawString(
        image,
        text,
        font: img.arial24, // Use built-in Arial font (24px)
        x: 10, // X position
        y: 10, // Y position
        wrap: true, // Enable text wrapping
      );

      // Save the modified image
      await imageFile.writeAsBytes(img.encodeJpg(image));
      return imageFile.path;
    } catch (e) {
      throw Exception('Failed to add text to image: $e');
    }
  }

  /// Get external storage path based on platform
  Future<String> _getExternalStoragePath() async {
    if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else {
      final directory = await getExternalStorageDirectory();
      return directory?.path ?? "";
    }
  }

  /// Clear any temporary files if needed
  Future<void> clearTempFiles() async {
    // Implementation for clearing temporary files if needed
    // This can be expanded based on requirements
  }
}
