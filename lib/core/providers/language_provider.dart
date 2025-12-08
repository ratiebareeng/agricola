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
