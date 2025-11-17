class NewPasswordModel {
  final String newPassword;

  NewPasswordModel({
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'newPassword': newPassword,
    };
  }

  factory NewPasswordModel.fromJson(Map<String, dynamic> json) {
    return NewPasswordModel(
      newPassword: json['newPassword'],
    );
  }
}
