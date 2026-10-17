import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum CardStyle { defaultCard, tall, wide }

extension ColorShade on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

class AdaptiveHobbyCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final Color color;
  final VoidCallback? onTap;
  final CardStyle style;
  final double? height;
  final double? width;

  const AdaptiveHobbyCard({
    super.key,
    required this.data,
    required this.color,
    this.onTap,
    this.style = CardStyle.defaultCard,
    this.height,
    this.width,
  });

  @override
  State<AdaptiveHobbyCard> createState() => _AdaptiveHobbyCardState();
}

class _AdaptiveHobbyCardState extends State<AdaptiveHobbyCard> {
  bool isLiked = false;
  int likeCount = 0;
  late final String contentId;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    contentId = widget.data['id'];
    likeCount = widget.data['likeCount'] ?? 0;
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    if (user == null) return;

    final likeDoc = await FirebaseFirestore.instance
        .collection('hobbyContent')
        .doc(contentId)
        .collection('likes')
        .doc(user!.uid)
        .get();

    if (mounted) {
      if (likeDoc.exists && likeDoc.data()?['liked'] == true) {
        setState(() => isLiked = true);
      }
    }
  }

  Future<void> _toggleLike() async {
    if (user == null) return;

    final contentRef = FirebaseFirestore.instance
        .collection('hobbyContent')
        .doc(contentId);
    final likeRef = contentRef.collection('likes').doc(user!.uid);

    final newLikeStatus = !isLiked;
    final newCount = likeCount + (newLikeStatus ? 1 : -1);

    if (mounted) {
      setState(() {
        isLiked = newLikeStatus;
        likeCount = newCount;
      });
    }

    try {
      if (newLikeStatus) {
        await likeRef.set({'liked': true});
      } else {
        await likeRef.delete();
      }

      await contentRef.update({
        'likeCount': FieldValue.increment(newLikeStatus ? 1 : -1),
      });
    } catch (e) {
      // print('Error toggling like: $e');
      // Revert UI state if something fails
      if (mounted) {
        setState(() {
          isLiked = !newLikeStatus;
          likeCount = likeCount + (newLikeStatus ? -1 : 1);
        });
      }
    }
  }

  List<String> _extractHashtags(Map<String, dynamic>? metadata) {
    if (metadata == null || metadata.isEmpty) return [];
    return metadata.entries.take(2).map((entry) {
      final value = entry.value;
      if (value is bool && value) return '#${entry.key}';
      if (value is String) return '#$value';
      if (value is num) return '#$value';
      if (value is List && value.isNotEmpty) return '#${value.first}';
      return '#${entry.key}';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hashtags = _extractHashtags(widget.data['metadata']);
    final imageUrl = widget.data['imageUrl'] ?? '';
    final title = widget.data['title'] ?? 'No title';
    final hobby = widget.data['hobby'] ?? '';

    final double cardHeight =
        widget.height ??
        (widget.style == CardStyle.tall
            ? 260
            : widget.style == CardStyle.wide
            ? 260
            : 220);

    final double cardWidth =
        widget.width ??
        (widget.style == CardStyle.tall
            ? 160
            : widget.style == CardStyle.wide
            ? 260
            : 200);

    return SizedBox(
      height: cardHeight + 60,
      width: cardWidth,
      child: Column(
        children: [
          GestureDetector(
            onTap: widget.onTap,
            onDoubleTap: _toggleLike,
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_outline,
                            color: Colors.redAccent,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$likeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 36,
                    left: 12,
                    right: 12,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                      ),
                    ),
                  ),
                  if (hashtags.isNotEmpty)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Wrap(
                        spacing: 6,
                        children: hashtags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(color: Colors.black45, blurRadius: 1),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.color, width: 1),
            ),
            child: Text(
              hobby,
              style: TextStyle(
                fontSize: 12,
                color: widget.color.darken(0.2),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
