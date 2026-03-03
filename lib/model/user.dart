import 'package:equatable/equatable.dart';

enum ProfileTheme {
  light,
  dark,
  blue,
  purple,
  green,
  orange,
  custom,
}

enum ProfileAccentColor {
  blue,
  red,
  pink,
  purple,
  green,
  orange,
  yellow,
  custom,
}

enum ProfileLayout {
  default,
  compact,
  detailed,
  minimal,
}

enum ProfilePrivacy {
  public,
  private,
  friends,
}

enum ProfileVisibility {
  showEmail,
  showLocation,
  showWebsite,
  showDob,
  showFollowers,
  showFollowing,
  showStats,
}

extension ProfileThemeExtension on ProfileTheme {
  String get displayName {
    switch (this) {
      case ProfileTheme.light:
        return 'Light';
      case ProfileTheme.dark:
        return 'Dark';
      case ProfileTheme.blue:
        return 'Blue';
      case ProfileTheme.purple:
        return 'Purple';
      case ProfileTheme.green:
        return 'Green';
      case ProfileTheme.orange:
        return 'Orange';
      case ProfileTheme.custom:
        return 'Custom';
    }
  }

  static ProfileTheme fromString(String theme) {
    switch (theme.toLowerCase()) {
      case 'light':
        return ProfileTheme.light;
      case 'dark':
        return ProfileTheme.dark;
      case 'blue':
        return ProfileTheme.blue;
      case 'purple':
        return ProfileTheme.purple;
      case 'green':
        return ProfileTheme.green;
      case 'orange':
        return ProfileTheme.orange;
      case 'custom':
        return ProfileTheme.custom;
      default:
        return ProfileTheme.light;
    }
  }
}

extension ProfileAccentColorExtension on ProfileAccentColor {
  String get displayName {
    switch (this) {
      case ProfileAccentColor.blue:
        return 'Blue';
      case ProfileAccentColor.red:
        return 'Red';
      case ProfileAccentColor.pink:
        return 'Pink';
      case ProfileAccentColor.purple:
        return 'Purple';
      case ProfileAccentColor.green:
        return 'Green';
      case ProfileAccentColor.orange:
        return 'Orange';
      case ProfileAccentColor.yellow:
        return 'Yellow';
      case ProfileAccentColor.custom:
        return 'Custom';
    }
  }

  static ProfileAccentColor fromString(String color) {
    switch (color.toLowerCase()) {
      case 'blue':
        return ProfileAccentColor.blue;
      case 'red':
        return ProfileAccentColor.red;
      case 'pink':
        return ProfileAccentColor.pink;
      case 'purple':
        return ProfileAccentColor.purple;
      case 'green':
        return ProfileAccentColor.green;
      case 'orange':
        return ProfileAccentColor.orange;
      case 'yellow':
        return ProfileAccentColor.yellow;
      case 'custom':
        return ProfileAccentColor.custom;
      default:
        return ProfileAccentColor.blue;
    }
  }
}

extension ProfileLayoutExtension on ProfileLayout {
  String get displayName {
    switch (this) {
      case ProfileLayout.default:
        return 'Default';
      case ProfileLayout.compact:
        return 'Compact';
      case ProfileLayout.detailed:
        return 'Detailed';
      case ProfileLayout.minimal:
        return 'Minimal';
    }
  }

  static ProfileLayout fromString(String layout) {
    switch (layout.toLowerCase()) {
      case 'default':
        return ProfileLayout.default;
      case 'compact':
        return ProfileLayout.compact;
      case 'detailed':
        return ProfileLayout.detailed;
      case 'minimal':
        return ProfileLayout.minimal;
      default:
        return ProfileLayout.default;
    }
  }
}

extension ProfilePrivacyExtension on ProfilePrivacy {
  String get displayName {
    switch (this) {
      case ProfilePrivacy.public:
        return 'Public';
      case ProfilePrivacy.private:
        return 'Private';
      case ProfilePrivacy.friends:
        return 'Friends';
    }
  }

  static ProfilePrivacy fromString(String privacy) {
    switch (privacy.toLowerCase()) {
      case 'public':
        return ProfilePrivacy.public;
      case 'private':
        return ProfilePrivacy.private;
      case 'friends':
        return ProfilePrivacy.friends;
      default:
        return ProfilePrivacy.public;
    }
  }
}

// ignore: must_be_immutable
class UserModel extends Equatable {
  String? key;
  String? email;
  String? userId;
  String? displayName;
  String? userName;
  String? webSite;
  String? profilePic;
  String? bannerImage;
  String? contact;
  String? bio;
  String? location;
  String? dob;
  String? createdAt;
  bool? isVerified;
  int? followers;
  int? following;
  String? fcmToken;
  List<String>? followersList;
  List<String>? followingList;
  
  // Profile customization properties
  ProfileTheme? profileTheme;
  ProfileAccentColor? accentColor;
  ProfileLayout? profileLayout;
  ProfilePrivacy? profilePrivacy;
  Set<ProfileVisibility>? visibilitySettings;
  String? customBackgroundColor;
  String? customTextColor;
  String? customAccentColor;
  bool? showProfileViews;
  bool? showTweetCount;
  bool? showFollowingCount;
  bool? showFollowerCount;
  bool? showJoinDate;
  bool? showLocation;
  bool? showWebsite;
  bool? showEmail;
  bool? allowDirectMessages;
  bool? allowTagging;
  bool? allowSearchIndexing;
  String? profileBackgroundImage;
  String? profileBorderColor;
  double? profileBorderWidth;
  String? profileFont;
  double? profileFontSize;
  bool? enableAnimations;
  bool? enableParticles;
  String? customCSS;

  UserModel(
      {this.email,
      this.userId,
      this.displayName,
      this.profilePic,
      this.bannerImage,
      this.key,
      this.contact,
      this.bio,
      this.dob,
      this.location,
      this.createdAt,
      this.userName,
      this.followers,
      this.following,
      this.webSite,
      this.isVerified,
      this.fcmToken,
      this.followersList,
      this.followingList});

  UserModel.fromJson(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return;
    }
    followersList ??= [];
    email = map['email'];
    userId = map['userId'];
    displayName = map['displayName'];
    profilePic = map['profilePic'];
    bannerImage = map['bannerImage'];
    key = map['key'];
    dob = map['dob'];
    bio = map['bio'];
    location = map['location'];
    contact = map['contact'];
    createdAt = map['createdAt'];
    followers = map['followers'];
    following = map['following'];
    userName = map['userName'];
    webSite = map['webSite'];
    fcmToken = map['fcmToken'];
    isVerified = map['isVerified'] ?? false;
    if (map['followerList'] != null) {
      followersList = <String>[];
      map['followerList'].forEach((value) {
        followersList!.add(value);
      });
    }
    followers = followersList != null ? followersList!.length : null;
    if (map['followingList'] != null) {
      followingList = <String>[];
      map['followingList'].forEach((value) {
        followingList!.add(value);
      });
    }
    following = followingList != null ? followingList!.length : null;
  }
  toJson() {
    return {
      'key': key,
      "userId": userId,
      "email": email,
      'displayName': displayName,
      'profilePic': profilePic,
      'bannerImage': bannerImage,
      'contact': contact,
      'dob': dob,
      'bio': bio,
      'location': location,
      'createdAt': createdAt,
      'followers': followersList != null ? followersList!.length : null,
      'following': followingList != null ? followingList!.length : null,
      'userName': userName,
      'webSite': webSite,
      'isVerified': isVerified ?? false,
      'fcmToken': fcmToken,
      'followerList': followersList,
      'followingList': followingList
    };
  }

  UserModel copyWith({
    String? email,
    String? userId,
    String? displayName,
    String? profilePic,
    String? key,
    String? contact,
    String? bio,
    String? dob,
    String? bannerImage,
    String? location,
    String? createdAt,
    String? userName,
    int? followers,
    int? following,
    String? webSite,
    bool? isVerified,
    String? fcmToken,
    List<String>? followingList,
    List<String>? followersList,
  }) {
    return UserModel(
      email: email ?? this.email,
      bio: bio ?? this.bio,
      contact: contact ?? this.contact,
      createdAt: createdAt ?? this.createdAt,
      displayName: displayName ?? this.displayName,
      dob: dob ?? this.dob,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isVerified: isVerified ?? this.isVerified,
      key: key ?? this.key,
      location: location ?? this.location,
      profilePic: profilePic ?? this.profilePic,
      bannerImage: bannerImage ?? this.bannerImage,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      webSite: webSite ?? this.webSite,
      fcmToken: fcmToken ?? this.fcmToken,
      followersList: followersList ?? this.followersList,
      followingList: followingList ?? this.followingList,
    );
  }

  String get getFollower {
    return '${followers ?? 0}';
  }

  String get getFollowing {
    return '${following ?? 0}';
  }

  @override
  List<Object?> get props => [
        key,
        email,
        userId,
        displayName,
        userName,
        webSite,
        profilePic,
        bannerImage,
        contact,
        bio,
        location,
        dob,
        createdAt,
        isVerified,
        followers,
        following,
        fcmToken,
        followersList,
        followingList
      ];
}
