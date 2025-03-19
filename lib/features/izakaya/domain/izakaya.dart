import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'izakaya.freezed.dart';
part 'izakaya.g.dart';

@freezed
class Izakaya with _$Izakaya {
  const factory Izakaya({
    String? id,
    required String name,
    required String address,
    required String phone,
    required String businessHours,
    required String holidays,
    required int budget,
    required String genre,
    required List<String> images,
    required bool isPublic,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Izakaya;

  factory Izakaya.fromJson(Map<String, dynamic> json) => _$IzakayaFromJson(json);

  factory Izakaya.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Izakaya.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate(),
    });
  }

  const Izakaya._();

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return {
      ...json,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
} 