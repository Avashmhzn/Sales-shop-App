import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stock_ledger_response.g.dart';

@JsonSerializable()
class StockLedgerReport {
  final bool success;
  final String message;
  final List<StockLedgerAccount>? data;

  StockLedgerReport({
    required this.success,
    required this.message,
    this.data,
  });

  factory StockLedgerReport.fromJson(Map<String, dynamic> json) =>
      _$StockLedgerReportFromJson(json);
  Map<String, dynamic> toJson() => _$StockLedgerReportToJson(this);
}

@JsonSerializable()
class StockLedgerAccount extends Equatable {
  @JsonKey(name: 'product')
  final String? productName;
  final List<StockLedgerEntry>? ledger;

  const StockLedgerAccount({this.productName, this.ledger});

  factory StockLedgerAccount.fromJson(Map<String, dynamic> json) =>
      _$StockLedgerAccountFromJson(json);
  Map<String, dynamic> toJson() => _$StockLedgerAccountToJson(this);

  @override
  List<Object?> get props => [productName, ledger];
}

@JsonSerializable()
class StockLedgerEntry extends Equatable {
  final String? date;
  final double? opening;
  final double? purchase;
  final double? sales;
  double? closing; // ← NOT FINAL (we set it later)
  @JsonKey(name: 'cost_price')
  final double? costPrice;
  @JsonKey(name: 'selling_price')
  final double? sellingPrice;

  StockLedgerEntry({
    this.date,
    this.opening,
    this.purchase,
    this.sales,
    this.closing,
    this.costPrice,
    this.sellingPrice,
  });

  factory StockLedgerEntry.fromJson(Map<String, dynamic> json) =>
      _$StockLedgerEntryFromJson(json);
  Map<String, dynamic> toJson() => _$StockLedgerEntryToJson(this);

  @override
  List<Object?> get props => [
        date,
        opening,
        purchase,
        sales,
        closing,
        costPrice,
        sellingPrice,
      ];
}
