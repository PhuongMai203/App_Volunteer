import 'package:cloud_firestore/cloud_firestore.dart';

class MyUserEntity {
  final String userId;
  final String email;
  final String name;
  final String? fullName;
  final String? idNumber;
  final String? role;
  final String? gender;
  final bool isApproved;
  final Timestamp createdAt;
  final bool hasActiveCart;
  final String avatarUrl;

  final int donationCount;
  final int campaignCount;
  final int createdRequests;
  final List<String> joinedEvents;
  final List<String> registeredEvents;

  final String? location;
  final String? address;
  final int? birthYear;
  final String? phone;
  final bool? linkedBank;
  final bool? linkedZaloPay;
  final bool? linkedMoMo;

  final String? rank;

  MyUserEntity({
    required this.userId,
    required this.email,
    required this.name,
    this.fullName,
    this.idNumber,
    this.role,
    this.gender,
    required this.isApproved,
    this.hasActiveCart = false,
    this.avatarUrl = '',
    required this.createdAt,
    this.donationCount = 0,
    this.campaignCount = 0,
    this.createdRequests = 0,
    this.joinedEvents = const [],
    this.registeredEvents = const [],
    this.location,
    this.address, // ✅ Constructor
    this.birthYear,
    this.phone,
    this.linkedBank,
    this.linkedZaloPay,
    this.linkedMoMo,
    this.rank = 'Đồng',
  });

  MyUserEntity copyWith({
    String? userId,
    String? email,
    String? name,
    String? fullName,
    String? idNumber,
    String? role,
    String? gender,
    bool? isApproved,
    bool? hasActiveCart,
    String? avatarUrl,
    Timestamp? createdAt,
    int? donationCount,
    int? campaignCount,
    int? createdRequests,
    List<String>? joinedEvents,
    List<String>? registeredEvents,
    String? location,
    String? address, // ✅ copyWith
    int? birthYear,
    String? phone,
    bool? linkedBank,
    bool? linkedZaloPay,
    bool? linkedMoMo,
    String? rank,
  }) {
    return MyUserEntity(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      idNumber: idNumber ?? this.idNumber,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      isApproved: isApproved ?? this.isApproved,
      hasActiveCart: hasActiveCart ?? this.hasActiveCart,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      donationCount: donationCount ?? this.donationCount,
      campaignCount: campaignCount ?? this.campaignCount,
      createdRequests: createdRequests ?? this.createdRequests,
      joinedEvents: joinedEvents ?? List.from(this.joinedEvents),
      registeredEvents: registeredEvents ?? List.from(this.registeredEvents),
      location: location ?? this.location,
      address: address ?? this.address, // ✅
      birthYear: birthYear ?? this.birthYear,
      phone: phone ?? this.phone,
      linkedBank: linkedBank ?? this.linkedBank,
      linkedZaloPay: linkedZaloPay ?? this.linkedZaloPay,
      linkedMoMo: linkedMoMo ?? this.linkedMoMo,
      rank: rank ?? this.rank,
    );
  }

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'fullName': fullName,
      'idNumber': idNumber,
      'role': role,
      'gender': gender,
      'isApproved': isApproved,
      'hasActiveCart': hasActiveCart,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt,
      'donationCount': donationCount,
      'campaignCount': campaignCount,
      'createdRequests': createdRequests,
      'joinedEvents': joinedEvents,
      'registeredEvents': registeredEvents,
      'location': location,
      'address': address, // ✅ map
      'birthYear': birthYear,
      'phone': phone,
      'linkedBank': linkedBank,
      'linkedZaloPay': linkedZaloPay,
      'linkedMoMo': linkedMoMo,
      'rank': rank,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
      userId: doc['userId']?.toString() ?? '',
      email: doc['email']?.toString() ?? '',
      name: doc['name']?.toString() ?? '',
      fullName: doc['fullName']?.toString(),
      idNumber: doc['idNumber']?.toString(),
      role: doc['role']?.toString(),
      gender: doc['gender']?.toString(),
      isApproved: doc['isApproved'] as bool? ?? false,
      hasActiveCart: doc['hasActiveCart'] as bool? ?? false,
      avatarUrl: doc['avatarUrl']?.toString() ?? doc['avatar']?.toString() ?? '',
      createdAt: doc['createdAt'] ?? Timestamp.now(),
      donationCount: (doc['donationCount'] as int?) ?? 0,
      campaignCount: (doc['campaignCount'] as int?) ?? 0,
      createdRequests: (doc['createdRequests'] as int?) ?? 0,
      joinedEvents: List<String>.from((doc['joinedEvents'] as List<dynamic>? ?? []).map((e) => e.toString())),
      registeredEvents: List<String>.from((doc['registeredEvents'] as List<dynamic>? ?? []).map((e) => e.toString())),
      location: doc['location']?.toString(),
      address: doc['address']?.toString(), // ✅ from doc
      birthYear: doc['birthYear'] as int?,
      phone: doc['phone']?.toString(),
      linkedBank: doc['linkedBank'] as bool?,
      linkedZaloPay: doc['linkedZaloPay'] as bool?,
      linkedMoMo: doc['linkedMoMo'] as bool?,
      rank: doc['rank']?.toString(),
    );
  }

  static MyUserEntity fromMap(Map<String, dynamic> map) {
    return MyUserEntity(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      fullName: map['fullName'] as String?,
      idNumber: map['idNumber'],
      role: map['role'],
      gender: map['gender'],
      isApproved: map['isApproved'] ?? false,
      hasActiveCart: map['hasActiveCart'] ?? false,
      avatarUrl: map['avatarUrl'] ?? map['avatar'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      donationCount: map['donationCount'] ?? 0,
      campaignCount: map['campaignCount'] ?? 0,
      createdRequests: map['createdRequests'] ?? 0,
      joinedEvents: List<String>.from(map['joinedEvents'] ?? []),
      registeredEvents: List<String>.from(map['registeredEvents'] ?? []),
      location: map['location'],
      address: map['address'], // ✅ from map
      birthYear: map['birthYear'],
      phone: map['phone'],
      linkedBank: map['linkedBank'],
      linkedZaloPay: map['linkedZaloPay'],
      linkedMoMo: map['linkedMoMo'],
      rank: map['rank'],
    );
  }
}
