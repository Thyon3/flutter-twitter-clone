import 'package:twitterclone/model/user.dart';

class PollOption {
  String id;
  String text;
  int voteCount;
  List<String> voterIds;
  
  PollOption({
    required this.id,
    required this.text,
    this.voteCount = 0,
    List<String>? voterIds,
  }) : voterIds = voterIds ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'voteCount': voteCount,
      'voterIds': voterIds,
    };
  }

  PollOption.fromJson(Map<dynamic, dynamic> map)
      : id = map['id'],
        text = map['text'],
        voteCount = map['voteCount'] ?? 0,
        voterIds = List<String>.from(map['voterIds'] ?? []);

  /// Get percentage of total votes
  double getPercentage(int totalVotes) {
    if (totalVotes == 0) return 0.0;
    return (voteCount / totalVotes) * 100;
  }

  /// Check if user has voted for this option
  bool hasUserVoted(String userId) {
    return voterIds.contains(userId);
  }

  /// Add user vote
  void addVote(String userId) {
    if (!hasUserVoted(userId)) {
      voterIds.add(userId);
      voteCount++;
    }
  }

  /// Remove user vote
  void removeVote(String userId) {
    if (hasUserVoted(userId)) {
      voterIds.remove(userId);
      voteCount--;
    }
  }
}

class PollModel {
  String? id;
  late String question;
  List<PollOption> options;
  late String userId;
  late String createdAt;
  late String expiresAt;
  bool isMultipleChoice;
  bool isActive;
  int totalVotes;
  UserModel? user;
  
  PollModel({
    this.id,
    required this.question,
    List<PollOption>? options,
    required this.userId,
    required this.createdAt,
    required this.expiresAt,
    this.isMultipleChoice = false,
    this.isActive = true,
    this.totalVotes = 0,
    this.user,
  }) : options = options ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options.map((option) => option.toJson()).toList(),
      'userId': userId,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      'isMultipleChoice': isMultipleChoice,
      'isActive': isActive,
      'totalVotes': totalVotes,
      'user': user?.toJson(),
    };
  }

  PollModel.fromJson(Map<dynamic, dynamic> map)
      : id = map['id'],
        question = map['question'],
        options = (map['options'] as List?)
            ?.map((option) => PollOption.fromJson(option))
            .toList() ?? [],
        userId = map['userId'],
        createdAt = map['createdAt'],
        expiresAt = map['expiresAt'],
        isMultipleChoice = map['isMultipleChoice'] ?? false,
        isActive = map['isActive'] ?? true,
        totalVotes = map['totalVotes'] ?? 0,
        user = map['user'] != null ? UserModel.fromJson(map['user']) : null;

  /// Check if poll has expired
  bool get isExpired {
    final expiryDate = DateTime.parse(expiresAt);
    return DateTime.now().isAfter(expiryDate);
  }

  /// Check if user can vote
  bool canUserVote(String userId) {
    return isActive && !isExpired && !hasUserVoted(userId);
  }

  /// Check if user has voted in this poll
  bool hasUserVoted(String userId) {
    return options.any((option) => option.hasUserVoted(userId));
  }

  /// Get user's voted options
  List<PollOption> getUserVotedOptions(String userId) {
    return options.where((option) => option.hasUserVoted(userId)).toList();
  }

  /// Vote for option(s)
  bool vote(String userId, List<String> optionIds) {
    if (!canUserVote(userId)) return false;
    
    if (!isMultipleChoice && optionIds.length > 1) {
      return false; // Single choice poll can only vote for one option
    }

    try {
      for (String optionId in optionIds) {
        final option = options.firstWhere((opt) => opt.id == optionId);
        option.addVote(userId);
      }
      
      // Update total votes
      totalVotes = options.fold(0, (sum, option) => sum + option.voteCount);
      return true;
    } catch (e) {
      print('Error voting in poll: $e');
      return false;
    }
  }

  /// Remove user's votes
  bool removeVote(String userId) {
    if (!hasUserVoted(userId)) return false;

    try {
      for (var option in options) {
        if (option.hasUserVoted(userId)) {
          option.removeVote(userId);
        }
      }
      
      // Update total votes
      totalVotes = options.fold(0, (sum, option) => sum + option.voteCount);
      return true;
    } catch (e) {
      print('Error removing vote from poll: $e');
      return false;
    }
  }

  /// Get time remaining
  String getTimeRemaining() {
    final now = DateTime.now();
    final expiry = DateTime.parse(expiresAt);
    
    if (now.isAfter(expiry)) {
      return 'Ended';
    }
    
    final duration = expiry.difference(now);
    
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'} left';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'} left';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'} left';
    } else {
      return 'Less than a minute left';
    }
  }

  /// Get leading option(s)
  List<PollOption> getLeadingOptions() {
    if (options.isEmpty) return [];
    
    final maxVotes = options.map((opt) => opt.voteCount).reduce((a, b) => a > b ? a : b);
    return options.where((opt) => opt.voteCount == maxVotes).toList();
  }

  /// Validate poll data
  bool get isValidPoll {
    return question.isNotEmpty &&
           options.length >= 2 &&
           options.length <= 4 &&
           options.every((option) => option.text.isNotEmpty) &&
           userId.isNotEmpty;
  }
}
