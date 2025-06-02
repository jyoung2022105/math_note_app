class Note {
  String id;
  String title;
  String content; // LaTeX content
  DateTime createdAt;
  DateTime updatedAt;
  String? folderId; // 폴더 ID (선택적)

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.folderId,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'folderId': folderId,
  };

  // JSON 역직렬화
  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    folderId: json['folderId'] as String?,
  );

  // copyWith 메소드 추가
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? folderId,
    bool setToNullFolderId = false, // folderId를 명시적으로 null로 설정할지 여부
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      folderId: setToNullFolderId ? null : folderId ?? this.folderId,
    );
  }
}
