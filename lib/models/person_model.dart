class Person {
  final int id;
  final String name;
  final String? profilePath;
  final String? biography;
  final String? knownForDepartment;
  final String? birthday;
  final String? placeOfBirth;
  final double? popularity;
  final int? gender; // 1 female, 2 male per TMDB

  Person({
    required this.id,
    required this.name,
    this.profilePath,
    this.biography,
    this.knownForDepartment,
    this.birthday,
    this.placeOfBirth,
    this.popularity,
    this.gender,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,
      name: (json['name'] ?? json['title'] ?? 'Unknown') as String,
      profilePath: json['profile_path'] as String?,
      biography: json['biography'] as String?,
      knownForDepartment: json['known_for_department'] as String?,
      birthday: json['birthday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble(),
      gender: json['gender'] as int?,
    );
  }
}


