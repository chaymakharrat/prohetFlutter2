import 'package:flutter/material.dart';
import 'package:projet_flutter/controller/user_controller.dart';
import 'package:projet_flutter/state/app_state.dart';
import 'package:provider/provider.dart';

class RatingPage extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;
  final String? targetUserImage; // URL or null

  const RatingPage({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
    this.targetUserImage,
  });

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _selectedRating = 5;
  final TextEditingController _commentController = TextEditingController();
  final UserController _userController = UserController();
  bool _isSubmitting = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }

  Future<void> _loadUserRating() async {
    try {
      final profile = await _userController.getUserProfile(widget.targetUserId);
      if (profile != null && mounted) {
        String feedbackText = profile.feedback;
        final Set<String> loadedTags = {};

        // Extract tags from feedback text
        for (final tag in _tags) {
          final tagPattern = "#$tag";
          if (feedbackText.contains(tagPattern)) {
            loadedTags.add(tag);
            feedbackText = feedbackText.replaceAll(tagPattern, "");
          }
        }

        setState(() {
          _selectedRating = profile.rating.round();
          if (_selectedRating < 1) _selectedRating = 1;
          if (_selectedRating > 5) _selectedRating = 5;
          
          _selectedTags.clear();
          _selectedTags.addAll(loadedTags);
          
          _commentController.text = feedbackText.trim();
        });
      }
    } catch (e) {
      debugPrint("Error loading rating: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }

  // Predefined compliment chips
  final List<String> _tags = ["Conduite Sûre", "Poli", "Ponctuel", "Voiture Propre", "Sympa"];
  final Set<String> _selectedTags = {};

  void _submitRating() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Combine comments and tags
      String finalComment = _commentController.text.trim();
      if (_selectedTags.isNotEmpty) {
        final tagsStr = _selectedTags.map((t) => "#$t").join(" ");
        if (finalComment.isNotEmpty) {
          finalComment += "\n$tagsStr";
        } else {
          finalComment = tagsStr;
        }
      }

      await _userController.addUserRating(
        widget.targetUserId,
        _selectedRating.toDouble(),
        finalComment,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Avis envoyé avec succès !"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Stack(
        children: [
          // 1. Header Background (Fixed)
          Container(
            height: 240,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // 2. Scrollable Content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100), // Push content down
                
                // Card + Avatar Stack
                Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    // Card
                    Container(
                      margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
                      padding: const EdgeInsets.only(
                          top: 60, bottom: 24, left: 24, right: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.targetUserName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Comment s'est passé votre trajet ?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Stars (Now inside the flow, interactive!)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () {
                                   setState(() => _selectedRating = index + 1);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    index < _selectedRating
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: index < _selectedRating
                                        ? const Color(0xFFFFB300)
                                        : Colors.grey.shade300,
                                    size: 42,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getRatingLabel(_selectedRating),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Avatar
                    Positioned(
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Hero(
                          tag: 'avatar_${widget.targetUserId}',
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFFE3F2FD),
                            backgroundImage: widget.targetUserImage != null
                                ? NetworkImage(widget.targetUserImage!)
                                : null,
                            child: widget.targetUserImage == null
                                ? const Icon(Icons.person,
                                    size: 50, color: Color(0xFF1976D2))
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Rest of Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Qu'avez-vous le plus apprécié ?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _tags.map((tag) {
                          final isSelected = _selectedTags.contains(tag);
                          return ChoiceChip(
                            label: Text(tag),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) _selectedTags.add(tag);
                                else _selectedTags.remove(tag);
                              });
                            },
                            selectedColor: const Color(0xFFE3F2FD),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF1976D2)
                                  : Colors.grey.shade700,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF1976D2)
                                    : Colors.grey.shade300,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      const Text(
                        "Laissez un commentaire",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _commentController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText:
                                "Dites-nous en plus sur votre expérience...",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitRating,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            elevation: 4,
                            shadowColor:
                                const Color(0xFF1976D2).withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text(
                                  "Envoyer l'avis",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Close Button (Floating on top)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 10),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingLabel(int rating) {
    if (rating == 1) return "Décevant 😞";
    if (rating == 2) return "Moyen 😐";
    if (rating == 3) return "Bien 🙂";
    if (rating == 4) return "Très Bien 😄";
    if (rating == 5) return "Excellent ! 🤩";
    return "";
  }
}
