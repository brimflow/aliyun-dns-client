import 'dart:convert';

import 'package:aliyun_dns_client/dns/models.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;

/// Client for interacting with Aliyun DNS API.
class Client {
  final String _apiBaseUrl = "https://alidns.aliyuncs.com";
  final String _accessKeyId;
  final String _accessKeySecret;
  final String domainName;

  Client({
    required String accessKeyId,
    required String accessKeySecret,
    required this.domainName,
  }) : _accessKeyId = accessKeyId,
       _accessKeySecret = accessKeySecret;

  /// Fetches all DNS records for the given domain.
  Future<DnsResponse<Map<String, dynamic>>> listRecords() async {
    final url = _generateDnsApiUrl(
      action: 'DescribeDomainRecords',
      params: {'DomainName': domainName},
    );
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return DnsResponse.success(data: jsonDecode(response.body));
    } else {
      return DnsResponse.failure(
        response.body.isNotEmpty
            ? response.body
            : 'Request failed with status: ${response.statusCode}',
      );
    }
  }

  /// Retrieves the record ID for a specific subdomain and record type.
  Future<DnsResponse<String>> getRecordId({
    required String host,
    required String type,
  }) async {
    final url = _generateDnsApiUrl(
      action: 'DescribeDomainRecords',
      params: {'DomainName': domainName},
    );
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      host = host.toLowerCase();
      type = type.toLowerCase();

      for (final record in data['DomainRecords']['Record']) {
        final recordRr = (record['RR'] as String?)?.toLowerCase();
        final recordType = (record['Type'] as String?)?.toLowerCase();
        if (recordRr == host && recordType == type) {
          return DnsResponse.success(data: record['RecordId'] as String);
        }
      }
      return DnsResponse.success(message: "Not found");
    } else {
      return DnsResponse.failure(
        response.body.isNotEmpty
            ? response.body
            : 'Request failed with status: ${response.statusCode}',
      );
    }
  }

  /// Updates the DNS record for a subdomain.
  Future<DnsResponse> updateRecordValue({
    required String recordId,
    required String host,
    required String type,
    required String newValue,
    int ttlSeconds = 600,
  }) async {
    final url = _generateDnsApiUrl(
      action: 'UpdateDomainRecord',
      params: {
        'RecordId': recordId,
        'RR': host,
        'Type': type,
        'Value': newValue,
        'TTL': ttlSeconds.toString(),
      },
    );

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return DnsResponse.success(data: jsonDecode(response.body));
    } else {
      return DnsResponse.failure(
        response.body.isNotEmpty
            ? response.body
            : 'Request failed with status: ${response.statusCode}',
      );
    }
  }

  /// Update the remark for a DNS record
  Future<DnsResponse> updateRecordRemark({
    required String recordId,
    required String remark,
  }) async {
    final url = _generateDnsApiUrl(
      action: 'UpdateDomainRecordRemark',
      params: {'RecordId': recordId, 'Remark': remark},
    );

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return DnsResponse.success(data: jsonDecode(response.body));
    } else {
      return DnsResponse.failure(
        response.body.isNotEmpty
            ? response.body
            : 'Request failed with status: ${response.statusCode}',
      );
    }
  }

  /// Generates a signature for the Aliyun API request.
  String _signature(String stringToSign, String accessKeySecret) {
    final key = utf8.encode('$accessKeySecret&');
    final bytes = utf8.encode(stringToSign);
    final hmac = crypto.Hmac(crypto.sha1, key);
    final digest = hmac.convert(bytes);
    return base64Encode(digest.bytes);
  }

  /// Generates the complete DNS API URL for the request.
  String _generateDnsApiUrl({
    required String action,
    Map<String, String> params = const {},
    String format = 'JSON',
    String version = '2015-01-09',
    String signatureMethod = 'HMAC-SHA1',
    String signatureVersion = '1.0',
    String? timestamp,
    String? signatureNonce,
  }) {
    final baseParams = {
      'Format': format,
      'Version': version,
      'AccessKeyId': _accessKeyId,
      'SignatureMethod': signatureMethod,
      'Timestamp': timestamp ?? DateTime.now().toUtc().toIso8601String(),
      'SignatureVersion': signatureVersion,
      'SignatureNonce':
          signatureNonce ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'Action': action,
    };

    final sortedParams = {...baseParams, ...params}
      ..removeWhere((key, value) => value.isEmpty);
    final sortedKeys = sortedParams.keys.toList()..sort();

    final queryString = sortedKeys
        .map((key) {
          final encodedKey = Uri.encodeComponent(key);
          final encodedValue = Uri.encodeComponent(sortedParams[key]!);
          return '$encodedKey=$encodedValue';
        })
        .join('&');

    final stringToSign = 'GET&%2F&${Uri.encodeComponent(queryString)}';
    final signature = _signature(stringToSign, _accessKeySecret);

    return '$_apiBaseUrl/?$queryString&Signature=${Uri.encodeComponent(signature)}';
  }
}
