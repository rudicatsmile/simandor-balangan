class UpbDetail {
  String? idt;
  String? kdUpb;
  String? nmUpb;
  String? kdKelurahan;
  String? idPostgreSql;

  UpbDetail({
    this.idt,
    this.kdUpb,
    this.nmUpb,
    this.kdKelurahan,
    this.idPostgreSql,
  });

  factory UpbDetail.fromJson(Map<String, dynamic> json) => UpbDetail(
        idt: json['IDT']?.toString(),
        kdUpb: json['Kd_UPB']?.toString(),
        nmUpb: json['Nm_UPB']?.toString(),
        kdKelurahan: json['KdKelurahan']?.toString(),
        idPostgreSql: json['IdPostgreSQL']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'IDT': idt,
        'Kd_UPB': kdUpb,
        'Nm_UPB': nmUpb,
        'KdKelurahan': kdKelurahan,
        'IdPostgreSQL': idPostgreSql,
      };

  @override
  String toString() => nmUpb ?? '';
}

