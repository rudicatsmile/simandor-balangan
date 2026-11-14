class UnitDetail {
  String? idt;
  String? idPostgreSql;
  String? kdUnit;
  String? nmUnit;
  String? kdUnitLink;
  String? nmUnitLink;
  String? nmaPimpinan;
  String? nipPimpinan;
  String? jabPimpinan;
  String? pktPimpinan;
  String? hpPimpinan;
  String? pinPimpinan;
  String? emaPimpinan;
  String? nmPengurus;
  String? nipPengurus;
  String? jbtPengurus;
  String? hpPengurus;
  String? pinPengurus;
  String? emaPengurus;
  String? nmPenyimpan;
  String? nipPenyimpan;
  String? jbtPenyimpan;
  String? hpPenyimpan;
  String? pinPenyimpan;
  String? emaPenyimpan;

  UnitDetail({
    this.idt,
    this.idPostgreSql,
    this.kdUnit,
    this.nmUnit,
    this.kdUnitLink,
    this.nmUnitLink,
    this.nmaPimpinan,
    this.nipPimpinan,
    this.jabPimpinan,
    this.pktPimpinan,
    this.hpPimpinan,
    this.pinPimpinan,
    this.emaPimpinan,
    this.nmPengurus,
    this.nipPengurus,
    this.jbtPengurus,
    this.hpPengurus,
    this.pinPengurus,
    this.emaPengurus,
    this.nmPenyimpan,
    this.nipPenyimpan,
    this.jbtPenyimpan,
    this.hpPenyimpan,
    this.pinPenyimpan,
    this.emaPenyimpan,
  });

  factory UnitDetail.fromJson(Map<String, dynamic> json) => UnitDetail(
        idt: json['IDT']?.toString(),
        idPostgreSql: json['IdPostgreSQL']?.toString(),
        kdUnit: json['Kd_Unit']?.toString(),
        nmUnit: json['Nm_Unit']?.toString(),
        kdUnitLink: json['Kd_Unit_Link']?.toString(),
        nmUnitLink: json['Nm_Unit_Link']?.toString(),
        nmaPimpinan: json['Nma_Pimpinan']?.toString(),
        nipPimpinan: json['Nip_Pimpinan']?.toString(),
        jabPimpinan: json['Jab_Pimpinan']?.toString(),
        pktPimpinan: json['Pkt_Pimpinan']?.toString(),
        hpPimpinan: json['Hp_Pimpinan']?.toString(),
        pinPimpinan: json['Pin_Pimpinan']?.toString(),
        emaPimpinan: json['Ema_Pimpinan']?.toString(),
        nmPengurus: json['Nm_Pengurus']?.toString(),
        nipPengurus: json['Nip_Pengurus']?.toString(),
        jbtPengurus: json['Jbt_Pengurus']?.toString(),
        hpPengurus: json['Hp_Pengurus']?.toString(),
        pinPengurus: json['Pin_Pengurus']?.toString(),
        emaPengurus: json['Ema_Pengurus']?.toString(),
        nmPenyimpan: json['Nm_Penyimpan']?.toString(),
        nipPenyimpan: json['Nip_Penyimpan']?.toString(),
        jbtPenyimpan: json['Jbt_Penyimpan']?.toString(),
        hpPenyimpan: json['Hp_Penyimpan']?.toString(),
        pinPenyimpan: json['Pin_Penyimpan']?.toString(),
        emaPenyimpan: json['Ema_Penyimpan']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'IDT': idt,
        'IdPostgreSQL': idPostgreSql,
        'Kd_Unit': kdUnit,
        'Nm_Unit': nmUnit,
        'Kd_Unit_Link': kdUnitLink,
        'Nm_Unit_Link': nmUnitLink,
        'Nma_Pimpinan': nmaPimpinan,
        'Nip_Pimpinan': nipPimpinan,
        'Jab_Pimpinan': jabPimpinan,
        'Pkt_Pimpinan': pktPimpinan,
        'Hp_Pimpinan': hpPimpinan,
        'Pin_Pimpinan': pinPimpinan,
        'Ema_Pimpinan': emaPimpinan,
        'Nm_Pengurus': nmPengurus,
        'Nip_Pengurus': nipPengurus,
        'Jbt_Pengurus': jbtPengurus,
        'Hp_Pengurus': hpPengurus,
        'Pin_Pengurus': pinPengurus,
        'Ema_Pengurus': emaPengurus,
        'Nm_Penyimpan': nmPenyimpan,
        'Nip_Penyimpan': nipPenyimpan,
        'Jbt_Penyimpan': jbtPenyimpan,
        'Hp_Penyimpan': hpPenyimpan,
        'Pin_Penyimpan': pinPenyimpan,
        'Ema_Penyimpan': emaPenyimpan,
      };

  @override
  String toString() => nmUnit ?? '';
}

