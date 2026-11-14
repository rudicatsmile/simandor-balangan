class Barang {
  String? idt;
  String? referensi;
  String? refGroup;
  String? refMutasi;
  String? refUsulan;
  String? refHistory;
  String? refUsulanHis;
  String? kdUpb;
  String? kdAset;
  String? kdAset108;
  String? kdRuang;
  String? noRegister;
  String? noPengadaan;
  String? refTemp;
  String? nmAset;
  String? kdPemilik;
  String? tglPerolehan;
  String? tglMutasi;
  String? tglMulai;
  String? tahun;
  String? luasM2;
  String? alamat;
  String? hakTanah;
  String? sertifikat;
  String? sertifikatTanggal;
  String? sertifikatNomor;
  String? penggunaan;
  String? asalUsul;
  String? harga;
  String? noSp2D;
  String? merk;
  String? type;
  String? ukuranCc;
  String? bahan;
  String? nomorPabrik;
  String? nomorRangka;
  String? nomorMesin;
  String? nomorPolisi;
  String? nomorPolisiLama;
  String? nomorBpkb;
  String? pemegang;
  String? pemegangLama;
  String? kondisi;
  String? masaManfaat;
  String? nilaiAkhir;
  String? bertingkat;
  String? beton;
  String? luasLantai;
  String? lokasi;
  String? fileName;
  String? keterangan;

  Barang({
    this.idt,
    this.referensi,
    this.refGroup,
    this.refMutasi,
    this.refUsulan,
    this.refHistory,
    this.refUsulanHis,
    this.kdUpb,
    this.kdAset,
    this.kdAset108,
    this.kdRuang,
    this.noRegister,
    this.noPengadaan,
    this.refTemp,
    this.nmAset,
    this.kdPemilik,
    this.tglPerolehan,
    this.tglMutasi,
    this.tglMulai,
    this.tahun,
    this.luasM2,
    this.alamat,
    this.hakTanah,
    this.sertifikat,
    this.sertifikatTanggal,
    this.sertifikatNomor,
    this.penggunaan,
    this.asalUsul,
    this.harga,
    this.noSp2D,
    this.merk,
    this.type,
    this.ukuranCc,
    this.bahan,
    this.nomorPabrik,
    this.nomorRangka,
    this.nomorMesin,
    this.nomorPolisi,
    this.nomorPolisiLama,
    this.nomorBpkb,
    this.pemegang,
    this.pemegangLama,
    this.kondisi,
    this.masaManfaat,
    this.nilaiAkhir,
    this.bertingkat,
    this.beton,
    this.luasLantai,
    this.lokasi,
    this.fileName,
    this.keterangan,
  });

  factory Barang.fromJson(Map<String, dynamic> json) => Barang(
        idt: (json['IDT'] ?? json['idt'])?.toString(),
        referensi: json['Referensi']?.toString(),
        refGroup: json['Ref_Group']?.toString(),
        refMutasi: json['Ref_Mutasi']?.toString(),
        refUsulan: json['Ref_Usulan']?.toString(),
        refHistory: json['Ref_History']?.toString(),
        refUsulanHis: json['Ref_Usulan_His']?.toString(),
        kdUpb: json['Kd_UPB']?.toString(),
        kdAset: json['Kd_Aset']?.toString(),
        kdAset108: json['Kd_Aset_108']?.toString(),
        kdRuang: json['Kd_Ruang']?.toString(),
        noRegister: json['No_Register']?.toString(),
        noPengadaan: json['No_Pengadaan']?.toString(),
        refTemp: json['Ref_Temp']?.toString(),
        nmAset: json['Nm_Aset']?.toString(),
        kdPemilik: json['Kd_Pemilik']?.toString(),
        tglPerolehan: json['Tgl_Perolehan']?.toString(),
        tglMutasi: json['Tgl_Mutasi']?.toString(),
        tglMulai: json['Tgl_Mulai']?.toString(),
        tahun: json['Tahun']?.toString(),
        luasM2: json['Luas_M2']?.toString(),
        alamat: json['Alamat']?.toString(),
        hakTanah: json['Hak_Tanah']?.toString(),
        sertifikat: json['Sertifikat']?.toString(),
        sertifikatTanggal: json['Sertifikat_Tanggal']?.toString(),
        sertifikatNomor: json['Sertifikat_Nomor']?.toString(),
        penggunaan: json['Penggunaan']?.toString(),
        asalUsul: json['Asal_Usul']?.toString(),
        harga: json['Harga']?.toString(),
        noSp2D: json['No_SP2D']?.toString(),
        merk: json['Merk']?.toString(),
        type: json['Type']?.toString(),
        ukuranCc: json['Ukuran_CC']?.toString(),
        bahan: json['Bahan']?.toString(),
        nomorPabrik: json['Nomor_Pabrik']?.toString(),
        nomorRangka: json['Nomor_Rangka']?.toString(),
        nomorMesin: json['Nomor_Mesin']?.toString(),
        nomorPolisi: json['Nomor_Polisi']?.toString(),
        nomorPolisiLama: json['Nomor_Polisi_Lama']?.toString(),
        nomorBpkb: json['Nomor_BPKB']?.toString(),
        pemegang: json['Pemegang']?.toString(),
        pemegangLama: json['Pemegang_Lama']?.toString(),
        kondisi: json['Kondisi']?.toString(),
        masaManfaat: json['Masa_Manfaat']?.toString(),
        nilaiAkhir: json['Nilai_Akhir']?.toString(),
        bertingkat: json['Bertingkat']?.toString(),
        beton: json['Beton']?.toString(),
        luasLantai: json['Luas_Lantai']?.toString(),
        lokasi: json['Lokasi']?.toString(),
        fileName: (json['file_name'] ?? json['File_Name'] ?? json['fileName'])?.toString(),
        keterangan: json['Keterangan']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'IDT': idt,
        'Referensi': referensi,
        'Ref_Group': refGroup,
        'Ref_Mutasi': refMutasi,
        'Ref_Usulan': refUsulan,
        'Ref_History': refHistory,
        'Ref_Usulan_His': refUsulanHis,
        'Kd_UPB': kdUpb,
        'Kd_Aset': kdAset,
        'Kd_Aset_108': kdAset108,
        'Kd_Ruang': kdRuang,
        'No_Register': noRegister,
        'No_Pengadaan': noPengadaan,
        'Ref_Temp': refTemp,
        'Nm_Aset': nmAset,
        'Kd_Pemilik': kdPemilik,
        'Tgl_Perolehan': tglPerolehan,
        'Tgl_Mutasi': tglMutasi,
        'Tgl_Mulai': tglMulai,
        'Tahun': tahun,
        'Luas_M2': luasM2,
        'Alamat': alamat,
        'Hak_Tanah': hakTanah,
        'Sertifikat': sertifikat,
        'Sertifikat_Tanggal': sertifikatTanggal,
        'Sertifikat_Nomor': sertifikatNomor,
        'Penggunaan': penggunaan,
        'Asal_Usul': asalUsul,
        'Harga': harga,
        'No_SP2D': noSp2D,
        'Merk': merk,
        'Type': type,
        'Ukuran_CC': ukuranCc,
        'Bahan': bahan,
        'Nomor_Pabrik': nomorPabrik,
        'Nomor_Rangka': nomorRangka,
        'Nomor_Mesin': nomorMesin,
        'Nomor_Polisi': nomorPolisi,
        'Nomor_Polisi_Lama': nomorPolisiLama,
        'Nomor_BPKB': nomorBpkb,
        'Pemegang': pemegang,
        'Pemegang_Lama': pemegangLama,
        'Kondisi': kondisi,
        'Masa_Manfaat': masaManfaat,
        'Nilai_Akhir': nilaiAkhir,
        'Bertingkat': bertingkat,
        'Beton': beton,
        'Luas_Lantai': luasLantai,
        'Lokasi': lokasi,
        'file_name': fileName,
        'Keterangan': keterangan,
      };

  @override
  String toString() => noRegister ?? nmAset ?? '';
}

