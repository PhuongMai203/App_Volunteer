import 'package:cloud_firestore/cloud_firestore.dart';

import '../../user_repository.dart';

class MyUser {
  final String userId;
  final String email;
  final String name;
  final String? fullName;
  final String? idNumber;
  final String? role;
  final bool? isApproved;

  final String? gender;
  final bool hasActiveCart;
  final String avatarUrl;

  final int donationCount;
  final int campaignCount;
  final int createdRequests;
  final List<String> joinedEvents;
  final List<String> registeredEvents;

  final String? location;
  final int? birthYear;
  final String? phone;
  final bool? linkedBank;
  final bool? linkedZaloPay;
  final bool? linkedMoMo;

  final String? rank;
  final String? address;

  final Timestamp createdAt;

  const MyUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.createdAt,
    this.fullName,
    this.idNumber,
    this.role,
    this.gender,
    this.isApproved,
    this.hasActiveCart = false,
    this.avatarUrl = '',
    this.donationCount = 0,
    this.campaignCount = 0,
    this.createdRequests = 0,
    this.joinedEvents = const [],
    this.registeredEvents = const [],
    this.location,
    this.birthYear,
    this.phone,
    this.linkedBank,
    this.linkedZaloPay,
    this.linkedMoMo,
    this.rank = 'Đồng',
    this.address,
  });

  MyUser copyWith({
    String? userId,
    String? email,
    String? name,
    String? fullName,
    String? idNumber,
    String? role,
    bool? isApproved,
    String? gender,
    bool? hasActiveCart,
    String? avatarUrl,
    int? donationCount,
    int? campaignCount,
    int? createdRequests,
    List<String>? joinedEvents,
    List<String>? registeredEvents,
    String? location,
    int? birthYear,
    String? phone,
    bool? linkedBank,
    bool? linkedZaloPay,
    bool? linkedMoMo,
    String? rank,
    String? address,
    Timestamp? createdAt,
  }) {
    return MyUser(
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
      donationCount: donationCount ?? this.donationCount,
      campaignCount: campaignCount ?? this.campaignCount,
      createdRequests: createdRequests ?? this.createdRequests,
      joinedEvents: joinedEvents ?? List.from(this.joinedEvents),
      registeredEvents: registeredEvents ?? List.from(this.registeredEvents),
      location: location ?? this.location,
      birthYear: birthYear ?? this.birthYear,
      phone: phone ?? this.phone,
      linkedBank: linkedBank ?? this.linkedBank,
      linkedZaloPay: linkedZaloPay ?? this.linkedZaloPay,
      linkedMoMo: linkedMoMo ?? this.linkedMoMo,
      rank: rank ?? this.rank,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,
      email: email,
      name: name,
      fullName: fullName,
      idNumber: idNumber,
      role: role,
      isApproved: isApproved ?? false,
      gender: gender,
      hasActiveCart: hasActiveCart,
      avatarUrl: avatarUrl,
      donationCount: donationCount,
      campaignCount: campaignCount,
      createdRequests: createdRequests,
      joinedEvents: joinedEvents,
      registeredEvents: registeredEvents,
      location: location,
      birthYear: birthYear,
      phone: phone,
      linkedBank: linkedBank,
      linkedZaloPay: linkedZaloPay,
      linkedMoMo: linkedMoMo,
      rank: rank,
      address: address,
      createdAt: createdAt,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      name: entity.name,
      fullName: entity.fullName,
      idNumber: entity.idNumber,
      role: entity.role,
      gender: entity.gender,
      isApproved: entity.isApproved,
      hasActiveCart: entity.hasActiveCart ?? false,
      avatarUrl: entity.avatarUrl ?? '',
      donationCount: entity.donationCount ?? 0,
      campaignCount: entity.campaignCount ?? 0,
      createdRequests: entity.createdRequests ?? 0,
      joinedEvents: List<String>.from(entity.joinedEvents ?? []),
      registeredEvents: List<String>.from(entity.registeredEvents ?? []),
      location: entity.location,
      birthYear: entity.birthYear,
      phone: entity.phone,
      linkedBank: entity.linkedBank,
      linkedZaloPay: entity.linkedZaloPay,
      linkedMoMo: entity.linkedMoMo,
      rank: entity.rank,
      address: entity.address,
      createdAt: entity.createdAt,
    );
  }

  static MyUser fromMap(Map<String, dynamic> map) {
    return MyUser(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      fullName: map['fullName'],
      idNumber: map['idNumber'],
      role: map['role'],
      gender: map['gender'],
      isApproved: map['isApproved'],
      hasActiveCart: map['hasActiveCart'] ?? false,
      avatarUrl: map['avatarUrl'] ?? '',
      donationCount: map['donationCount'] ?? 0,
      campaignCount: map['campaignCount'] ?? 0,
      createdRequests: map['createdRequests'] ?? 0,
      joinedEvents: List<String>.from(map['joinedEvents'] ?? []),
      registeredEvents: List<String>.from(map['registeredEvents'] ?? []),
      location: map['location'],
      birthYear: map['birthYear'],
      phone: map['phone'],
      linkedBank: map['linkedBank'],
      linkedZaloPay: map['linkedZaloPay'],
      linkedMoMo: map['linkedMoMo'],
      rank: map['rank'],
      address: map['address'], // ✅ FROMMAP
      createdAt: map['createdAt'],
    );
  }

  @override
  String toString() {
    return '''MyUser(
      userId: $userId,
      email: $email,
      name: $name,
      fullName: $fullName,
      idNumber: $idNumber,
      role: $role,
      gender: $gender,
      isApproved: $isApproved,
      hasActiveCart: $hasActiveCart,
      avatarUrl: $avatarUrl,
      donationCount: $donationCount,
      campaignCount: $campaignCount,
      createdRequests: $createdRequests,
      joinedEvents: ${joinedEvents.length} items,
      registeredEvents: ${registeredEvents.length} items,
      location: $location,
      birthYear: $birthYear,
      phone: $phone,
      linkedBank: $linkedBank,
      linkedZaloPay: $linkedZaloPay,
      linkedMoMo: $linkedMoMo,
      rank: $rank,
      address: $address, // ✅ IN RA ADDRESS
      createdAt: $createdAt
    )''';
  }
}
