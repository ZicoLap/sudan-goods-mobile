/// Content model for a single onboarding walkthrough page.
class OnboardingPage {
  const OnboardingPage({
    required this.assetPath,
    required this.title,
    required this.subtitle,
    required this.semanticsLabel,
    this.backdropVariant = 0,
  });

  final String assetPath;
  final String title;
  final String subtitle;
  final String semanticsLabel;
  final int backdropVariant;
}
