enum ModerationStatus {
  pending,
  approved,
  rejected,
  underReview,
  flagged,
  removed,
  suspended,
  banned,
}

enum ModerationAction {
  approve,
  reject,
  flag,
  remove,
  suspend,
  ban,
  warn,
  shadowBan,
}

enum ReportReason {
  spam,
  harassment,
  hateSpeech,
  violence,
  adultContent,
  copyright,
  impersonation,
  misinformation,
  selfHarm,
  illegalContent,
  privacyViolation,
  threats,
  bullying,
  other,
}

enum ModerationSeverity {
  low,
  medium,
  high,
  critical,
}

enum ContentType {
  tweet,
  reply,
  retweet,
  quote,
  message,
  profile,
  banner,
  media,
  link,
  hashtag,
}

enum ModerationFilter {
  profanity,
  hateSpeech,
  spam,
  links,
  mentions,
  hashtags,
  media,
  emojis,
}

enum ModerationPriority {
  low,
  normal,
  high,
  urgent,
}

extension ModerationStatusExtension on ModerationStatus {
  String get displayName {
    switch (this) {
      case ModerationStatus.pending:
        return 'Pending';
      case ModerationStatus.approved:
        return 'Approved';
      case ModerationStatus.rejected:
        return 'Rejected';
      case ModerationStatus.underReview:
        return 'Under Review';
      case ModerationStatus.flagged:
        return 'Flagged';
      case ModerationStatus.removed:
        return 'Removed';
      case ModerationStatus.suspended:
        return 'Suspended';
      case ModerationStatus.banned:
        return 'Banned';
    }
  }

  String get description {
    switch (this) {
      case ModerationStatus.pending:
        return 'Content is pending moderation review';
      case ModerationStatus.approved:
        return 'Content has been approved and is visible';
      case ModerationStatus.rejected:
        return 'Content has been rejected and hidden';
      case ModerationStatus.underReview:
        return 'Content is currently under review';
      case ModerationStatus.flagged:
        return 'Content has been flagged for review';
      case ModerationStatus.removed:
        return 'Content has been removed';
      case ModerationStatus.suspended:
        return 'User account is suspended';
      case ModerationStatus.banned:
        return 'User account is permanently banned';
    }
  }

  static ModerationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ModerationStatus.pending;
      case 'approved':
        return ModerationStatus.approved;
      case 'rejected':
        return ModerationStatus.rejected;
      case 'underreview':
        return ModerationStatus.underReview;
      case 'flagged':
        return ModerationStatus.flagged;
      case 'removed':
        return ModerationStatus.removed;
      case 'suspended':
        return ModerationStatus.suspended;
      case 'banned':
        return ModerationStatus.banned;
      default:
        return ModerationStatus.pending;
    }
  }
}

extension ModerationActionExtension on ModerationAction {
  String get displayName {
    switch (this) {
      case ModerationAction.approve:
        return 'Approve';
      case ModerationAction.reject:
        return 'Reject';
      case ModerationAction.flag:
        return 'Flag';
      case ModerationAction.remove:
        return 'Remove';
      case ModerationAction.suspend:
        return 'Suspend';
      case ModerationAction.ban:
        return 'Ban';
      case ModerationAction.warn:
        return 'Warn';
      case ModerationAction.shadowBan:
        return 'Shadow Ban';
    }
  }

  String get description {
    switch (this) {
      case ModerationAction.approve:
        return 'Approve content and make it visible';
      case ModerationAction.reject:
        return 'Reject content and hide it';
      case ModerationAction.flag:
        return 'Flag content for review';
      case ModerationAction.remove:
        return 'Remove content permanently';
      case ModerationAction.suspend:
        return 'Suspend user account temporarily';
      case ModerationAction.ban:
        return 'Ban user account permanently';
      case ModerationAction.warn:
        return 'Send warning to user';
      case ModerationAction.shadowBan:
        return 'Shadow ban user (hidden restriction)';
    }
  }

  static ModerationAction fromString(String action) {
    switch (action.toLowerCase()) {
      case 'approve':
        return ModerationAction.approve;
      case 'reject':
        return ModerationAction.reject;
      case 'flag':
        return ModerationAction.flag;
      case 'remove':
        return ModerationAction.remove;
      case 'suspend':
        return ModerationAction.suspend;
      case 'ban':
        return ModerationAction.ban;
      case 'warn':
        return ModerationAction.warn;
      case 'shadowban':
        return ModerationAction.shadowBan;
      default:
        return ModerationAction.flag;
    }
  }
}

extension ReportReasonExtension on ReportReason {
  String get displayName {
    switch (this) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Harassment';
      case ReportReason.hateSpeech:
        return 'Hate Speech';
      case ReportReason.violence:
        return 'Violence';
      case ReportReason.adultContent:
        return 'Adult Content';
      case ReportReason.copyright:
        return 'Copyright';
      case ReportReason.impersonation:
        return 'Impersonation';
      case ReportReason.misinformation:
        return 'Misinformation';
      case ReportReason.selfHarm:
        return 'Self Harm';
      case ReportReason.illegalContent:
        return 'Illegal Content';
      case ReportReason.privacyViolation:
        return 'Privacy Violation';
      case ReportReason.threats:
        return 'Threats';
      case ReportReason.bullying:
        return 'Bullying';
      case ReportReason.other:
        return 'Other';
    }
  }

  String get description {
    switch (this) {
      case ReportReason.spam:
        return 'Unsolicited or repetitive content';
      case ReportReason.harassment:
        return 'Targeted abuse or harassment';
      case ReportReason.hateSpeech:
        return 'Content promoting hate or discrimination';
      case ReportReason.violence:
        return 'Content depicting or promoting violence';
      case ReportReason.adultContent:
        return 'Sexually explicit content';
      case ReportReason.copyright:
        return 'Copyright infringement';
      case ReportReason.impersonation:
        return 'Impersonating another person or entity';
      case ReportReason.misinformation:
        return 'False or misleading information';
      case ReportReason.selfHarm:
        return 'Content promoting self-harm';
      case ReportReason.illegalContent:
        return 'Content that is illegal';
      case ReportReason.privacyViolation:
        return 'Violation of privacy rights';
      case ReportReason.threats:
        return 'Threats of harm or violence';
      case ReportReason.bullying:
        return 'Bullying or intimidation';
      case ReportReason.other:
        return 'Other reason';
    }
  }

  int get severityLevel {
    switch (this) {
      case ReportReason.spam:
        return 1;
      case ReportReason.bullying:
        return 2;
      case ReportReason.privacyViolation:
        return 3;
      case ReportReason.misinformation:
        return 3;
      case ReportReason.copyright:
        return 4;
      case ReportReason.impersonation:
        return 4;
      case ReportReason.adultContent:
        return 5;
      case ReportReason.selfHarm:
        return 6;
      case ReportReason.threats:
        return 7;
      case ReportReason.harassment:
        return 7;
      case ReportReason.hateSpeech:
        return 8;
      case ReportReason.violence:
        return 9;
      case ReportReason.illegalContent:
        return 10;
      case ReportReason.other:
        return 2;
    }
  }

  static ReportReason fromString(String reason) {
    switch (reason.toLowerCase()) {
      case 'spam':
        return ReportReason.spam;
      case 'harassment':
        return ReportReason.harassment;
      case 'hatespeech':
        return ReportReason.hateSpeech;
      case 'violence':
        return ReportReason.violence;
      case 'adultcontent':
        return ReportReason.adultContent;
      case 'copyright':
        return ReportReason.copyright;
      case 'impersonation':
        return ReportReason.impersonation;
      case 'misinformation':
        return ReportReason.misinformation;
      case 'selfharm':
        return ReportReason.selfHarm;
      case 'illegalcontent':
        return ReportReason.illegalContent;
      case 'privacyviolation':
        return ReportReason.privacyViolation;
      case 'threats':
        return ReportReason.threats;
      case 'bullying':
        return ReportReason.bullying;
      case 'other':
        return ReportReason.other;
      default:
        return ReportReason.other;
    }
  }
}

extension ModerationSeverityExtension on ModerationSeverity {
  String get displayName {
    switch (this) {
      case ModerationSeverity.low:
        return 'Low';
      case ModerationSeverity.medium:
        return 'Medium';
      case ModerationSeverity.high:
        return 'High';
      case ModerationSeverity.critical:
        return 'Critical';
    }
  }

  String get color {
    switch (this) {
      case ModerationSeverity.low:
        return '#28a745'; // Green
      case ModerationSeverity.medium:
        return '#ffc107'; // Yellow
      case ModerationSeverity.high:
        return '#fd7e14'; // Orange
      case ModerationSeverity.critical:
        return '#dc3545'; // Red
    }
  }

  static ModerationSeverity fromString(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return ModerationSeverity.low;
      case 'medium':
        return ModerationSeverity.medium;
      case 'high':
        return ModerationSeverity.high;
      case 'critical':
        return ModerationSeverity.critical;
      default:
        return ModerationSeverity.medium;
    }
  }
}

extension ContentTypeExtension on ContentType {
  String get displayName {
    switch (this) {
      case ContentType.tweet:
        return 'Tweet';
      case ContentType.reply:
        return 'Reply';
      case ContentType.retweet:
        return 'Retweet';
      case ContentType.quote:
        return 'Quote Tweet';
      case ContentType.message:
        return 'Message';
      case ContentType.profile:
        return 'Profile';
      case ContentType.banner:
        return 'Banner';
      case ContentType.media:
        return 'Media';
      case ContentType.link:
        return 'Link';
      case ContentType.hashtag:
        return 'Hashtag';
    }
  }

  static ContentType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'tweet':
        return ContentType.tweet;
      case 'reply':
        return ContentType.reply;
      case 'retweet':
        return ContentType.retweet;
      case 'quote':
        return ContentType.quote;
      case 'message':
        return ContentType.message;
      case 'profile':
        return ContentType.profile;
      case 'banner':
        return ContentType.banner;
      case 'media':
        return ContentType.media;
      case 'link':
        return ContentType.link;
      case 'hashtag':
        return ContentType.hashtag;
      default:
        return ContentType.tweet;
    }
  }
}

extension ModerationFilterExtension on ModerationFilter {
  String get displayName {
    switch (this) {
      case ModerationFilter.profanity:
        return 'Profanity';
      case ModerationFilter.hateSpeech:
        return 'Hate Speech';
      case ModerationFilter.spam:
        return 'Spam';
      case ModerationFilter.links:
        return 'Links';
      case ModerationFilter.mentions:
        return 'Mentions';
      case ModerationFilter.hashtags:
        return 'Hashtags';
      case ModerationFilter.media:
        return 'Media';
      case ModerationFilter.emojis:
        return 'Emojis';
    }
  }

  static ModerationFilter fromString(String filter) {
    switch (filter.toLowerCase()) {
      case 'profanity':
        return ModerationFilter.profanity;
      case 'hatespeech':
        return ModerationFilter.hateSpeech;
      case 'spam':
        return ModerationFilter.spam;
      case 'links':
        return ModerationFilter.links;
      case 'mentions':
        return ModerationFilter.mentions;
      case 'hashtags':
        return ModerationFilter.hashtags;
      case 'media':
        return ModerationFilter.media;
      case 'emojis':
        return ModerationFilter.emojis;
      default:
        return ModerationFilter.spam;
    }
  }
}

extension ModerationPriorityExtension on ModerationPriority {
  String get displayName {
    switch (this) {
      case ModerationPriority.low:
        return 'Low';
      case ModerationPriority.normal:
        return 'Normal';
      case ModerationPriority.high:
        return 'High';
      case ModerationPriority.urgent:
        return 'Urgent';
    }
  }

  String get color {
    switch (this) {
      case ModerationPriority.low:
        return '#6c757d'; // Gray
      case ModerationPriority.normal:
        return '#17a2b8'; // Cyan
      case ModerationPriority.high:
        return '#ffc107'; // Yellow
      case ModerationPriority.urgent:
        return '#dc3545'; // Red
    }
  }

  static ModerationPriority fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return ModerationPriority.low;
      case 'normal':
        return ModerationPriority.normal;
      case 'high':
        return ModerationPriority.high;
      case 'urgent':
        return ModerationPriority.urgent;
      default:
        return ModerationPriority.normal;
    }
  }
}
