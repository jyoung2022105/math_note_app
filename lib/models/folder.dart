class Folder {
  String id;
  String name;
  List<String> noteIds; // 또는 List<Note> notes;
  DateTime createdAt;

  Folder({
    required this.id,
    required this.name,
    required this.noteIds,
    required this.createdAt,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'noteIds': noteIds,
    'createdAt': createdAt.toIso8601String(),
  };

  // JSON 역직렬화
  factory Folder.fromJson(Map<String, dynamic> json) => Folder(
    id: json['id'] as String,
    name: json['name'] as String,
    noteIds: List<String>.from(json['noteIds'] as List),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
