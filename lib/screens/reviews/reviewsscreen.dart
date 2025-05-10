import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/models/review.dart';
import 'package:foodapp/screens/resturants/cubit.dart';

class Reviewsscreen extends StatefulWidget {
  final String restaurantId;

  const Reviewsscreen({super.key, required this.restaurantId});

  @override
  State<Reviewsscreen> createState() => _ReviewsscreenState();
}

class _ReviewsscreenState extends State<Reviewsscreen> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 3.0;
  bool _isLoading = false;
  List<Review> _reviews = [];
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get reviews from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(widget.restaurantId)
          .collection("reviews")
          .orderBy('date', descending: true)
          .get();

      // Convert to Review objects
      final reviews = querySnapshot.docs
          .map((doc) => Review.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Calculate average rating
      if (reviews.isNotEmpty) {
        final totalRating = reviews.fold<double>(
            0, (sum, review) => sum + double.parse(review.rating));
        double average = totalRating / reviews.length;
        _averageRating = double.parse(average.toStringAsFixed(1));
      } else {
        _averageRating = 0.0;
      }

      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching reviews: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a review')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current date
      final now = DateTime.now();
      final formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} – ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      // Create review object
      final reviewData = {
        'name': 'Anonymous User', // Replace with actual user name if available
        'review': _reviewController.text.trim(),
        'rating': _rating.toString(),
        'date': formattedDate,
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(widget.restaurantId)
          .collection("reviews")
          .add(reviewData);

      // Clear input
      _reviewController.clear();
      setState(() {
        _rating = 3.0;
      });

      // Refresh reviews
      await _fetchReviews();

      // Update the restaurant's average rating
      await _updateRestaurantRating();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submitted successfully')),
      );
    } catch (e) {
      print("Error submitting review: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update the restaurant's average rating
  Future<void> _updateRestaurantRating() async {
    try {
      // Round to one decimal place for consistency
      double roundedRating = double.parse(_averageRating.toStringAsFixed(1));

      // Get the current restaurant data
      final restaurantDoc = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(widget.restaurantId)
          .get();

      if (restaurantDoc.exists) {
        // Update the rating in the restaurant document
        await FirebaseFirestore.instance
            .collection("restaurants")
            .doc(widget.restaurantId)
            .update({'rating': roundedRating});

        // Also refresh the restaurants list
        Restuarantscubit.get(context).getRestuarants();
      }
    } catch (e) {
      print('Error updating restaurant rating: $e');
    }
  }

  // Custom star rating widget
  Widget _buildRatingStars(double rating,
      {bool interactive = false, double size = 20}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: interactive
              ? () {
                  if (interactive) {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  }
                }
              : null,
          child: Icon(
            index < rating
                ? Icons.star
                : index < rating + 0.5 && index >= rating
                    ? Icons.star_half
                    : Icons.star_border,
            color: Colors.amber,
            size: size.sp,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).reviews),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Rating Summary
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).average_rating,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Text(
                          _averageRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _buildRatingStars(_averageRating),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${_reviews.length} ${S.of(context).reviews}",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          // Add New Review
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).write_review,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildRatingStars(_rating, interactive: true, size: 30),
                SizedBox(height: 10.h),
                TextField(
                  controller: _reviewController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: S.of(context).review_hint,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(S.of(context).submit),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Review List
          Expanded(
            child: _isLoading && _reviews.isEmpty
                ? Center(child: CircularProgressIndicator())
                : _reviews.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rate_review_outlined,
                                size: 50.sp, color: Colors.grey),
                            SizedBox(height: 10.h),
                            Text(
                              S.of(context).no_reviews,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(12.w),
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          final review = _reviews[index];
                          return ReviewCard(
                            review: review,
                            buildRatingStars: _buildRatingStars,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;
  final Widget Function(double, {bool interactive, double size})
      buildRatingStars;

  const ReviewCard({
    super.key,
    required this.review,
    required this.buildRatingStars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.deepOrange.withOpacity(0.2),
                child: Icon(Icons.person, color: Colors.deepOrange),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      review.date,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 14.sp),
                    SizedBox(width: 2.w),
                    Text(
                      review.rating,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            review.review,
            style: TextStyle(fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
