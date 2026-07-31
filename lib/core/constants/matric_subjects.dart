class MatricSubjects {
  static const subjects = [
    {'id': 'math', 'name': 'Mathematics', 'color': 0xFF1976D2},
    {'id': 'physics', 'name': 'Physics', 'color': 0xFF7B1FA2},
    {'id': 'chemistry', 'name': 'Chemistry', 'color': 0xFF388E3C},
    {'id': 'biology', 'name': 'Biology', 'color': 0xFFE64A19},
    {'id': 'english', 'name': 'English', 'color': 0xFF5D4037},
    {'id': 'urdu', 'name': 'Urdu', 'color': 0xFF00796B},
    {'id': 'islamiat', 'name': 'Islamiyat', 'color': 0xFF455A64},
    {'id': 'ethics', 'name': 'Ethics', 'color': 0xFF6D4C41},
    {'id': 'tarjumaTulQuran', 'name': 'Tarjuma-tul-Quran', 'color': 0xFF6A1B9A},
    {'id': 'pakStudies', 'name': 'Pakistan Studies', 'color': 0xFFD84315},
    {'id': 'computer', 'name': 'Computer Science', 'color': 0xFF5E35B1},
    // Humanities/Arts subjects
    {'id': 'civics', 'name': 'Civics', 'color': 0xFF8E24AA},
    {'id': 'economics', 'name': 'Economics', 'color': 0xFFFB8C00},
    {'id': 'education', 'name': 'Education', 'color': 0xFF00897B},
    {'id': 'islamicStudies', 'name': 'Islamic Studies', 'color': 0xFF5D4037},
    {'id': 'psychology', 'name': 'Psychology', 'color': 0xFF6A1B9A},
    {'id': 'punjabi', 'name': 'Punjabi', 'color': 0xFFC2185B},
  ];

  static const List<Map<String, String>> compulsorySubjects = [
    {'id': 'english', 'name': 'English'},
    {'id': 'urdu', 'name': 'Urdu'},
    {'id': 'pakStudies', 'name': 'Pakistan Studies'},
    {'id': 'math', 'name': 'Mathematics'},
    {'id': 'tarjumaTulQuran', 'name': 'Tarjuma-tul-Quran'},
  ];

  static const Map<String, List<Map<String, String>>> electiveGroups = {
    'Science (Biology Group)': [
      {'id': 'physics', 'name': 'Physics'},
      {'id': 'chemistry', 'name': 'Chemistry'},
      {'id': 'biology', 'name': 'Biology'},
    ],
    'Science (Computer Science Group)': [
      {'id': 'physics', 'name': 'Physics'},
      {'id': 'chemistry', 'name': 'Chemistry'},
      {'id': 'computer', 'name': 'Computer Science'},
    ],
    'Humanities / Arts Group': [
      {'id': 'civics', 'name': 'Civics'},
      {'id': 'economics', 'name': 'Economics'},
      {'id': 'education', 'name': 'Education'},
      {'id': 'islamicStudies', 'name': 'Islamic Studies'},
      {'id': 'psychology', 'name': 'Psychology'},
      {'id': 'punjabi', 'name': 'Punjabi'},
    ],
  };

  static List<Map<String, String>> getSubjectsForGroup(String group, {bool isMuslim = true}) {
    final List<Map<String, String>> allSubjects = [];
    
    // Add all compulsory subjects
    allSubjects.addAll(compulsorySubjects.where((subject) {
      // For non-Muslim students, exclude Islamiat and include Ethics instead
      if (subject['id'] == 'islamiat' && !isMuslim) return false;
      if (subject['id'] == 'ethics' && isMuslim) return false;
      return true;
    }));
    
    // Add elective subjects for the selected group
    if (electiveGroups.containsKey(group)) {
      allSubjects.addAll(electiveGroups[group]!);
    }
    
    return allSubjects;
  }
}