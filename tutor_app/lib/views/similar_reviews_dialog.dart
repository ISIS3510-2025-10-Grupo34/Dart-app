import 'package:flutter/material.dart';
import '../models/similar_tutor_review_model.dart';

class SimilarReviewsDialog extends StatelessWidget {
  final List<SimilarTutorInfo> similarReviews;

  const SimilarReviewsDialog({super.key, required this.similarReviews});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Reviews from Similar Tutors"),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: similarReviews.isEmpty
            ? const Center(child: Text("No similar tutor reviews found."))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: similarReviews.length,
                itemBuilder: (context, index) {
                  final tutorInfo = similarReviews[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                              "Similarity Basis: ${tutorInfo.similarityBasis.join(', ')}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          const Text(
                            "Best Reviews:",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Column(
                            children: tutorInfo.bestReviews.map((review) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(4)),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    // Use Column for review details
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          _buildStaticStarRating(
                                              review.rating.toDouble()),
                                          const Spacer(),
                                          Text(
                                            review.reviewDate,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        review.courseName,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        review.comment,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Close"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildStaticStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    int totalStars = 5;

    for (int i = 0; i < totalStars; i++) {
      stars.add(Icon(
        i < fullStars ? Icons.star : Icons.star_border,
        color: const Color(0xFF192650),
        size: 16,
      ));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}
