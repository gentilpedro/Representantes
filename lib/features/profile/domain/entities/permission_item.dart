import 'package:flutter/material.dart';

enum PermissionStatus { granted, restricted }

class PermissionItem {
  const PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String description;
  final PermissionStatus status;
}
