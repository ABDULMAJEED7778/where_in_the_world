import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/online_game_models.dart';

/// Scrollable list of asked questions with yes/no answer badges.
class OnlineQuestionsList extends StatelessWidget {
  final List<OnlineQuestion> questions;

  const OnlineQuestionsList({super.key, required this.questions});

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: Colors.white.withOpacity(0.3),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'No questions asked yet',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ask yes/no questions to narrow down the country!',
              style: GoogleFonts.hanaleiFill(color: Colors.white24),
              maxLines: 1,
              textScaler: const TextScaler.linear(0.8),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEA00).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.quiz,
                  color: Color(0xFFFFEA00),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'QUESTIONS',
                style: GoogleFonts.hanaleiFill(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${questions.length}',
                  style: GoogleFonts.hanaleiFill(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Scrollable Questions List
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: questions
                    .asMap()
                    .entries
                    .map(
                      (entry) => _buildQuestionTile(entry.value, entry.key + 1),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTile(OnlineQuestion question, int number) {
    final isYes = question.answer;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isYes
              ? const Color(0xFF74E67C).withOpacity(0.3)
              : const Color(0xFFE63C3D).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Question number
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.hanaleiFill(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Question content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.text,
                  style: GoogleFonts.hanaleiFill(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Asked by ${question.askedByName}',
                  style: GoogleFonts.hanaleiFill(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Answer badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isYes
                    ? [const Color(0xFF74E67C), const Color(0xFF4CAF50)]
                    : [const Color(0xFFE63C3D), const Color(0xFFB71C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isYes
                      ? const Color(0xFF74E67C).withOpacity(0.4)
                      : const Color(0xFFE63C3D).withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isYes ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isYes ? 'YES' : 'NO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
