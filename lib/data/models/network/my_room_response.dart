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
  int? id;
  String? roomNumber; // Matches your UI call: _roomData?.data?.roomNumber
  String? blockName;  // Matches your UI call: _roomData?.data?.blockName
  String? roomType;
  int? capacity;
  int? occupancy;

  RoomData({
    this.id,
    this.roomNumber,
    this.blockName,
    this.roomType,
    this.capacity,
    this.occupancy,
  });

  RoomData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // Logic to handle different backend naming conventions (snake_case vs camelCase)
    roomNumber = json['room_number'] ?? json['roomNumber'];
    blockName = json['block_name'] ?? json['blockName'];
    roomType = json['room_type'] ?? json['roomType'];
    capacity = json['capacity'];
    occupancy = json['occupancy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['room_number'] = roomNumber;
    data['block_name'] = blockName;
    data['room_type'] = roomType;
    data['capacity'] = capacity;
    data['occupancy'] = occupancy;
    return data;
  }
}