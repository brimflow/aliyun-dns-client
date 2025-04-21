class DnsResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  DnsResponse(this.success, {this.data, this.message});

  /// Factory constructor for a successful response.
  factory DnsResponse.success({T? data, String? message}) {
    return DnsResponse(true, data: data, message: message);
  }

  /// Factory constructor for a failed response.
  factory DnsResponse.failure(String message) {
    return DnsResponse(false, message: message);
  }

  /// Checks if the response was successful.
  bool get isSuccess => success;
}
