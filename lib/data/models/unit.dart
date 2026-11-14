class Unit {
  String? kodeUnit;
  String? namaUnit;

  Unit({
    this.kodeUnit,
    this.namaUnit,
  });

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
        kodeUnit: json['kode_unit']?.toString(),
        namaUnit: json['nama_unit']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'kode_unit': kodeUnit,
        'nama_unit': namaUnit,
      };

  @override
  String toString() => namaUnit ?? '';
}

