import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Hello World'**
  String get title;

  /// Message for the home page
  ///
  /// In en, this message translates to:
  /// **'Welcome to Flutter Internationalization'**
  String get message;

  /// Description of LEAV environment
  ///
  /// In en, this message translates to:
  /// **'LEAV Environments'**
  String get environmentLeav;

  /// To monitor environmental variables
  ///
  /// In en, this message translates to:
  /// **'Monitor'**
  String get monitor;

  /// Charts
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get charts;

  /// To program environments
  ///
  /// In en, this message translates to:
  /// **'Program'**
  String get program;

  /// Blue color intensity in µmol/m²/s
  ///
  /// In en, this message translates to:
  /// **'Blue Intensity [PPFD]'**
  String get ppfdBlue;

  /// White color intensity in µmol/m²/s
  ///
  /// In en, this message translates to:
  /// **'White Intensity [PPFD]'**
  String get ppfdWhite;

  /// RBW color intensity in µmol/m²/s
  ///
  /// In en, this message translates to:
  /// **'RBW Intensity [PPFD]'**
  String get ppfdRBW;

  /// Red color intensity in µmol/m²/s
  ///
  /// In en, this message translates to:
  /// **'Red Intensity [PPFD]'**
  String get ppfdRed;

  /// Blue LED dimming in percentage
  ///
  /// In en, this message translates to:
  /// **'Blue Dimming [%]'**
  String get dimBlue;

  /// White LED dimming in percentage
  ///
  /// In en, this message translates to:
  /// **'White Dimming [%]'**
  String get dimWhite;

  /// RBW LED dimming in percentage
  ///
  /// In en, this message translates to:
  /// **'RBW Dimming [%]'**
  String get dimRBW;

  /// Red LED dimming in percentage
  ///
  /// In en, this message translates to:
  /// **'Red Dimming [%]'**
  String get dimRed;

  /// Ambient temperature, reading made by DHT 22 sensor
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// Ambient humidity, reading made by DHT 22 sensor
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// Way of measuring the proportion of carbon dioxide molecules relative to all other molecules in the environment
  ///
  /// In en, this message translates to:
  /// **'PPM CO2'**
  String get ppmCo2;

  /// Energy measured in kWh in the protected environment
  ///
  /// In en, this message translates to:
  /// **'Energy (kWh)'**
  String get kWh;

  /// Power in Watts, used in the system
  ///
  /// In en, this message translates to:
  /// **'Power (W)'**
  String get watts;

  /// Received signal strength indicator
  ///
  /// In en, this message translates to:
  /// **'WIFI Network'**
  String get wifi;

  /// Power factor of LED luminaires
  ///
  /// In en, this message translates to:
  /// **'Power Factor'**
  String get factorPower;

  /// Sensor did not send information... Waiting
  ///
  /// In en, this message translates to:
  /// **'Sensor did not send information... Waiting'**
  String get waitSensor;

  /// Start date and time
  ///
  /// In en, this message translates to:
  /// **'Start Date and Time'**
  String get dateTimeSearchInit;

  /// End date and time
  ///
  /// In en, this message translates to:
  /// **'End Date and Time'**
  String get dateTimeSearchEnd;

  /// Select
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selected;

  /// Synchronized
  ///
  /// In en, this message translates to:
  /// **'Synchronized'**
  String get synchronized;

  /// Synchronizing
  ///
  /// In en, this message translates to:
  /// **'Synchronizing'**
  String get synchronizing;

  /// Off
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// On
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// Automatic
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// Reset the kWh
  ///
  /// In en, this message translates to:
  /// **'Reset the kWh'**
  String get resetKwh;

  /// Program Environment
  ///
  /// In en, this message translates to:
  /// **'Program Environment'**
  String get programEnvironment;

  /// Gaussian
  ///
  /// In en, this message translates to:
  /// **'Gaussian'**
  String get gaussian;

  /// Constant
  ///
  /// In en, this message translates to:
  /// **'Constant'**
  String get constant;

  /// Mean (μ)
  ///
  /// In en, this message translates to:
  /// **'Mean (μ)'**
  String get mean;

  /// Sigma (σ)
  ///
  /// In en, this message translates to:
  /// **'Sigma (σ)'**
  String get sigma;

  /// Max Intensity
  ///
  /// In en, this message translates to:
  /// **'Max Intensity'**
  String get maxIntensity;

  /// Min Intensity
  ///
  /// In en, this message translates to:
  /// **'Min Intensity'**
  String get minIntensity;

  /// Start
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// End
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// Daily Light Integral (DLI)
  ///
  /// In en, this message translates to:
  /// **'Daily Light Integral (DLI)'**
  String get dailyLightIntegral;

  /// Constant Equivalent Intensity (CEI)
  ///
  /// In en, this message translates to:
  /// **'Constant Equivalent Intensity (CEI)'**
  String get constantEquivalentIntensity;

  /// Save to Board
  ///
  /// In en, this message translates to:
  /// **'Save to Board'**
  String get saveToBoard;

  /// Label for the light panel
  ///
  /// In en, this message translates to:
  /// **'Light Panel'**
  String get lightPanel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
