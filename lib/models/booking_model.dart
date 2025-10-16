class Booking {
  final int id;
  final int userId;
  final int portId;
  final String portName;
  final String terminalName;
  final String gateInPlan;
  final String shiftInPlan;
  final String containerNo;
  final String containerType;
  final String containerSize;
  final String containerStatus;
  final String isoCode;
  final String stid;

  Booking({
    required this.stid,
    required this.id,
    required this.userId,
    required this.portId,
    required this.portName,
    required this.terminalName,
    required this.gateInPlan,
    required this.shiftInPlan,
    required this.containerNo,
    required this.containerType,
    required this.containerSize,
    required this.containerStatus,
    required this.isoCode,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      portId: json['port_id'] ?? 0,
      portName: json['port_name'] ?? '',
      terminalName: json['terminal_name'] ?? '',
      gateInPlan: json['gate_in_plan'] ?? '',
      shiftInPlan: json['shift_in_plan'] ?? '',
      containerNo: json['container_no'] ?? '',
      containerType: json['container_type'] ?? '',
      containerSize: json['container_size'] ?? '',
      containerStatus: json['container_status'] ?? '',
      isoCode: json['iso_code'] ?? '',
      stid: json['stid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'port_id': portId,
        'port_name': portName,
        'terminal_name': terminalName,
        'gate_in_plan': gateInPlan,
        'shift_in_plan': shiftInPlan,
        'container_no': containerNo,
        'container_type': containerType,
        'container_size': containerSize,
        'container_status': containerStatus,
        'iso_code': isoCode,
        'stid': stid,
      };
}
