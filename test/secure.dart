import "package:envied/envied.dart";

part "secure.g.dart";

// Run the following command to generate the code：
// dart run build_runner build

@Envied(path: '../.secure/backend-keys')
final class BackendKeys {
  @EnviedField(varName: "aliyun.dns.access-key-id")
  static const String aliyunDnsAccessKeyId = _BackendKeys.aliyunDnsAccessKeyId;

  @EnviedField(varName: "aliyun.dns.access-key-secret")
  static const String aliyunDnsAccessKeySecret =
      _BackendKeys.aliyunDnsAccessKeySecret;
}
