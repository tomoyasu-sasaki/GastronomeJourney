import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

part 'storage_repository.g.dart';

@riverpod
StorageRepository storageRepository(Ref ref) {
  return StorageRepository(FirebaseStorage.instance);
}

class StorageRepository {
  final FirebaseStorage _storage;
  final _uuid = const Uuid();
  final _logger = Logger('StorageRepository');

  StorageRepository(this._storage);

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 70,
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      throw Exception('Failed to compress image');
    }

    return File(result.path);
  }

  Future<String> uploadImage({
    required File file,
    required String path,
    void Function(double)? onProgress,
  }) async {
    try {
      // 画像を圧縮
      final compressedFile = await _compressImage(file);
      
      // アップロード
      final ref = _storage.ref().child(path);
      final task = ref.putFile(compressedFile);

      // 進捗状況を監視
      if (onProgress != null) {
        task.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // アップロード完了を待機
      await task;

      // ダウンロードURLを取得
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      _logger.severe('Failed to upload image: $e');
      throw Exception('画像のアップロードに失敗しました');
    }
  }

  Future<List<String>> uploadImages(List<File> files) async {
    try {
      final futures = files.map((file) => uploadImage(file: file, path: 'izakaya_images/${_uuid.v4()}.jpg'));
      return await Future.wait(futures);
    } catch (e) {
      _logger.severe('Failed to upload images: $e');
      throw Exception('画像のアップロードに失敗しました');
    }
  }

  Future<void> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // URLが無効な場合や、既に削除されている場合は無視
      _logger.warning('Failed to delete image: $e');
    }
  }

  Future<void> deleteImages(List<String> urls) async {
    final futures = urls.map(deleteImage);
    await Future.wait(futures);
  }
} 