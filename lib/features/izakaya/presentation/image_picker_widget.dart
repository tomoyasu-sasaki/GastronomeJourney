import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends HookConsumerWidget {
  const ImagePickerWidget({
    super.key,
    this.initialImages = const [],
    required this.onImagesChanged,
    required this.onImageDeleted,
  });

  final List<String> initialImages;
  final void Function(List<File>) onImagesChanged;
  final void Function(String) onImageDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImages = useState<List<File>>([]);
    final uploadProgress = useState<Map<String, double>>({});

    Future<void> pickImages() async {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage();
      if (images.isEmpty) return;

      final files = images.map((xFile) => File(xFile.path)).toList();
      selectedImages.value = [...selectedImages.value, ...files];
      onImagesChanged(selectedImages.value);
    }

    void removeImage(int index) {
      selectedImages.value = [
        ...selectedImages.value.sublist(0, index),
        ...selectedImages.value.sublist(index + 1),
      ];
      onImagesChanged(selectedImages.value);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('画像'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...initialImages.map(
              (url) => Stack(
                children: [
                  Image.network(
                    url,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton.filled(
                      onPressed: () => onImageDeleted(url),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...selectedImages.value.asMap().entries.map(
                  (entry) => Stack(
                    children: [
                      Image.file(
                        entry.value,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      if (uploadProgress.value[entry.value.path] != null)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black38,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: uploadProgress.value[entry.value.path],
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton.filled(
                          onPressed: () => removeImage(entry.key),
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            IconButton.outlined(
              onPressed: pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              style: IconButton.styleFrom(
                fixedSize: const Size(100, 100),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 