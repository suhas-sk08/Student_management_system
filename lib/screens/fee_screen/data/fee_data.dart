class FeeData {
  final String receiptNo;
  final String month;
  final String date;
  final String paymentStatus;
  final String totalAmount;

  FeeData(this.receiptNo, this.month, this.date, this.paymentStatus,
      this.totalAmount);
}

List<FeeData> fee = [
  FeeData('90871', 'November', '8 Nov 2020', 'Pending', '980\$'),
];
