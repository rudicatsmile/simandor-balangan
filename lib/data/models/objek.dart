class Objek {
  String? idt;
  String? kdAset;
  String? nmAset;

  Objek({
    this.idt,
    this.kdAset,
    this.nmAset,
  });

  factory Objek.fromJson(Map<String, dynamic> json) => Objek(
        idt: json['IDT']?.toString(),
        kdAset: json['Kd_Aset']?.toString(),
        nmAset: json['Nm_Aset']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'IDT': idt,
        'Kd_Aset': kdAset,
        'Nm_Aset': nmAset,
      };

  @override
  String toString() => nmAset ?? '';
}

