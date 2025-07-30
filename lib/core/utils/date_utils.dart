import 'package:intl/intl.dart';

/// Date and time utility functions
class AppDateUtils {
  // Date formatters
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _apiDateTimeFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'fr_FR');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMMM', 'fr_FR');
  
  // Format date for display
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }
  
  // Format time for display
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }
  
  // Format date and time for display
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }
  
  // Format date for API calls
  static String formatApiDate(DateTime date) {
    return _apiDateFormat.format(date);
  }
  
  // Format date time for API calls
  static String formatApiDateTime(DateTime date) {
    return _apiDateTimeFormat.format(date.toUtc());
  }
  
  // Parse API date string
  static DateTime? parseApiDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  // Format relative time (e.g., "il y a 2 heures")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'il y a $years an${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'il y a $months mois';
    } else if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }
  
  // Format duration (e.g., "2h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h${minutes > 0 ? ' ${minutes}m' : ''}';
    } else {
      return '${minutes}m';
    }
  }
  
  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }
  
  // Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  // Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
  
  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
  
  // Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }
  
  // Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final daysToSunday = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToSunday)));
  }
  
  // Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  // Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }
  
  // Format month and year
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }
  
  // Format day and month
  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }
  
  // Get age from birth date
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }
  
  // Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }
  
  // Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }
  
  // Get days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }
  
  // Get business days between two dates (excluding weekends)
  static int businessDaysBetween(DateTime start, DateTime end) {
    int days = 0;
    DateTime current = start;
    
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      if (current.weekday < 6) { // Monday = 1, Sunday = 7
        days++;
      }
      current = current.add(const Duration(days: 1));
    }
    
    return days;
  }
}
