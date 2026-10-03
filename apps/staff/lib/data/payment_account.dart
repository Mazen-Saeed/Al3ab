/// Where customers pay for one method (InstaPay or wallet). The venue owner fills it in.
class PaymentAccount {
  const PaymentAccount({required this.link, this.handle, this.phone});

  final String link; // checkout draws a QR code from this
  final String? handle; // InstaPay handle, e.g. name@instapay
  final String? phone; // phone number that receives the transfer

  /// What is written out under the QR for people to type if the scan fails.
  List<String> get typeable => [?handle, ?phone];
}
