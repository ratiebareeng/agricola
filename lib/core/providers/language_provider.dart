import 'dart:developer' as developer;

import 'package:agricola/core/providers/app_initialization_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final hasSeenWelcomeProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('has_seen_welcome') ?? false;
});

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((
  ref,
) {
  return LanguageNotifier(ref);
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
  'agri_shop': {
    AppLanguage.english: 'Agri Shop',
    AppLanguage.setswana: 'Lebenkele la Temo',
  },
  'agri_shop_desc': {
    AppLanguage.english: 'I sell seeds, fertiliser, tools, machinery',
    AppLanguage.setswana: 'Ke rekisa dipeu, monontsha, didiriswa, metšhine',
  },
  'merchant': {
    AppLanguage.english: 'Merchant',
    AppLanguage.setswana: 'Morekisi',
  },
  'supermarket_vendor': {
    AppLanguage.english: 'Supermarket/Vendor',
    AppLanguage.setswana: 'Supermarket/Morekisi',
  },
  'supermarket_vendor_desc': {
    AppLanguage.english: 'I buy and sell farm produce',
    AppLanguage.setswana: 'Ke reka le go rekisa thobo ya polasi',
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
  'or': {AppLanguage.english: 'or', AppLanguage.setswana: 'kgotsa'},
  'continue_as_guest': {
    AppLanguage.english: 'Continue as Guest',
    AppLanguage.setswana: 'Tswelela jaaka moeng',
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
    AppLanguage.english: 'Town / Village / Area',
    AppLanguage.setswana: 'Motse / Kgaolo',
  },
  'location': {AppLanguage.english: 'Location', AppLanguage.setswana: 'Lefelo'},
  'select_village': {
    AppLanguage.english: 'Select your location',
    AppLanguage.setswana: 'Tlhopha lefelo la gago',
  },
  'select_location': {
    AppLanguage.english: 'Select business location',
    AppLanguage.setswana: 'Tlhopha lefelo la kgwebo',
  },
  'specify_location': {
    AppLanguage.english: 'Specify location',
    AppLanguage.setswana: 'Tlhalosa lefelo',
  },
  'select_multiple': {
    AppLanguage.english: 'Select all that apply',
    AppLanguage.setswana: 'Tlhopha tsotlhe tse di siameng',
  },
  'tap_to_add_photo': {
    AppLanguage.english: 'Tap to add profile photo',
    AppLanguage.setswana: 'Tobetsa go tsenya setshwantsho',
  },
  'tap_to_change_photo': {
    AppLanguage.english: 'Tap to change photo',
    AppLanguage.setswana: 'Tobetsa go fetola setshwantsho',
  },
  'select_at_least_one_crop': {
    AppLanguage.english: 'Select at least one crop you grow',
    AppLanguage.setswana:
        'Tlhopha bonyenyane sejalo se le sengwe se o se lemang',
  },
  'select_farm_size_hint': {
    AppLanguage.english: 'This helps us provide better recommendations',
    AppLanguage.setswana: 'Seno se re thusa go go fa dikatlholo tse di botoka',
  },
  'photo_optional_hint': {
    AppLanguage.english:
        'Adding a photo is optional, but it personalizes your profile',
    AppLanguage.setswana:
        'Go tsenya setshwantsho ga se tlamego, mme se dira gore profaele ya gago e itlhophele',
  },
  // Crops
  'Maize': {AppLanguage.english: 'Maize', AppLanguage.setswana: 'Mmidi'},
  'Sorghum': {AppLanguage.english: 'Sorghum', AppLanguage.setswana: 'Mabele'},
  'Beans': {AppLanguage.english: 'Beans', AppLanguage.setswana: 'Dinawa'},
  'Watermelon': {
    AppLanguage.english: 'Watermelon',
    AppLanguage.setswana: 'Legapu',
  },
  'Lettuce': {AppLanguage.english: 'Lettuce', AppLanguage.setswana: 'Letese'},
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
  'Millet': {
    AppLanguage.english: 'Millet',
    AppLanguage.setswana: 'Mabele a mannye',
  },
  'Wheat': {AppLanguage.english: 'Wheat', AppLanguage.setswana: 'Korong'},
  'Rice': {AppLanguage.english: 'Rice', AppLanguage.setswana: 'Raese'},
  'Barley': {AppLanguage.english: 'Barley', AppLanguage.setswana: 'Bhari'},
  'Cowpeas': {AppLanguage.english: 'Cowpeas', AppLanguage.setswana: 'Letlhodi'},
  'Peas': {
    AppLanguage.english: 'Peas',
    AppLanguage.setswana: 'Dinawa tse dinnye',
  },
  'Lentils': {AppLanguage.english: 'Lentils', AppLanguage.setswana: 'Lentšhe'},
  'Groundnuts': {
    AppLanguage.english: 'Groundnuts',
    AppLanguage.setswana: 'Ditloo',
  },
  'Soybeans': {
    AppLanguage.english: 'Soybeans',
    AppLanguage.setswana: 'Dinawa tsa soya',
  },
  'Carrots': {
    AppLanguage.english: 'Carrots',
    AppLanguage.setswana: 'Dikerotse',
  },
  'Peppers': {
    AppLanguage.english: 'Peppers',
    AppLanguage.setswana: 'Dipelepele',
  },
  'Oranges': {AppLanguage.english: 'Oranges', AppLanguage.setswana: 'Dinamune'},
  'Bananas': {AppLanguage.english: 'Bananas', AppLanguage.setswana: 'Dipanana'},
  'Grapes': {AppLanguage.english: 'Grapes', AppLanguage.setswana: 'Morara'},
  'Mangoes': {AppLanguage.english: 'Mangoes', AppLanguage.setswana: 'Dimango'},
  'Apples': {AppLanguage.english: 'Apples', AppLanguage.setswana: 'Diapole'},
  'Potatoes': {
    AppLanguage.english: 'Potatoes',
    AppLanguage.setswana: 'Ditapole',
  },
  'Cassava': {AppLanguage.english: 'Cassava', AppLanguage.setswana: 'Monyane'},
  'Sweet Potatoes': {
    AppLanguage.english: 'Sweet Potatoes',
    AppLanguage.setswana: 'Ditapole tse di monate',
  },
  'Yams': {AppLanguage.english: 'Yams', AppLanguage.setswana: 'Diamu'},
  'Cotton': {AppLanguage.english: 'Cotton', AppLanguage.setswana: 'Kotonye'},
  'Tobacco': {AppLanguage.english: 'Tobacco', AppLanguage.setswana: 'Motsoko'},
  'Coffee': {AppLanguage.english: 'Coffee', AppLanguage.setswana: 'Kofi'},
  'Tea': {AppLanguage.english: 'Tea', AppLanguage.setswana: 'Tee'},
  'Sugarcane': {
    AppLanguage.english: 'Sugarcane',
    AppLanguage.setswana: 'Mooba',
  },
  'Butternut': {
    AppLanguage.english: 'Butternut',
    AppLanguage.setswana: 'Batanate',
  },
  'Pumpkin': {AppLanguage.english: 'Pumpkin', AppLanguage.setswana: 'Mophuthi'},
  // Products
  'Grains': {AppLanguage.english: 'Grains', AppLanguage.setswana: 'Dithoro'},
  'Legumes': {AppLanguage.english: 'Legumes', AppLanguage.setswana: 'Dinawa'},
  'Vegetables': {
    AppLanguage.english: 'Vegetables',
    AppLanguage.setswana: 'Merogo',
  },
  'Fruits': {AppLanguage.english: 'Fruits', AppLanguage.setswana: 'Maungo'},
  'Root & Tubers': {
    AppLanguage.english: 'Root & Tubers',
    AppLanguage.setswana: 'Medi',
  },
  'Cash Crops': {
    AppLanguage.english: 'Cash Crops',
    AppLanguage.setswana: 'Dijalo tsa Kgwebo',
  },
  'Livestock': {
    AppLanguage.english: 'Livestock',
    AppLanguage.setswana: 'Leruo',
  },
  'Livestock Products': {
    AppLanguage.english: 'Livestock Products',
    AppLanguage.setswana: 'Dithoto tsa Leruo',
  },
  'Dairy': {AppLanguage.english: 'Dairy', AppLanguage.setswana: 'Mashi'},
  'Poultry': {AppLanguage.english: 'Poultry', AppLanguage.setswana: 'Dikoko'},
  'Eggs': {AppLanguage.english: 'Eggs', AppLanguage.setswana: 'Mae'},
  'Processed Foods': {
    AppLanguage.english: 'Processed Foods',
    AppLanguage.setswana: 'Dijo tse di Baakantsweng',
  },
  'Seeds': {AppLanguage.english: 'Seeds', AppLanguage.setswana: 'Dipeu'},
  'Fertiliser': {
    AppLanguage.english: 'Fertiliser',
    AppLanguage.setswana: 'Monontsha',
  },
  'Pesticides': {
    AppLanguage.english: 'Pesticides',
    AppLanguage.setswana: 'Dibolayadi-twatsi',
  },
  'Tools': {AppLanguage.english: 'Tools', AppLanguage.setswana: 'Didiriswa'},
  'Machinery': {
    AppLanguage.english: 'Machinery',
    AppLanguage.setswana: 'Metšhine',
  },
  'Animal Feed': {
    AppLanguage.english: 'Animal Feed',
    AppLanguage.setswana: 'Dijo tsa Diphoofolo',
  },
  'Irrigation Equipment': {
    AppLanguage.english: 'Irrigation Equipment',
    AppLanguage.setswana: 'Didiriswa tsa Nosetso',
  },
  'Farming Supplies': {
    AppLanguage.english: 'Farming Supplies',
    AppLanguage.setswana: 'Dithoto tsa Temo',
  },
  'what_do_you_sell': {
    AppLanguage.english: 'What do you sell?',
    AppLanguage.setswana: 'O rekisa eng?',
  },
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
  'welcome_back_merchant': {
    AppLanguage.english: 'Welcome back, Merchant!',
    AppLanguage.setswana: 'O amogelesegile, Morekisi!',
  },
  'welcome_back_vendor': {
    AppLanguage.english: 'Welcome back, Vendor!',
    AppLanguage.setswana: 'O amogelesegile, Morekisi!',
  },
  // Dashboard
  'dashboard': {
    AppLanguage.english: 'Dashboard',
    AppLanguage.setswana: 'Tshobokanyo',
  },
  'products': {
    AppLanguage.english: 'Products',
    AppLanguage.setswana: 'Dithoto',
  },
  'produce': {AppLanguage.english: 'Produce', AppLanguage.setswana: 'Thobo'},
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
  'marketplace': {
    AppLanguage.english: 'Marketplace',
    AppLanguage.setswana: 'Mmaraka',
  },
  'search_supplies': {
    AppLanguage.english: 'Search for seeds, tools, supplies...',
    AppLanguage.setswana: 'Batla dipeu, didiriswa, dithoto...',
  },
  'search_produce': {
    AppLanguage.english: 'Search for produce, grains, vegetables...',
    AppLanguage.setswana: 'Batla thobo, dithoro, merogo...',
  },
  'farmer_marketplace_hint': {
    AppLanguage.english: 'Browse agricultural supplies from trusted sellers',
    AppLanguage.setswana:
        'Batla dithoto tsa temo go tswa go barekisi ba ba ikanametseng',
  },
  'merchant_marketplace_hint': {
    AppLanguage.english: 'Find fresh produce from local farmers',
    AppLanguage.setswana: 'Bona thobo e e foreše go tswa go balemi ba gae',
  },
  'vendor_marketplace_hint': {
    AppLanguage.english: 'Discover farm produce for your business',
    AppLanguage.setswana: 'Bona thobo ya polasi ya kgwebo ya gago',
  },
  'no_results': {
    AppLanguage.english: 'No Results Found',
    AppLanguage.setswana: 'Ga go na Dipholo',
  },
  'try_different_search': {
    AppLanguage.english: 'Try adjusting your search terms',
    AppLanguage.setswana: 'Leka go fetola mafoko a patlo',
  },
  'marketplace_empty': {
    AppLanguage.english: 'No Listings Yet',
    AppLanguage.setswana: 'Ga go na Dilisti',
  },
  'marketplace_empty_hint': {
    AppLanguage.english: 'Check back later for new listings',
    AppLanguage.setswana: 'Boa moragonyana go bona dilisti tse dintsha',
  },
  'ready_soon': {
    AppLanguage.english: 'Ready Soon',
    AppLanguage.setswana: 'E Tlile',
  },
  'growing': {AppLanguage.english: 'Growing', AppLanguage.setswana: 'E Gola'},
  'planted': {
    AppLanguage.english: 'Planted',
    AppLanguage.setswana: 'E Jalilwe',
  },
  'harvest': {AppLanguage.english: 'Harvest', AppLanguage.setswana: 'Thobo'},
  'price': {AppLanguage.english: 'Price', AppLanguage.setswana: 'Tlhwatlhwa'},
  'available': {
    AppLanguage.english: 'Available',
    AppLanguage.setswana: 'E Teng',
  },
  'description': {
    AppLanguage.english: 'Description',
    AppLanguage.setswana: 'Tlhaloso',
  },
  'seller_information': {
    AppLanguage.english: 'Seller Information',
    AppLanguage.setswana: 'Tshedimosetso ya Morekisi',
  },
  'supplier': {
    AppLanguage.english: 'Supplier',
    AppLanguage.setswana: 'Morekisi',
  },
  'call_seller': {
    AppLanguage.english: 'Call Seller',
    AppLanguage.setswana: 'Letsa Morekisi',
  },
  'email_seller': {
    AppLanguage.english: 'Email Seller',
    AppLanguage.setswana: 'Romela Imeile',
  },
  'contact_seller': {
    AppLanguage.english: 'Contact Seller',
    AppLanguage.setswana: 'Ikgolaganye le Morekisi',
  },
  'phone_copied': {
    AppLanguage.english: 'Phone number copied to clipboard',
    AppLanguage.setswana: 'Nomoro ya mogala e kopiilwe',
  },
  'email_copied': {
    AppLanguage.english: 'Email copied to clipboard',
    AppLanguage.setswana: 'Imeile e kopiilwe',
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
  'your_profile': {
    AppLanguage.english: 'Your Profile',
    AppLanguage.setswana: 'Profaele ya Gago',
  },
  'farm_size': {
    AppLanguage.english: 'Farm Size',
    AppLanguage.setswana: 'Bogolo jwa Polasi',
  },
  'profile_complete': {
    AppLanguage.english: 'Profile Complete!',
    AppLanguage.setswana: 'Profaele e Fedile!',
  },
  'ready_to_start': {
    AppLanguage.english: 'You\'re all set to start managing your farm',
    AppLanguage.setswana: 'O siametse go simolola go laola polasi ya gago',
  },
  'go_to_dashboard': {
    AppLanguage.english: 'Go to Dashboard',
    AppLanguage.setswana: 'Eya kwa Dashbod',
  },
  'whats_next': {
    AppLanguage.english: 'What\'s Next?',
    AppLanguage.setswana: 'Go Tlang?',
  },
  'track_crops': {
    AppLanguage.english: 'Track Your Crops',
    AppLanguage.setswana: 'Lebela Dijalo tsa Gago',
  },
  'track_crops_desc': {
    AppLanguage.english: 'Monitor planting to harvest',
    AppLanguage.setswana: 'Lebela go tswa go go jala go ya kwa thobo',
  },
  'manage_inventory': {
    AppLanguage.english: 'Manage Inventory',
    AppLanguage.setswana: 'Laola Dithoto',
  },
  'manage_inventory_desc': {
    AppLanguage.english: 'Keep track of your produce',
    AppLanguage.setswana: 'Boloka rekoto ya thobo ya gago',
  },
  'view_analytics': {
    AppLanguage.english: 'View Analytics',
    AppLanguage.setswana: 'Bona Dipalopalo',
  },
  'view_analytics_desc': {
    AppLanguage.english: 'Get insights on your farm',
    AppLanguage.setswana: 'Bona tlhaloganyo ya polasi ya gago',
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
  'profile': {AppLanguage.english: 'Profile', AppLanguage.setswana: 'Profaele'},
  // Profile Screen
  'profile_information': {
    AppLanguage.english: 'Profile Information',
    AppLanguage.setswana: 'Profaele',
  },
  'phone': {AppLanguage.english: 'Phone', AppLanguage.setswana: 'Mogala'},
  'farm_details': {
    AppLanguage.english: 'Farm Details',
    AppLanguage.setswana: 'Dintlha tsa Polase',
  },
  'primary_crops': {
    AppLanguage.english: 'Primary Crops',
    AppLanguage.setswana: 'Dijalo tsa Ntlha',
  },
  'quick_actions': {
    AppLanguage.english: 'Quick Actions',
    AppLanguage.setswana: 'Ditiro tse di Bonolo',
  },
  'view_reports': {
    AppLanguage.english: 'View Reports',
    AppLanguage.setswana: 'Bona Dipegelo',
  },
  'view_reports_desc': {
    AppLanguage.english: 'See your farming statistics',
    AppLanguage.setswana: 'Bona dipalopalo tsa temo',
  },
  'activity_history': {
    AppLanguage.english: 'Activity History',
    AppLanguage.setswana: 'Hisitori ya Ditiro',
  },
  'activity_history_desc': {
    AppLanguage.english: 'Track all your activities',
    AppLanguage.setswana: 'Latela ditiro tsotlhe tsa gago',
  },
  'export_data_desc': {
    AppLanguage.english: 'Download your records',
    AppLanguage.setswana: 'Kopolola direkoto tsa gago',
  },
  'change_password': {
    AppLanguage.english: 'Change Password',
    AppLanguage.setswana: 'Fetola Phasewete',
  },
  'change_pin': {
    AppLanguage.english: 'Change PIN',
    AppLanguage.setswana: 'Fetola PIN',
  },
  'notifications': {
    AppLanguage.english: 'Notifications',
    AppLanguage.setswana: 'Dikitsiso',
  },
  'report_bug': {
    AppLanguage.english: 'Report Bug',
    AppLanguage.setswana: 'Bega Bothata',
  },
  'help_support': {
    AppLanguage.english: 'Help & Support',
    AppLanguage.setswana: 'Thuso le Tshegetso',
  },
  'about': {AppLanguage.english: 'About', AppLanguage.setswana: 'Ka ga Rona'},
  'logout': {AppLanguage.english: 'Logout', AppLanguage.setswana: 'Tswa'},
  'logout_confirmation': {
    AppLanguage.english: 'Are you sure you want to logout?',
    AppLanguage.setswana: 'A o tlhomamisa gore o batla go tswa?',
  },
  // Merchant Profile
  'business_stats': {
    AppLanguage.english: 'Business Statistics',
    AppLanguage.setswana: 'Dipalopalo tsa Kgwebo',
  },
  'total_purchases': {
    AppLanguage.english: 'Total Purchases',
    AppLanguage.setswana: 'Direko Tsotlhe',
  },
  'total_products': {
    AppLanguage.english: 'Total Products',
    AppLanguage.setswana: 'Dithoto Tsotlhe',
  },
  'monthly_revenue': {
    AppLanguage.english: 'Monthly Revenue',
    AppLanguage.setswana: 'Lotseno lwa Kgwedi',
  },
  'active_orders': {
    AppLanguage.english: 'Active Orders',
    AppLanguage.setswana: 'Ditaelo tse di Dirang',
  },
  'low_stock_items': {
    AppLanguage.english: 'Low Stock Items',
    AppLanguage.setswana: 'Dithoto tse di Fokotsegile',
  },
  'total_suppliers': {
    AppLanguage.english: 'Total Suppliers',
    AppLanguage.setswana: 'Barekisi Botlhe',
  },
  'monthly_purchases': {
    AppLanguage.english: 'Monthly Purchases',
    AppLanguage.setswana: 'Direko tsa Kgwedi',
  },
  'pending_orders': {
    AppLanguage.english: 'Pending Orders',
    AppLanguage.setswana: 'Ditaelo tse di Emetsweng',
  },
  'available_produce': {
    AppLanguage.english: 'Available Produce',
    AppLanguage.setswana: 'Thobo e e Teng',
  },
  'store_inventory': {
    AppLanguage.english: 'Store Inventory',
    AppLanguage.setswana: 'Dithoto tsa Lebenkele',
  },
  'produce_inventory': {
    AppLanguage.english: 'Produce Inventory',
    AppLanguage.setswana: 'Thobo ya Lebenkele',
  },
  'suppliers': {
    AppLanguage.english: 'Suppliers',
    AppLanguage.setswana: 'Barekisi',
  },
  'this_month': {
    AppLanguage.english: 'This Month',
    AppLanguage.setswana: 'Kgwedi Eno',
  },
  'products_bought': {
    AppLanguage.english: 'Products Bought',
    AppLanguage.setswana: 'Dithoto tse di Rekwang',
  },
  'purchase_history': {
    AppLanguage.english: 'Purchase History',
    AppLanguage.setswana: 'Hisitori ya Direko',
  },
  'purchase_history_desc': {
    AppLanguage.english: 'View all your purchases',
    AppLanguage.setswana: 'Bona direko tsotlhe tsa gago',
  },
  'manage_suppliers': {
    AppLanguage.english: 'Manage Suppliers',
    AppLanguage.setswana: 'Laola Barekisi',
  },
  'manage_suppliers_desc': {
    AppLanguage.english: 'Track your supplier network',
    AppLanguage.setswana: 'Latela barekisi ba gago',
  },
  // Crop Form
  'add_crop': {
    AppLanguage.english: 'Add Crop',
    AppLanguage.setswana: 'Tsenya Sejalo',
  },
  'edit_crop': {
    AppLanguage.english: 'Edit Crop',
    AppLanguage.setswana: 'Baakanya Sejalo',
  },
  'crop_details': {
    AppLanguage.english: 'Crop Details',
    AppLanguage.setswana: 'Dintlha tsa Sejalo',
  },
  'field_info': {
    AppLanguage.english: 'Field Information',
    AppLanguage.setswana: 'Tshedimosetso ya Tshimo',
  },
  'yield_storage': {
    AppLanguage.english: 'Yield & Storage',
    AppLanguage.setswana: 'Thobo le Poloko',
  },
  'crop_type': {
    AppLanguage.english: 'Crop Type',
    AppLanguage.setswana: 'Mofuta wa Sejalo',
  },
  'crop_selected': {
    AppLanguage.english: 'crop selected',
    AppLanguage.setswana: 'sejalo se tlhophilwe',
  },
  'crops_selected': {
    AppLanguage.english: 'crops selected',
    AppLanguage.setswana: 'dijalo di tlhophilwe',
  },
  'select_multiple_crops_hint': {
    AppLanguage.english: 'You can select multiple crops at once',
    AppLanguage.setswana: 'O ka tlhopha dijalo tse dintsi ka nako e le nngwe',
  },
  'specify_other_crop': {
    AppLanguage.english: 'Specify Other Crop',
    AppLanguage.setswana: 'Tlhalosa Sejalo se Sengwe',
  },
  'enter_crop_name': {
    AppLanguage.english: 'Enter crop name',
    AppLanguage.setswana: 'Kwala leina la sejalo',
  },
  'post_harvest_loss': {
    AppLanguage.english: 'Post-Harvest Loss (Est.)',
    AppLanguage.setswana: 'Taelo ya Morago ga Kotulo',
  },
  'estimated_loss_15': {
    AppLanguage.english: 'Estimated loss (15%)',
    AppLanguage.setswana: 'Taelo e e lebelerwang (15%)',
  },
  'expected_after_loss': {
    AppLanguage.english: 'Expected after loss',
    AppLanguage.setswana: 'E e lebelerweng morago ga taelo',
  },
  'field_name': {
    AppLanguage.english: 'Field Name',
    AppLanguage.setswana: 'Leina la Tshimo',
  },
  'field_size': {
    AppLanguage.english: 'Field Size',
    AppLanguage.setswana: 'Bogolo jwa Tshimo',
  },
  'planting_date': {
    AppLanguage.english: 'Planting Date',
    AppLanguage.setswana: 'Letlha la go Jala',
  },
  'expected_harvest_date': {
    AppLanguage.english: 'Expected Harvest Date',
    AppLanguage.setswana: 'Letlha la Thobo',
  },
  'estimated_yield': {
    AppLanguage.english: 'Estimated Yield',
    AppLanguage.setswana: 'Thobo e e Lebeletsiweng',
  },
  'storage_method': {
    AppLanguage.english: 'Storage Method',
    AppLanguage.setswana: 'Mokgwa wa Poloko',
  },
  'notes': {AppLanguage.english: 'Notes', AppLanguage.setswana: 'Ditshupiso'},
  'save': {AppLanguage.english: 'Save', AppLanguage.setswana: 'Boloka'},
  'cancel': {AppLanguage.english: 'Cancel', AppLanguage.setswana: 'Khansela'},
  'next': {AppLanguage.english: 'Next', AppLanguage.setswana: 'Go Latelang'},
  'back': {AppLanguage.english: 'Back', AppLanguage.setswana: 'Morago'},
  'skip': {AppLanguage.english: 'Skip', AppLanguage.setswana: 'Feta'},
  'edit': {AppLanguage.english: 'Edit', AppLanguage.setswana: 'Baakanya'},
  'delete': {AppLanguage.english: 'Delete', AppLanguage.setswana: 'Phimola'},

  // Crop categories and crop type translations are now served by the backend
  // via the crop catalog API. Category keys ('vegetables', 'field_crops', 'fruits')
  // are still needed for the t() fallback when catalog hasn't loaded yet.
  'vegetables': {
    AppLanguage.english: 'Vegetables',
    AppLanguage.setswana: 'Merogo',
  },
  'field_crops': {
    AppLanguage.english: 'Field Crops',
    AppLanguage.setswana: 'Dijalo tsa Masimo',
  },
  'fruits': {AppLanguage.english: 'Fruits', AppLanguage.setswana: 'Maungo'},

  'other': {AppLanguage.english: 'Other', AppLanguage.setswana: 'Tse Dingwe'},
  // Units
  'hectares': {
    AppLanguage.english: 'Hectares',
    AppLanguage.setswana: 'Di-Hectare',
  },
  'metres': {AppLanguage.english: 'Metres', AppLanguage.setswana: 'Dimithara'},
  'kg': {AppLanguage.english: 'Kilograms', AppLanguage.setswana: 'Dikilogram'},
  'bags': {AppLanguage.english: 'Bags', AppLanguage.setswana: 'Mekotla'},
  'tons': {AppLanguage.english: 'Tons', AppLanguage.setswana: 'Ditone'},
  // Storage Methods
  'traditional_granary': {
    AppLanguage.english: 'Traditional Granary',
    AppLanguage.setswana: 'Selala sa Setso',
  },
  'improved_storage': {
    AppLanguage.english: 'Improved Storage',
    AppLanguage.setswana: 'Poloko e e Tokafetseng',
  },
  'bags_in_room': {
    AppLanguage.english: 'Bags in Room',
    AppLanguage.setswana: 'Mekotla mo Kamoreng',
  },
  'open_air': {
    AppLanguage.english: 'Open Air',
    AppLanguage.setswana: 'Kwa Ntle',
  },
  'warehouse': {
    AppLanguage.english: 'Warehouse',
    AppLanguage.setswana: 'Warehouse',
  },
  // Helper text
  'optional': {
    AppLanguage.english: 'Optional',
    AppLanguage.setswana: 'Ga e a Tlhokega',
  },
  'required': {
    AppLanguage.english: 'Required',
    AppLanguage.setswana: 'E a Tlhokega',
  },
  'select_crop_type': {
    AppLanguage.english: 'Select the type of crop',
    AppLanguage.setswana: 'Tlhopha mofuta wa sejalo',
  },
  'enter_field_name': {
    AppLanguage.english: 'E.g., Field A, North Plot',
    AppLanguage.setswana: 'Mohlala: Tshimo A, Kgaolo ya Bokone',
  },
  'auto_calculate_harvest': {
    AppLanguage.english: 'Auto-calculate based on crop',
    AppLanguage.setswana: 'Bala ka go iketla go ya ka sejalo',
  },
  // Crop Details Screen
  'ready': {AppLanguage.english: 'Ready', AppLanguage.setswana: 'E Siametse'},
  'days_since_planting': {
    AppLanguage.english: 'Days Since Planting',
    AppLanguage.setswana: 'Malatsi go Tswa go Jalwa',
  },
  'days_until_harvest': {
    AppLanguage.english: 'Days Until Harvest',
    AppLanguage.setswana: 'Malatsi go Fitlha Thobo',
  },
  'current_stage': {
    AppLanguage.english: 'Current Stage',
    AppLanguage.setswana: 'Kgato ya Jaana',
  },
  'weather': {AppLanguage.english: 'Weather', AppLanguage.setswana: 'Boso'},
  'temperature': {
    AppLanguage.english: 'Temperature',
    AppLanguage.setswana: 'Mogote',
  },
  'humidity': {
    AppLanguage.english: 'Humidity',
    AppLanguage.setswana: 'Mongobo',
  },
  'rainfall': {AppLanguage.english: 'Rainfall', AppLanguage.setswana: 'Pula'},
  'record_harvest': {
    AppLanguage.english: 'Record Harvest',
    AppLanguage.setswana: 'Kwala Thobo',
  },
  'harvest_history': {
    AppLanguage.english: 'Harvest History',
    AppLanguage.setswana: 'Hisitori ya Thobo',
  },
  'no_harvest_history': {
    AppLanguage.english: 'No previous harvests recorded',
    AppLanguage.setswana: 'Ga go na dithobo tsa pele',
  },
  'planted_on': {
    AppLanguage.english: 'Planted on',
    AppLanguage.setswana: 'E jalilwe ka',
  },
  'harvest_expected': {
    AppLanguage.english: 'Harvest expected',
    AppLanguage.setswana: 'Thobo e lebeletswe',
  },
  'germination': {
    AppLanguage.english: 'Germination',
    AppLanguage.setswana: 'Go Mela',
  },
  'vegetative': {
    AppLanguage.english: 'Vegetative',
    AppLanguage.setswana: 'Go Gola',
  },
  'flowering': {
    AppLanguage.english: 'Flowering',
    AppLanguage.setswana: 'Go Thunya',
  },
  'ripening': {
    AppLanguage.english: 'Ripening',
    AppLanguage.setswana: 'Go Beba',
  },
  'harvest_ready': {
    AppLanguage.english: 'Harvest Ready',
    AppLanguage.setswana: 'Thobo e Siametse',
  },
  'confirm_delete': {
    AppLanguage.english: 'Confirm Delete',
    AppLanguage.setswana: 'Tlhomamisa go Phimola',
  },
  'delete_crop_message': {
    AppLanguage.english: 'Are you sure you want to delete this crop?',
    AppLanguage.setswana:
        'A o tlhomamisegile gore o batla go phimola sejalo se?',
  },
  'harvested_on': {
    AppLanguage.english: 'Harvested on',
    AppLanguage.setswana: 'E thobilwe ka',
  },
  'actual_yield': {
    AppLanguage.english: 'Actual Yield',
    AppLanguage.setswana: 'Thobo ya Nnete',
  },
  // Harvest Recording
  'harvest_date': {
    AppLanguage.english: 'Harvest Date',
    AppLanguage.setswana: 'Letlha la Thobo',
  },
  'quality_assessment': {
    AppLanguage.english: 'Quality Assessment',
    AppLanguage.setswana: 'Tekolo ya Boleng',
  },
  'good': {AppLanguage.english: 'Good', AppLanguage.setswana: 'Botoka'},
  'fair': {AppLanguage.english: 'Fair', AppLanguage.setswana: 'Magareng'},
  'poor': {AppLanguage.english: 'Poor', AppLanguage.setswana: 'Bobe'},
  'immediate_losses': {
    AppLanguage.english: 'Immediate Losses',
    AppLanguage.setswana: 'Ditshenyegelo tsa Bonako',
  },
  'loss_amount': {
    AppLanguage.english: 'Loss Amount',
    AppLanguage.setswana: 'Seelo sa Tshenyegelo',
  },
  'loss_reason': {
    AppLanguage.english: 'Loss Reason',
    AppLanguage.setswana: 'Lebaka la Tshenyegelo',
  },
  'storage_location': {
    AppLanguage.english: 'Storage Location',
    AppLanguage.setswana: 'Lefelo la Poloko',
  },
  'save_to_inventory': {
    AppLanguage.english: 'Save to Inventory',
    AppLanguage.setswana: 'Boloka mo Dithoto',
  },
  'expected_vs_actual': {
    AppLanguage.english: 'Expected vs Actual',
    AppLanguage.setswana: 'E e Lebeletsiweng vs ya Nnete',
  },
  'expected': {
    AppLanguage.english: 'Expected',
    AppLanguage.setswana: 'E Lebeletswe',
  },
  'actual': {AppLanguage.english: 'Actual', AppLanguage.setswana: 'Ya Nnete'},
  'difference': {
    AppLanguage.english: 'Difference',
    AppLanguage.setswana: 'Pharologano',
  },
  'select_quality': {
    AppLanguage.english: 'Select quality of harvest',
    AppLanguage.setswana: 'Tlhopha boleng jwa thobo',
  },
  'enter_loss_amount': {
    AppLanguage.english: 'Enter amount lost',
    AppLanguage.setswana: 'Tsenya seelo se se senyegileng',
  },
  'enter_loss_reason': {
    AppLanguage.english: 'E.g., Pests, Spoilage, Weather damage',
    AppLanguage.setswana: 'Mohlala: Dikgokgo, Go Senyega, Boso',
  },
  'pest_damage': {
    AppLanguage.english: 'Pest Damage',
    AppLanguage.setswana: 'Tshenyego ya Dikgokgo',
  },
  'spoilage': {
    AppLanguage.english: 'Spoilage',
    AppLanguage.setswana: 'Go Senyega',
  },
  'weather_damage': {
    AppLanguage.english: 'Weather Damage',
    AppLanguage.setswana: 'Tshenyego ya Boso',
  },
  'handling_damage': {
    AppLanguage.english: 'Handling Damage',
    AppLanguage.setswana: 'Tshenyego ya Tsamaiso',
  },
  'other_loss': {
    AppLanguage.english: 'Other',
    AppLanguage.setswana: 'Tse Dingwe',
  },
  // Inventory
  'inventory_view': {
    AppLanguage.english: 'Inventory',
    AppLanguage.setswana: 'Dithoto',
  },
  'total_value': {
    AppLanguage.english: 'Total Value',
    AppLanguage.setswana: 'Tlhwatlhwa Yotlhe',
  },
  'items_needing_attention': {
    AppLanguage.english: 'Need Attention',
    AppLanguage.setswana: 'Di Tlhoka Tlhokomelo',
  },
  'filter_by': {
    AppLanguage.english: 'Filter by',
    AppLanguage.setswana: 'Kgetha ka',
  },
  'all_crops': {
    AppLanguage.english: 'All Crops',
    AppLanguage.setswana: 'Dijalo Tsotlhe',
  },
  'all_locations': {
    AppLanguage.english: 'All Locations',
    AppLanguage.setswana: 'Mafelo Otlhe',
  },
  'sort_by_date': {
    AppLanguage.english: 'Sort by Date',
    AppLanguage.setswana: 'Rulaganya ka Letlha',
  },
  'stored_on': {
    AppLanguage.english: 'Stored on',
    AppLanguage.setswana: 'E bolokilwe ka',
  },
  'condition': {
    AppLanguage.english: 'Condition',
    AppLanguage.setswana: 'Maemo',
  },
  'excellent': {
    AppLanguage.english: 'Excellent',
    AppLanguage.setswana: 'Botoka Thata',
  },
  'needs_attention': {
    AppLanguage.english: 'Needs Attention',
    AppLanguage.setswana: 'E Tlhoka Tlhokomelo',
  },
  'critical': {
    AppLanguage.english: 'Critical',
    AppLanguage.setswana: 'Botlhokwa',
  },
  'update_quantity': {
    AppLanguage.english: 'Update Quantity',
    AppLanguage.setswana: 'Baakanya Selekanyo',
  },
  'record_loss': {
    AppLanguage.english: 'Record Loss',
    AppLanguage.setswana: 'Kwala Tshenyegelo',
  },
  'record_sale': {
    AppLanguage.english: 'Record Sale',
    AppLanguage.setswana: 'Kwala Thekiso',
  },
  'no_inventory': {
    AppLanguage.english: 'No inventory items yet',
    AppLanguage.setswana: 'Ga go dithoto tsa jaana',
  },
  'add_inventory': {
    AppLanguage.english: 'Add Inventory',
    AppLanguage.setswana: 'Tsenya Dithoto',
  },
  'add_inventory_hint': {
    AppLanguage.english: 'Add your first harvest to start tracking',
    AppLanguage.setswana: 'Tsenya thobo ya gago ya ntlha go simolola go latela',
  },
  'edit_inventory': {
    AppLanguage.english: 'Edit Inventory',
    AppLanguage.setswana: 'Baakanya Dithoto',
  },
  'save_inventory': {
    AppLanguage.english: 'Save Inventory',
    AppLanguage.setswana: 'Boloka Dithoto',
  },
  'update_inventory': {
    AppLanguage.english: 'Update Inventory',
    AppLanguage.setswana: 'Baakanya Dithoto',
  },
  'inventory_added': {
    AppLanguage.english: 'Inventory item added successfully',
    AppLanguage.setswana: 'Selo sa dithoto se tsentswe ka katlego',
  },
  'inventory_updated': {
    AppLanguage.english: 'Inventory item updated successfully',
    AppLanguage.setswana: 'Selo sa dithoto se baakantse ka katlego',
  },
  'inventory_deleted': {
    AppLanguage.english: 'Inventory item deleted successfully',
    AppLanguage.setswana: 'Selo sa dithoto se phimolotse ka katlego',
  },
  'delete_inventory': {
    AppLanguage.english: 'Delete Inventory Item',
    AppLanguage.setswana: 'Phimola Selo sa Dithoto',
  },
  'delete_inventory_confirm': {
    AppLanguage.english: 'Are you sure you want to delete this inventory item?',
    AppLanguage.setswana:
        'A o tlhomamisa gore o batla go phimola selo se sa dithoto?',
  },
  'error_loading_inventory': {
    AppLanguage.english: 'Failed to load inventory',
    AppLanguage.setswana: 'Go padile go tsenya dithoto',
  },
  'inventory_details': {
    AppLanguage.english: 'Inventory Details',
    AppLanguage.setswana: 'Dintlha tsa Dithoto',
  },
  'storage_info': {
    AppLanguage.english: 'Storage Information',
    AppLanguage.setswana: 'Tshedimosetso ya Poloko',
  },
  'storage_date': {
    AppLanguage.english: 'Storage Date',
    AppLanguage.setswana: 'Letlha la Poloko',
  },
  'enter_quantity': {
    AppLanguage.english: 'Enter quantity',
    AppLanguage.setswana: 'Tsenya selekanyo',
  },
  'quantity_required': {
    AppLanguage.english: 'Quantity is required',
    AppLanguage.setswana: 'Selekanyo se a tlhokega',
  },
  'quantity_invalid': {
    AppLanguage.english: 'Quantity must be greater than 0',
    AppLanguage.setswana: 'Selekanyo se tshwanetse go feta 0',
  },
  'add_notes': {
    AppLanguage.english: 'Add any notes about this item...',
    AppLanguage.setswana: 'Tsenya ditshupiso ka selo se...',
  },
  'error': {AppLanguage.english: 'Error', AppLanguage.setswana: 'Phoso'},
  'sunflower': {
    AppLanguage.english: 'Sunflower',
    AppLanguage.setswana: 'Sunflower',
  },
  'quantity': {
    AppLanguage.english: 'Quantity',
    AppLanguage.setswana: 'Selekanyo',
  },
  'days_in_storage': {
    AppLanguage.english: 'days in storage',
    AppLanguage.setswana: 'malatsi mo polokong',
  },
  'filters': {AppLanguage.english: 'Filters', AppLanguage.setswana: 'Dikgetho'},
  'apply_filters': {
    AppLanguage.english: 'Apply Filters',
    AppLanguage.setswana: 'Dirisa Dikgetho',
  },
  'clear_filters': {
    AppLanguage.english: 'Clear All',
    AppLanguage.setswana: 'Phimola Tsotlhe',
  },
  'price_range': {
    AppLanguage.english: 'Price Range',
    AppLanguage.setswana: 'Tlhwatlhwa',
  },
  'min_price': {AppLanguage.english: 'Min', AppLanguage.setswana: 'Bonnye'},
  'max_price': {AppLanguage.english: 'Max', AppLanguage.setswana: 'Bogolo'},
  'category': {AppLanguage.english: 'Category', AppLanguage.setswana: 'Mokgwa'},
  'error_loading': {
    AppLanguage.english: 'Failed to Load',
    AppLanguage.setswana: 'Go Padile go Tsenya',
  },
  'retry': {AppLanguage.english: 'Retry', AppLanguage.setswana: 'Leka Gape'},
  // Agri Shop specific
  'orders': {AppLanguage.english: 'Orders', AppLanguage.setswana: 'Ditaelo'},
  'orders_today': {
    AppLanguage.english: 'Orders Today',
    AppLanguage.setswana: 'Ditaelo Gompieno',
  },
  'revenue_month': {
    AppLanguage.english: 'Revenue This Month',
    AppLanguage.setswana: 'Lotseno Kgwedi Eno',
  },
  'low_stock': {
    AppLanguage.english: 'Low Stock',
    AppLanguage.setswana: 'Dithoto Tse Nnye',
  },
  'coming_soon': {
    AppLanguage.english: 'Coming Soon',
    AppLanguage.setswana: 'E Tlaa',
  },
  'add_new_product': {
    AppLanguage.english: 'Add New Product',
    AppLanguage.setswana: 'Tsenya Selo Se Sesha',
  },
  'add_to_catalog': {
    AppLanguage.english: 'Add to your catalog',
    AppLanguage.setswana: 'Tsenya mo lenaneong la gago',
  },
  'add_product': {
    AppLanguage.english: 'Add Product',
    AppLanguage.setswana: 'Tsenya Selo',
  },
  'edit_product': {
    AppLanguage.english: 'Edit Product',
    AppLanguage.setswana: 'Fetola Selo',
  },
  'update_product': {
    AppLanguage.english: 'Update Product',
    AppLanguage.setswana: 'Ntšhafatsa Selo',
  },
  'product_name': {
    AppLanguage.english: 'Product Name',
    AppLanguage.setswana: 'Leina la Selo',
  },
  'enter_product_name': {
    AppLanguage.english: 'Enter product name',
    AppLanguage.setswana: 'Tsenya leina la selo',
  },
  'enter_description': {
    AppLanguage.english: 'Enter description',
    AppLanguage.setswana: 'Tsenya tlhaloso',
  },
  'unit': {AppLanguage.english: 'Unit', AppLanguage.setswana: 'Tekanyetso'},
  'quantity_available': {
    AppLanguage.english: 'Quantity Available',
    AppLanguage.setswana: 'Palo e e Leng Teng',
  },
  'view_orders': {
    AppLanguage.english: 'View Orders',
    AppLanguage.setswana: 'Bona Ditaelo',
  },
  'view_all_orders': {
    AppLanguage.english: 'View All Orders',
    AppLanguage.setswana: 'Bona Ditaelo Tsotlhe',
  },
  'manage_customer_orders': {
    AppLanguage.english: 'Manage customer orders',
    AppLanguage.setswana: 'Laola ditaelo tsa badirisi',
  },
  'check_inventory': {
    AppLanguage.english: 'Check Inventory',
    AppLanguage.setswana: 'Tlhola Dithoto',
  },
  'manage_stock_levels': {
    AppLanguage.english: 'Manage stock levels',
    AppLanguage.setswana: 'Laola maemo a dithoto',
  },
  'business_insights': {
    AppLanguage.english: 'Business insights',
    AppLanguage.setswana: 'Ditlhaloso tsa kgwebo',
  },
  'no_orders_yet': {
    AppLanguage.english: 'No orders yet',
    AppLanguage.setswana: 'Ga go ditaelo jaanong',
  },
  'orders_will_appear_here': {
    AppLanguage.english: 'Orders from farmers will appear here',
    AppLanguage.setswana: 'Ditaelo go tswa go balemi di tlaa bonala fano',
  },
  'add_products_to_start': {
    AppLanguage.english:
        'Add products to your catalog to start receiving orders',
    AppLanguage.setswana:
        'Tsenya dithoto mo lenaneong go simolola go amogela ditaelo',
  },
  'no_recent_orders': {
    AppLanguage.english: 'No recent orders',
    AppLanguage.setswana: 'Ga go ditaelo tsa bosheng',
  },
  'good_morning': {
    AppLanguage.english: 'Good morning',
    AppLanguage.setswana: 'Dumela rra/mma',
  },
  'good_afternoon': {
    AppLanguage.english: 'Good afternoon',
    AppLanguage.setswana: 'Dumela rra/mma',
  },
  'good_evening': {
    AppLanguage.english: 'Good evening',
    AppLanguage.setswana: 'Dumela rra/mma',
  },
  'feature_under_development': {
    AppLanguage.english:
        'This feature is currently under development and will be available soon.',
    AppLanguage.setswana:
        'Sediriswa se se santse se dirwa mme se tlaa nna teng ka bonako.',
  },
  'okay': {AppLanguage.english: 'Okay', AppLanguage.setswana: 'Go siame'},
  'what_are_orders': {
    AppLanguage.english: 'What are orders?',
    AppLanguage.setswana: 'Ditaelo ke eng?',
  },
  'orders_description': {
    AppLanguage.english:
        'Orders are purchase requests from farmers who want to buy your products. Once you add products to your catalog, farmers can place orders through the marketplace.',
    AppLanguage.setswana:
        'Ditaelo ke dikopo tsa go reka go tswa go balemi ba ba batlang go reka dithoto tsa gago. Fa o tsenya dithoto mo lenaneong la gago, balemi ba ka dira ditaelo go ralala mmaraka.',
  },
  'record_purchase': {
    AppLanguage.english: 'Record Purchase',
    AppLanguage.setswana: 'Kwala Theko',
  },
  'record_new_purchase': {
    AppLanguage.english: 'Record New Purchase',
    AppLanguage.setswana: 'Kwala Theko e Ntšhwa',
  },
  'seller_name': {
    AppLanguage.english: 'Seller Name',
    AppLanguage.setswana: 'Leina la Morekisi',
  },
  'seller_name_hint': {
    AppLanguage.english: 'e.g. Thabo Modise',
    AppLanguage.setswana: 'sekao Thabo Modise',
  },
  'price_per_unit': {
    AppLanguage.english: 'Price per Unit',
    AppLanguage.setswana: 'Tlhwatlhwa ka Selekanyo',
  },
  'total_amount': {
    AppLanguage.english: 'Total Amount',
    AppLanguage.setswana: 'Palogotlhe',
  },
  'purchase_date': {
    AppLanguage.english: 'Purchase Date',
    AppLanguage.setswana: 'Letlha la Theko',
  },
  'purchase_saved': {
    AppLanguage.english: 'Purchase recorded successfully',
    AppLanguage.setswana: 'Theko e kwalilwe sentle',
  },
  'purchase_save_failed': {
    AppLanguage.english: 'Failed to save purchase',
    AppLanguage.setswana: 'Go boloka theko go paletse',
  },
  'purchases': {
    AppLanguage.english: 'Purchases',
    AppLanguage.setswana: 'Ditheko',
  },
  'no_purchases': {
    AppLanguage.english: 'No purchases yet',
    AppLanguage.setswana: 'Ga go na ditheko',
  },
  'record_from_farmers': {
    AppLanguage.english: 'Record purchases from farmers',
    AppLanguage.setswana: 'Kwala ditheko go tswa go balemi',
  },
  // Loss Calculator
  'crop_harvest': {
    AppLanguage.english: 'Crop & Harvest',
    AppLanguage.setswana: 'Sejalo & Thobo',
  },
  'loss_details': {
    AppLanguage.english: 'Loss Details',
    AppLanguage.setswana: 'Dintlha tsa Ditshenyegelo',
  },
  'results': {AppLanguage.english: 'Results', AppLanguage.setswana: 'Dipholo'},
  'select_crop': {
    AppLanguage.english: 'Select Crop',
    AppLanguage.setswana: 'Tlhopha Sejalo',
  },
  'select_crop_for_calculation': {
    AppLanguage.english: 'Choose a crop to calculate post-harvest losses',
    AppLanguage.setswana:
        'Tlhopha sejalo go bala ditshenyegelo tsa morago ga thobo',
  },
  'no_crops_add_first': {
    AppLanguage.english:
        'No crops found. Add a crop first to use the calculator.',
    AppLanguage.setswana:
        'Ga go na dijalo. Tsenya sejalo pele go dirisa sekala-ditshenyegelo.',
  },
  'choose_crop': {
    AppLanguage.english: 'Choose a crop',
    AppLanguage.setswana: 'Tlhopha sejalo',
  },
  'harvest_amount': {
    AppLanguage.english: 'Harvest Amount',
    AppLanguage.setswana: 'Selekanyo sa Thobo',
  },
  'market_price_per_unit': {
    AppLanguage.english: 'Market Price per Unit',
    AppLanguage.setswana: 'Tlhwatlhwa ya Mmaraka ka Selekanyo',
  },
  'enter_valid_number': {
    AppLanguage.english: 'Enter a valid number',
    AppLanguage.setswana: 'Tsenya nomoro e e nepagetseng',
  },
  'enter_losses_by_stage': {
    AppLanguage.english: 'Enter Losses by Stage',
    AppLanguage.setswana: 'Tsenya Ditshenyegelo ka Mogato',
  },
  'enter_losses_description': {
    AppLanguage.english:
        'Enter the amount lost at each stage. Leave blank if none.',
    AppLanguage.setswana:
        'Tsenya selekanyo se se latlhegileng mo mogatong mongwe le mongwe. Tlogela go se na sepe fa go se na.',
  },
  'select_cause': {
    AppLanguage.english: 'Select cause (optional)',
    AppLanguage.setswana: 'Tlhopha lebaka (ka boithaopo)',
  },
  'loss_stage_field': {
    AppLanguage.english: 'Field Losses',
    AppLanguage.setswana: 'Ditshenyegelo tsa Tshimo',
  },
  'loss_stage_transport': {
    AppLanguage.english: 'Transport Losses',
    AppLanguage.setswana: 'Ditshenyegelo tsa Dipalangwa',
  },
  'loss_stage_storage': {
    AppLanguage.english: 'Storage Losses',
    AppLanguage.setswana: 'Ditshenyegelo tsa Polokelo',
  },
  'loss_stage_processing': {
    AppLanguage.english: 'Processing Losses',
    AppLanguage.setswana: 'Ditshenyegelo tsa Tiragatso',
  },
  'running_total': {
    AppLanguage.english: 'Running Total',
    AppLanguage.setswana: 'Palogotlhe e e Tswelelang',
  },
  'calculate': {AppLanguage.english: 'Calculate', AppLanguage.setswana: 'Bala'},
  'done': {AppLanguage.english: 'Done', AppLanguage.setswana: 'Go Fedile'},
  'total_loss': {
    AppLanguage.english: 'Total Loss',
    AppLanguage.setswana: 'Ditshenyegelo Tsotlhe',
  },
  'total_harvest_value': {
    AppLanguage.english: 'Total Harvest Value',
    AppLanguage.setswana: 'Boleng Jotlhe jwa Thobo',
  },
  'value_lost': {
    AppLanguage.english: 'Value Lost',
    AppLanguage.setswana: 'Boleng jo bo Latlhegileng',
  },
  'remaining_value': {
    AppLanguage.english: 'Remaining Value',
    AppLanguage.setswana: 'Boleng jo bo Setseng',
  },
  'loss_by_stage': {
    AppLanguage.english: 'Loss by Stage',
    AppLanguage.setswana: 'Ditshenyegelo ka Mogato',
  },
  'loss_severity_low': {
    AppLanguage.english: 'Low Loss',
    AppLanguage.setswana: 'Ditshenyegelo Tse Dinnye',
  },
  'loss_severity_moderate': {
    AppLanguage.english: 'Moderate Loss',
    AppLanguage.setswana: 'Ditshenyegelo Tse di Magareng',
  },
  'loss_severity_high': {
    AppLanguage.english: 'High Loss',
    AppLanguage.setswana: 'Ditshenyegelo Tse Dikgolo',
  },
  'loss_severity_critical': {
    AppLanguage.english: 'Critical Loss',
    AppLanguage.setswana: 'Ditshenyegelo Tse di Masisi',
  },
  'below_regional_average': {
    AppLanguage.english: 'Below regional average — well done!',
    AppLanguage.setswana:
        'Ka fa tlase ga palogare ya tikologo — o dirile sentle!',
  },
  'above_regional_average': {
    AppLanguage.english: 'Above regional average — room for improvement',
    AppLanguage.setswana:
        'Ka fa godimo ga palogare ya tikologo — go na le sebaka sa tokafatso',
  },
  'regional_average': {
    AppLanguage.english: 'Regional average',
    AppLanguage.setswana: 'Palogare ya tikologo',
  },
  'prevention_tips': {
    AppLanguage.english: 'Prevention Tips',
    AppLanguage.setswana: 'Dikgakololo tsa Thibelo',
  },
  'based_on_highest_loss': {
    AppLanguage.english: 'Based on your highest loss stage',
    AppLanguage.setswana:
        'Go ya ka mogato wa gago o o nang le ditshenyegelo tse dintsi',
  },
  'no_losses_recorded': {
    AppLanguage.english: 'No losses recorded — great job!',
    AppLanguage.setswana: 'Ga go na ditshenyegelo — o dirile sentle!',
  },
  'calculate_losses': {
    AppLanguage.english: 'Calculate Losses',
    AppLanguage.setswana: 'Bala Ditshenyegelo',
  },
  'estimate_post_harvest_losses': {
    AppLanguage.english: 'Estimate post-harvest losses',
    AppLanguage.setswana: 'Akanya ditshenyegelo tsa morago ga thobo',
  },
  // Loss causes
  'mechanical_damage': {
    AppLanguage.english: 'Mechanical Damage',
    AppLanguage.setswana: 'Tshenyegelo ya Motšhine',
  },
  'late_harvest': {
    AppLanguage.english: 'Late Harvest',
    AppLanguage.setswana: 'Thobo e e Latelang',
  },
  'spillage': {
    AppLanguage.english: 'Spillage',
    AppLanguage.setswana: 'Go Tshologa',
  },
  'heat_exposure': {
    AppLanguage.english: 'Heat Exposure',
    AppLanguage.setswana: 'Go Amiwa ke Mogote',
  },
  'poor_packaging': {
    AppLanguage.english: 'Poor Packaging',
    AppLanguage.setswana: 'Pakeji e e Sa Siamang',
  },
  'moisture_damage': {
    AppLanguage.english: 'Moisture Damage',
    AppLanguage.setswana: 'Tshenyegelo ya Monola',
  },
  'rodent_damage': {
    AppLanguage.english: 'Rodent Damage',
    AppLanguage.setswana: 'Tshenyegelo ya Dipeba',
  },
  'threshing_loss': {
    AppLanguage.english: 'Threshing Loss',
    AppLanguage.setswana: 'Tshenyegelo ya go Photha',
  },
  'cleaning_loss': {
    AppLanguage.english: 'Cleaning Loss',
    AppLanguage.setswana: 'Tshenyegelo ya go Phepafatsa',
  },
  'drying_loss': {
    AppLanguage.english: 'Drying Loss',
    AppLanguage.setswana: 'Tshenyegelo ya go Omisa',
  },
  // Storage methods
  'traditional': {
    AppLanguage.english: 'Traditional Storage',
    AppLanguage.setswana: 'Polokelo ya Setso',
  },
  'cold_storage': {
    AppLanguage.english: 'Cold Storage',
    AppLanguage.setswana: 'Polokelo ya Tsididi',
  },
  // Prevention tips
  'tip_field_timely_harvest': {
    AppLanguage.english:
        'Harvest at the right time — delays increase field losses by up to 10%.',
    AppLanguage.setswana:
        'Roba ka nako e e siameng — go diega go oketsa ditshenyegelo tsa tshimo ka 10%.',
  },
  'tip_field_pest_management': {
    AppLanguage.english:
        'Use integrated pest management before and during harvest to reduce crop damage.',
    AppLanguage.setswana:
        'Dirisa taolo ya disenyi pele le ka nako ya thobo go fokotsa tshenyegelo ya dijalo.',
  },
  'tip_field_proper_handling': {
    AppLanguage.english:
        'Handle produce gently during harvest — avoid dropping or throwing.',
    AppLanguage.setswana:
        'Tshwara dijalo ka kelotlhoko ka nako ya thobo — tila go latlhela kgotsa go tshola.',
  },
  'tip_transport_proper_containers': {
    AppLanguage.english:
        'Use clean, rigid containers (crates, baskets) instead of sacks to prevent crushing.',
    AppLanguage.setswana:
        'Dirisa ditshipi tse di phepa (dikerese, ditlatla) go na le mekotla go thibela go pitlagana.',
  },
  'tip_transport_minimize_distance': {
    AppLanguage.english:
        'Minimize transport time and distance. Sell or process closer to the farm.',
    AppLanguage.setswana:
        'Fokotsa nako le sebaka sa dipalangwa. Rekisa kgotsa dirisa gaufi le polasa.',
  },
  'tip_transport_avoid_heat': {
    AppLanguage.english:
        'Transport during cooler hours (early morning or evening) to reduce spoilage.',
    AppLanguage.setswana:
        'Rwala ka dinako tse di tsididi (phakela kgotsa mantsiboa) go fokotsa go bolela.',
  },
  'tip_storage_dry_before_storing': {
    AppLanguage.english:
        'Dry crops to safe moisture levels before storing (e.g., 13% for grains).',
    AppLanguage.setswana:
        'Omisa dijalo go ya maemong a a babalesegileng a monola pele ga polokelo (sekao, 13% go mabele).',
  },
  'tip_storage_use_hermetic': {
    AppLanguage.english:
        'Use hermetic (airtight) storage bags or containers to prevent pests and mould.',
    AppLanguage.setswana:
        'Dirisa mekotla kgotsa ditshipi tse di tswalwang ka botlalo go thibela disenyi le mofufutso.',
  },
  'tip_storage_check_regularly': {
    AppLanguage.english:
        'Inspect stored produce regularly for signs of pests, mould, or moisture.',
    AppLanguage.setswana:
        'Tlhola dithoto tse di bolokwileng ka metlha go bona matshwao a disenyi, mofufutso, kgotsa monola.',
  },
  'tip_storage_upgrade_method': {
    AppLanguage.english:
        'Consider upgrading from open-air/traditional to improved or hermetic storage.',
    AppLanguage.setswana:
        'Akanya go tokafatsa go tswa mo polokelong ya setso go ya go e e tokafaditsweng kgotsa ya hermetic.',
  },
  'tip_processing_calibrate_equipment': {
    AppLanguage.english:
        'Calibrate threshing and milling equipment to minimize grain breakage.',
    AppLanguage.setswana:
        'Rulaganya didirisiwa tsa go photha le go sila go fokotsa go thubega ga mabele.',
  },
  'tip_processing_proper_drying': {
    AppLanguage.english:
        'Ensure proper drying before processing — wet grain shatters more easily.',
    AppLanguage.setswana:
        'Netefatsa go omisa sentle pele ga tiragatso — mabele a a metsi a thubega bonolo.',
  },
  'tip_processing_train_workers': {
    AppLanguage.english:
        'Train workers on gentle handling techniques to reduce spillage and waste.',
    AppLanguage.setswana:
        'Katisa badiri ka mekgwa ya go tshwara ka kelotlhoko go fokotsa go tshologa le mosenyi.',
  },
  'tip_general_record_losses': {
    AppLanguage.english:
        'Recording losses regularly helps identify patterns and areas for improvement.',
    AppLanguage.setswana:
        'Go kwala ditshenyegelo ka metlha go thusa go lemoga mekgwa le mafelo a tokafatso.',
  },
  'list_on_marketplace': {
    AppLanguage.english: 'List on Marketplace',
    AppLanguage.setswana: 'Romela mo Marketplace',
  },
  'listed_on_marketplace': {
    AppLanguage.english: 'Listed on Marketplace',
    AppLanguage.setswana: 'E romeletswe mo Marketplace',
  },
  'unlist': {AppLanguage.english: 'Unlist', AppLanguage.setswana: 'Ntsha'},
  'unlist_confirm': {
    AppLanguage.english:
        'Are you sure you want to remove this item from the marketplace?',
    AppLanguage.setswana:
        'A o tlhomamisegile gore o batla go ntsha seno mo marketplace?',
  },
  'listing_from_inventory': {
    AppLanguage.english:
        'Pre-filled from your inventory. Review and set a price.',
    AppLanguage.setswana:
        'E tladitswe go tswa mo inventory ya gago. Sekaseka o bo o beye tlhwatlhwa.',
  },
  'listed': {
    AppLanguage.english: 'Listed',
    AppLanguage.setswana: 'E romeletswe',
  },
  'unlisted_success': {
    AppLanguage.english: 'Item removed from marketplace',
    AppLanguage.setswana: 'Seno se ntshitswe mo marketplace',
  },
  'manage_store_products': {
    AppLanguage.english: 'Manage your store products',
    AppLanguage.setswana: 'Laola ditlhagiso tsa lebenkele la gago',
  },
  'track_produce_stock': {
    AppLanguage.english: 'Track your produce stock',
    AppLanguage.setswana: 'Latela ditlhagiso tsa gago',
  },
  'total_items': {
    AppLanguage.english: 'Total Items',
    AppLanguage.setswana: 'Palogotlhe',
  },
  // Settings Screen
  'language': {AppLanguage.english: 'Language', AppLanguage.setswana: 'Puo'},
  'account': {AppLanguage.english: 'Account', AppLanguage.setswana: 'Akhaonto'},
  'support': {
    AppLanguage.english: 'Support',
    AppLanguage.setswana: 'Tshegetso',
  },
  'delete_account': {
    AppLanguage.english: 'Delete Account',
    AppLanguage.setswana: 'Phimola Akhaonto',
  },
  'delete_account_warning': {
    AppLanguage.english:
        'This action cannot be undone. Deleting your account will permanently remove all your data, crops, inventory, and marketplace listings.',
    AppLanguage.setswana:
        'Tiro eno e ka se boelwe morago. Go phimola akhaonto ya gago go tla ntsha data yotlhe ya gago, dijalo, dithoto, le dilenaneo tsa mmaraka.',
  },
  'delete_permanent_warning': {
    AppLanguage.english:
        'This will permanently delete your account and all associated data. This action cannot be undone.',
    AppLanguage.setswana:
        'Se se tla phimola akhaonto ya gago le data yotlhe e e amanang. Tiro eno e ka se boelwe morago.',
  },
  'delete_account_confirm': {
    AppLanguage.english: 'DELETE ACCOUNT',
    AppLanguage.setswana: 'PHIMOLA AKHAONTO',
  },
  'continue_text': {
    AppLanguage.english: 'Continue',
    AppLanguage.setswana: 'Tswelela',
  },
  'final_confirmation': {
    AppLanguage.english: 'Final Confirmation',
    AppLanguage.setswana: 'Tlhomamiso ya Bofelo',
  },
  'no_email_error': {
    AppLanguage.english: 'No email address associated with this account',
    AppLanguage.setswana: 'Ga go na imeile e e amanang le akhaonto eno',
  },
  'password_reset_message': {
    AppLanguage.english:
        'We will send a password reset link to your email address:',
    AppLanguage.setswana:
        'Re tla romela linki ya go fetola phasewete go imeile ya gago:',
  },
  'reset_failed': {
    AppLanguage.english: 'Failed to send reset email',
    AppLanguage.setswana: 'Go padile go romela imeile ya go fetola',
  },
  'reset_email_sent': {
    AppLanguage.english: 'Password reset email sent! Check your inbox.',
    AppLanguage.setswana:
        'Imeile ya go fetola phasewete e rometswe! Tlhola inbox ya gago.',
  },
  'send_reset_link': {
    AppLanguage.english: 'Send Reset Link',
    AppLanguage.setswana: 'Romela Linki ya go Fetola',
  },
  // Reports Screen
  'farm_overview': {
    AppLanguage.english: 'Farm Overview',
    AppLanguage.setswana: 'Kakaretso ya Polasa',
  },
  'business_overview': {
    AppLanguage.english: 'Business Overview',
    AppLanguage.setswana: 'Kakaretso ya Kgwebo',
  },
  'active_crops': {
    AppLanguage.english: 'Active Crops',
    AppLanguage.setswana: 'Dijalo tse di Dirang',
  },
  'harvested': {
    AppLanguage.english: 'Harvested',
    AppLanguage.setswana: 'Tse di Roobilweng',
  },
  'field_summary': {
    AppLanguage.english: 'Field Summary',
    AppLanguage.setswana: 'Kakaretso ya Masimo',
  },
  'total_field_size': {
    AppLanguage.english: 'Total Field Size',
    AppLanguage.setswana: 'Bogolo Jotlhe jwa Masimo',
  },
  'inventory_items': {
    AppLanguage.english: 'Inventory Items',
    AppLanguage.setswana: 'Dithoto tsa Polokelo',
  },
  'items_need_attention': {
    AppLanguage.english: 'Items Need Attention',
    AppLanguage.setswana: 'Dilo tse di Tlhokang Tlhokomelo',
  },
  'marketplace_listings': {
    AppLanguage.english: 'Marketplace Listings',
    AppLanguage.setswana: 'Dilenaneo tsa Mmaraka',
  },
  'financial_summary': {
    AppLanguage.english: 'Financial Summary',
    AppLanguage.setswana: 'Kakaretso ya Madi',
  },
  'total_revenue': {
    AppLanguage.english: 'Total Revenue',
    AppLanguage.setswana: 'Lotseno Lotlhe',
  },
  'total_purchase_value': {
    AppLanguage.english: 'Total Purchase Value',
    AppLanguage.setswana: 'Boleng Jotlhe jwa Ditheko',
  },
  'inventory_summary': {
    AppLanguage.english: 'Inventory Summary',
    AppLanguage.setswana: 'Kakaretso ya Dithoto',
  },
  'offlineModeTitle': {
    AppLanguage.english: 'Offline Mode',
    AppLanguage.setswana: 'Mokgwa wa go sa Golagana',
  },
  'offlineModeToggle': {
    AppLanguage.english: 'Enable offline mode',
    AppLanguage.setswana: 'Dumela mokgwa wa go sa golagana',
  },
  'offlineModeDesc': {
    AppLanguage.english:
        'Save data locally to work without internet. Uses a small amount of phone storage.',
    AppLanguage.setswana:
        'Boloka data mono go dira ntle le inthanete. E dirisa bogolo bo bonnye jwa polokelo.',
  },
  'cacheSize': {
    AppLanguage.english: 'Cached data size',
    AppLanguage.setswana: 'Bogolo jwa data e e bolokilweng',
  },
  'clearCache': {
    AppLanguage.english: 'Clear cached data',
    AppLanguage.setswana: 'Tlosa data e e bolokilweng',
  },
  'clearCacheWarning': {
    AppLanguage.english:
        'This will delete all locally saved data. Any unsynced changes will be lost.',
    AppLanguage.setswana:
        'Se se tla tlosa data yotlhe e e bolokilweng mono. Diphetogo tse di sa romelelwang di tla latlhega.',
  },
  'cacheCleared': {
    AppLanguage.english: 'Cached data cleared',
    AppLanguage.setswana: 'Data e e bolokilweng e tlositswe',
  },
  'offlineMode': {
    AppLanguage.english: 'You are offline',
    AppLanguage.setswana: 'Ga o a golagana le inthanete',
  },
  'pendingChanges': {
    AppLanguage.english: 'pending changes',
    AppLanguage.setswana: 'diphetogo tse di emetseng',
  },
  'checkingConnection': {
    AppLanguage.english: 'Checking connection...',
    AppLanguage.setswana: 'Go lekola kgolagano...',
  },
  'offlineNotAvailable': {
    AppLanguage.english: 'This action requires an internet connection',
    AppLanguage.setswana: 'Tiro eno e tlhoka kgolagano ya inthanete',
  },
  'changesSaved': {
    AppLanguage.english: 'Changes saved locally, will sync when online',
    AppLanguage.setswana:
        'Diphetogo di boloketswe mono, di tla romelwa fa o golagana',
  },
  // Data export
  'export_data': {
    AppLanguage.english: 'Export Data',
    AppLanguage.setswana: 'Romela Tshedimosetso',
  },
  'select_format': {
    AppLanguage.english: 'Select Format',
    AppLanguage.setswana: 'Tlhopha Sebopego',
  },
  'select_data': {
    AppLanguage.english: 'Select Data to Export',
    AppLanguage.setswana: 'Tlhopha Tshedimosetso go Romela',
  },
  'crops_report': {
    AppLanguage.english: 'Crops',
    AppLanguage.setswana: 'Dijalo',
  },
  'inventory_report': {
    AppLanguage.english: 'Inventory',
    AppLanguage.setswana: 'Setoko',
  },
  'purchases_report': {
    AppLanguage.english: 'Purchases',
    AppLanguage.setswana: 'Ditheko',
  },
  'orders_report': {
    AppLanguage.english: 'Orders',
    AppLanguage.setswana: 'Di-odara',
  },
  'farm_summary': {
    AppLanguage.english: 'Farm Summary',
    AppLanguage.setswana: 'Kakaretso ya Polasi',
  },
  'business_summary': {
    AppLanguage.english: 'Business Summary',
    AppLanguage.setswana: 'Kakaretso ya Kgwebo',
  },
  'export_success': {
    AppLanguage.english: 'Export ready',
    AppLanguage.setswana: 'Pego e siame',
  },
  'export_error': {
    AppLanguage.english: 'Export failed',
    AppLanguage.setswana: 'Pego e paletswe',
  },
  'generating_report': {
    AppLanguage.english: 'Generating report...',
    AppLanguage.setswana: 'Go dira pego...',
  },
  'no_data_to_export': {
    AppLanguage.english: 'No data to export',
    AppLanguage.setswana: 'Ga go na tshedimosetso go romela',
  },
  'generated_on': {
    AppLanguage.english: 'Generated on',
    AppLanguage.setswana: 'E dirilwe ka',
  },
  'seller': {AppLanguage.english: 'Seller', AppLanguage.setswana: 'Morekisi'},
  'price_per_unit': {
    AppLanguage.english: 'Price per Unit',
    AppLanguage.setswana: 'Tlhwatlhwa ka Yuniti',
  },
  'total_amount': {
    AppLanguage.english: 'Total Amount',
    AppLanguage.setswana: 'Palogotlhe',
  },
  'purchase_date': {
    AppLanguage.english: 'Purchase Date',
    AppLanguage.setswana: 'Letsatsi la Theko',
  },
  'order_id': {
    AppLanguage.english: 'Order ID',
    AppLanguage.setswana: 'Nomoro ya Odara',
  },
  // Loss Calculator — history & save
  'history': {
    AppLanguage.english: 'History',
    AppLanguage.setswana: 'Hisitori',
  },
  'loss_history': {
    AppLanguage.english: 'Loss History',
    AppLanguage.setswana: 'Hisitori ya Ditshenyegelo',
  },
  'no_saved_calculations': {
    AppLanguage.english: 'No saved calculations yet',
    AppLanguage.setswana: 'Ga go na dipalo tse di bolokilweng',
  },
  'save_results': {
    AppLanguage.english: 'Save Results',
    AppLanguage.setswana: 'Boloka Dipholo',
  },
  'saved': {
    AppLanguage.english: 'Saved',
    AppLanguage.setswana: 'E Bolokilwe',
  },
  'save_failed': {
    AppLanguage.english: 'Failed to save. Please try again.',
    AppLanguage.setswana: 'Go boloka go paletse. Leka gape.',
  },
  'delete_calculation': {
    AppLanguage.english: 'Delete Calculation',
    AppLanguage.setswana: 'Phimola Palo',
  },
  'delete_calculation_confirm': {
    AppLanguage.english: 'Are you sure you want to delete this calculation?',
    AppLanguage.setswana: 'A o tlhomamisegile gore o batla go phimola palo e?',
  },
};

String t(String key, AppLanguage lang) {
  return _localizedStrings[key]?[lang] ?? key;
}

enum AppLanguage { english, setswana }

class LanguageNotifier extends StateNotifier<AppLanguage> {
  final Ref _ref;

  LanguageNotifier(this._ref) : super(AppLanguage.english) {
    _loadLanguage();
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'language_code',
      language == AppLanguage.setswana ? 'tn' : 'en',
    );
    await prefs.setBool('has_seen_welcome', true);
    developer.log(
      '✅ LANGUAGE SET: ${language.name}, has_seen_welcome = true',
      name: 'LanguageProvider',
    );

    // Update the initialization provider synchronously
    _ref
        .read(appInitializationProvider.notifier)
        .updateFlag(hasSeenWelcome: true);
    developer.log(
      '🔄 UPDATED: appInitializationProvider (hasSeenWelcome: true)',
      name: 'LanguageProvider',
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
