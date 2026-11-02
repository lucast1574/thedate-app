import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'api_client.dart';

class ProfilePhotoPicker {
  final ImagePicker _picker = ImagePicker();
  Future<Uint8List?> choose() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 480,
      maxHeight: 480,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (file == null) return null;
    if (await file.length() > (10 << 20)) {
      throw const ApiException('Elige una foto de menos de 10 MB.');
    }
    return normalize(await file.readAsBytes());
  }

  static Future<Uint8List> normalize(Uint8List source) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(source);
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? image;
    try {
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      final factor = math.min(
        1.0,
        480 / math.max(descriptor.width, descriptor.height),
      );
      codec = await descriptor.instantiateCodec(
        targetWidth: math.max(1, (descriptor.width * factor).round()),
        targetHeight: math.max(1, (descriptor.height * factor).round()),
      );
      image = (await codec.getNextFrame()).image;
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null || data.lengthInBytes > (1 << 20)) {
        throw const ApiException(
          'No pudimos preparar esta foto. Elige otra imagen.',
        );
      }
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer.dispose();
    }
  }
}
