import 'package:miro_hybrid/core/database/app_database.dart';
import 'package:miro_hybrid/l10n/app_localizations.dart';

String mealTypeLabel(MealType type, L10n l10n) {
  switch (type) {
    case MealType.breakfast:
      return l10n.mealBreakfast;
    case MealType.lunch:
      return l10n.mealLunch;
    case MealType.dinner:
      return l10n.mealDinner;
    case MealType.snack:
      return l10n.mealSnack;
  }
}
