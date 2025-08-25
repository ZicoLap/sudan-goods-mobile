/// Lightweight store summary used in messaging domain.
///
/// This keeps the Conversation entity small and avoids depending on the
/// full Store model.
class StoreSummary {
  final String id;
  final String name;
  final String? logoUrl;
  final bool isActive;
  final bool isApproved;

  const StoreSummary({
    required this.id,
    required this.name,
    this.logoUrl,
    this.isActive = true,
    this.isApproved = false,
  });

  StoreSummary copyWith({
    String? id,
    String? name,
    String? logoUrl,
    bool? isActive,
    bool? isApproved,
  }) {
    return StoreSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  @override
  String toString() => 'StoreSummary(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is StoreSummary &&
            other.id == id &&
            other.name == name &&
            other.logoUrl == logoUrl &&
            other.isActive == isActive &&
            other.isApproved == isApproved);
  }

  @override
  int get hashCode => Object.hash(id, name, logoUrl, isActive, isApproved);
}
