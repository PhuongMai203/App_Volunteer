import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/entities.dart';

export 'user.dart';

class MyUser {
  final String userId;
  final String email;
  final String name;
  final String? fullName;
  final String? idNumber;
  final String? role;
  final bool isApproved;
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
  final bool linkedBank;
  final bool linkedZaloPay;
  final bool linkedMoMo;
  final String? gender;
  final Timestamp createdAt;
  final String? rank;

  const MyUser({
    required this.userId,
    required this.email,
    required this.name,
    this.fullName,
    this.idNumber,
    this.role,
    this.isApproved = false,
    this.hasActiveCart = false,
    this.avatarUrl = '',
    this.donationCount = 0,
    this.campaignCount = 0,
    this.createdRequests = 0,
    this.joinedEvents = const [],
    this.registeredEvents = const [],
    this.location = '',
    this.address = '', // ✅ Thêm address
    this.birthYear = 0,
    this.phone = '',
    this.linkedBank = false,
    this.linkedZaloPay = false,
    this.linkedMoMo = false,
    this.gender = '',
    required this.createdAt,
    this.rank = 'Đồng',
  });

  static final empty = MyUser(
    userId: '',
    email: '',
    name: '',
    fullName: '',
    idNumber: '',
    role: '',
    isApproved: true,
    linkedBank: false,
    linkedZaloPay: false,
    linkedMoMo: false,
    gender: '',
    address: '', // ✅ Thêm address
    createdAt: Timestamp.now(),
    rank: '',
  );

  MyUser copyWith({
    String? userId,
    String? email,
    String? name,
    String? fullName,
    String? idNumber,
    String? role,
    bool? isApproved,
    bool? hasActiveCart,
    String? avatarUrl,
    int? donationCount,
    int? campaignCount,
    int? createdRequests,
    List<String>? joinedEvents,
    List<String>? registeredEvents,
    String? location,
    String? address, // ✅ Thêm address
    int? birthYear,
    String? phone,
    bool? linkedBank,
    bool? linkedZaloPay,
    bool? linkedMoMo,
    String? gender,
    Timestamp? createdAt,
    String? rank,
  }) {
    return MyUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      idNumber: idNumber ?? this.idNumber,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
      hasActiveCart: hasActiveCart ?? this.hasActiveCart,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      donationCount: donationCount ?? this.donationCount,
      campaignCount: campaignCount ?? this.campaignCount,
      createdRequests: createdRequests ?? this.createdRequests,
      joinedEvents: joinedEvents ?? List.from(this.joinedEvents),
      registeredEvents: registeredEvents ?? List.from(this.registeredEvents),
      location: location ?? this.location,
      address: address ?? this.address, // ✅ Thêm address
      birthYear: birthYear ?? this.birthYear,
      phone: phone ?? this.phone,
      linkedBank: linkedBank ?? this.linkedBank,
      linkedZaloPay: linkedZaloPay ?? this.linkedZaloPay,
      linkedMoMo: linkedMoMo ?? this.linkedMoMo,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      rank: rank ?? this.rank,
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
      isApproved: isApproved,
      hasActiveCart: hasActiveCart,
      avatarUrl: avatarUrl,
      donationCount: donationCount,
      campaignCount: campaignCount,
      createdRequests: createdRequests,
      joinedEvents: joinedEvents,
      registeredEvents: registeredEvents,
      location: location,
      address: address, // ✅ Thêm address
      birthYear: birthYear,
      phone: phone,
      linkedBank: linkedBank,
      linkedZaloPay: linkedZaloPay,
      linkedMoMo: linkedMoMo,
      gender: gender,
      createdAt: createdAt,
      rank: rank,
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
      isApproved: entity.isApproved ?? false,
      hasActiveCart: entity.hasActiveCart ?? false,
      avatarUrl: entity.avatarUrl ?? '',
      donationCount: entity.donationCount ?? 0,
      campaignCount: entity.campaignCount ?? 0,
      createdRequests: entity.createdRequests ?? 0,
      joinedEvents: (entity.joinedEvents is List<String>) ? List.from(entity.joinedEvents) : [],
      registeredEvents: (entity.registeredEvents is List<String>) ? List.from(entity.registeredEvents) : [],
      location: entity.location ?? '',
      address: entity.address ?? '', // ✅ Thêm address
      birthYear: entity.birthYear ?? 0,
      phone: entity.phone ?? '',
      linkedBank: entity.linkedBank ?? false,
      linkedZaloPay: entity.linkedZaloPay ?? false,
      linkedMoMo: entity.linkedMoMo ?? false,
      gender: entity.gender ?? '',
      createdAt: entity.createdAt ?? Timestamp.now(),
      rank: entity.rank ?? '',
    );
  }

  static MyUserEntity fromMap(Map<String, dynamic> map) {
    return MyUserEntity(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      fullName: map['fullName'],
      idNumber: map['idNumber'],
      role: map['role'],
      isApproved: map['isApproved'] ?? false,
      hasActiveCart: map['hasActiveCart'] ?? false,
      avatarUrl: map['avatarUrl'] ?? '',
      donationCount: map['donationCount'] ?? 0,
      campaignCount: map['campaignCount'] ?? 0,
      createdRequests: map['createdRequests'] ?? 0,
      joinedEvents: List<String>.from(map['joinedEvents'] ?? []),
      registeredEvents: List<String>.from(map['registeredEvents'] ?? []),
      location: map['location'] ?? '',
      address: map['address'] ?? '', // ✅ Thêm address
      birthYear: map['birthYear'] ?? 0,
      phone: map['phone'] ?? '',
      linkedBank: map['linkedBank'] ?? false,
      linkedZaloPay: map['linkedZaloPay'] ?? false,
      linkedMoMo: map['linkedMoMo'] ?? false,
      gender: map['gender'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      rank: map['rank'] ?? '',
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
      isApproved: $isApproved,
      campaignCount: $campaignCount,
      createdRequests: $createdRequests,
      location: $location,
      address: $address,
      phone: $phone,
      gender: $gender,
      createdAt: $createdAt,
      rank: $rank
    )''';
  }
}
