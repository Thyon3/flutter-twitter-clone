import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitterclone/model/pollModel.dart';
import 'package:twitterclone/state/authState.dart';
import 'package:twitterclone/state/pollState.dart';
import 'package:twitterclone/ui/theme/theme.dart';
import 'package:twitterclone/widgets/customWidgets.dart';

class PollWidget extends StatefulWidget {
  final PollModel poll;
  final bool isCompact;

  const PollWidget({
    Key? key,
    required this.poll,
    this.isCompact = false,
  }) : super(key: key);

  @override
  _PollWidgetState createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  List<String> _selectedOptions = [];
  bool _hasVoted = false;
  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
    _checkUserVote();
  }

  void _checkUserVote() {
    final authState = context.read<AuthState>();
    final userId = authState.userModel?.userId;
    
    if (userId != null) {
      _hasVoted = widget.poll.hasUserVoted(userId);
      _selectedOptions = widget.poll
          .getUserVotedOptions(userId)
          .map((option) => option.id)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poll question
          Text(
            widget.poll.question,
            style: TextStyle(
              fontSize: widget.isCompact ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Poll options
          ...widget.poll.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedOptions.contains(option.id);
            final percentage = widget.poll.totalVotes > 0 
                ? option.getPercentage(widget.poll.totalVotes) 
                : 0.0;
            
            return _buildPollOption(
              context,
              option,
              index,
              isSelected,
              percentage,
            );
          }).toList(),
          
          const SizedBox(height: 12),
          
          // Poll footer
          _buildPollFooter(context),
        ],
      ),
    );
  }

  Widget _buildPollOption(
    BuildContext context,
    PollOption option,
    int index,
    bool isSelected,
    double percentage,
  ) {
    final authState = context.read<AuthState>();
    final userId = authState.userModel?.userId;
    final canVote = widget.poll.canUserVote(userId ?? '');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canVote && !_hasVoted ? () => _toggleOption(option.id) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: _hasVoted 
                  ? Colors.grey.shade100 
                  : isSelected 
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
            ),
            child: Stack(
              children: [
                // Progress bar for voted polls
                if (_hasVoted)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isSelected ? AppTheme.primaryColor : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                
                // Option content
                Row(
                  children: [
                    // Radio button/checkbox
                    if (!_hasVoted)
                      widget.poll.isMultipleChoice
                          ? Checkbox(
                              value: isSelected,
                              onChanged: canVote ? (value) => _toggleOption(option.id) : null,
                              activeColor: AppTheme.primaryColor,
                            )
                          : Radio<String>(
                              value: option.id,
                              groupValue: _selectedOptions.isNotEmpty ? _selectedOptions.first : null,
                              onChanged: canVote ? (value) => _selectSingleOption(option.id) : null,
                              activeColor: AppTheme.primaryColor,
                            )
                    else
                      Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
                        size: 20,
                      ),
                    
                    const SizedBox(width: 12),
                    
                    // Option text
                    Expanded(
                      child: Text(
                        option.text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    
                    // Vote count and percentage
                    if (_hasVoted)
                      Row(
                        children: [
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
                            ),
                          ),
                          if (option.voteCount > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• ${option.voteCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPollFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Vote count
        Text(
          '${widget.poll.totalVotes} vote${widget.poll.totalVotes == 1 ? '' : 's'}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        // Time remaining or status
        Row(
          children: [
            Icon(
              widget.poll.isExpired ? Icons.access_time : Icons.schedule,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              widget.poll.getTimeRemaining(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        // Vote button (for non-voted, active polls)
        if (!_hasVoted && widget.poll.canUserVote(context.read<AuthState>().userModel?.userId ?? ''))
          TextButton(
            onPressed: _selectedOptions.isNotEmpty ? _submitVote : null,
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isVoting
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Vote',
                    style: TextStyle(fontSize: 12),
                  ),
          ),
      ],
    );
  }

  void _toggleOption(String optionId) {
    setState(() {
      if (widget.poll.isMultipleChoice) {
        if (_selectedOptions.contains(optionId)) {
          _selectedOptions.remove(optionId);
        } else {
          _selectedOptions.add(optionId);
        }
      }
    });
  }

  void _selectSingleOption(String optionId) {
    setState(() {
      _selectedOptions = [optionId];
    });
  }

  Future<void> _submitVote() async {
    if (_selectedOptions.isEmpty || _isVoting) return;

    setState(() {
      _isVoting = true;
    });

    try {
      final pollState = context.read<PollState>();
      final authState = context.read<AuthState>();
      final userId = authState.userModel?.userId;

      if (userId != null) {
        final success = await pollState.voteInPoll(
          widget.poll.id!,
          userId,
          _selectedOptions,
        );

        if (success) {
          setState(() {
            _hasVoted = true;
            _isVoting = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vote submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _isVoting = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit vote'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isVoting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class CompactPollWidget extends StatelessWidget {
  final PollModel poll;

  const CompactPollWidget({
    Key? key,
    required this.poll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PollWidget(
      poll: poll,
      isCompact: true,
    );
  }
}
