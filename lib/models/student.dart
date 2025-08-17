class Student {
  final int id;
  final String name;

  final int age;
  final DateTime registrationDate;
final String? fatherName;
final String? motherName;
final String? phoneNumber;
final String? email;
final String? address;


  Student({
    required this.id,
    required this.name,
    required this.fatherName,
    required this.motherName,
    required this.age,
    required this.registrationDate,
    required this.phoneNumber,
    required this.email,
    required this.address,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      fatherName: json['father_name'],
      motherName: json['mother_name'],
      age: json['age'],
      registrationDate: DateTime.parse(json['registration_date']),
      phoneNumber: json['phone_number'],
      email: json['email'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'father_name': fatherName,
      'mother_name': motherName,
      'age': age,
      // 'registration_date': registrationDate.toIso8601String(),
      // lib/models/student.dart (ضمن toJson)
      'registration_date': registrationDate.toIso8601String().split('T').first,

      'phone_number': phoneNumber,
      'email': email,
      'address': address,
    };
  }
}
