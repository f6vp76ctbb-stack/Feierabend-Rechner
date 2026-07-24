import 'work_config.dart';

/// Ein Arbeitszeit-Profil (z. B. „Mo–Do", „Freitag", „Nachtschicht").
///
/// Reine Domain-Klasse. Bündelt einen Namen mit einer [WorkConfig].
class Profile {
  final String id;
  final String name;
  final WorkConfig config;

  const Profile({
    required this.id,
    required this.name,
    required this.config,
  });

  Profile copyWith({String? name, WorkConfig? config}) => Profile(
        id: id,
        name: name ?? this.name,
        config: config ?? this.config,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'config': config.toJson(),
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        name: json['name'] as String,
        config: WorkConfig.fromJson(
          (json['config'] as Map).cast<String, dynamic>(),
        ),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          other.id == id &&
          other.name == name &&
          other.config == config;

  @override
  int get hashCode => Object.hash(id, name, config);

  @override
  String toString() => 'Profile($id, $name, $config)';
}
