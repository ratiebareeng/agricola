import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((
  ref,
) {
  return LanguageNotifier();
});

// Simple string map for prototype
final Map<String, Map<AppLanguage, String>> _localizedStrings = {
  'app_title': {
    AppLanguage.english: 'Agricola',
    AppLanguage.setswana: 'Agricola',
  },
  'tagline': {
    AppLanguage.english: 'Empowering Farmers',
    AppLanguage.setswana: 'Re Balemi ba Botswana',
  },
  'welcome': {
    AppLanguage.english: 'Welcome',
    AppLanguage.setswana: 'Amogelesega',
  },
  'select_language': {
    AppLanguage.english: 'Select Language',
    AppLanguage.setswana: 'Tlhopha Puo',
  },
  'english': {AppLanguage.english: 'English', AppLanguage.setswana: 'English'},
  'setswana': {
    AppLanguage.english: 'Setswana',
    AppLanguage.setswana: 'Setswana',
  },
  'continue': {
    AppLanguage.english: 'Continue',
    AppLanguage.setswana: 'Tswelela',
  },
  // Onboarding
  'onboarding_1_title': {
    AppLanguage.english: 'Track your crops from planting to harvest',
    AppLanguage.setswana:
        'Sala dijalo tsa gago morago go tloga go jalweng go ya go thobeng',
  },
  'onboarding_1_desc': {
    AppLanguage.english:
        'Monitor every stage of your crop\'s lifecycle with ease.',
    AppLanguage.setswana:
        'Ela tlhoko kgato nngwe le nngwe ya botshelo jwa dijalo tsa gago motlhofo.',
  },
  'onboarding_2_title': {
    AppLanguage.english: 'Manage inventory and reduce losses',
    AppLanguage.setswana: 'Laola dithoto mme o fokotse ditshenyegelo',
  },
  'onboarding_2_desc': {
    AppLanguage.english: 'Keep track of your stock and minimize waste.',
    AppLanguage.setswana: 'Itse gore o na le eng mme o fokotse tshenyo.',
  },
  'onboarding_3_title': {
    AppLanguage.english: 'Understand where your losses happen',
    AppLanguage.setswana:
        'Tlhaloganya gore ditshenyegelo tsa gago di direga kae',
  },
  'onboarding_3_desc': {
    AppLanguage.english:
        'Gain insights into your farm\'s performance and identify areas for improvement.',
    AppLanguage.setswana:
        'Bona gore polasi ya gago e dira jang mme o bone fa o ka tokafatsang teng.',
  },
  'onboarding_4_title': {
    AppLanguage.english: 'Built for Botswana farmers',
    AppLanguage.setswana: 'E diretswe balemi ba Botswana',
  },
  'onboarding_4_desc': {
    AppLanguage.english:
        'Works perfectly offline. Your data is safe even without internet.',
    AppLanguage.setswana:
        'E bereka sentle le fa go sena inthanete. Tshedimosetso ya gago e bolokesegile.',
  },
  'next': {AppLanguage.english: 'Next', AppLanguage.setswana: 'E latelang'},
  'back': {AppLanguage.english: 'Back', AppLanguage.setswana: 'Morago'},
  'skip': {AppLanguage.english: 'Skip', AppLanguage.setswana: 'Feta'},
  'get_started': {
    AppLanguage.english: 'Get Started',
    AppLanguage.setswana: 'Simolola',
  },
  // Registration
  'create_account': {
    AppLanguage.english: 'Create Account',
    AppLanguage.setswana: 'Ithomele Akhaonto',
  },
  'select_account_type': {
    AppLanguage.english: 'Select Account Type',
    AppLanguage.setswana: 'Tlhopha Mofuta wa Akhaonto',
  },
  'farmer': {AppLanguage.english: 'Farmer', AppLanguage.setswana: 'Molemi'},
  'farmer_desc': {
    AppLanguage.english: 'I grow crops or raise livestock',
    AppLanguage.setswana: 'Ke lema dijalo kgotsa ke rua leruo',
  },
  'agri_merchant': {
    AppLanguage.english: 'AgriMerchant',
    AppLanguage.setswana: 'Morekisi wa Temo',
  },
  'agri_merchant_desc': {
    AppLanguage.english: 'I sell agricultural supplies or buy produce',
    AppLanguage.setswana: 'Ke rekisa dithoto tsa temo kgotsa ke reka thobo',
  },
  // Auth
  'sign_up': {AppLanguage.english: 'Sign Up', AppLanguage.setswana: 'Ikwadise'},
  'sign_in': {AppLanguage.english: 'Sign In', AppLanguage.setswana: 'Tsena'},
  'email': {AppLanguage.english: 'Email', AppLanguage.setswana: 'Imeile'},
  'password': {
    AppLanguage.english: 'Password',
    AppLanguage.setswana: 'Phasewete',
  },
  'confirm_password': {
    AppLanguage.english: 'Confirm Password',
    AppLanguage.setswana: 'Netefatsa Phasewete',
  },
  'or_continue_with': {
    AppLanguage.english: 'Or continue with',
    AppLanguage.setswana: 'Kgotsa tswelela ka',
  },
  'already_have_account': {
    AppLanguage.english: 'Already have an account?',
    AppLanguage.setswana: 'A o setse o na le akhaonto?',
  },
  'dont_have_account': {
    AppLanguage.english: 'Don\'t have an account?',
    AppLanguage.setswana: 'Ga o na akhaonto?',
  },
  'google': {AppLanguage.english: 'Google', AppLanguage.setswana: 'Google'},
  'facebook': {
    AppLanguage.english: 'Facebook',
    AppLanguage.setswana: 'Facebook',
  },
  // Profile Setup
  'step': {AppLanguage.english: 'Step', AppLanguage.setswana: 'Kgato'},
  'of': {AppLanguage.english: 'of', AppLanguage.setswana: 'ya'},
  'finish': {AppLanguage.english: 'Finish', AppLanguage.setswana: 'Fetsa'},
  'upload_photo': {
    AppLanguage.english: 'Upload Photo',
    AppLanguage.setswana: 'Tsenya Setshwantsho',
  },
  'where_is_farm': {
    AppLanguage.english: 'Where is your farm?',
    AppLanguage.setswana: 'Polasi ya gago e kae?',
  },
  'what_do_you_grow': {
    AppLanguage.english: 'What do you grow?',
    AppLanguage.setswana: 'O lema eng?',
  },
  'how_big_is_farm': {
    AppLanguage.english: 'How big is your farm?',
    AppLanguage.setswana: 'Polasi ya gago e kana kang?',
  },
  'add_photo': {
    AppLanguage.english: 'Add a photo',
    AppLanguage.setswana: 'Tsenya setshwantsho',
  },
  'business_details': {
    AppLanguage.english: 'Business Details',
    AppLanguage.setswana: 'Dintlha tsa Kgwebo',
  },
  'where_are_you_located': {
    AppLanguage.english: 'Where are you located?',
    AppLanguage.setswana: 'O bonwa kae?',
  },
  'what_do_you_buy': {
    AppLanguage.english: 'What do you buy?',
    AppLanguage.setswana: 'O reka eng?',
  },
  'business_name': {
    AppLanguage.english: 'Business Name',
    AppLanguage.setswana: 'Leina la Kgwebo',
  },
  'village_area': {
    AppLanguage.english: 'Village / Area',
    AppLanguage.setswana: 'Motse / Kgaolo',
  },
  'location': {AppLanguage.english: 'Location', AppLanguage.setswana: 'Lefelo'},
  // Crops
  'Maize': {AppLanguage.english: 'Maize', AppLanguage.setswana: 'Mmidi'},
  'Sorghum': {AppLanguage.english: 'Sorghum', AppLanguage.setswana: 'Mabele'},
  'Beans': {AppLanguage.english: 'Beans', AppLanguage.setswana: 'Dinawa'},
  'Watermelon': {
    AppLanguage.english: 'Watermelon',
    AppLanguage.setswana: 'Legapu',
  },
  'Spinach': {
    AppLanguage.english: 'Spinach',
    AppLanguage.setswana: 'Espinatšhe',
  },
  'Tomatoes': {AppLanguage.english: 'Tomatoes', AppLanguage.setswana: 'Tamati'},
  'Onions': {AppLanguage.english: 'Onions', AppLanguage.setswana: 'Eie'},
  'Cabbage': {
    AppLanguage.english: 'Cabbage',
    AppLanguage.setswana: 'Khabetšhe',
  },
  // Products
  'Grains': {AppLanguage.english: 'Grains', AppLanguage.setswana: 'Dithoro'},
  'Vegetables': {
    AppLanguage.english: 'Vegetables',
    AppLanguage.setswana: 'Merogo',
  },
  'Fruits': {AppLanguage.english: 'Fruits', AppLanguage.setswana: 'Maungo'},
  'Livestock': {
    AppLanguage.english: 'Livestock',
    AppLanguage.setswana: 'Leruo',
  },
  'Dairy': {AppLanguage.english: 'Dairy', AppLanguage.setswana: 'Mashi'},
  'Poultry': {AppLanguage.english: 'Poultry', AppLanguage.setswana: 'Dikoko'},
  // Farm Sizes
  '< 1 Hectare': {
    AppLanguage.english: '< 1 Hectare',
    AppLanguage.setswana: '< 1 Hectare',
  },
  '1-5 Hectares': {
    AppLanguage.english: '1-5 Hectares',
    AppLanguage.setswana: '1-5 Hectares',
  },
  '5-10 Hectares': {
    AppLanguage.english: '5-10 Hectares',
    AppLanguage.setswana: '5-10 Hectares',
  },
  '10+ Hectares': {
    AppLanguage.english: '10+ Hectares',
    AppLanguage.setswana: '10+ Hectares',
  },
  // Home
  'home_title': {AppLanguage.english: 'Home', AppLanguage.setswana: 'Gae'},
  'welcome_message': {
    AppLanguage.english: 'Welcome back, Farmer!',
    AppLanguage.setswana: 'O amogelesegile, Molemi!',
  },
  // Dashboard
  'dashboard': {
    AppLanguage.english: 'Dashboard',
    AppLanguage.setswana: 'Tshobokanyo',
  },
  'crops': {AppLanguage.english: 'Crops', AppLanguage.setswana: 'Dijalo'},
  'inventory': {
    AppLanguage.english: 'Inventory',
    AppLanguage.setswana: 'Dithoto',
  },
  'loss_calculator': {
    AppLanguage.english: 'Loss Calc',
    AppLanguage.setswana: 'Ditshenyegelo',
  },
  'settings': {
    AppLanguage.english: 'Settings',
    AppLanguage.setswana: 'Di-setting',
  },
  'total_fields': {
    AppLanguage.english: 'Total Fields',
    AppLanguage.setswana: 'Masimo Otlhe',
  },
  'upcoming_harvests': {
    AppLanguage.english: 'Upcoming Harvests',
    AppLanguage.setswana: 'Thobo e e Tlang',
  },
  'inventory_value': {
    AppLanguage.english: 'Inventory Value',
    AppLanguage.setswana: 'Tlhwatlhwa ya Dithoto',
  },
  'estimated_losses': {
    AppLanguage.english: 'Est. Losses',
    AppLanguage.setswana: 'Ditshenyegelo',
  },
  'my_crops': {
    AppLanguage.english: 'My Crops',
    AppLanguage.setswana: 'Dijalo tsa Me',
  },
  'add_new_crop': {
    AppLanguage.english: 'Add New Crop',
    AppLanguage.setswana: 'Tsenya Sejalo',
  },
  'recent_activity': {
    AppLanguage.english: 'Recent Activity',
    AppLanguage.setswana: 'Ditiro tsa Bosheng',
  },
  'view_all': {
    AppLanguage.english: 'View All',
    AppLanguage.setswana: 'Bona Tsotlhe',
  },
  'profile': {AppLanguage.english: 'Profile', AppLanguage.setswana: 'Omang'},
};

String t(String key, AppLanguage lang) {
  return _localizedStrings[key]?[lang] ?? key;
}

enum AppLanguage { english, setswana }

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.english) {
    _loadLanguage();
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'language_code',
      language == AppLanguage.setswana ? 'tn' : 'en',
    );
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code');
    if (langCode == 'tn') {
      state = AppLanguage.setswana;
    } else {
      state = AppLanguage.english;
    }
  }
}
