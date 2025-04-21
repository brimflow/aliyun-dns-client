# 阿里云 DNS 客户端（Flutter）

一个简洁的 Flutter 库，用于操作阿里云 DNS 记录。该库封装了阿里云 DNS API 的常见功能，例如列出和更新 DNS 记录，以及修改记录备注，并可根据需求进一步扩展。

**ℹ️ 说明：这是一个独立的开源项目，与阿里云无关。**

## 功能

- **列出 DNS 记录**：获取指定域名的所有 DNS 记录。
- **获取记录 ID**：获取特定记录的 ID，以便后续更新。
- **更新记录值**：根据 ID 更新 DNS 记录的值。
- **更新记录备注**：根据 ID 更新 DNS 记录的备注。

## 📦 安装

在 Flutter 项目中添加此包：

```yaml
dependencies:
  aliyun_dns_client:
    git:
      url: https://github.com/brimflow/aliyun-dns-client.git
```

## 📝 使用方法

### 初始化客户端

```dart
final client = Client(
  accessKeyId: "your-access-key",
  accessKeySecret: "your-secret",
  domainName: "example.com",
);
```

### 列出 DNS 记录

```dart
final records = await client.listRecords();
print(JsonEncoder.withIndent("  ").convert(records.data));
```

### 获取记录 ID

```dart
final recordId = await client.getRecordId(host: "www", type: "A");
print(recordId.data);
```

### 更新记录值

```dart
final recordId = await client.getRecordId(host: "www", type: "A");
if (recordId.data != null) {
  final updateRecordValue = await dnsClient.updateRecordValue(
    recordId: recordId.data!,
    host: "www",
    type: "A",
    newValue: "55.66.77.88",
  );
  if (updateRecordValue.success) {
    print("DNS 记录更新成功: ${updateRecordValue.data}");
  } else {
    print("错误: ${updateRecordValue.message}");
  }
}
```

### 更新记录备注

```dart
final recordId = await client.getRecordId(host: "www", type: "A");
if (recordId.data != null) {
  final updateRecordRemark = await dnsClient.updateRecordRemark(
    recordId: recordId.data!,
    remark: "dns-client",
  );
  if (updateRecordRemark.success) {
    print("DNS 备注更新成功: ${updateRecordRemark.data}");
  } else {
    print("错误: ${updateRecordRemark.message}");
  }
}
```

## ⚠️ 错误处理

所有方法在失败时都会抛出异常：

```dart
try {
  final recordId = await client.getRecordId(host: "www", type: "A");
} catch (error) {
  print("错误: $error");
}
```

## ✅ 测试

您需要准备一个域名，并创建一个子域 `record-for-test`（当然，您也可以根据需要调整）用于功能测试。您可以通过[**这个链接**](https://www.aliyun.com/minisite/goods?userCode=k4gobdfa)购买域名，**享受 9 折扣优惠**，同时支持本项目。

请按照以下步骤配置测试环境：

### 1. **创建 RAM 用户**

按照[官方指引](https://help.aliyun.com/zh/ram/user-guide/create-a-ram-user)创建用于操作 DNS 的 RAM 用户，并[授予](https://help.aliyun.com/zh/ram/user-guide/grant-permissions-to-the-ram-user)其 `AliyunDNSFullAccess` 权限。

### 2. **配置 API 密钥**

需要注意，**您的 API 密钥不要包含在版本控制中**，确保像 `secure.g.dart` 这样的文件不被提交到 Git 仓库中。

在项目的根目录创建 `.secure` 文件夹（该文件夹默认不会加入 Git 版本管理），并添加 `backend-keys` 文件来存储 API 密钥。

目录结构示例：

```text
E:\PROJECT-DIR
  |-- .secure           // 存放密钥文件的文件夹
      |-- backend-keys  // 存储 API 密钥的文件
  |-- aliyun-dns-client  // 源码根目录
      |-- .git
      |-- ...
```

`.secure/backend-keys` 文件应包含以下内容：

- `aliyun.dns.access-key-id`：RAM 用户的访问密钥 ID（可以用英文引号括起来，但不是必需的）。
- `aliyun.dns.access-key-secret`：RAM 用户的访问密钥 Secret（可以用英文引号括起来，但不是必需的）。

示例内容：

```
aliyun.dns.access-key-id = "7rtIMKEtYbUfZTaMysMxbN9b4ECS1jAq"
aliyun.dns.access-key-secret = "L29xIZX344SWWHAfxosjArUp1mrjeycUx5a3sKey"
```

### 3. **运行构建命令**

在运行测试之前，请执行以下命令生成环境变量代码。这会自动生成必要的代码，以便在应用中安全读取 API 密钥。

```sh
dart run build_runner build
```

### 4. **运行测试**

完成上述步骤后，可以使用以下命令运行测试：

```sh
flutter test
```

## 📜 许可证

MIT 许可证
