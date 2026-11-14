class UserSession {
  final String userName;
  final String userIid;
  final String kodeUpb;
  final String fullName;
  final String shortName;
  final String level;
  final String admin;
  final String active;
  final String readonly;
  final String nmUnit;
  final String nmSub;
  final String nmUpb;

  const UserSession({
    this.userName = '',
    this.userIid = '',
    this.kodeUpb = '',
    this.fullName = '',
    this.shortName = '',
    this.level = '',
    this.admin = '',
    this.active = '',
    this.readonly = '',
    this.nmUnit = '',
    this.nmSub = '',
    this.nmUpb = '',
  });

  bool get isActive => active == 'Y' || active.isEmpty;
  bool get isAdmin => admin == '1';

  String get kdUnit => kodeUpb.length >= 11 ? kodeUpb.substring(0, 11) : kodeUpb;
  String get kdSubUnit => kodeUpb.length >= 14 ? kodeUpb.substring(0, 14) : kodeUpb;

  factory UserSession.fromMap(Map<String, dynamic> json, {String username = ''}) {
    return UserSession(
      userName: username,
      userIid: json['User_ID']?.toString() ?? '',
      kodeUpb: json['Kode']?.toString() ?? '',
      fullName: json['Full_Name']?.toString() ?? '',
      shortName: json['Short_Name']?.toString() ?? '',
      level: json['Level']?.toString() ?? '',
      admin: json['Admin']?.toString() ?? '',
      active: json['Active']?.toString() ?? '',
      readonly: json['Readonly']?.toString() ?? '',
      nmUnit: json['Nm_Unit']?.toString() ?? '',
      nmSub: json['Nm_Sub']?.toString() ?? '',
      nmUpb: json['Nm_UPB']?.toString() ?? '',
    );
  }
}

