import 'package:flutter_test/flutter_test.dart';
import 'package:simandoronline/core/network/api_result.dart';
import 'package:simandoronline/core/utils/currency_format.dart';
import 'package:simandoronline/data/models/user_session.dart';

void main() {
  group('CurrencyFormat Tests', () {
    test('Format positive number correctly', () {
      final formatted = CurrencyFormat.convertToIdr(10000000, 0);
      expect(formatted.contains('10.000.000'), isTrue);
    });

    test('Handle null and string values safely', () {
      expect(CurrencyFormat.convertToIdr(null, 0), 'Rp 0');
      final formattedString = CurrencyFormat.convertToIdr('500000', 0);
      expect(formattedString.contains('500.000'), isTrue);
    });
  });

  group('UserSession Tests', () {
    test('Default session is active and not admin', () {
      const session = UserSession();
      expect(session.isActive, isTrue);
      expect(session.isAdmin, isFalse);
    });

    test('Parse from JSON correctly with substrings', () {
      final json = {
        'User_ID': '10',
        'Kode': '24.04.04.01.01.001',
        'Full_Name': 'John Doe',
        'Short_Name': 'John',
        'Level': '1',
        'Admin': '1',
        'Active': 'Y',
        'Readonly': 'N',
        'Nm_Unit': 'Dinas Pendidikan',
        'Nm_Sub': 'Sub Bagian Umum',
        'Nm_UPB': 'SMPN 1 Balangan',
      };

      final session = UserSession.fromMap(json, username: 'admin1');
      expect(session.userName, 'admin1');
      expect(session.fullName, 'John Doe');
      expect(session.isAdmin, isTrue);
      expect(session.isActive, isTrue);
      expect(session.kdUnit, '24.04.04.01');
      expect(session.kdSubUnit, '24.04.04.01.01');
    });
  });

  group('ApiResult Tests', () {
    test('Success returns data and isSuccess=true', () {
      final result = ApiResult.success('OK');
      expect(result.isSuccess, isTrue);
      expect(result.data, 'OK');
      expect(result.errorMessage, isNull);
    });

    test('Failure returns errorMessage and isSuccess=false', () {
      final result = ApiResult.failure('Network error');
      expect(result.isSuccess, isFalse);
      expect(result.data, isNull);
      expect(result.errorMessage, 'Network error');
    });
  });
}

