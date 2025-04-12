import 'package:flutter/material.dart';

class Department {
  String name;
  String head;

  Department({required this.name, required this.head});
}

class DepartmentProvider extends ChangeNotifier {
  final List<Department> _departments = [
    Department(name: 'HR', head: 'Alice'),
    Department(name: 'Finance', head: 'Bob'),
    Department(name: 'IT', head: 'Charlie'),
  ];

  List<Department> get departments => _departments;

  void addDepartment(Department department) {
    _departments.add(department);
    notifyListeners();
  }

  void removeDepartment(Department department) {
    _departments.remove(department);
    notifyListeners();
  }
}
