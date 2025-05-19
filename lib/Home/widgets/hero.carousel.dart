


import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  int _currentIndex = 0;

  final List<String> _carouselItems = [
    'https://firebasestorage.googleapis.com/v0/b/sudan-mall-a458a.firebasestorage.app/o/hero_mobile_app%2Fhero1.png?alt=media&token=0c6ee3f0-a38e-4bae-b9d0-f4580e6d5038',
    'https://firebasestorage.googleapis.com/v0/b/sudan-mall-a458a.firebasestorage.app/o/hero_mobile_app%2Fhero2.png?alt=media&token=5e4b6520-38a4-4359-a513-00dd1d82a719',
    'https://firebasestorage.googleapis.com/v0/b/sudan-mall-a458a.firebasestorage.app/o/hero_mobile_app%2Fhero3.png?alt=media&token=909cd123-1bc5-49b6-b9ad-a4ad9c6127a8',
    'https://firebasestorage.googleapis.com/v0/b/sudan-mall-a458a.firebasestorage.app/o/hero_mobile_app%2Fhero5.png?alt=media&token=68ccad82-e6ab-4000-9d86-3ab11ab71608',
    'https://firebasestorage.googleapis.com/v0/b/sudan-mall-a458a.firebasestorage.app/o/hero_mobile_app%2Fhero6.png?alt=media&token=5f55d1a1-3229-4298-80e5-acd3f52091fb',
  ];


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _carouselItems.length,
          itemBuilder: (context, index, realIndex) {
            final imageUrl = _carouselItems[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          },
          options: CarouselOptions(
            height: 250,
            animateToClosest: true,
           scrollDirection: Axis.horizontal,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _carouselItems.asMap().entries.map((entry) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == entry.key
                    ? Colors.orange
                    : Colors.grey.shade300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
