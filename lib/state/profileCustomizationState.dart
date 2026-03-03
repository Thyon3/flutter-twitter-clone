import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitterclone/model/user.dart';
import 'package:twitterclone/helper/utility.dart';
import 'package:twitterclone/state/appState.dart';

class ProfileCustomizationState extends AppState {
  final DatabaseReference _profileReference = FirebaseDatabase.instance.ref();
  
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  
  // Customization state
  ProfileTheme _selectedTheme = ProfileTheme.light;
  ProfileAccentColor _selectedAccentColor = ProfileAccentColor.blue;
  ProfileLayout _selectedLayout = ProfileLayout.default;
  ProfilePrivacy _selectedPrivacy = ProfilePrivacy.public;
  Set<ProfileVisibility> _visibilitySettings = {
    ProfileVisibility.showEmail,
    ProfileVisibility.showLocation,
    ProfileVisibility.showWebsite,
    ProfileVisibility.showFollowers,
    ProfileVisibility.showFollowing,
    ProfileVisibility.showStats,
  };
  
  // Custom styling
  String _customBackgroundColor = '';
  String _customTextColor = '';
  String _customAccentColor = '';
  String _profileBackgroundImage = '';
  String _profileBorderColor = '';
  double _profileBorderWidth = 2.0;
  String _profileFont = 'System';
  double _profileFontSize = 14.0;
  
  // Display preferences
  bool _showProfileViews = true;
  bool _showTweetCount = true;
  bool _showFollowingCount = true;
  bool _showFollowerCount = true;
  bool _showJoinDate = true;
  bool _showLocation = true;
  bool _showWebsite = true;
  bool _showEmail = false;
  
  // Privacy settings
  bool _allowDirectMessages = true;
  bool _allowTagging = true;
  bool _allowSearchIndexing = true;
  
  // Visual effects
  bool _enableAnimations = true;
  bool _enableParticles = false;
  String _customCSS = '';
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  ProfileTheme get selectedTheme => _selectedTheme;
  ProfileAccentColor get selectedAccentColor => _selectedAccentColor;
  ProfileLayout get selectedLayout => _selectedLayout;
  ProfilePrivacy get selectedPrivacy => _selectedPrivacy;
  Set<ProfileVisibility> get visibilitySettings => Set.from(_visibilitySettings);
  
  String get customBackgroundColor => _customBackgroundColor;
  String get customTextColor => _customTextColor;
  String get customAccentColor => _customAccentColor;
  String get profileBackgroundImage => _profileBackgroundImage;
  String get profileBorderColor => _profileBorderColor;
  double get profileBorderWidth => _profileBorderWidth;
  String get profileFont => _profileFont;
  double get profileFontSize => _profileFontSize;
  
  bool get showProfileViews => _showProfileViews;
  bool get showTweetCount => _showTweetCount;
  bool get showFollowingCount => _showFollowingCount;
  bool get showFollowerCount => _showFollowerCount;
  bool get showJoinDate => _showJoinDate;
  bool get showLocation => _showLocation;
  bool get showWebsite => _showWebsite;
  bool get showEmail => _showEmail;
  
  bool get allowDirectMessages => _allowDirectMessages;
  bool get allowTagging => _allowTagging;
  bool get allowSearchIndexing => _allowSearchIndexing;
  
  bool get enableAnimations => _enableAnimations;
  bool get enableParticles => _enableParticles;
  String get customCSS => _customCSS;
  
  /// Initialize profile customization state
  Future<void> initialize() async {
    await loadCustomizationSettings();
  }
  
  /// Load customization settings from Firebase
  Future<void> loadCustomizationSettings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final snapshot = await _profileReference
          .child('profile')
          .child(userId)
          .child('customization')
          .get();
      
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value);
        
        _selectedTheme = ProfileThemeExtension.fromString(data['theme'] ?? 'light');
        _selectedAccentColor = ProfileAccentColorExtension.fromString(data['accentColor'] ?? 'blue');
        _selectedLayout = ProfileLayoutExtension.fromString(data['layout'] ?? 'default');
        _selectedPrivacy = ProfilePrivacyExtension.fromString(data['privacy'] ?? 'public');
        
        _customBackgroundColor = data['customBackgroundColor'] ?? '';
        _customTextColor = data['customTextColor'] ?? '';
        _customAccentColor = data['customAccentColor'] ?? '';
        _profileBackgroundImage = data['profileBackgroundImage'] ?? '';
        _profileBorderColor = data['profileBorderColor'] ?? '';
        _profileBorderWidth = (data['profileBorderWidth'] ?? 2.0).toDouble();
        _profileFont = data['profileFont'] ?? 'System';
        _profileFontSize = (data['profileFontSize'] ?? 14.0).toDouble();
        
        _showProfileViews = data['showProfileViews'] ?? true;
        _showTweetCount = data['showTweetCount'] ?? true;
        _showFollowingCount = data['showFollowingCount'] ?? true;
        _showFollowerCount = data['showFollowerCount'] ?? true;
        _showJoinDate = data['showJoinDate'] ?? true;
        _showLocation = data['showLocation'] ?? true;
        _showWebsite = data['showWebsite'] ?? true;
        _showEmail = data['showEmail'] ?? false;
        
        _allowDirectMessages = data['allowDirectMessages'] ?? true;
        _allowTagging = data['allowTagging'] ?? true;
        _allowSearchIndexing = data['allowSearchIndexing'] ?? true;
        
        _enableAnimations = data['enableAnimations'] ?? true;
        _enableParticles = data['enableParticles'] ?? false;
        _customCSS = data['customCSS'] ?? '';
        
        if (data['visibilitySettings'] != null) {
          _visibilitySettings.clear();
          final visibilityList = data['visibilitySettings'] as List;
          for (final visibility in visibilityList) {
            switch (visibility) {
              case 'showEmail':
                _visibilitySettings.add(ProfileVisibility.showEmail);
                break;
              case 'showLocation':
                _visibilitySettings.add(ProfileVisibility.showLocation);
                break;
              case 'showWebsite':
                _visibilitySettings.add(ProfileVisibility.showWebsite);
                break;
              case 'showDob':
                _visibilitySettings.add(ProfileVisibility.showDob);
                break;
              case 'showFollowers':
                _visibilitySettings.add(ProfileVisibility.showFollowers);
                break;
              case 'showFollowing':
                _visibilitySettings.add(ProfileVisibility.showFollowing);
                break;
              case 'showStats':
                _visibilitySettings.add(ProfileVisibility.showStats);
                break;
            }
          }
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load customization settings: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Save customization settings to Firebase
  Future<void> saveCustomizationSettings() async {
    try {
      _isSaving = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final customizationData = {
        'theme': _selectedTheme.name,
        'accentColor': _selectedAccentColor.name,
        'layout': _selectedLayout.name,
        'privacy': _selectedPrivacy.name,
        'customBackgroundColor': _customBackgroundColor,
        'customTextColor': _customTextColor,
        'customAccentColor': _customAccentColor,
        'profileBackgroundImage': _profileBackgroundImage,
        'profileBorderColor': _profileBorderColor,
        'profileBorderWidth': _profileBorderWidth,
        'profileFont': _profileFont,
        'profileFontSize': _profileFontSize,
        'showProfileViews': _showProfileViews,
        'showTweetCount': _showTweetCount,
        'showFollowingCount': _showFollowingCount,
        'showFollowerCount': _showFollowerCount,
        'showJoinDate': _showJoinDate,
        'showLocation': _showLocation,
        'showWebsite': _showWebsite,
        'showEmail': _showEmail,
        'allowDirectMessages': _allowDirectMessages,
        'allowTagging': _allowTagging,
        'allowSearchIndexing': _allowSearchIndexing,
        'enableAnimations': _enableAnimations,
        'enableParticles': _enableParticles,
        'customCSS': _customCSS,
        'visibilitySettings': _visibilitySettings.map((v) => v.name).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      await _profileReference
          .child('profile')
          .child(userId)
          .child('customization')
          .set(customizationData);
      
      _isSaving = false;
      notifyListeners();
      
      cprint('Profile customization settings saved', event: 'save_customization');
    } catch (e) {
      _error = 'Failed to save customization settings: $e';
      _isSaving = false;
      notifyListeners();
    }
  }
  
  /// Set profile theme
  void setTheme(ProfileTheme theme) {
    _selectedTheme = theme;
    notifyListeners();
  }
  
  /// Set accent color
  void setAccentColor(ProfileAccentColor color) {
    _selectedAccentColor = color;
    notifyListeners();
  }
  
  /// Set profile layout
  void setLayout(ProfileLayout layout) {
    _selectedLayout = layout;
    notifyListeners();
  }
  
  /// Set profile privacy
  void setPrivacy(ProfilePrivacy privacy) {
    _selectedPrivacy = privacy;
    notifyListeners();
  }
  
  /// Toggle visibility setting
  void toggleVisibility(ProfileVisibility visibility) {
    if (_visibilitySettings.contains(visibility)) {
      _visibilitySettings.remove(visibility);
    } else {
      _visibilitySettings.add(visibility);
    }
    notifyListeners();
  }
  
  /// Set custom background color
  void setCustomBackgroundColor(String color) {
    _customBackgroundColor = color;
    notifyListeners();
  }
  
  /// Set custom text color
  void setCustomTextColor(String color) {
    _customTextColor = color;
    notifyListeners();
  }
  
  /// Set custom accent color
  void setCustomAccentColor(String color) {
    _customAccentColor = color;
    notifyListeners();
  }
  
  /// Set profile background image
  void setProfileBackgroundImage(String imageUrl) {
    _profileBackgroundImage = imageUrl;
    notifyListeners();
  }
  
  /// Set profile border color
  void setProfileBorderColor(String color) {
    _profileBorderColor = color;
    notifyListeners();
  }
  
  /// Set profile border width
  void setProfileBorderWidth(double width) {
    _profileBorderWidth = width;
    notifyListeners();
  }
  
  /// Set profile font
  void setProfileFont(String font) {
    _profileFont = font;
    notifyListeners();
  }
  
  /// Set profile font size
  void setProfileFontSize(double size) {
    _profileFontSize = size;
    notifyListeners();
  }
  
  /// Toggle display preference
  void toggleDisplayPreference(String preference) {
    switch (preference) {
      case 'showProfileViews':
        _showProfileViews = !_showProfileViews;
        break;
      case 'showTweetCount':
        _showTweetCount = !_showTweetCount;
        break;
      case 'showFollowingCount':
        _showFollowingCount = !_showFollowingCount;
        break;
      case 'showFollowerCount':
        _showFollowerCount = !_showFollowerCount;
        break;
      case 'showJoinDate':
        _showJoinDate = !_showJoinDate;
        break;
      case 'showLocation':
        _showLocation = !_showLocation;
        break;
      case 'showWebsite':
        _showWebsite = !_showWebsite;
        break;
      case 'showEmail':
        _showEmail = !_showEmail;
        break;
    }
    notifyListeners();
  }
  
  /// Toggle privacy setting
  void togglePrivacySetting(String setting) {
    switch (setting) {
      case 'allowDirectMessages':
        _allowDirectMessages = !_allowDirectMessages;
        break;
      case 'allowTagging':
        _allowTagging = !_allowTagging;
        break;
      case 'allowSearchIndexing':
        _allowSearchIndexing = !_allowSearchIndexing;
        break;
    }
    notifyListeners();
  }
  
  /// Toggle visual effects
  void toggleVisualEffect(String effect) {
    switch (effect) {
      case 'enableAnimations':
        _enableAnimations = !_enableAnimations;
        break;
      case 'enableParticles':
        _enableParticles = !_enableParticles;
        break;
    }
    notifyListeners();
  }
  
  /// Set custom CSS
  void setCustomCSS(String css) {
    _customCSS = css;
    notifyListeners();
  }
  
  /// Reset to default settings
  void resetToDefaults() {
    _selectedTheme = ProfileTheme.light;
    _selectedAccentColor = ProfileAccentColor.blue;
    _selectedLayout = ProfileLayout.default;
    _selectedPrivacy = ProfilePrivacy.public;
    
    _customBackgroundColor = '';
    _customTextColor = '';
    _customAccentColor = '';
    _profileBackgroundImage = '';
    _profileBorderColor = '';
    _profileBorderWidth = 2.0;
    _profileFont = 'System';
    _profileFontSize = 14.0;
    
    _showProfileViews = true;
    _showTweetCount = true;
    _showFollowingCount = true;
    _showFollowerCount = true;
    _showJoinDate = true;
    _showLocation = true;
    _showWebsite = true;
    _showEmail = false;
    
    _allowDirectMessages = true;
    _allowTagging = true;
    _allowSearchIndexing = true;
    
    _enableAnimations = true;
    _enableParticles = false;
    _customCSS = '';
    
    _visibilitySettings = {
      ProfileVisibility.showEmail,
      ProfileVisibility.showLocation,
      ProfileVisibility.showWebsite,
      ProfileVisibility.showFollowers,
      ProfileVisibility.showFollowing,
      ProfileVisibility.showStats,
    };
    
    notifyListeners();
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
