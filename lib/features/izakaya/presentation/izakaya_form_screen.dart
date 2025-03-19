import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/izakaya_repository.dart';
import '../data/storage_repository.dart';
import '../domain/izakaya.dart';
import 'image_picker_widget.dart';

class IzakayaFormScreen extends HookConsumerWidget {
  const IzakayaFormScreen({super.key, this.izakaya});

  final Izakaya? izakaya;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isLoading = useState(false);
    final selectedImages = useState<List<File>>([]);
    final deletedImageUrls = useState<List<String>>([]);
    final uploadProgress = useState<Map<String, double>>({});

    Future<void> onSubmit() async {
      if (!formKey.currentState!.saveAndValidate()) return;

      final values = formKey.currentState!.value;
      final now = DateTime.now();

      try {
        isLoading.value = true;

        // 画像のアップロード
        final storage = ref.read(storageRepositoryProvider);
        final uploadedUrls = await Future.wait(
          selectedImages.value.map((file) async {
            final path = 'izakaya_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
            return storage.uploadImage(
              file: file,
              path: path,
              onProgress: (progress) {
                uploadProgress.value = {
                  ...uploadProgress.value,
                  file.path: progress,
                };
              },
            );
          }),
        );

        // 削除された画像の処理
        await Future.wait(
          deletedImageUrls.value.map((url) => storage.deleteImage(url)),
        );

        // 既存の画像と新しい画像を結合
        final images = [
          ...?izakaya?.images
              .where((url) => !deletedImageUrls.value.contains(url)),
          ...uploadedUrls,
        ];

        final newIzakaya = Izakaya(
          id: izakaya?.id,
          name: values['name'] as String,
          address: values['address'] as String,
          phone: values['phone'] as String,
          businessHours: values['businessHours'] as String,
          holidays: values['holidays'] as String,
          budget: int.parse(values['budget'] as String),
          genre: values['genre'] as String,
          images: images,
          isPublic: values['isPublic'] as bool,
          userId: 'dummy-user-id', // TODO: 認証機能と連携
          createdAt: izakaya?.createdAt ?? now,
          updatedAt: now,
        );

        if (izakaya == null) {
          await ref.read(izakayaRepositoryProvider).create(newIzakaya);
        } else {
          await ref.read(izakayaRepositoryProvider).update(newIzakaya);
        }

        if (!context.mounted) return;
        Navigator.of(context).pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        isLoading.value = false;
      }
    }

    void onImageDeleted(String url) {
      deletedImageUrls.value = [...deletedImageUrls.value, url];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(izakaya == null ? '居酒屋を登録' : '居酒屋情報を編集'),
      ),
      body: FormBuilder(
        key: formKey,
        initialValue: {
          'name': izakaya?.name ?? '',
          'address': izakaya?.address ?? '',
          'phone': izakaya?.phone ?? '',
          'businessHours': izakaya?.businessHours ?? '',
          'holidays': izakaya?.holidays ?? '',
          'budget': izakaya?.budget.toString() ?? '',
          'genre': izakaya?.genre ?? '',
          'isPublic': izakaya?.isPublic ?? true,
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(
                  labelText: '店名',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: '店名を入力してください'),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'address',
                decoration: const InputDecoration(
                  labelText: '住所',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: '住所を入力してください'),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'phone',
                decoration: const InputDecoration(
                  labelText: '電話番号',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: '電話番号を入力してください'),
                  FormBuilderValidators.numeric(errorText: '数字のみ入力可能です'),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'businessHours',
                decoration: const InputDecoration(
                  labelText: '営業時間',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: '営業時間を入力してください'),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'holidays',
                decoration: const InputDecoration(
                  labelText: '定休日',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: '定休日を入力してください'),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'budget',
                decoration: const InputDecoration(
                  labelText: '予算',
                  border: OutlineInputBorder(),
                  suffixText: '円',
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: '予算を入力してください'),
                  FormBuilderValidators.numeric(errorText: '数字のみ入力可能です'),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'genre',
                decoration: const InputDecoration(
                  labelText: 'ジャンル',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'ジャンルを入力してください'),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderSwitch(
                name: 'isPublic',
                title: const Text('公開する'),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 16),
              ImagePickerWidget(
                initialImages: izakaya?.images ?? [],
                onImagesChanged: (images) => selectedImages.value = images,
                onImageDeleted: onImageDeleted,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: isLoading.value ? null : onSubmit,
                child: isLoading.value
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(izakaya == null ? '登録する' : '更新する'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 