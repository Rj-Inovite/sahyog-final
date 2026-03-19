class MyRoomResponse {
  bool? success;
  String? message;
  RoomData? data;

  MyRoomResponse({this.success, this.message, this.data});

  MyRoomResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? RoomData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class RoomData {
  String? studentName;
  int? hostelId;
  String? roomNumber;
  int? floor;
  String? bedNumber; // Corrected field
  String? roomType;
  String? status;
  int? monthlyRent;

  RoomData({
    this.studentName,
    this.hostelId,
    this.roomNumber,
    this.floor,
    this.bedNumber,
    this.roomType,
    this.status,
    this.monthlyRent,
  });

  RoomData.fromJson(Map<String, dynamic> json) {
    studentName = json['student_name'];
    hostelId = json['hostel_id'];
    roomNumber = json['room_number']?.toString();
    floor = json['floor'];
    bedNumber = json['bed_number']?.toString(); // Mapping from API 'bed_number'
    roomType = json['room_type'];
    status = json['status'];
    monthlyRent = json['monthly_rent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['student_name'] = studentName;
    data['hostel_id'] = hostelId;
    data['room_number'] = roomNumber;
    data['floor'] = floor;
    data['bed_number'] = bedNumber;
    data['room_type'] = roomType;
    data['status'] = status;
    data['monthly_rent'] = monthlyRent;
    return data;
  }
}