// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'izakaya.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IzakayaImpl _$$IzakayaImplFromJson(Map<String, dynamic> json) =>
    _$IzakayaImpl(
      id: json['id'] as String?,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      businessHours: json['businessHours'] as String,
      holidays: json['holidays'] as String,
      budget: (json['budget'] as num).toInt(),
      genre: json['genre'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      isPublic: json['isPublic'] as bool,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$IzakayaImplToJson(_$IzakayaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
      'businessHours': instance.businessHours,
      'holidays': instance.holidays,
      'budget': instance.budget,
      'genre': instance.genre,
      'images': instance.images,
      'isPublic': instance.isPublic,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
