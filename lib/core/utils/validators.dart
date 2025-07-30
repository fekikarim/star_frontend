import 'package:star_frontend/core/constants/app_strings.dart';
import 'package:star_frontend/core/config/app_config.dart';

/// Validation utilities for forms and inputs
class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.emailInvalid;
    }
    
    return null;
  }
  
  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    
    if (value.length < AppConfig.minPasswordLength) {
      return AppStrings.passwordTooShort;
    }
    
    if (value.length > AppConfig.maxPasswordLength) {
      return 'Mot de passe trop long (max ${AppConfig.maxPasswordLength} caractères)';
    }
    
    return null;
  }
  
  // Required field validation
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null 
          ? '$fieldName est requis' 
          : AppStrings.fieldRequired;
    }
    return null;
  }
  
  // Name validation
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value.trim().length > AppConfig.maxNameLength) {
      return 'Nom trop long (max ${AppConfig.maxNameLength} caractères)';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Nom invalide';
    }
    
    return null;
  }
  
  // Description validation
  static String? description(String? value) {
    if (value != null && value.length > AppConfig.maxDescriptionLength) {
      return 'Description trop longue (max ${AppConfig.maxDescriptionLength} caractères)';
    }
    return null;
  }
  
  // Numeric validation
  static String? numeric(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? AppStrings.fieldRequired : null;
    }
    
    if (double.tryParse(value) == null) {
      return 'Valeur numérique invalide';
    }
    
    return null;
  }
  
  // Integer validation
  static String? integer(String? value, {bool required = false, int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return required ? AppStrings.fieldRequired : null;
    }
    
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Valeur entière invalide';
    }
    
    if (min != null && intValue < min) {
      return 'Valeur minimale: $min';
    }
    
    if (max != null && intValue > max) {
      return 'Valeur maximale: $max';
    }
    
    return null;
  }
  
  // Date validation
  static String? date(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? AppStrings.fieldRequired : null;
    }
    
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Date invalide';
    }
  }
  
  // URL validation
  static String? url(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? AppStrings.fieldRequired : null;
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'URL invalide';
    }
    
    return null;
  }
  
  // Phone number validation (French format)
  static String? phoneNumber(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? AppStrings.fieldRequired : null;
    }
    
    // Remove spaces and special characters
    final cleanValue = value.replaceAll(RegExp(r'[\s\-\.\(\)]'), '');
    
    // French phone number regex
    final phoneRegex = RegExp(r'^(?:\+33|0)[1-9](?:[0-9]{8})$');
    
    if (!phoneRegex.hasMatch(cleanValue)) {
      return 'Numéro de téléphone invalide';
    }
    
    return null;
  }
  
  // Confirm password validation
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value != originalPassword) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }
  
  // Custom validation with regex
  static String? custom(String? value, RegExp regex, String errorMessage, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? AppStrings.fieldRequired : null;
    }
    
    if (!regex.hasMatch(value)) {
      return errorMessage;
    }
    
    return null;
  }
}
