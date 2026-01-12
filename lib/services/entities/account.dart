class UserAccount {
  final String? firstname;
  final String? lastname;
  final String? username;
  final String? id;
  final int initial_color;
  final DateTime? create_at;
  final DateTime? lastActivity;
  final DateTime? lastConnexion;

  static const AVATAR_COLOR = [
    "#E65100",
    "#01579B",
    "#880E4F",
    "#2E7D32",
    "#4A148C"
  ];

  UserAccount(
      {this.create_at,
      this.lastActivity,
      this.lastConnexion,
      this.initial_color = 0,
      this.id,
      this.firstname,
      this.lastname,
      this.username});

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
      id: json['_id'],
      username: json['username'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      create_at: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      lastActivity: json['last_activity'] != null ? DateTime.parse(json['last_activity']) : null,
      lastConnexion: json['last_connexion'] != null ? DateTime.parse(json['last_connexion']) : null,
      initial_color: json["initial_color"] ?? 0);
}
