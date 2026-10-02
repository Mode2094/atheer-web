import 'package:flutter/widgets.dart';
import 'package:perfume/l10n/app_localizations.dart';

extension LocalizationHelper on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;

  String localizeQuestion(String key) {
    switch (key) {
      case 'question1':
        return loc.question1;
      case 'question2':
        return loc.question2;
      case 'question3':
        return loc.question3;
      case 'question4':
        return loc.question4;
      case 'question5':
        return loc.question5;
      case 'question6':
        return loc.question6;
      case 'question7':
        return loc.question7;
      case 'question8':
        return loc.question8;
      case 'question9':
        return loc.question9;
      case 'question10':
        return loc.question10;
      case 'question11':
        return loc.question11;
      case 'question12':
        return loc.question12;
      case 'question13':
        return loc.question13;
      case 'question14':
        return loc.question14;
      case 'question15':
        return loc.question15;
      default:
        return key;
    }
  }

  String localizeOption(String key) {
    switch (key) {
      case 'answer_yes':
        return loc.answerYes;
      case 'answer_no':
        return loc.answerNo;
      case 'answer_sometimes':
        return loc.answerSometimes;
      case 'answer_medium':
        return loc.answerMedium;
      case 'usage_daily':
        return loc.usageDaily;
      case 'usage_work':
        return loc.usageWork;
      case 'usage_events':
        return loc.usageEvents;
      case 'usage_evening':
        return loc.usageEvening;
      case 'impression_luxurious':
        return loc.impressionLuxurious;
      case 'impression_charming':
        return loc.impressionCharming;
      case 'impression_elegant':
        return loc.impressionElegant;
      case 'impression_calm':
        return loc.impressionCalm;
      default:
        return key;
    }
  }
}
