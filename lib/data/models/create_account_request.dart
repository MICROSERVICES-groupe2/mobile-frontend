class CreateAccountRequest {
  final String clientId;
  final String type;
  final double solde;
  final String devise;
  final String operatorId;

  const CreateAccountRequest({
    required this.clientId,
    required this.type,
    required this.solde,
    required this.devise,
    this.operatorId = '00000000-0000-0000-0000-000000000000',
  });

  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        'type': type,
        'solde': solde,
        'devise': devise,
        'operatorId': operatorId,
      };
}
