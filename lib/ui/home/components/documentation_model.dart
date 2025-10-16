import 'package:flutter/material.dart';

class DocumentationModel {
  final String title;      
  final int count;         
  final String unit;       
  final IconData icon;     
  final Color iconColor;   
  final Color backgroundColor; 

  DocumentationModel({
    required this.title,
    required this.count,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}
