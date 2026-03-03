import 'package:firebase_database/firebase_database.dart';
import 'package:twitterclone/model/moderationModel.dart';
import 'package:twitterclone/model/moderationFilterModel.dart';
import 'package:twitterclone/model/feedModel.dart';
import 'package:twitterclone/helper/utility.dart';

class ModerationService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final List<ModerationFilterRule> _filterRules = [];
  
  ModerationService() {
    _loadFilterRules();
  }
  
  /// Analyze content for moderation
  Future<ModerationResult> analyzeContent({
    required String content,
    required ContentType contentType,
    String? userId,
    String? contentId,
  }) async {
    final results = <FilterResult>[];
    final triggeredRules = <ModerationFilterRule>[];
    
    // Check against all active filter rules
    for (final rule in _filterRules) {
      if (rule.matches(content, userId, contentType)) {
        rule.recordTrigger();
        
        final result = FilterResult(
          ruleId: rule.id,
          ruleName: rule.name,
          action: rule.action,
          severity: rule.severity,
          customMessage: rule.customMessage,
          triggered: true,
          timestamp: DateTime.now(),
          context: {
            'content': content,
            'contentType': contentType.name,
            'userId': userId,
            'contentId': contentId,
          },
        );
        
        results.add(result);
        triggeredRules.add(rule);
      }
    }
    
    // Determine overall action based on highest severity
    final overallAction = _determineOverallAction(triggeredRules);
    final overallSeverity = _determineOverallSeverity(triggeredRules);
    
    return ModerationResult(
      isFlagged: triggeredRules.isNotEmpty,
      action: overallAction,
      severity: overallSeverity,
      triggeredRules: triggeredRules,
      filterResults: results,
      confidence: _calculateConfidence(triggeredRules),
      recommendations: _generateRecommendations(triggeredRules),
    );
  }
  
  /// Process text for profanity
  bool containsProfanity(String text) {
    final profanityList = [
      'damn', 'hell', 'shit', 'fuck', 'bitch', 'bastard', 'asshole',
      'dick', 'pussy', 'cock', 'cunt', 'whore', 'slut',
    ];
    
    final lowerText = text.toLowerCase();
    return profanityList.any((word) => lowerText.contains(word));
  }
  
  /// Detect spam patterns
  bool isSpam(String text) {
    // Check for excessive repetition
    final words = text.toLowerCase().split(' ');
    final wordCounts = <String, int>{};
    
    for (final word in words) {
      wordCounts[word] = (wordCounts[word] ?? 0) + 1;
    }
    
    // If any word appears more than 3 times, likely spam
    if (wordCounts.values.any((count) => count > 3)) {
      return true;
    }
    
    // Check for excessive capitalization
    final upperCaseRatio = text
        .split('')
        .where((char) => char.toUpperCase() == char)
        .length / text.length;
    
    if (upperCaseRatio > 0.7) {
      return true;
    }
    
    // Check for excessive punctuation
    final punctuationCount = text
        .split('')
        .where((char) => '!@#$%^&*()'.contains(char))
        .length;
    
    if (punctuationCount > text.length * 0.2) {
      return true;
    }
    
    return false;
  }
  
  /// Detect hate speech patterns
  bool containsHateSpeech(String text) {
    final hateSpeechPatterns = [
      'hate', 'kill', 'die', 'murder', 'terrorist', 'nazi',
      'racist', 'sexist', 'homophobe', 'xenophobe',
    ];
    
    final lowerText = text.toLowerCase();
    return hateSpeechPatterns.any((pattern) => lowerText.contains(pattern));
  }
  
  /// Check for suspicious links
  bool hasSuspiciousLinks(String text) {
    final urlPattern = RegExp(r'https?://[^\s]+');
    final urls = urlPattern.allMatches(text);
    
    // Check for URL shorteners (often used in spam)
    final shorteners = [
      'bit.ly', 'tinyurl.com', 't.co', 'goo.gl', 'ow.ly',
      'is.gd', 'buff.ly', 'adf.ly', 'bit.do',
    ];
    
    for (final match in urls) {
      final url = text.substring(match.start, match.end).toLowerCase();
      if (shorteners.any((shortener) => url.contains(shortener))) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Analyze sentiment (basic implementation)
  SentimentAnalysis analyzeSentiment(String text) {
    final positiveWords = [
      'good', 'great', 'awesome', 'amazing', 'excellent', 'fantastic',
      'wonderful', 'love', 'like', 'happy', 'joy', 'blessed',
    ];
    
    final negativeWords = [
      'bad', 'terrible', 'awful', 'horrible', 'hate', 'dislike',
      'angry', 'sad', 'depressed', 'worst', 'disgusting',
    ];
    
    final words = text.toLowerCase().split(' ');
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final word in words) {
      if (positiveWords.contains(word)) {
        positiveCount++;
      } else if (negativeWords.contains(word)) {
        negativeCount++;
      }
    }
    
    final totalSentimentWords = positiveCount + negativeCount;
    if (totalSentimentWords == 0) {
      return SentimentAnalysis(
        score: 0.0,
        sentiment: Sentiment.neutral,
        confidence: 0.0,
      );
    }
    
    final score = (positiveCount - negativeCount) / totalSentimentWords;
    
    Sentiment sentiment;
    if (score > 0.2) {
      sentiment = Sentiment.positive;
    } else if (score < -0.2) {
      sentiment = Sentiment.negative;
    } else {
      sentiment = Sentiment.neutral;
    }
    
    return SentimentAnalysis(
      score: score,
      sentiment: sentiment,
      confidence: totalSentimentWords / words.length,
    );
  }
  
  /// Generate content safety score
  double generateSafetyScore(String text) {
    double score = 100.0; // Start with perfect score
    
    // Deduct for profanity
    if (containsProfanity(text)) {
      score -= 20.0;
    }
    
    // Deduct for spam
    if (isSpam(text)) {
      score -= 25.0;
    }
    
    // Deduct for hate speech
    if (containsHateSpeech(text)) {
      score -= 40.0;
    }
    
    // Deduct for suspicious links
    if (hasSuspiciousLinks(text)) {
      score -= 15.0;
    }
    
    // Check sentiment
    final sentiment = analyzeSentiment(text);
    if (sentiment.sentiment == Sentiment.negative && sentiment.confidence > 0.5) {
      score -= 10.0;
    }
    
    return score.clamp(0.0, 100.0);
  }
  
  /// Get content recommendations
  List<String> getContentRecommendations(String text) {
    final recommendations = <String>[];
    
    if (containsProfanity(text)) {
      recommendations.add('Consider removing profanity for broader appeal');
    }
    
    if (isSpam(text)) {
      recommendations.add('Reduce repetition and excessive punctuation');
    }
    
    if (containsHateSpeech(text)) {
      recommendations.add('Review content for potentially offensive language');
    }
    
    if (hasSuspiciousLinks(text)) {
      recommendations.add('Verify link safety before sharing');
    }
    
    final sentiment = analyzeSentiment(text);
    if (sentiment.sentiment == Sentiment.negative) {
      recommendations.add('Consider a more positive tone');
    }
    
    return recommendations;
  }
  
  /// Private helper methods
  
  Future<void> _loadFilterRules() async {
    try {
      final snapshot = await _database
          .child('moderation')
          .child('filterRules')
          .get();
      
      if (snapshot.exists) {
        final rulesMap = snapshot.value as Map<String, dynamic>;
        _filterRules.clear();
        
        for (final entry in rulesMap.entries) {
          final rule = ModerationFilterRule.fromJson(entry.value);
          if (rule.isActive) {
            _filterRules.add(rule);
          }
        }
        
        // Sort by priority
        _filterRules.sort((a, b) => b.priority.compareTo(a.priority));
      }
    } catch (e) {
      cprint('Error loading filter rules: $e', errorIn: 'ModerationService');
    }
  }
  
  FilterAction _determineOverallAction(List<ModerationFilterRule> rules) {
    if (rules.isEmpty) return FilterAction.log;
    
    // Return the most severe action
    for (final action in [
      FilterAction.block,
      FilterAction.escalate,
      FilterAction.quarantine,
      FilterAction.warn,
      FilterAction.flag,
      FilterAction.log,
    ]) {
      if (rules.any((rule) => rule.action == action)) {
        return action;
      }
    }
    
    return FilterAction.log;
  }
  
  ModerationSeverity _determineOverallSeverity(List<ModerationFilterRule> rules) {
    if (rules.isEmpty) return ModerationSeverity.low;
    
    // Return the highest severity
    for (final severity in [
      ModerationSeverity.critical,
      ModerationSeverity.high,
      ModerationSeverity.medium,
      ModerationSeverity.low,
    ]) {
      if (rules.any((rule) => rule.severity == severity)) {
        return severity;
      }
    }
    
    return ModerationSeverity.low;
  }
  
  double _calculateConfidence(List<ModerationFilterRule> rules) {
    if (rules.isEmpty) return 0.0;
    
    // Higher confidence when multiple rules trigger
    final triggerCount = rules.length;
    final maxTriggerCount = _filterRules.length;
    
    return (triggerCount / maxTriggerCount).clamp(0.0, 1.0);
  }
  
  List<String> _generateRecommendations(List<ModerationFilterRule> rules) {
    final recommendations = <String>[];
    
    for (final rule in rules) {
      if (rule.customMessage != null) {
        recommendations.add(rule.customMessage!);
      }
    }
    
    return recommendations;
  }
}

class ModerationResult {
  final bool isFlagged;
  final FilterAction action;
  final ModerationSeverity severity;
  final List<ModerationFilterRule> triggeredRules;
  final List<FilterResult> filterResults;
  final double confidence;
  final List<String> recommendations;
  
  ModerationResult({
    required this.isFlagged,
    required this.action,
    required this.severity,
    required this.triggeredRules,
    required this.filterResults,
    required this.confidence,
    required this.recommendations,
  });
}

class SentimentAnalysis {
  final double score;
  final Sentiment sentiment;
  final double confidence;
  
  SentimentAnalysis({
    required this.score,
    required this.sentiment,
    required this.confidence,
  });
}

enum Sentiment {
  positive,
  negative,
  neutral,
}
