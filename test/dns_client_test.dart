// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:aliyun_dns_client/dns.dart';
import 'package:flutter_test/flutter_test.dart';

import 'secure.dart';

void main() {
  const testDomainName = "example.com"; // REPLACE WITH YOUR DOMAIN NAME
  const testRecordHost = "record-for-test";
  const testRecordType = "A";
  const nonExistentRecord = "nonexistent-record";

  final client = Client(
    accessKeyId: BackendKeys.aliyunDnsAccessKeyId,
    accessKeySecret: BackendKeys.aliyunDnsAccessKeySecret,
    domainName: testDomainName,
  );

  test('listRecords', () async {
    final records = await client.listRecords();
    print(JsonEncoder.withIndent("  ").convert(records.data));
    expect(records.data, isNotNull);
  });

  test('getRecordId for existing subdomain', () async {
    final recordId = await client.getRecordId(
      host: testRecordHost,
      type: testRecordType,
    );
    print(recordId.data);
    expect(recordId.data, isNotNull);
  });

  test('getRecordId for non-existent subdomain', () async {
    final recordId = await client.getRecordId(
      host: nonExistentRecord,
      type: "A",
    );
    print(recordId.data);
    expect(
      recordId.data,
      isNull,
      reason: 'Expected null for non-existent subdomain',
    );
  });

  test('updateRecordValue for existing host', () async {
    final recordId = await client.getRecordId(
      host: testRecordHost,
      type: testRecordType,
    );
    expect(recordId.data, isNotNull);

    if (recordId.data != null) {
      final updateRecordValue = await client.updateRecordValue(
        recordId: recordId.data!,
        host: testRecordHost,
        type: "A",
        newValue: "55.66.77.88",
      );
      if (updateRecordValue.success) {
        print('DNS record updated successfully: ${updateRecordValue.data}');
      } else {
        print('Error: ${updateRecordValue.message}');
      }
    }
  });

  test('updateRecordRemark for existing host', () async {
    final recordId = await client.getRecordId(
      host: testRecordHost,
      type: testRecordType,
    );
    expect(recordId.data, isNotNull);

    if (recordId.data != null) {
      final now = DateTime.now();
      final remark =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-"
          "${now.day.toString().padLeft(2, '0')}."
          "${now.hour.toString().padLeft(2, '0')}-"
          "${now.minute.toString().padLeft(2, '0')}-"
          "${now.second.toString().padLeft(2, '0')}";

      final updateRecordRemark = await client.updateRecordRemark(
        recordId: recordId.data!,
        remark: remark,
      );
      if (updateRecordRemark.success) {
        print('DNS remark updated successfully: ${updateRecordRemark.data}');
      } else {
        print('Error: ${updateRecordRemark.message}');
      }
    }
  });
}
