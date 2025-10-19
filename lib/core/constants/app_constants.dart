class AppConstants {
  // Using the display name for the UI, and a map for validation/API calls
  static const List<String> germanCitiesForUI = [
    'Berlin',
    'Hamburg',
    'Munich',
    'Cologne',
    'Frankfurt am Main',
    'Stuttgart',
    'Düsseldorf',
    'Dortmund',
    'Essen',
    'Leipzig',
    'Bremen',
    'Dresden',
    'Hanover',
    'Nuremberg',
    'Duisburg',
    'Bochum',
    'Wuppertal',
    'Bielefeld',
    'Bonn',
    'Münster'
  ];

  static const Map<String, String> cityNameToApiName = {
    'Munich': 'München',
    'Cologne': 'Köln',
    'Hanover': 'Hannover',
    'Nuremberg': 'Nürnberg',
    // Add other cities that have different names if necessary
  };

  // Helper to get the name for API calls
  static String getApiCityName(String uiCityName) {
    return cityNameToApiName[uiCityName] ?? uiCityName;
  }
}