import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/promotion.dart';

class PromotionBanner extends StatelessWidget {
  final List<Promotion> promotions;

  const PromotionBanner({Key? key, required this.promotions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        viewportFraction: 0.9,
        aspectRatio: 16/9,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: promotions.map((promotion) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                // Handle promotion tap (e.g., open the link)
                print('Tapped promotion: ${promotion.title}');
                // You can implement navigation to the promotion details or use the linkUrl here
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(promotion.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promotion.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          promotion.description,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
