class ApiEndpoints {
  //static const String baseUrl = 'https://sicaper.balangankab.go.id/api';
  static const String baseUrl = "https://www.sipandabmd.balangankab.go.id/admin/api";
  static const String baseUrlImages = 'https://www.sipandabmd.balangankab.go.id/images';
  static const String baseUrlImagesSimandor =
      'https://www.sipandabmd.balangankab.go.id/admin/simandor/images';

  // Auth
  static const String login = '$baseUrl/login_kib.php';

  // Barang
  static const String getBarangDetail = '$baseUrl/getBarangDetail.php';
  static const String getBarang = '$baseUrl/getBarang.php';
  static const String getBarang3 = '$baseUrl/getBarang3.php';

  // Units
  static const String getUnit = '$baseUrl/getUnit.php';
  static const String getUnitDetail = '$baseUrl/getUnitDetail.php';
  static const String getUpbDetail = '$baseUrl/getUpbDetail.php';
  static const String getRuangDetail = '$baseUrl/getRuangDetail.php';

  // Mapping & Verify
  static const String updateTabelKib = '$baseUrl/update_tabel_kib.php';
  static const String addVerificationData = '$baseUrl/add_verification_data.php';

  // Photo
  static const String checkViewKibPhoto = '$baseUrl/checkViewKibPhoto.php';
  static const String uploadPhoto = '$baseUrl/upload_photo.php';
  static const String uploadPhotoV2 = '$baseUrl/upload_photo_v2.php';

  // Pesan / Message
  static const String insertMessage = '$baseUrl/insert_message.php';
  static const String pesanGetAll = '$baseUrl/pesan/getAll.php';
  static const String pesanTampil = '$baseUrl/pesan/tampil.php';
}

