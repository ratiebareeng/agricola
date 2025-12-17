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
  'select_village': {
    AppLanguage.english: 'Select your village',
    AppLanguage.setswana: 'Tlhopha motse wa gago',
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
  'Cowpeas': {AppLanguage.english: 'Cowpeas', AppLanguage.setswana: 'Letlhodi'},
  'Groundnuts': {
    AppLanguage.english: 'Groundnuts',
    AppLanguage.setswana: 'Ditloo',
  },
  'Carrots': {
    AppLanguage.english: 'Carrots',
    AppLanguage.setswana: 'Dikerotse',
  },
  'Peppers': {
    AppLanguage.english: 'Peppers',
    AppLanguage.setswana: 'Dipelepele',
  },
  'Butternut': {
    AppLanguage.english: 'Butternut',
    AppLanguage.setswana: 'Batanate',
  },
  'Pumpkin': {AppLanguage.english: 'Pumpkin', AppLanguage.setswana: 'Mophuthi'},
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
  'profile': {AppLanguage.english: 'Profile', AppLanguage.setswana: 'Omang'},
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
  // Crop Types
  'maize': {AppLanguage.english: 'Maize', AppLanguage.setswana: 'Mmidi'},
  'sorghum': {AppLanguage.english: 'Sorghum', AppLanguage.setswana: 'Mabele'},
  'beans': {AppLanguage.english: 'Beans', AppLanguage.setswana: 'Dinawa'},
  'cowpeas': {AppLanguage.english: 'Cowpeas', AppLanguage.setswana: 'Letlhodi'},
  'melons': {AppLanguage.english: 'Melons', AppLanguage.setswana: 'Marotse'},
  'other': {AppLanguage.english: 'Other', AppLanguage.setswana: 'Tse Dingwe'},
  // Units
  'hectares': {
    AppLanguage.english: 'Hectares',
    AppLanguage.setswana: 'Di-Hectare',
  },
  'acres': {AppLanguage.english: 'Acres', AppLanguage.setswana: 'Di-Acre'},
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
  'growing': {AppLanguage.english: 'Growing', AppLanguage.setswana: 'E a Gola'},
  'ready': {AppLanguage.english: 'Ready', AppLanguage.setswana: 'E Siametse'},
  'harvested': {
    AppLanguage.english: 'Harvested',
    AppLanguage.setswana: 'E Thobilwe',
  },
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
  'edit': {AppLanguage.english: 'Edit', AppLanguage.setswana: 'Baakanya'},
  'delete': {AppLanguage.english: 'Delete', AppLanguage.setswana: 'Phimola'},
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
    AppLanguage.english: 'Add your first harvest to start tracking',
    AppLanguage.setswana: 'Tsenya thobo ya gago ya ntlha go simolola go latela',
  },
  'quantity': {
    AppLanguage.english: 'Quantity',
    AppLanguage.setswana: 'Selekanyo',
  },
  'location': {AppLanguage.english: 'Location', AppLanguage.setswana: 'Lefelo'},
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
    AppLanguage.english: 'Clear',
    AppLanguage.setswana: 'Phimola',
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
