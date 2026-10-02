import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Perfume Recommendation System'**
  String get appName;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @idealPerfume.
  ///
  /// In en, this message translates to:
  /// **'Your Ideal Perfume'**
  String get idealPerfume;

  /// No description provided for @analysisComplete.
  ///
  /// In en, this message translates to:
  /// **'Analysis Complete'**
  String get analysisComplete;

  /// No description provided for @findingPerfume.
  ///
  /// In en, this message translates to:
  /// **'Finding your ideal perfume...'**
  String get findingPerfume;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @sometimes.
  ///
  /// In en, this message translates to:
  /// **'Sometimes'**
  String get sometimes;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @questionCounterOf.
  ///
  /// In en, this message translates to:
  /// **'of {total}'**
  String questionCounterOf(int total);

  /// No description provided for @preferencesAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'We analyzed your preferences'**
  String get preferencesAnalyzed;

  /// No description provided for @seeRecommendation.
  ///
  /// In en, this message translates to:
  /// **'See your recommendation'**
  String get seeRecommendation;

  /// No description provided for @deviceNotConfiguredStore.
  ///
  /// In en, this message translates to:
  /// **'Device is not configured for any store'**
  String get deviceNotConfiguredStore;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get newCustomer;

  /// No description provided for @noRecommendationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No recommendations available'**
  String get noRecommendationsAvailable;

  /// No description provided for @suggestedPerfumesTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested Perfumes'**
  String get suggestedPerfumesTitle;

  /// No description provided for @selectPerfumeForSensorTest.
  ///
  /// In en, this message translates to:
  /// **'Select the perfume you want to test with the sensor'**
  String get selectPerfumeForSensorTest;

  /// No description provided for @restartTest.
  ///
  /// In en, this message translates to:
  /// **'Restart Test'**
  String get restartTest;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorTitle;

  /// No description provided for @startTest.
  ///
  /// In en, this message translates to:
  /// **'Start Test'**
  String get startTest;

  /// No description provided for @neuralAnalysisResults.
  ///
  /// In en, this message translates to:
  /// **'Neural Analysis Results'**
  String get neuralAnalysisResults;

  /// No description provided for @interest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get interest;

  /// No description provided for @excitement.
  ///
  /// In en, this message translates to:
  /// **'Excitement'**
  String get excitement;

  /// No description provided for @relaxation.
  ///
  /// In en, this message translates to:
  /// **'Relaxation'**
  String get relaxation;

  /// No description provided for @engagement.
  ///
  /// In en, this message translates to:
  /// **'Engagement'**
  String get engagement;

  /// No description provided for @attention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get attention;

  /// No description provided for @stress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get stress;

  /// No description provided for @lowerStressHigherRelaxation.
  ///
  /// In en, this message translates to:
  /// **'* Lower stress = higher relaxation'**
  String get lowerStressHigherRelaxation;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get excellent;

  /// No description provided for @veryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get veryGood;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @guestPrefix.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestPrefix;

  /// No description provided for @question1.
  ///
  /// In en, this message translates to:
  /// **'Do you prefer trying new and unfamiliar things?'**
  String get question1;

  /// No description provided for @question2.
  ///
  /// In en, this message translates to:
  /// **'Do you prefer rare and unusual scents?'**
  String get question2;

  /// No description provided for @question3.
  ///
  /// In en, this message translates to:
  /// **'Do you like being the center of attention in social events?'**
  String get question3;

  /// No description provided for @question4.
  ///
  /// In en, this message translates to:
  /// **'Do you prefer strong and noticeable perfumes?'**
  String get question4;

  /// No description provided for @question5.
  ///
  /// In en, this message translates to:
  /// **'Are you quickly affected by your surroundings and mood?'**
  String get question5;

  /// No description provided for @question6.
  ///
  /// In en, this message translates to:
  /// **'Do you prefer calm and relaxing scents?'**
  String get question6;

  /// No description provided for @question7.
  ///
  /// In en, this message translates to:
  /// **'Do you prefer fresh scents like citrus?'**
  String get question7;

  /// No description provided for @question8.
  ///
  /// In en, this message translates to:
  /// **'Do you like sweet scents such as vanilla?'**
  String get question8;

  /// No description provided for @question9.
  ///
  /// In en, this message translates to:
  /// **'Do you prefer warm scents like amber and woods?'**
  String get question9;

  /// No description provided for @question10.
  ///
  /// In en, this message translates to:
  /// **'Do you like strong perfumes that last long?'**
  String get question10;

  /// No description provided for @question11.
  ///
  /// In en, this message translates to:
  /// **'When will you mostly use the perfume?'**
  String get question11;

  /// No description provided for @question12.
  ///
  /// In en, this message translates to:
  /// **'Do you want your perfume to be noticeable to others?'**
  String get question12;

  /// No description provided for @question13.
  ///
  /// In en, this message translates to:
  /// **'Do you prefer a long-lasting perfume?'**
  String get question13;

  /// No description provided for @question14.
  ///
  /// In en, this message translates to:
  /// **'How do you want others to perceive you?'**
  String get question14;

  /// No description provided for @question15.
  ///
  /// In en, this message translates to:
  /// **'Do you prefer luxurious and rare perfumes?'**
  String get question15;

  /// No description provided for @answerYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get answerYes;

  /// No description provided for @answerNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get answerNo;

  /// No description provided for @answerSometimes.
  ///
  /// In en, this message translates to:
  /// **'Sometimes'**
  String get answerSometimes;

  /// No description provided for @answerMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get answerMedium;

  /// No description provided for @usageDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get usageDaily;

  /// No description provided for @usageWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get usageWork;

  /// No description provided for @usageEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get usageEvents;

  /// No description provided for @usageEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get usageEvening;

  /// No description provided for @impressionLuxurious.
  ///
  /// In en, this message translates to:
  /// **'Luxurious'**
  String get impressionLuxurious;

  /// No description provided for @impressionCharming.
  ///
  /// In en, this message translates to:
  /// **'Charming'**
  String get impressionCharming;

  /// No description provided for @impressionElegant.
  ///
  /// In en, this message translates to:
  /// **'Elegant'**
  String get impressionElegant;

  /// No description provided for @impressionCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get impressionCalm;

  /// No description provided for @usersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersTitle;

  /// No description provided for @noUsersYet.
  ///
  /// In en, this message translates to:
  /// **'No users yet'**
  String get noUsersYet;

  /// No description provided for @userDetailsFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get userDetailsFallbackTitle;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfo;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @registrationDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Registration Date'**
  String get registrationDateLabel;

  /// No description provided for @personalityAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Personality Analysis'**
  String get personalityAnalysis;

  /// No description provided for @sensoryPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sensory Preferences'**
  String get sensoryPreferencesTitle;

  /// No description provided for @recommendationHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommendation History'**
  String get recommendationHistoryTitle;

  /// No description provided for @noPreviousRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No previous recommendations'**
  String get noPreviousRecommendations;

  /// No description provided for @unspecifiedValue.
  ///
  /// In en, this message translates to:
  /// **'Unspecified'**
  String get unspecifiedValue;

  /// No description provided for @unknownValue.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownValue;

  /// No description provided for @traitOpenness.
  ///
  /// In en, this message translates to:
  /// **'Openness'**
  String get traitOpenness;

  /// No description provided for @traitExtraversion.
  ///
  /// In en, this message translates to:
  /// **'Extraversion'**
  String get traitExtraversion;

  /// No description provided for @traitNeuroticism.
  ///
  /// In en, this message translates to:
  /// **'Neuroticism'**
  String get traitNeuroticism;

  /// No description provided for @traitFreshness.
  ///
  /// In en, this message translates to:
  /// **'Freshness'**
  String get traitFreshness;

  /// No description provided for @traitSweetness.
  ///
  /// In en, this message translates to:
  /// **'Sweetness'**
  String get traitSweetness;

  /// No description provided for @traitWarmth.
  ///
  /// In en, this message translates to:
  /// **'Warmth'**
  String get traitWarmth;

  /// No description provided for @traitIntensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get traitIntensity;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailable;

  /// No description provided for @recommendationsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recommendations'**
  String recommendationsCount(int count);
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
