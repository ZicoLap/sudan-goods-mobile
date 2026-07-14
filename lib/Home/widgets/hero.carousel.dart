import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sudan_goods/home/widgets/shimmer_components.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  int _currentIndex = 0;
  bool _isLoading = true;

  final List<String> _carouselItems = [
    'https://firebasestorage.googleapis.com/v0/b/sudan-mall-a458a.firebasestorage.app/o/hero_mobile_app%2Fhero1.png?alt=media&token=0c6ee3f0-a38e-4bae-b9d0-f4580e6d5038',
    'https://firebasestorage.googleapis.com/v0/b/sudan-mall-a458a.firebasestorage.app/o/hero_mobile_app%2Fhero2.png?alt=media&token=5e4b6520-38a4-4359-a513-00dd1d82a719',
    'https://firebasestorage.googleapis.com/v0/b/sudan-mall-a458a.firebasestorage.app/o/hero_mobile_app%2Fhero3.png?alt=media&token=909cd123-1bc5-49b6-b9ad-a4ad9c6127a8',
    'https://firebasestorage.googleapis.com/v0/b/sudan-mall-a458a.firebasestorage.app/o/hero_mobile_app%2Fhero5.png?alt=media&token=68ccad82-e6ab-4000-9d86-3ab11ab71608',
    'https://firebasestorage.googleapis.com/v0/b/sudan-mall-a458a.firebasestorage.app/o/hero_mobile_app%2Fhero6.png?alt=media&token=5f55d1a1-3229-4298-80e5-acd3f52091fb',
  ];

  @override
  void initState() {
    super.initState();
    // Simulate initial loading delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final height = isTablet ? 360.0 : 200.0;

    if (_isLoading) {
      return ShimmerComponents.heroCarouselShimmer();
    }

    return Column(
      children: [
        // ── Slides ────────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              CarouselSlider.builder(
                itemCount: _carouselItems.length,
                itemBuilder: (context, index, realIndex) {
                  final imageUrl = _carouselItems[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder:
                            (context, url) => ShimmerComponents.shimmerWrapper(
                              child: Container(
                                color: Colors.white,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                      // Bottom gradient overlay
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 70,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.45),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                options: CarouselOptions(
                  height: height,
                  animateToClosest: true,
                  scrollDirection: Axis.horizontal,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 700),
                  autoPlayCurve: Curves.easeInOutCubic,
                  enlargeCenterPage: false,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    setState(() => _currentIndex = index);
                  },
                ),
              ),
              // Pill indicators overlaid bottom-center
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      _carouselItems.asMap().entries.map((entry) {
                        final active = _currentIndex == entry.key;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOut,
                          width: active ? 20 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color:
                                active
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
        // ── Progress line ─────────────────────────────────────────────
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_carouselItems.length, (i) {
            final active = i == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: active ? 28 : 6,
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color:
                    active
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }
}
