import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('検索'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              leading: const Icon(Icons.search),
              hintText: '居酒屋を検索',
              onChanged: (value) {
                // TODO: 検索機能の実装
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('和食'),
                    selected: false,
                    onSelected: (selected) {
                      // TODO: フィルター機能の実装
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('焼き鳥'),
                    selected: false,
                    onSelected: (selected) {
                      // TODO: フィルター機能の実装
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('居酒屋'),
                    selected: false,
                    onSelected: (selected) {
                      // TODO: フィルター機能の実装
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('イタリアン'),
                    selected: false,
                    onSelected: (selected) {
                      // TODO: フィルター機能の実装
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 0, // TODO: 検索結果の表示
              itemBuilder: (context, index) {
                return const SizedBox(); // TODO: 検索結果アイテムの表示
              },
            ),
          ),
        ],
      ),
    );
  }
} 