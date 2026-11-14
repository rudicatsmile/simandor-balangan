class VerifyDataResponse {
  final String? msg;
  final String? kodeBarang;
  final String? state;

  VerifyDataResponse({
    this.msg,
    this.kodeBarang,
    this.state,
  });

  factory VerifyDataResponse.fromJson(Map<String, dynamic> json) =>
      VerifyDataResponse(
        msg: json['msg']?.toString(),
        kodeBarang: json['jmlCountId']?.toString(),
        state: json['KodeBookings']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'msg': msg,
        'jmlCountId': kodeBarang,
        'KodeBookings': state,
      };
}

