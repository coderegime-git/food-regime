class WalletTransaction {
  final int id;
  final double amount;
  final String transactionType; // 'credit' | 'debit'
  final String description;
  final String referenceId;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.transactionType,
    required this.description,
    required this.referenceId,
    required this.createdAt,
  });

  bool get isCredit => transactionType == 'credit';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      transactionType: json['transaction_type'],
      description: json['description'],
      referenceId: json['reference_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class WalletData {
  final double walletBalance;
  final List<WalletTransaction> transactions;

  WalletData({required this.walletBalance, required this.transactions});

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      walletBalance: (json['wallet_balance'] as num).toDouble(),
      transactions: (json['data'] as List)
          .map((e) => WalletTransaction.fromJson(e))
          .toList(),
    );
  }
}
