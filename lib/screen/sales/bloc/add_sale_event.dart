abstract class AddSaleEvent {}

class SubmitSale extends AddSaleEvent {
  final String billType;
  final String customer;
  final String paymentMethod;
  final List<Map<String, dynamic>> items;
  final String narration;
  final double total;

  SubmitSale({
    required this.billType,
    required this.customer,
    required this.paymentMethod,
    required this.items,
    required this.narration,
    required this.total,
  });
}

class GenerateBill extends AddSaleEvent {
  final int saleId;

  GenerateBill({required this.saleId});
}
