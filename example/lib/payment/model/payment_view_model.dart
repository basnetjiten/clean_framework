import 'package:clean_framework/clean_framework.dart';

enum ServiceStatus { failed, successful, unknown }
enum DataStatus { valid, invalid, unknown }

class PaymentViewModel extends ViewModel {
  final String fromAccount;
  final String toAccount;
  final double amount;
  final serviceStatus;
  final dataStatus;

  PaymentViewModel(
      {this.fromAccount,
      this.toAccount,
      this.amount,
      this.serviceStatus = ServiceStatus.unknown,
      this.dataStatus = DataStatus.unknown})
      : assert(fromAccount != null && toAccount != null && amount != null);

  @override
  List<Object> get props =>
      [fromAccount, toAccount, amount, serviceStatus, dataStatus];
}
