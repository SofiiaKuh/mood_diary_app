import 'package:flutter/material.dart';

class MoodCard extends StatelessWidget {
  final String date;
  final int rating;
  final String emoji;
  final String note;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MoodCard({
    super.key,
    required this.date,
    required this.rating,
    required this.emoji,
    required this.note,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
  width: 280,
  height: 350,
  margin: const EdgeInsets.only(right: 16),
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date,
              style: const TextStyle(
                  fontFamily: 'Jua', fontSize: 16, color: Colors.black)),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
              IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: onDelete),
            ],
          )
        ],
      ),
      const SizedBox(height: 20),

      Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (i) => Icon(
              i < rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 36,
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),

      Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 40),
        ),
      ),
      const SizedBox(height: 20),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          note,
          style: const TextStyle(
            fontFamily: 'Jua',
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
      ),
    ],
  ),
);
  }
}