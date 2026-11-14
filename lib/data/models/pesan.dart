class Pesan {
  final String? idt;
  final String? pesan;
  final String? userName;
  final String? recorded;
  final String? pencatat;
  final String? tampil;

  Pesan({
    this.idt,
    this.pesan,
    this.userName,
    this.recorded,
    this.pencatat,
    this.tampil,
  });

  factory Pesan.fromJson(Map<String, dynamic> json) => Pesan(
        idt: json["idt"]?.toString(),
        pesan: json["pesan"]?.toString(),
        userName: json["userName"]?.toString(),
        recorded: (json["Recorded"] ?? json["recorded"])?.toString(),
        pencatat: (json["Pencatat"] ?? json["pencatat"])?.toString(),
        tampil: json["tampil"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "idt": idt,
        "pesan": pesan,
        "userName": userName,
        "Recorded": recorded,
        "Pencatat": pencatat,
        "tampil": tampil,
      };
}
