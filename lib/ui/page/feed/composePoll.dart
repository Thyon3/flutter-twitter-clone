import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitterclone/state/authState.dart';
import 'package:twitterclone/state/pollState.dart';
import 'package:twitterclone/ui/theme/theme.dart';
import 'package:twitterclone/widgets/customWidgets.dart';

class ComposePollPage extends StatefulWidget {
  const ComposePollPage({Key? key}) : super(key: key);

  @override
  _ComposePollPageState createState() => _ComposePollPageState();
}

class _ComposePollPageState extends State<ComposePollPage> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  
  bool _isMultipleChoice = false;
  Duration _duration = const Duration(days: 1);
  bool _isPosting = false;
  int _questionCharacterCount = 0;
  
  static const int maxQuestionCharacters = 280;
  static const int maxOptionCharacters = 25;
  static const int maxOptions = 4;
  static const int minOptions = 2;

  @override
  void initState() {
    super.initState();
    _questionController.addListener(() {
      setState(() {
        _questionCharacterCount = _questionController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Poll',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _canPost() ? _postPoll : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: _isPosting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(fontSize: 14),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircularImage(
                  path: context.read<AuthState>().userModel?.profilePic,
                  height: 40,
                  width: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.read<AuthState>().userModel?.displayName ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        context.read<AuthState>().userModel?.userName ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Poll question
            TextField(
              controller: _questionController,
              maxLines: 3,
              maxLength: maxQuestionCharacters,
              decoration: InputDecoration(
                hintText: 'Ask a question...',
                hintStyle: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
              ),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            
            // Character count for question
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$_questionCharacterCount/$maxQuestionCharacters',
                  style: TextStyle(
                    fontSize: 12,
                    color: _questionCharacterCount > maxQuestionCharacters
                        ? Colors.red
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Poll options
            Text(
              'Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            
            ..._optionControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    // Option number
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Option text field
                    Expanded(
                      child: TextField(
                        controller: controller,
                        maxLength: maxOptionCharacters,
                        decoration: InputDecoration(
                          hintText: 'Option ${index + 1}',
                          hintStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.primaryColor),
                          ),
                          counterText: '',
                          suffixIcon: index >= minOptions && index < _optionControllers.length - 1
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _removeOption(index),
                                )
                              : null,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            
            // Add option button
            if (_optionControllers.length < maxOptions)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add option'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Poll settings
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            
            // Multiple choice toggle
            SwitchListTile(
              title: const Text('Multiple choice'),
              subtitle: const Text('Allow people to select multiple options'),
              value: _isMultipleChoice,
              onChanged: (value) {
                setState(() {
                  _isMultipleChoice = value;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
            
            // Duration selector
            ListTile(
              title: const Text('Poll duration'),
              subtitle: Text(_getDurationText()),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: _showDurationPicker,
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _addOption() {
    if (_optionControllers.length < maxOptions) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > minOptions) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  String _getDurationText() {
    if (_duration.inDays >= 1) {
      return '${_duration.inDays} day${_duration.inDays == 1 ? '' : 's'}';
    } else if (_duration.inHours >= 1) {
      return '${_duration.inHours} hour${_duration.inHours == 1 ? '' : 's'}';
    } else {
      return '${_duration.inMinutes} minutes';
    }
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Poll Duration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('5 minutes'),
            onTap: () {
              setState(() {
                _duration = const Duration(minutes: 5);
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('30 minutes'),
            onTap: () {
              setState(() {
                _duration = const Duration(minutes: 30);
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('1 hour'),
            onTap: () {
              setState(() {
                _duration = const Duration(hours: 1);
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('6 hours'),
            onTap: () {
              setState(() {
                _duration = const Duration(hours: 6);
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('1 day'),
            onTap: () {
              setState(() {
                _duration = const Duration(days: 1);
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('3 days'),
            onTap: () {
              setState(() {
                _duration = const Duration(days: 3);
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('7 days'),
            onTap: () {
              setState(() {
                _duration = const Duration(days: 7);
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  bool _canPost() {
    if (_isPosting) return false;
    
    final question = _questionController.text.trim();
    final options = _optionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    
    return question.isNotEmpty &&
           options.length >= minOptions &&
           _questionCharacterCount <= maxQuestionCharacters;
  }

  Future<void> _postPoll() async {
    if (!_canPost()) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final pollState = context.read<PollState>();
      final question = _questionController.text.trim();
      final options = _optionControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final success = await pollState.createPoll(
        question: question,
        optionTexts: options,
        duration: _duration,
        isMultipleChoice: _isMultipleChoice,
      );

      if (success != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Poll created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create poll'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }
}
