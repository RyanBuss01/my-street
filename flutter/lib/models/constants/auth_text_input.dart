import 'package:flutter/material.dart';

InputDecoration textInputDecoration (String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle:  TextStyle(color: Colors.grey[600]),
      labelText: hintText,
      labelStyle: const TextStyle(color: Colors.white),
      fillColor: Colors.black,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blueAccent, width: 0.5),
        borderRadius: BorderRadius.circular(10.0),
      ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red, width: 0.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 0.5),
        borderRadius: BorderRadius.circular(10.0),
      )
  );
}