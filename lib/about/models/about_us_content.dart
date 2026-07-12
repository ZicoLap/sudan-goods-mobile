class AboutUsContent {
  final String title;
  final String body;
  final String? titleAr;
  final String? bodyAr;
  final String? phone;
  final String? email;
  final String? website;
  final String? instagram;
  final String? twitter;
  final String? facebook;

  const AboutUsContent({
    required this.title,
    required this.body,
    this.titleAr,
    this.bodyAr,
    this.phone,
    this.email,
    this.website,
    this.instagram,
    this.twitter,
    this.facebook,
  });

  String localizedTitle(String languageCode) =>
      languageCode == 'ar' && titleAr != null && titleAr!.isNotEmpty
          ? titleAr!
          : title;

  String localizedBody(String languageCode) =>
      languageCode == 'ar' && bodyAr != null && bodyAr!.isNotEmpty
          ? bodyAr!
          : body;

  factory AboutUsContent.fromMap(Map<String, dynamic> map) {
    return AboutUsContent(
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      titleAr: map['title_ar'] as String?,
      bodyAr: map['body_ar'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      website: map['website'] as String?,
      instagram: map['instagram'] as String?,
      twitter: map['twitter'] as String?,
      facebook: map['facebook'] as String?,
    );
  }
}
