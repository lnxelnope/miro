// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FoodEntriesTable extends FoodEntries
    with TableInfo<$FoodEntriesTable, FoodEntryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _foodNameMeta =
      const VerificationMeta('foodName');
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
      'food_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _foodNameEnMeta =
      const VerificationMeta('foodNameEn');
  @override
  late final GeneratedColumn<String> foodNameEn = GeneratedColumn<String>(
      'food_name_en', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<MealType, int> mealType =
      GeneratedColumn<int>('meal_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<MealType>($FoodEntriesTable.$convertermealType);
  static const VerificationMeta _servingSizeMeta =
      const VerificationMeta('servingSize');
  @override
  late final GeneratedColumn<double> servingSize = GeneratedColumn<double>(
      'serving_size', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _servingUnitMeta =
      const VerificationMeta('servingUnit');
  @override
  late final GeneratedColumn<String> servingUnit = GeneratedColumn<String>(
      'serving_unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _servingGramsMeta =
      const VerificationMeta('servingGrams');
  @override
  late final GeneratedColumn<double> servingGrams = GeneratedColumn<double>(
      'serving_grams', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _caloriesMeta =
      const VerificationMeta('calories');
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
      'calories', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _proteinMeta =
      const VerificationMeta('protein');
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
      'protein', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
      'carbs', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
      'fat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _baseCaloriesMeta =
      const VerificationMeta('baseCalories');
  @override
  late final GeneratedColumn<double> baseCalories = GeneratedColumn<double>(
      'base_calories', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _baseProteinMeta =
      const VerificationMeta('baseProtein');
  @override
  late final GeneratedColumn<double> baseProtein = GeneratedColumn<double>(
      'base_protein', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _baseCarbsMeta =
      const VerificationMeta('baseCarbs');
  @override
  late final GeneratedColumn<double> baseCarbs = GeneratedColumn<double>(
      'base_carbs', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _baseFatMeta =
      const VerificationMeta('baseFat');
  @override
  late final GeneratedColumn<double> baseFat = GeneratedColumn<double>(
      'base_fat', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<double> fiber = GeneratedColumn<double>(
      'fiber', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sugarMeta = const VerificationMeta('sugar');
  @override
  late final GeneratedColumn<double> sugar = GeneratedColumn<double>(
      'sugar', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sodiumMeta = const VerificationMeta('sodium');
  @override
  late final GeneratedColumn<double> sodium = GeneratedColumn<double>(
      'sodium', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _cholesterolMeta =
      const VerificationMeta('cholesterol');
  @override
  late final GeneratedColumn<double> cholesterol = GeneratedColumn<double>(
      'cholesterol', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _saturatedFatMeta =
      const VerificationMeta('saturatedFat');
  @override
  late final GeneratedColumn<double> saturatedFat = GeneratedColumn<double>(
      'saturated_fat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _transFatMeta =
      const VerificationMeta('transFat');
  @override
  late final GeneratedColumn<double> transFat = GeneratedColumn<double>(
      'trans_fat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _unsaturatedFatMeta =
      const VerificationMeta('unsaturatedFat');
  @override
  late final GeneratedColumn<double> unsaturatedFat = GeneratedColumn<double>(
      'unsaturated_fat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _monounsaturatedFatMeta =
      const VerificationMeta('monounsaturatedFat');
  @override
  late final GeneratedColumn<double> monounsaturatedFat =
      GeneratedColumn<double>('monounsaturated_fat', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _polyunsaturatedFatMeta =
      const VerificationMeta('polyunsaturatedFat');
  @override
  late final GeneratedColumn<double> polyunsaturatedFat =
      GeneratedColumn<double>('polyunsaturated_fat', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _potassiumMeta =
      const VerificationMeta('potassium');
  @override
  late final GeneratedColumn<double> potassium = GeneratedColumn<double>(
      'potassium', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DataSource, int> source =
      GeneratedColumn<int>('source', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DataSource>($FoodEntriesTable.$convertersource);
  @override
  late final GeneratedColumnWithTypeConverter<FoodSearchMode, int> searchMode =
      GeneratedColumn<int>('search_mode', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<FoodSearchMode>(
              $FoodEntriesTable.$convertersearchMode);
  static const VerificationMeta _aiConfidenceMeta =
      const VerificationMeta('aiConfidence');
  @override
  late final GeneratedColumn<double> aiConfidence = GeneratedColumn<double>(
      'ai_confidence', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isVerifiedMeta =
      const VerificationMeta('isVerified');
  @override
  late final GeneratedColumn<bool> isVerified = GeneratedColumn<bool>(
      'is_verified', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_verified" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _myMealIdMeta =
      const VerificationMeta('myMealId');
  @override
  late final GeneratedColumn<int> myMealId = GeneratedColumn<int>(
      'my_meal_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _ingredientIdMeta =
      const VerificationMeta('ingredientId');
  @override
  late final GeneratedColumn<int> ingredientId = GeneratedColumn<int>(
      'ingredient_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _groupSourceMeta =
      const VerificationMeta('groupSource');
  @override
  late final GeneratedColumn<String> groupSource = GeneratedColumn<String>(
      'group_source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _groupOrderMeta =
      const VerificationMeta('groupOrder');
  @override
  late final GeneratedColumn<int> groupOrder = GeneratedColumn<int>(
      'group_order', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isGroupOriginalMeta =
      const VerificationMeta('isGroupOriginal');
  @override
  late final GeneratedColumn<bool> isGroupOriginal = GeneratedColumn<bool>(
      'is_group_original', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_group_original" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _ingredientsJsonMeta =
      const VerificationMeta('ingredientsJson');
  @override
  late final GeneratedColumn<String> ingredientsJson = GeneratedColumn<String>(
      'ingredients_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userInputTextMeta =
      const VerificationMeta('userInputText');
  @override
  late final GeneratedColumn<String> userInputText = GeneratedColumn<String>(
      'user_input_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalFoodNameMeta =
      const VerificationMeta('originalFoodName');
  @override
  late final GeneratedColumn<String> originalFoodName = GeneratedColumn<String>(
      'original_food_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalFoodNameEnMeta =
      const VerificationMeta('originalFoodNameEn');
  @override
  late final GeneratedColumn<String> originalFoodNameEn =
      GeneratedColumn<String>('original_food_name_en', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalCaloriesMeta =
      const VerificationMeta('originalCalories');
  @override
  late final GeneratedColumn<double> originalCalories = GeneratedColumn<double>(
      'original_calories', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _originalProteinMeta =
      const VerificationMeta('originalProtein');
  @override
  late final GeneratedColumn<double> originalProtein = GeneratedColumn<double>(
      'original_protein', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _originalCarbsMeta =
      const VerificationMeta('originalCarbs');
  @override
  late final GeneratedColumn<double> originalCarbs = GeneratedColumn<double>(
      'original_carbs', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _originalFatMeta =
      const VerificationMeta('originalFat');
  @override
  late final GeneratedColumn<double> originalFat = GeneratedColumn<double>(
      'original_fat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _originalIngredientsJsonMeta =
      const VerificationMeta('originalIngredientsJson');
  @override
  late final GeneratedColumn<String> originalIngredientsJson =
      GeneratedColumn<String>('original_ingredients_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editCountMeta =
      const VerificationMeta('editCount');
  @override
  late final GeneratedColumn<int> editCount = GeneratedColumn<int>(
      'edit_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isUserCorrectedMeta =
      const VerificationMeta('isUserCorrected');
  @override
  late final GeneratedColumn<bool> isUserCorrected = GeneratedColumn<bool>(
      'is_user_corrected', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_user_corrected" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _correctionHistoryJsonMeta =
      const VerificationMeta('correctionHistoryJson');
  @override
  late final GeneratedColumn<String> correctionHistoryJson =
      GeneratedColumn<String>('correction_history_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _brandNameMeta =
      const VerificationMeta('brandName');
  @override
  late final GeneratedColumn<String> brandName = GeneratedColumn<String>(
      'brand_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _brandNameEnMeta =
      const VerificationMeta('brandNameEn');
  @override
  late final GeneratedColumn<String> brandNameEn = GeneratedColumn<String>(
      'brand_name_en', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _productBarcodeMeta =
      const VerificationMeta('productBarcode');
  @override
  late final GeneratedColumn<String> productBarcode = GeneratedColumn<String>(
      'product_barcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _netWeightMeta =
      const VerificationMeta('netWeight');
  @override
  late final GeneratedColumn<double> netWeight = GeneratedColumn<double>(
      'net_weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _netWeightUnitMeta =
      const VerificationMeta('netWeightUnit');
  @override
  late final GeneratedColumn<String> netWeightUnit = GeneratedColumn<String>(
      'net_weight_unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chainNameMeta =
      const VerificationMeta('chainName');
  @override
  late final GeneratedColumn<String> chainName = GeneratedColumn<String>(
      'chain_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _productCategoryMeta =
      const VerificationMeta('productCategory');
  @override
  late final GeneratedColumn<String> productCategory = GeneratedColumn<String>(
      'product_category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _packageSizeMeta =
      const VerificationMeta('packageSize');
  @override
  late final GeneratedColumn<String> packageSize = GeneratedColumn<String>(
      'package_size', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nutritionSourceMeta =
      const VerificationMeta('nutritionSource');
  @override
  late final GeneratedColumn<String> nutritionSource = GeneratedColumn<String>(
      'nutrition_source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sceneContextMeta =
      const VerificationMeta('sceneContext');
  @override
  late final GeneratedColumn<String> sceneContext = GeneratedColumn<String>(
      'scene_context', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _detectedObjectsJsonMeta =
      const VerificationMeta('detectedObjectsJson');
  @override
  late final GeneratedColumn<String> detectedObjectsJson =
      GeneratedColumn<String>('detected_objects_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _arBoundingBoxMeta =
      const VerificationMeta('arBoundingBox');
  @override
  late final GeneratedColumn<String> arBoundingBox = GeneratedColumn<String>(
      'ar_bounding_box', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _estimatedWidthCmMeta =
      const VerificationMeta('estimatedWidthCm');
  @override
  late final GeneratedColumn<double> estimatedWidthCm = GeneratedColumn<double>(
      'estimated_width_cm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _estimatedHeightCmMeta =
      const VerificationMeta('estimatedHeightCm');
  @override
  late final GeneratedColumn<double> estimatedHeightCm =
      GeneratedColumn<double>('estimated_height_cm', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _estimatedDepthCmMeta =
      const VerificationMeta('estimatedDepthCm');
  @override
  late final GeneratedColumn<double> estimatedDepthCm = GeneratedColumn<double>(
      'estimated_depth_cm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _referenceObjectUsedMeta =
      const VerificationMeta('referenceObjectUsed');
  @override
  late final GeneratedColumn<String> referenceObjectUsed =
      GeneratedColumn<String>('reference_object_used', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceConfidenceMeta =
      const VerificationMeta('referenceConfidence');
  @override
  late final GeneratedColumn<double> referenceConfidence =
      GeneratedColumn<double>('reference_confidence', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _plateDiameterCmMeta =
      const VerificationMeta('plateDiameterCm');
  @override
  late final GeneratedColumn<double> plateDiameterCm = GeneratedColumn<double>(
      'plate_diameter_cm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _estimatedVolumeMlMeta =
      const VerificationMeta('estimatedVolumeMl');
  @override
  late final GeneratedColumn<double> estimatedVolumeMl =
      GeneratedColumn<double>('estimated_volume_ml', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isCalibratedMeta =
      const VerificationMeta('isCalibrated');
  @override
  late final GeneratedColumn<bool> isCalibrated = GeneratedColumn<bool>(
      'is_calibrated', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_calibrated" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _arLabelsJsonMeta =
      const VerificationMeta('arLabelsJson');
  @override
  late final GeneratedColumn<String> arLabelsJson = GeneratedColumn<String>(
      'ar_labels_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _arImageWidthMeta =
      const VerificationMeta('arImageWidth');
  @override
  late final GeneratedColumn<double> arImageWidth = GeneratedColumn<double>(
      'ar_image_width', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _arImageHeightMeta =
      const VerificationMeta('arImageHeight');
  @override
  late final GeneratedColumn<double> arImageHeight = GeneratedColumn<double>(
      'ar_image_height', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _arPixelPerCmMeta =
      const VerificationMeta('arPixelPerCm');
  @override
  late final GeneratedColumn<double> arPixelPerCm = GeneratedColumn<double>(
      'ar_pixel_per_cm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _healthConnectIdMeta =
      const VerificationMeta('healthConnectId');
  @override
  late final GeneratedColumn<String> healthConnectId = GeneratedColumn<String>(
      'health_connect_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _firebaseDocIdMeta =
      const VerificationMeta('firebaseDocId');
  @override
  late final GeneratedColumn<String> firebaseDocId = GeneratedColumn<String>(
      'firebase_doc_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncAtMeta =
      const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
      'last_sync_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailUrlMeta =
      const VerificationMeta('thumbnailUrl');
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
      'thumbnail_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailFirebasePathMeta =
      const VerificationMeta('thumbnailFirebasePath');
  @override
  late final GeneratedColumn<String> thumbnailFirebasePath =
      GeneratedColumn<String>('thumbnail_firebase_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vitaminAMeta =
      const VerificationMeta('vitaminA');
  @override
  late final GeneratedColumn<double> vitaminA = GeneratedColumn<double>(
      'vitamin_a', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _vitaminCMeta =
      const VerificationMeta('vitaminC');
  @override
  late final GeneratedColumn<double> vitaminC = GeneratedColumn<double>(
      'vitamin_c', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _vitaminDMeta =
      const VerificationMeta('vitaminD');
  @override
  late final GeneratedColumn<double> vitaminD = GeneratedColumn<double>(
      'vitamin_d', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _vitaminEMeta =
      const VerificationMeta('vitaminE');
  @override
  late final GeneratedColumn<double> vitaminE = GeneratedColumn<double>(
      'vitamin_e', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _vitaminKMeta =
      const VerificationMeta('vitaminK');
  @override
  late final GeneratedColumn<double> vitaminK = GeneratedColumn<double>(
      'vitamin_k', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _thiaminMeta =
      const VerificationMeta('thiamin');
  @override
  late final GeneratedColumn<double> thiamin = GeneratedColumn<double>(
      'thiamin', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _riboflavinMeta =
      const VerificationMeta('riboflavin');
  @override
  late final GeneratedColumn<double> riboflavin = GeneratedColumn<double>(
      'riboflavin', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _niacinMeta = const VerificationMeta('niacin');
  @override
  late final GeneratedColumn<double> niacin = GeneratedColumn<double>(
      'niacin', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _vitaminB6Meta =
      const VerificationMeta('vitaminB6');
  @override
  late final GeneratedColumn<double> vitaminB6 = GeneratedColumn<double>(
      'vitamin_b6', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _folateMeta = const VerificationMeta('folate');
  @override
  late final GeneratedColumn<double> folate = GeneratedColumn<double>(
      'folate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _vitaminB12Meta =
      const VerificationMeta('vitaminB12');
  @override
  late final GeneratedColumn<double> vitaminB12 = GeneratedColumn<double>(
      'vitamin_b12', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _calciumMeta =
      const VerificationMeta('calcium');
  @override
  late final GeneratedColumn<double> calcium = GeneratedColumn<double>(
      'calcium', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _ironMeta = const VerificationMeta('iron');
  @override
  late final GeneratedColumn<double> iron = GeneratedColumn<double>(
      'iron', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _magnesiumMeta =
      const VerificationMeta('magnesium');
  @override
  late final GeneratedColumn<double> magnesium = GeneratedColumn<double>(
      'magnesium', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _phosphorusMeta =
      const VerificationMeta('phosphorus');
  @override
  late final GeneratedColumn<double> phosphorus = GeneratedColumn<double>(
      'phosphorus', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _zincMeta = const VerificationMeta('zinc');
  @override
  late final GeneratedColumn<double> zinc = GeneratedColumn<double>(
      'zinc', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        foodName,
        foodNameEn,
        timestamp,
        imagePath,
        mealType,
        servingSize,
        servingUnit,
        servingGrams,
        calories,
        protein,
        carbs,
        fat,
        baseCalories,
        baseProtein,
        baseCarbs,
        baseFat,
        fiber,
        sugar,
        sodium,
        cholesterol,
        saturatedFat,
        transFat,
        unsaturatedFat,
        monounsaturatedFat,
        polyunsaturatedFat,
        potassium,
        source,
        searchMode,
        aiConfidence,
        isVerified,
        isDeleted,
        notes,
        myMealId,
        ingredientId,
        groupId,
        groupSource,
        groupOrder,
        isGroupOriginal,
        ingredientsJson,
        userInputText,
        originalFoodName,
        originalFoodNameEn,
        originalCalories,
        originalProtein,
        originalCarbs,
        originalFat,
        originalIngredientsJson,
        editCount,
        isUserCorrected,
        correctionHistoryJson,
        brandName,
        brandNameEn,
        productName,
        productBarcode,
        netWeight,
        netWeightUnit,
        chainName,
        productCategory,
        packageSize,
        nutritionSource,
        sceneContext,
        detectedObjectsJson,
        arBoundingBox,
        estimatedWidthCm,
        estimatedHeightCm,
        estimatedDepthCm,
        referenceObjectUsed,
        referenceConfidence,
        plateDiameterCm,
        estimatedVolumeMl,
        isCalibrated,
        arLabelsJson,
        arImageWidth,
        arImageHeight,
        arPixelPerCm,
        healthConnectId,
        syncedAt,
        isSynced,
        firebaseDocId,
        lastSyncAt,
        thumbnailUrl,
        thumbnailFirebasePath,
        vitaminA,
        vitaminC,
        vitaminD,
        vitaminE,
        vitaminK,
        thiamin,
        riboflavin,
        niacin,
        vitaminB6,
        folate,
        vitaminB12,
        calcium,
        iron,
        magnesium,
        phosphorus,
        zinc,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_entries';
  @override
  VerificationContext validateIntegrity(Insertable<FoodEntryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('food_name')) {
      context.handle(_foodNameMeta,
          foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta));
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('food_name_en')) {
      context.handle(
          _foodNameEnMeta,
          foodNameEn.isAcceptableOrUnknown(
              data['food_name_en']!, _foodNameEnMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('serving_size')) {
      context.handle(
          _servingSizeMeta,
          servingSize.isAcceptableOrUnknown(
              data['serving_size']!, _servingSizeMeta));
    } else if (isInserting) {
      context.missing(_servingSizeMeta);
    }
    if (data.containsKey('serving_unit')) {
      context.handle(
          _servingUnitMeta,
          servingUnit.isAcceptableOrUnknown(
              data['serving_unit']!, _servingUnitMeta));
    } else if (isInserting) {
      context.missing(_servingUnitMeta);
    }
    if (data.containsKey('serving_grams')) {
      context.handle(
          _servingGramsMeta,
          servingGrams.isAcceptableOrUnknown(
              data['serving_grams']!, _servingGramsMeta));
    }
    if (data.containsKey('calories')) {
      context.handle(_caloriesMeta,
          calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta));
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(_proteinMeta,
          protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta));
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
          _carbsMeta, carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta));
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
          _fatMeta, fat.isAcceptableOrUnknown(data['fat']!, _fatMeta));
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('base_calories')) {
      context.handle(
          _baseCaloriesMeta,
          baseCalories.isAcceptableOrUnknown(
              data['base_calories']!, _baseCaloriesMeta));
    }
    if (data.containsKey('base_protein')) {
      context.handle(
          _baseProteinMeta,
          baseProtein.isAcceptableOrUnknown(
              data['base_protein']!, _baseProteinMeta));
    }
    if (data.containsKey('base_carbs')) {
      context.handle(_baseCarbsMeta,
          baseCarbs.isAcceptableOrUnknown(data['base_carbs']!, _baseCarbsMeta));
    }
    if (data.containsKey('base_fat')) {
      context.handle(_baseFatMeta,
          baseFat.isAcceptableOrUnknown(data['base_fat']!, _baseFatMeta));
    }
    if (data.containsKey('fiber')) {
      context.handle(
          _fiberMeta, fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta));
    }
    if (data.containsKey('sugar')) {
      context.handle(
          _sugarMeta, sugar.isAcceptableOrUnknown(data['sugar']!, _sugarMeta));
    }
    if (data.containsKey('sodium')) {
      context.handle(_sodiumMeta,
          sodium.isAcceptableOrUnknown(data['sodium']!, _sodiumMeta));
    }
    if (data.containsKey('cholesterol')) {
      context.handle(
          _cholesterolMeta,
          cholesterol.isAcceptableOrUnknown(
              data['cholesterol']!, _cholesterolMeta));
    }
    if (data.containsKey('saturated_fat')) {
      context.handle(
          _saturatedFatMeta,
          saturatedFat.isAcceptableOrUnknown(
              data['saturated_fat']!, _saturatedFatMeta));
    }
    if (data.containsKey('trans_fat')) {
      context.handle(_transFatMeta,
          transFat.isAcceptableOrUnknown(data['trans_fat']!, _transFatMeta));
    }
    if (data.containsKey('unsaturated_fat')) {
      context.handle(
          _unsaturatedFatMeta,
          unsaturatedFat.isAcceptableOrUnknown(
              data['unsaturated_fat']!, _unsaturatedFatMeta));
    }
    if (data.containsKey('monounsaturated_fat')) {
      context.handle(
          _monounsaturatedFatMeta,
          monounsaturatedFat.isAcceptableOrUnknown(
              data['monounsaturated_fat']!, _monounsaturatedFatMeta));
    }
    if (data.containsKey('polyunsaturated_fat')) {
      context.handle(
          _polyunsaturatedFatMeta,
          polyunsaturatedFat.isAcceptableOrUnknown(
              data['polyunsaturated_fat']!, _polyunsaturatedFatMeta));
    }
    if (data.containsKey('potassium')) {
      context.handle(_potassiumMeta,
          potassium.isAcceptableOrUnknown(data['potassium']!, _potassiumMeta));
    }
    if (data.containsKey('ai_confidence')) {
      context.handle(
          _aiConfidenceMeta,
          aiConfidence.isAcceptableOrUnknown(
              data['ai_confidence']!, _aiConfidenceMeta));
    }
    if (data.containsKey('is_verified')) {
      context.handle(
          _isVerifiedMeta,
          isVerified.isAcceptableOrUnknown(
              data['is_verified']!, _isVerifiedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('my_meal_id')) {
      context.handle(_myMealIdMeta,
          myMealId.isAcceptableOrUnknown(data['my_meal_id']!, _myMealIdMeta));
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
          _ingredientIdMeta,
          ingredientId.isAcceptableOrUnknown(
              data['ingredient_id']!, _ingredientIdMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    }
    if (data.containsKey('group_source')) {
      context.handle(
          _groupSourceMeta,
          groupSource.isAcceptableOrUnknown(
              data['group_source']!, _groupSourceMeta));
    }
    if (data.containsKey('group_order')) {
      context.handle(
          _groupOrderMeta,
          groupOrder.isAcceptableOrUnknown(
              data['group_order']!, _groupOrderMeta));
    }
    if (data.containsKey('is_group_original')) {
      context.handle(
          _isGroupOriginalMeta,
          isGroupOriginal.isAcceptableOrUnknown(
              data['is_group_original']!, _isGroupOriginalMeta));
    }
    if (data.containsKey('ingredients_json')) {
      context.handle(
          _ingredientsJsonMeta,
          ingredientsJson.isAcceptableOrUnknown(
              data['ingredients_json']!, _ingredientsJsonMeta));
    }
    if (data.containsKey('user_input_text')) {
      context.handle(
          _userInputTextMeta,
          userInputText.isAcceptableOrUnknown(
              data['user_input_text']!, _userInputTextMeta));
    }
    if (data.containsKey('original_food_name')) {
      context.handle(
          _originalFoodNameMeta,
          originalFoodName.isAcceptableOrUnknown(
              data['original_food_name']!, _originalFoodNameMeta));
    }
    if (data.containsKey('original_food_name_en')) {
      context.handle(
          _originalFoodNameEnMeta,
          originalFoodNameEn.isAcceptableOrUnknown(
              data['original_food_name_en']!, _originalFoodNameEnMeta));
    }
    if (data.containsKey('original_calories')) {
      context.handle(
          _originalCaloriesMeta,
          originalCalories.isAcceptableOrUnknown(
              data['original_calories']!, _originalCaloriesMeta));
    }
    if (data.containsKey('original_protein')) {
      context.handle(
          _originalProteinMeta,
          originalProtein.isAcceptableOrUnknown(
              data['original_protein']!, _originalProteinMeta));
    }
    if (data.containsKey('original_carbs')) {
      context.handle(
          _originalCarbsMeta,
          originalCarbs.isAcceptableOrUnknown(
              data['original_carbs']!, _originalCarbsMeta));
    }
    if (data.containsKey('original_fat')) {
      context.handle(
          _originalFatMeta,
          originalFat.isAcceptableOrUnknown(
              data['original_fat']!, _originalFatMeta));
    }
    if (data.containsKey('original_ingredients_json')) {
      context.handle(
          _originalIngredientsJsonMeta,
          originalIngredientsJson.isAcceptableOrUnknown(
              data['original_ingredients_json']!,
              _originalIngredientsJsonMeta));
    }
    if (data.containsKey('edit_count')) {
      context.handle(_editCountMeta,
          editCount.isAcceptableOrUnknown(data['edit_count']!, _editCountMeta));
    }
    if (data.containsKey('is_user_corrected')) {
      context.handle(
          _isUserCorrectedMeta,
          isUserCorrected.isAcceptableOrUnknown(
              data['is_user_corrected']!, _isUserCorrectedMeta));
    }
    if (data.containsKey('correction_history_json')) {
      context.handle(
          _correctionHistoryJsonMeta,
          correctionHistoryJson.isAcceptableOrUnknown(
              data['correction_history_json']!, _correctionHistoryJsonMeta));
    }
    if (data.containsKey('brand_name')) {
      context.handle(_brandNameMeta,
          brandName.isAcceptableOrUnknown(data['brand_name']!, _brandNameMeta));
    }
    if (data.containsKey('brand_name_en')) {
      context.handle(
          _brandNameEnMeta,
          brandNameEn.isAcceptableOrUnknown(
              data['brand_name_en']!, _brandNameEnMeta));
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    }
    if (data.containsKey('product_barcode')) {
      context.handle(
          _productBarcodeMeta,
          productBarcode.isAcceptableOrUnknown(
              data['product_barcode']!, _productBarcodeMeta));
    }
    if (data.containsKey('net_weight')) {
      context.handle(_netWeightMeta,
          netWeight.isAcceptableOrUnknown(data['net_weight']!, _netWeightMeta));
    }
    if (data.containsKey('net_weight_unit')) {
      context.handle(
          _netWeightUnitMeta,
          netWeightUnit.isAcceptableOrUnknown(
              data['net_weight_unit']!, _netWeightUnitMeta));
    }
    if (data.containsKey('chain_name')) {
      context.handle(_chainNameMeta,
          chainName.isAcceptableOrUnknown(data['chain_name']!, _chainNameMeta));
    }
    if (data.containsKey('product_category')) {
      context.handle(
          _productCategoryMeta,
          productCategory.isAcceptableOrUnknown(
              data['product_category']!, _productCategoryMeta));
    }
    if (data.containsKey('package_size')) {
      context.handle(
          _packageSizeMeta,
          packageSize.isAcceptableOrUnknown(
              data['package_size']!, _packageSizeMeta));
    }
    if (data.containsKey('nutrition_source')) {
      context.handle(
          _nutritionSourceMeta,
          nutritionSource.isAcceptableOrUnknown(
              data['nutrition_source']!, _nutritionSourceMeta));
    }
    if (data.containsKey('scene_context')) {
      context.handle(
          _sceneContextMeta,
          sceneContext.isAcceptableOrUnknown(
              data['scene_context']!, _sceneContextMeta));
    }
    if (data.containsKey('detected_objects_json')) {
      context.handle(
          _detectedObjectsJsonMeta,
          detectedObjectsJson.isAcceptableOrUnknown(
              data['detected_objects_json']!, _detectedObjectsJsonMeta));
    }
    if (data.containsKey('ar_bounding_box')) {
      context.handle(
          _arBoundingBoxMeta,
          arBoundingBox.isAcceptableOrUnknown(
              data['ar_bounding_box']!, _arBoundingBoxMeta));
    }
    if (data.containsKey('estimated_width_cm')) {
      context.handle(
          _estimatedWidthCmMeta,
          estimatedWidthCm.isAcceptableOrUnknown(
              data['estimated_width_cm']!, _estimatedWidthCmMeta));
    }
    if (data.containsKey('estimated_height_cm')) {
      context.handle(
          _estimatedHeightCmMeta,
          estimatedHeightCm.isAcceptableOrUnknown(
              data['estimated_height_cm']!, _estimatedHeightCmMeta));
    }
    if (data.containsKey('estimated_depth_cm')) {
      context.handle(
          _estimatedDepthCmMeta,
          estimatedDepthCm.isAcceptableOrUnknown(
              data['estimated_depth_cm']!, _estimatedDepthCmMeta));
    }
    if (data.containsKey('reference_object_used')) {
      context.handle(
          _referenceObjectUsedMeta,
          referenceObjectUsed.isAcceptableOrUnknown(
              data['reference_object_used']!, _referenceObjectUsedMeta));
    }
    if (data.containsKey('reference_confidence')) {
      context.handle(
          _referenceConfidenceMeta,
          referenceConfidence.isAcceptableOrUnknown(
              data['reference_confidence']!, _referenceConfidenceMeta));
    }
    if (data.containsKey('plate_diameter_cm')) {
      context.handle(
          _plateDiameterCmMeta,
          plateDiameterCm.isAcceptableOrUnknown(
              data['plate_diameter_cm']!, _plateDiameterCmMeta));
    }
    if (data.containsKey('estimated_volume_ml')) {
      context.handle(
          _estimatedVolumeMlMeta,
          estimatedVolumeMl.isAcceptableOrUnknown(
              data['estimated_volume_ml']!, _estimatedVolumeMlMeta));
    }
    if (data.containsKey('is_calibrated')) {
      context.handle(
          _isCalibratedMeta,
          isCalibrated.isAcceptableOrUnknown(
              data['is_calibrated']!, _isCalibratedMeta));
    }
    if (data.containsKey('ar_labels_json')) {
      context.handle(
          _arLabelsJsonMeta,
          arLabelsJson.isAcceptableOrUnknown(
              data['ar_labels_json']!, _arLabelsJsonMeta));
    }
    if (data.containsKey('ar_image_width')) {
      context.handle(
          _arImageWidthMeta,
          arImageWidth.isAcceptableOrUnknown(
              data['ar_image_width']!, _arImageWidthMeta));
    }
    if (data.containsKey('ar_image_height')) {
      context.handle(
          _arImageHeightMeta,
          arImageHeight.isAcceptableOrUnknown(
              data['ar_image_height']!, _arImageHeightMeta));
    }
    if (data.containsKey('ar_pixel_per_cm')) {
      context.handle(
          _arPixelPerCmMeta,
          arPixelPerCm.isAcceptableOrUnknown(
              data['ar_pixel_per_cm']!, _arPixelPerCmMeta));
    }
    if (data.containsKey('health_connect_id')) {
      context.handle(
          _healthConnectIdMeta,
          healthConnectId.isAcceptableOrUnknown(
              data['health_connect_id']!, _healthConnectIdMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('firebase_doc_id')) {
      context.handle(
          _firebaseDocIdMeta,
          firebaseDocId.isAcceptableOrUnknown(
              data['firebase_doc_id']!, _firebaseDocIdMeta));
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
          _lastSyncAtMeta,
          lastSyncAt.isAcceptableOrUnknown(
              data['last_sync_at']!, _lastSyncAtMeta));
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
          _thumbnailUrlMeta,
          thumbnailUrl.isAcceptableOrUnknown(
              data['thumbnail_url']!, _thumbnailUrlMeta));
    }
    if (data.containsKey('thumbnail_firebase_path')) {
      context.handle(
          _thumbnailFirebasePathMeta,
          thumbnailFirebasePath.isAcceptableOrUnknown(
              data['thumbnail_firebase_path']!, _thumbnailFirebasePathMeta));
    }
    if (data.containsKey('vitamin_a')) {
      context.handle(_vitaminAMeta,
          vitaminA.isAcceptableOrUnknown(data['vitamin_a']!, _vitaminAMeta));
    }
    if (data.containsKey('vitamin_c')) {
      context.handle(_vitaminCMeta,
          vitaminC.isAcceptableOrUnknown(data['vitamin_c']!, _vitaminCMeta));
    }
    if (data.containsKey('vitamin_d')) {
      context.handle(_vitaminDMeta,
          vitaminD.isAcceptableOrUnknown(data['vitamin_d']!, _vitaminDMeta));
    }
    if (data.containsKey('vitamin_e')) {
      context.handle(_vitaminEMeta,
          vitaminE.isAcceptableOrUnknown(data['vitamin_e']!, _vitaminEMeta));
    }
    if (data.containsKey('vitamin_k')) {
      context.handle(_vitaminKMeta,
          vitaminK.isAcceptableOrUnknown(data['vitamin_k']!, _vitaminKMeta));
    }
    if (data.containsKey('thiamin')) {
      context.handle(_thiaminMeta,
          thiamin.isAcceptableOrUnknown(data['thiamin']!, _thiaminMeta));
    }
    if (data.containsKey('riboflavin')) {
      context.handle(
          _riboflavinMeta,
          riboflavin.isAcceptableOrUnknown(
              data['riboflavin']!, _riboflavinMeta));
    }
    if (data.containsKey('niacin')) {
      context.handle(_niacinMeta,
          niacin.isAcceptableOrUnknown(data['niacin']!, _niacinMeta));
    }
    if (data.containsKey('vitamin_b6')) {
      context.handle(_vitaminB6Meta,
          vitaminB6.isAcceptableOrUnknown(data['vitamin_b6']!, _vitaminB6Meta));
    }
    if (data.containsKey('folate')) {
      context.handle(_folateMeta,
          folate.isAcceptableOrUnknown(data['folate']!, _folateMeta));
    }
    if (data.containsKey('vitamin_b12')) {
      context.handle(
          _vitaminB12Meta,
          vitaminB12.isAcceptableOrUnknown(
              data['vitamin_b12']!, _vitaminB12Meta));
    }
    if (data.containsKey('calcium')) {
      context.handle(_calciumMeta,
          calcium.isAcceptableOrUnknown(data['calcium']!, _calciumMeta));
    }
    if (data.containsKey('iron')) {
      context.handle(
          _ironMeta, iron.isAcceptableOrUnknown(data['iron']!, _ironMeta));
    }
    if (data.containsKey('magnesium')) {
      context.handle(_magnesiumMeta,
          magnesium.isAcceptableOrUnknown(data['magnesium']!, _magnesiumMeta));
    }
    if (data.containsKey('phosphorus')) {
      context.handle(
          _phosphorusMeta,
          phosphorus.isAcceptableOrUnknown(
              data['phosphorus']!, _phosphorusMeta));
    }
    if (data.containsKey('zinc')) {
      context.handle(
          _zincMeta, zinc.isAcceptableOrUnknown(data['zinc']!, _zincMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodEntryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodEntryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      foodName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}food_name'])!,
      foodNameEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}food_name_en']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      mealType: $FoodEntriesTable.$convertermealType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}meal_type'])!),
      servingSize: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}serving_size'])!,
      servingUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}serving_unit'])!,
      servingGrams: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}serving_grams']),
      calories: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calories'])!,
      protein: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}protein'])!,
      carbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs'])!,
      fat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat'])!,
      baseCalories: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}base_calories'])!,
      baseProtein: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}base_protein'])!,
      baseCarbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}base_carbs'])!,
      baseFat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}base_fat'])!,
      fiber: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fiber']),
      sugar: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sugar']),
      sodium: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sodium']),
      cholesterol: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cholesterol']),
      saturatedFat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}saturated_fat']),
      transFat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}trans_fat']),
      unsaturatedFat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unsaturated_fat']),
      monounsaturatedFat: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}monounsaturated_fat']),
      polyunsaturatedFat: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}polyunsaturated_fat']),
      potassium: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}potassium']),
      source: $FoodEntriesTable.$convertersource.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source'])!),
      searchMode: $FoodEntriesTable.$convertersearchMode.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}search_mode'])!),
      aiConfidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ai_confidence']),
      isVerified: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_verified'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      myMealId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}my_meal_id']),
      ingredientId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ingredient_id']),
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id']),
      groupSource: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_source']),
      groupOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_order']),
      isGroupOriginal: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_group_original'])!,
      ingredientsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ingredients_json']),
      userInputText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_input_text']),
      originalFoodName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}original_food_name']),
      originalFoodNameEn: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}original_food_name_en']),
      originalCalories: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}original_calories']),
      originalProtein: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}original_protein']),
      originalCarbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}original_carbs']),
      originalFat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}original_fat']),
      originalIngredientsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}original_ingredients_json']),
      editCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}edit_count'])!,
      isUserCorrected: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_user_corrected'])!,
      correctionHistoryJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}correction_history_json']),
      brandName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand_name']),
      brandNameEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand_name_en']),
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name']),
      productBarcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_barcode']),
      netWeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}net_weight']),
      netWeightUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}net_weight_unit']),
      chainName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chain_name']),
      productCategory: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}product_category']),
      packageSize: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}package_size']),
      nutritionSource: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}nutrition_source']),
      sceneContext: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scene_context']),
      detectedObjectsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}detected_objects_json']),
      arBoundingBox: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ar_bounding_box']),
      estimatedWidthCm: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}estimated_width_cm']),
      estimatedHeightCm: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}estimated_height_cm']),
      estimatedDepthCm: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}estimated_depth_cm']),
      referenceObjectUsed: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reference_object_used']),
      referenceConfidence: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}reference_confidence']),
      plateDiameterCm: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}plate_diameter_cm']),
      estimatedVolumeMl: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}estimated_volume_ml']),
      isCalibrated: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_calibrated'])!,
      arLabelsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ar_labels_json']),
      arImageWidth: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ar_image_width']),
      arImageHeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ar_image_height']),
      arPixelPerCm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ar_pixel_per_cm']),
      healthConnectId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}health_connect_id']),
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      firebaseDocId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firebase_doc_id']),
      lastSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync_at']),
      thumbnailUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_url']),
      thumbnailFirebasePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}thumbnail_firebase_path']),
      vitaminA: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}vitamin_a']),
      vitaminC: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}vitamin_c']),
      vitaminD: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}vitamin_d']),
      vitaminE: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}vitamin_e']),
      vitaminK: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}vitamin_k']),
      thiamin: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}thiamin']),
      riboflavin: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}riboflavin']),
      niacin: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}niacin']),
      vitaminB6: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}vitamin_b6']),
      folate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}folate']),
      vitaminB12: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}vitamin_b12']),
      calcium: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calcium']),
      iron: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}iron']),
      magnesium: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}magnesium']),
      phosphorus: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}phosphorus']),
      zinc: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}zinc']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FoodEntriesTable createAlias(String alias) {
    return $FoodEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MealType, int, int> $convertermealType =
      const EnumIndexConverter<MealType>(MealType.values);
  static JsonTypeConverter2<DataSource, int, int> $convertersource =
      const EnumIndexConverter<DataSource>(DataSource.values);
  static JsonTypeConverter2<FoodSearchMode, int, int> $convertersearchMode =
      const EnumIndexConverter<FoodSearchMode>(FoodSearchMode.values);
}

class FoodEntryData extends DataClass implements Insertable<FoodEntryData> {
  int id;
  String foodName;
  String? foodNameEn;
  DateTime timestamp;
  String? imagePath;
  MealType mealType;
  double servingSize;
  String servingUnit;
  double? servingGrams;
  double calories;
  double protein;
  double carbs;
  double fat;
  double baseCalories;
  double baseProtein;
  double baseCarbs;
  double baseFat;
  double? fiber;
  double? sugar;
  double? sodium;
  double? cholesterol;
  double? saturatedFat;
  double? transFat;
  double? unsaturatedFat;
  double? monounsaturatedFat;
  double? polyunsaturatedFat;
  double? potassium;
  DataSource source;
  FoodSearchMode searchMode;
  double? aiConfidence;
  bool isVerified;
  bool isDeleted;
  String? notes;
  int? myMealId;
  int? ingredientId;
  String? groupId;
  String? groupSource;
  int? groupOrder;
  bool isGroupOriginal;
  String? ingredientsJson;
  String? userInputText;
  String? originalFoodName;
  String? originalFoodNameEn;
  double? originalCalories;
  double? originalProtein;
  double? originalCarbs;
  double? originalFat;
  String? originalIngredientsJson;
  int editCount;
  bool isUserCorrected;
  String? correctionHistoryJson;
  String? brandName;
  String? brandNameEn;
  String? productName;
  String? productBarcode;
  double? netWeight;
  String? netWeightUnit;
  String? chainName;
  String? productCategory;
  String? packageSize;
  String? nutritionSource;
  String? sceneContext;
  String? detectedObjectsJson;
  String? arBoundingBox;
  double? estimatedWidthCm;
  double? estimatedHeightCm;
  double? estimatedDepthCm;
  String? referenceObjectUsed;
  double? referenceConfidence;
  double? plateDiameterCm;
  double? estimatedVolumeMl;
  bool isCalibrated;
  String? arLabelsJson;
  double? arImageWidth;
  double? arImageHeight;
  double? arPixelPerCm;
  String? healthConnectId;
  DateTime? syncedAt;
  bool isSynced;
  String? firebaseDocId;
  DateTime? lastSyncAt;
  String? thumbnailUrl;
  String? thumbnailFirebasePath;
  double? vitaminA;
  double? vitaminC;
  double? vitaminD;
  double? vitaminE;
  double? vitaminK;
  double? thiamin;
  double? riboflavin;
  double? niacin;
  double? vitaminB6;
  double? folate;
  double? vitaminB12;
  double? calcium;
  double? iron;
  double? magnesium;
  double? phosphorus;
  double? zinc;
  DateTime createdAt;
  DateTime updatedAt;
  FoodEntryData(
      {required this.id,
      required this.foodName,
      this.foodNameEn,
      required this.timestamp,
      this.imagePath,
      required this.mealType,
      required this.servingSize,
      required this.servingUnit,
      this.servingGrams,
      required this.calories,
      required this.protein,
      required this.carbs,
      required this.fat,
      required this.baseCalories,
      required this.baseProtein,
      required this.baseCarbs,
      required this.baseFat,
      this.fiber,
      this.sugar,
      this.sodium,
      this.cholesterol,
      this.saturatedFat,
      this.transFat,
      this.unsaturatedFat,
      this.monounsaturatedFat,
      this.polyunsaturatedFat,
      this.potassium,
      required this.source,
      required this.searchMode,
      this.aiConfidence,
      required this.isVerified,
      required this.isDeleted,
      this.notes,
      this.myMealId,
      this.ingredientId,
      this.groupId,
      this.groupSource,
      this.groupOrder,
      required this.isGroupOriginal,
      this.ingredientsJson,
      this.userInputText,
      this.originalFoodName,
      this.originalFoodNameEn,
      this.originalCalories,
      this.originalProtein,
      this.originalCarbs,
      this.originalFat,
      this.originalIngredientsJson,
      required this.editCount,
      required this.isUserCorrected,
      this.correctionHistoryJson,
      this.brandName,
      this.brandNameEn,
      this.productName,
      this.productBarcode,
      this.netWeight,
      this.netWeightUnit,
      this.chainName,
      this.productCategory,
      this.packageSize,
      this.nutritionSource,
      this.sceneContext,
      this.detectedObjectsJson,
      this.arBoundingBox,
      this.estimatedWidthCm,
      this.estimatedHeightCm,
      this.estimatedDepthCm,
      this.referenceObjectUsed,
      this.referenceConfidence,
      this.plateDiameterCm,
      this.estimatedVolumeMl,
      required this.isCalibrated,
      this.arLabelsJson,
      this.arImageWidth,
      this.arImageHeight,
      this.arPixelPerCm,
      this.healthConnectId,
      this.syncedAt,
      required this.isSynced,
      this.firebaseDocId,
      this.lastSyncAt,
      this.thumbnailUrl,
      this.thumbnailFirebasePath,
      this.vitaminA,
      this.vitaminC,
      this.vitaminD,
      this.vitaminE,
      this.vitaminK,
      this.thiamin,
      this.riboflavin,
      this.niacin,
      this.vitaminB6,
      this.folate,
      this.vitaminB12,
      this.calcium,
      this.iron,
      this.magnesium,
      this.phosphorus,
      this.zinc,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['food_name'] = Variable<String>(foodName);
    if (!nullToAbsent || foodNameEn != null) {
      map['food_name_en'] = Variable<String>(foodNameEn);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    {
      map['meal_type'] =
          Variable<int>($FoodEntriesTable.$convertermealType.toSql(mealType));
    }
    map['serving_size'] = Variable<double>(servingSize);
    map['serving_unit'] = Variable<String>(servingUnit);
    if (!nullToAbsent || servingGrams != null) {
      map['serving_grams'] = Variable<double>(servingGrams);
    }
    map['calories'] = Variable<double>(calories);
    map['protein'] = Variable<double>(protein);
    map['carbs'] = Variable<double>(carbs);
    map['fat'] = Variable<double>(fat);
    map['base_calories'] = Variable<double>(baseCalories);
    map['base_protein'] = Variable<double>(baseProtein);
    map['base_carbs'] = Variable<double>(baseCarbs);
    map['base_fat'] = Variable<double>(baseFat);
    if (!nullToAbsent || fiber != null) {
      map['fiber'] = Variable<double>(fiber);
    }
    if (!nullToAbsent || sugar != null) {
      map['sugar'] = Variable<double>(sugar);
    }
    if (!nullToAbsent || sodium != null) {
      map['sodium'] = Variable<double>(sodium);
    }
    if (!nullToAbsent || cholesterol != null) {
      map['cholesterol'] = Variable<double>(cholesterol);
    }
    if (!nullToAbsent || saturatedFat != null) {
      map['saturated_fat'] = Variable<double>(saturatedFat);
    }
    if (!nullToAbsent || transFat != null) {
      map['trans_fat'] = Variable<double>(transFat);
    }
    if (!nullToAbsent || unsaturatedFat != null) {
      map['unsaturated_fat'] = Variable<double>(unsaturatedFat);
    }
    if (!nullToAbsent || monounsaturatedFat != null) {
      map['monounsaturated_fat'] = Variable<double>(monounsaturatedFat);
    }
    if (!nullToAbsent || polyunsaturatedFat != null) {
      map['polyunsaturated_fat'] = Variable<double>(polyunsaturatedFat);
    }
    if (!nullToAbsent || potassium != null) {
      map['potassium'] = Variable<double>(potassium);
    }
    {
      map['source'] =
          Variable<int>($FoodEntriesTable.$convertersource.toSql(source));
    }
    {
      map['search_mode'] = Variable<int>(
          $FoodEntriesTable.$convertersearchMode.toSql(searchMode));
    }
    if (!nullToAbsent || aiConfidence != null) {
      map['ai_confidence'] = Variable<double>(aiConfidence);
    }
    map['is_verified'] = Variable<bool>(isVerified);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || myMealId != null) {
      map['my_meal_id'] = Variable<int>(myMealId);
    }
    if (!nullToAbsent || ingredientId != null) {
      map['ingredient_id'] = Variable<int>(ingredientId);
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    if (!nullToAbsent || groupSource != null) {
      map['group_source'] = Variable<String>(groupSource);
    }
    if (!nullToAbsent || groupOrder != null) {
      map['group_order'] = Variable<int>(groupOrder);
    }
    map['is_group_original'] = Variable<bool>(isGroupOriginal);
    if (!nullToAbsent || ingredientsJson != null) {
      map['ingredients_json'] = Variable<String>(ingredientsJson);
    }
    if (!nullToAbsent || userInputText != null) {
      map['user_input_text'] = Variable<String>(userInputText);
    }
    if (!nullToAbsent || originalFoodName != null) {
      map['original_food_name'] = Variable<String>(originalFoodName);
    }
    if (!nullToAbsent || originalFoodNameEn != null) {
      map['original_food_name_en'] = Variable<String>(originalFoodNameEn);
    }
    if (!nullToAbsent || originalCalories != null) {
      map['original_calories'] = Variable<double>(originalCalories);
    }
    if (!nullToAbsent || originalProtein != null) {
      map['original_protein'] = Variable<double>(originalProtein);
    }
    if (!nullToAbsent || originalCarbs != null) {
      map['original_carbs'] = Variable<double>(originalCarbs);
    }
    if (!nullToAbsent || originalFat != null) {
      map['original_fat'] = Variable<double>(originalFat);
    }
    if (!nullToAbsent || originalIngredientsJson != null) {
      map['original_ingredients_json'] =
          Variable<String>(originalIngredientsJson);
    }
    map['edit_count'] = Variable<int>(editCount);
    map['is_user_corrected'] = Variable<bool>(isUserCorrected);
    if (!nullToAbsent || correctionHistoryJson != null) {
      map['correction_history_json'] = Variable<String>(correctionHistoryJson);
    }
    if (!nullToAbsent || brandName != null) {
      map['brand_name'] = Variable<String>(brandName);
    }
    if (!nullToAbsent || brandNameEn != null) {
      map['brand_name_en'] = Variable<String>(brandNameEn);
    }
    if (!nullToAbsent || productName != null) {
      map['product_name'] = Variable<String>(productName);
    }
    if (!nullToAbsent || productBarcode != null) {
      map['product_barcode'] = Variable<String>(productBarcode);
    }
    if (!nullToAbsent || netWeight != null) {
      map['net_weight'] = Variable<double>(netWeight);
    }
    if (!nullToAbsent || netWeightUnit != null) {
      map['net_weight_unit'] = Variable<String>(netWeightUnit);
    }
    if (!nullToAbsent || chainName != null) {
      map['chain_name'] = Variable<String>(chainName);
    }
    if (!nullToAbsent || productCategory != null) {
      map['product_category'] = Variable<String>(productCategory);
    }
    if (!nullToAbsent || packageSize != null) {
      map['package_size'] = Variable<String>(packageSize);
    }
    if (!nullToAbsent || nutritionSource != null) {
      map['nutrition_source'] = Variable<String>(nutritionSource);
    }
    if (!nullToAbsent || sceneContext != null) {
      map['scene_context'] = Variable<String>(sceneContext);
    }
    if (!nullToAbsent || detectedObjectsJson != null) {
      map['detected_objects_json'] = Variable<String>(detectedObjectsJson);
    }
    if (!nullToAbsent || arBoundingBox != null) {
      map['ar_bounding_box'] = Variable<String>(arBoundingBox);
    }
    if (!nullToAbsent || estimatedWidthCm != null) {
      map['estimated_width_cm'] = Variable<double>(estimatedWidthCm);
    }
    if (!nullToAbsent || estimatedHeightCm != null) {
      map['estimated_height_cm'] = Variable<double>(estimatedHeightCm);
    }
    if (!nullToAbsent || estimatedDepthCm != null) {
      map['estimated_depth_cm'] = Variable<double>(estimatedDepthCm);
    }
    if (!nullToAbsent || referenceObjectUsed != null) {
      map['reference_object_used'] = Variable<String>(referenceObjectUsed);
    }
    if (!nullToAbsent || referenceConfidence != null) {
      map['reference_confidence'] = Variable<double>(referenceConfidence);
    }
    if (!nullToAbsent || plateDiameterCm != null) {
      map['plate_diameter_cm'] = Variable<double>(plateDiameterCm);
    }
    if (!nullToAbsent || estimatedVolumeMl != null) {
      map['estimated_volume_ml'] = Variable<double>(estimatedVolumeMl);
    }
    map['is_calibrated'] = Variable<bool>(isCalibrated);
    if (!nullToAbsent || arLabelsJson != null) {
      map['ar_labels_json'] = Variable<String>(arLabelsJson);
    }
    if (!nullToAbsent || arImageWidth != null) {
      map['ar_image_width'] = Variable<double>(arImageWidth);
    }
    if (!nullToAbsent || arImageHeight != null) {
      map['ar_image_height'] = Variable<double>(arImageHeight);
    }
    if (!nullToAbsent || arPixelPerCm != null) {
      map['ar_pixel_per_cm'] = Variable<double>(arPixelPerCm);
    }
    if (!nullToAbsent || healthConnectId != null) {
      map['health_connect_id'] = Variable<String>(healthConnectId);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || firebaseDocId != null) {
      map['firebase_doc_id'] = Variable<String>(firebaseDocId);
    }
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || thumbnailFirebasePath != null) {
      map['thumbnail_firebase_path'] = Variable<String>(thumbnailFirebasePath);
    }
    if (!nullToAbsent || vitaminA != null) {
      map['vitamin_a'] = Variable<double>(vitaminA);
    }
    if (!nullToAbsent || vitaminC != null) {
      map['vitamin_c'] = Variable<double>(vitaminC);
    }
    if (!nullToAbsent || vitaminD != null) {
      map['vitamin_d'] = Variable<double>(vitaminD);
    }
    if (!nullToAbsent || vitaminE != null) {
      map['vitamin_e'] = Variable<double>(vitaminE);
    }
    if (!nullToAbsent || vitaminK != null) {
      map['vitamin_k'] = Variable<double>(vitaminK);
    }
    if (!nullToAbsent || thiamin != null) {
      map['thiamin'] = Variable<double>(thiamin);
    }
    if (!nullToAbsent || riboflavin != null) {
      map['riboflavin'] = Variable<double>(riboflavin);
    }
    if (!nullToAbsent || niacin != null) {
      map['niacin'] = Variable<double>(niacin);
    }
    if (!nullToAbsent || vitaminB6 != null) {
      map['vitamin_b6'] = Variable<double>(vitaminB6);
    }
    if (!nullToAbsent || folate != null) {
      map['folate'] = Variable<double>(folate);
    }
    if (!nullToAbsent || vitaminB12 != null) {
      map['vitamin_b12'] = Variable<double>(vitaminB12);
    }
    if (!nullToAbsent || calcium != null) {
      map['calcium'] = Variable<double>(calcium);
    }
    if (!nullToAbsent || iron != null) {
      map['iron'] = Variable<double>(iron);
    }
    if (!nullToAbsent || magnesium != null) {
      map['magnesium'] = Variable<double>(magnesium);
    }
    if (!nullToAbsent || phosphorus != null) {
      map['phosphorus'] = Variable<double>(phosphorus);
    }
    if (!nullToAbsent || zinc != null) {
      map['zinc'] = Variable<double>(zinc);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FoodEntriesCompanion toCompanion(bool nullToAbsent) {
    return FoodEntriesCompanion(
      id: Value(id),
      foodName: Value(foodName),
      foodNameEn: foodNameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(foodNameEn),
      timestamp: Value(timestamp),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      mealType: Value(mealType),
      servingSize: Value(servingSize),
      servingUnit: Value(servingUnit),
      servingGrams: servingGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(servingGrams),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
      baseCalories: Value(baseCalories),
      baseProtein: Value(baseProtein),
      baseCarbs: Value(baseCarbs),
      baseFat: Value(baseFat),
      fiber:
          fiber == null && nullToAbsent ? const Value.absent() : Value(fiber),
      sugar:
          sugar == null && nullToAbsent ? const Value.absent() : Value(sugar),
      sodium:
          sodium == null && nullToAbsent ? const Value.absent() : Value(sodium),
      cholesterol: cholesterol == null && nullToAbsent
          ? const Value.absent()
          : Value(cholesterol),
      saturatedFat: saturatedFat == null && nullToAbsent
          ? const Value.absent()
          : Value(saturatedFat),
      transFat: transFat == null && nullToAbsent
          ? const Value.absent()
          : Value(transFat),
      unsaturatedFat: unsaturatedFat == null && nullToAbsent
          ? const Value.absent()
          : Value(unsaturatedFat),
      monounsaturatedFat: monounsaturatedFat == null && nullToAbsent
          ? const Value.absent()
          : Value(monounsaturatedFat),
      polyunsaturatedFat: polyunsaturatedFat == null && nullToAbsent
          ? const Value.absent()
          : Value(polyunsaturatedFat),
      potassium: potassium == null && nullToAbsent
          ? const Value.absent()
          : Value(potassium),
      source: Value(source),
      searchMode: Value(searchMode),
      aiConfidence: aiConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(aiConfidence),
      isVerified: Value(isVerified),
      isDeleted: Value(isDeleted),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      myMealId: myMealId == null && nullToAbsent
          ? const Value.absent()
          : Value(myMealId),
      ingredientId: ingredientId == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientId),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      groupSource: groupSource == null && nullToAbsent
          ? const Value.absent()
          : Value(groupSource),
      groupOrder: groupOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(groupOrder),
      isGroupOriginal: Value(isGroupOriginal),
      ingredientsJson: ingredientsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientsJson),
      userInputText: userInputText == null && nullToAbsent
          ? const Value.absent()
          : Value(userInputText),
      originalFoodName: originalFoodName == null && nullToAbsent
          ? const Value.absent()
          : Value(originalFoodName),
      originalFoodNameEn: originalFoodNameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(originalFoodNameEn),
      originalCalories: originalCalories == null && nullToAbsent
          ? const Value.absent()
          : Value(originalCalories),
      originalProtein: originalProtein == null && nullToAbsent
          ? const Value.absent()
          : Value(originalProtein),
      originalCarbs: originalCarbs == null && nullToAbsent
          ? const Value.absent()
          : Value(originalCarbs),
      originalFat: originalFat == null && nullToAbsent
          ? const Value.absent()
          : Value(originalFat),
      originalIngredientsJson: originalIngredientsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(originalIngredientsJson),
      editCount: Value(editCount),
      isUserCorrected: Value(isUserCorrected),
      correctionHistoryJson: correctionHistoryJson == null && nullToAbsent
          ? const Value.absent()
          : Value(correctionHistoryJson),
      brandName: brandName == null && nullToAbsent
          ? const Value.absent()
          : Value(brandName),
      brandNameEn: brandNameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(brandNameEn),
      productName: productName == null && nullToAbsent
          ? const Value.absent()
          : Value(productName),
      productBarcode: productBarcode == null && nullToAbsent
          ? const Value.absent()
          : Value(productBarcode),
      netWeight: netWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(netWeight),
      netWeightUnit: netWeightUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(netWeightUnit),
      chainName: chainName == null && nullToAbsent
          ? const Value.absent()
          : Value(chainName),
      productCategory: productCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(productCategory),
      packageSize: packageSize == null && nullToAbsent
          ? const Value.absent()
          : Value(packageSize),
      nutritionSource: nutritionSource == null && nullToAbsent
          ? const Value.absent()
          : Value(nutritionSource),
      sceneContext: sceneContext == null && nullToAbsent
          ? const Value.absent()
          : Value(sceneContext),
      detectedObjectsJson: detectedObjectsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(detectedObjectsJson),
      arBoundingBox: arBoundingBox == null && nullToAbsent
          ? const Value.absent()
          : Value(arBoundingBox),
      estimatedWidthCm: estimatedWidthCm == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedWidthCm),
      estimatedHeightCm: estimatedHeightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedHeightCm),
      estimatedDepthCm: estimatedDepthCm == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedDepthCm),
      referenceObjectUsed: referenceObjectUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceObjectUsed),
      referenceConfidence: referenceConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceConfidence),
      plateDiameterCm: plateDiameterCm == null && nullToAbsent
          ? const Value.absent()
          : Value(plateDiameterCm),
      estimatedVolumeMl: estimatedVolumeMl == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedVolumeMl),
      isCalibrated: Value(isCalibrated),
      arLabelsJson: arLabelsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(arLabelsJson),
      arImageWidth: arImageWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(arImageWidth),
      arImageHeight: arImageHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(arImageHeight),
      arPixelPerCm: arPixelPerCm == null && nullToAbsent
          ? const Value.absent()
          : Value(arPixelPerCm),
      healthConnectId: healthConnectId == null && nullToAbsent
          ? const Value.absent()
          : Value(healthConnectId),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      isSynced: Value(isSynced),
      firebaseDocId: firebaseDocId == null && nullToAbsent
          ? const Value.absent()
          : Value(firebaseDocId),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      thumbnailFirebasePath: thumbnailFirebasePath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailFirebasePath),
      vitaminA: vitaminA == null && nullToAbsent
          ? const Value.absent()
          : Value(vitaminA),
      vitaminC: vitaminC == null && nullToAbsent
          ? const Value.absent()
          : Value(vitaminC),
      vitaminD: vitaminD == null && nullToAbsent
          ? const Value.absent()
          : Value(vitaminD),
      vitaminE: vitaminE == null && nullToAbsent
          ? const Value.absent()
          : Value(vitaminE),
      vitaminK: vitaminK == null && nullToAbsent
          ? const Value.absent()
          : Value(vitaminK),
      thiamin: thiamin == null && nullToAbsent
          ? const Value.absent()
          : Value(thiamin),
      riboflavin: riboflavin == null && nullToAbsent
          ? const Value.absent()
          : Value(riboflavin),
      niacin:
          niacin == null && nullToAbsent ? const Value.absent() : Value(niacin),
      vitaminB6: vitaminB6 == null && nullToAbsent
          ? const Value.absent()
          : Value(vitaminB6),
      folate:
          folate == null && nullToAbsent ? const Value.absent() : Value(folate),
      vitaminB12: vitaminB12 == null && nullToAbsent
          ? const Value.absent()
          : Value(vitaminB12),
      calcium: calcium == null && nullToAbsent
          ? const Value.absent()
          : Value(calcium),
      iron: iron == null && nullToAbsent ? const Value.absent() : Value(iron),
      magnesium: magnesium == null && nullToAbsent
          ? const Value.absent()
          : Value(magnesium),
      phosphorus: phosphorus == null && nullToAbsent
          ? const Value.absent()
          : Value(phosphorus),
      zinc: zinc == null && nullToAbsent ? const Value.absent() : Value(zinc),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FoodEntryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodEntryData(
      id: serializer.fromJson<int>(json['id']),
      foodName: serializer.fromJson<String>(json['foodName']),
      foodNameEn: serializer.fromJson<String?>(json['foodNameEn']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      mealType: $FoodEntriesTable.$convertermealType
          .fromJson(serializer.fromJson<int>(json['mealType'])),
      servingSize: serializer.fromJson<double>(json['servingSize']),
      servingUnit: serializer.fromJson<String>(json['servingUnit']),
      servingGrams: serializer.fromJson<double?>(json['servingGrams']),
      calories: serializer.fromJson<double>(json['calories']),
      protein: serializer.fromJson<double>(json['protein']),
      carbs: serializer.fromJson<double>(json['carbs']),
      fat: serializer.fromJson<double>(json['fat']),
      baseCalories: serializer.fromJson<double>(json['baseCalories']),
      baseProtein: serializer.fromJson<double>(json['baseProtein']),
      baseCarbs: serializer.fromJson<double>(json['baseCarbs']),
      baseFat: serializer.fromJson<double>(json['baseFat']),
      fiber: serializer.fromJson<double?>(json['fiber']),
      sugar: serializer.fromJson<double?>(json['sugar']),
      sodium: serializer.fromJson<double?>(json['sodium']),
      cholesterol: serializer.fromJson<double?>(json['cholesterol']),
      saturatedFat: serializer.fromJson<double?>(json['saturatedFat']),
      transFat: serializer.fromJson<double?>(json['transFat']),
      unsaturatedFat: serializer.fromJson<double?>(json['unsaturatedFat']),
      monounsaturatedFat:
          serializer.fromJson<double?>(json['monounsaturatedFat']),
      polyunsaturatedFat:
          serializer.fromJson<double?>(json['polyunsaturatedFat']),
      potassium: serializer.fromJson<double?>(json['potassium']),
      source: $FoodEntriesTable.$convertersource
          .fromJson(serializer.fromJson<int>(json['source'])),
      searchMode: $FoodEntriesTable.$convertersearchMode
          .fromJson(serializer.fromJson<int>(json['searchMode'])),
      aiConfidence: serializer.fromJson<double?>(json['aiConfidence']),
      isVerified: serializer.fromJson<bool>(json['isVerified']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      notes: serializer.fromJson<String?>(json['notes']),
      myMealId: serializer.fromJson<int?>(json['myMealId']),
      ingredientId: serializer.fromJson<int?>(json['ingredientId']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      groupSource: serializer.fromJson<String?>(json['groupSource']),
      groupOrder: serializer.fromJson<int?>(json['groupOrder']),
      isGroupOriginal: serializer.fromJson<bool>(json['isGroupOriginal']),
      ingredientsJson: serializer.fromJson<String?>(json['ingredientsJson']),
      userInputText: serializer.fromJson<String?>(json['userInputText']),
      originalFoodName: serializer.fromJson<String?>(json['originalFoodName']),
      originalFoodNameEn:
          serializer.fromJson<String?>(json['originalFoodNameEn']),
      originalCalories: serializer.fromJson<double?>(json['originalCalories']),
      originalProtein: serializer.fromJson<double?>(json['originalProtein']),
      originalCarbs: serializer.fromJson<double?>(json['originalCarbs']),
      originalFat: serializer.fromJson<double?>(json['originalFat']),
      originalIngredientsJson:
          serializer.fromJson<String?>(json['originalIngredientsJson']),
      editCount: serializer.fromJson<int>(json['editCount']),
      isUserCorrected: serializer.fromJson<bool>(json['isUserCorrected']),
      correctionHistoryJson:
          serializer.fromJson<String?>(json['correctionHistoryJson']),
      brandName: serializer.fromJson<String?>(json['brandName']),
      brandNameEn: serializer.fromJson<String?>(json['brandNameEn']),
      productName: serializer.fromJson<String?>(json['productName']),
      productBarcode: serializer.fromJson<String?>(json['productBarcode']),
      netWeight: serializer.fromJson<double?>(json['netWeight']),
      netWeightUnit: serializer.fromJson<String?>(json['netWeightUnit']),
      chainName: serializer.fromJson<String?>(json['chainName']),
      productCategory: serializer.fromJson<String?>(json['productCategory']),
      packageSize: serializer.fromJson<String?>(json['packageSize']),
      nutritionSource: serializer.fromJson<String?>(json['nutritionSource']),
      sceneContext: serializer.fromJson<String?>(json['sceneContext']),
      detectedObjectsJson:
          serializer.fromJson<String?>(json['detectedObjectsJson']),
      arBoundingBox: serializer.fromJson<String?>(json['arBoundingBox']),
      estimatedWidthCm: serializer.fromJson<double?>(json['estimatedWidthCm']),
      estimatedHeightCm:
          serializer.fromJson<double?>(json['estimatedHeightCm']),
      estimatedDepthCm: serializer.fromJson<double?>(json['estimatedDepthCm']),
      referenceObjectUsed:
          serializer.fromJson<String?>(json['referenceObjectUsed']),
      referenceConfidence:
          serializer.fromJson<double?>(json['referenceConfidence']),
      plateDiameterCm: serializer.fromJson<double?>(json['plateDiameterCm']),
      estimatedVolumeMl:
          serializer.fromJson<double?>(json['estimatedVolumeMl']),
      isCalibrated: serializer.fromJson<bool>(json['isCalibrated']),
      arLabelsJson: serializer.fromJson<String?>(json['arLabelsJson']),
      arImageWidth: serializer.fromJson<double?>(json['arImageWidth']),
      arImageHeight: serializer.fromJson<double?>(json['arImageHeight']),
      arPixelPerCm: serializer.fromJson<double?>(json['arPixelPerCm']),
      healthConnectId: serializer.fromJson<String?>(json['healthConnectId']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      firebaseDocId: serializer.fromJson<String?>(json['firebaseDocId']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      thumbnailFirebasePath:
          serializer.fromJson<String?>(json['thumbnailFirebasePath']),
      vitaminA: serializer.fromJson<double?>(json['vitaminA']),
      vitaminC: serializer.fromJson<double?>(json['vitaminC']),
      vitaminD: serializer.fromJson<double?>(json['vitaminD']),
      vitaminE: serializer.fromJson<double?>(json['vitaminE']),
      vitaminK: serializer.fromJson<double?>(json['vitaminK']),
      thiamin: serializer.fromJson<double?>(json['thiamin']),
      riboflavin: serializer.fromJson<double?>(json['riboflavin']),
      niacin: serializer.fromJson<double?>(json['niacin']),
      vitaminB6: serializer.fromJson<double?>(json['vitaminB6']),
      folate: serializer.fromJson<double?>(json['folate']),
      vitaminB12: serializer.fromJson<double?>(json['vitaminB12']),
      calcium: serializer.fromJson<double?>(json['calcium']),
      iron: serializer.fromJson<double?>(json['iron']),
      magnesium: serializer.fromJson<double?>(json['magnesium']),
      phosphorus: serializer.fromJson<double?>(json['phosphorus']),
      zinc: serializer.fromJson<double?>(json['zinc']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'foodName': serializer.toJson<String>(foodName),
      'foodNameEn': serializer.toJson<String?>(foodNameEn),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'imagePath': serializer.toJson<String?>(imagePath),
      'mealType': serializer
          .toJson<int>($FoodEntriesTable.$convertermealType.toJson(mealType)),
      'servingSize': serializer.toJson<double>(servingSize),
      'servingUnit': serializer.toJson<String>(servingUnit),
      'servingGrams': serializer.toJson<double?>(servingGrams),
      'calories': serializer.toJson<double>(calories),
      'protein': serializer.toJson<double>(protein),
      'carbs': serializer.toJson<double>(carbs),
      'fat': serializer.toJson<double>(fat),
      'baseCalories': serializer.toJson<double>(baseCalories),
      'baseProtein': serializer.toJson<double>(baseProtein),
      'baseCarbs': serializer.toJson<double>(baseCarbs),
      'baseFat': serializer.toJson<double>(baseFat),
      'fiber': serializer.toJson<double?>(fiber),
      'sugar': serializer.toJson<double?>(sugar),
      'sodium': serializer.toJson<double?>(sodium),
      'cholesterol': serializer.toJson<double?>(cholesterol),
      'saturatedFat': serializer.toJson<double?>(saturatedFat),
      'transFat': serializer.toJson<double?>(transFat),
      'unsaturatedFat': serializer.toJson<double?>(unsaturatedFat),
      'monounsaturatedFat': serializer.toJson<double?>(monounsaturatedFat),
      'polyunsaturatedFat': serializer.toJson<double?>(polyunsaturatedFat),
      'potassium': serializer.toJson<double?>(potassium),
      'source': serializer
          .toJson<int>($FoodEntriesTable.$convertersource.toJson(source)),
      'searchMode': serializer.toJson<int>(
          $FoodEntriesTable.$convertersearchMode.toJson(searchMode)),
      'aiConfidence': serializer.toJson<double?>(aiConfidence),
      'isVerified': serializer.toJson<bool>(isVerified),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'notes': serializer.toJson<String?>(notes),
      'myMealId': serializer.toJson<int?>(myMealId),
      'ingredientId': serializer.toJson<int?>(ingredientId),
      'groupId': serializer.toJson<String?>(groupId),
      'groupSource': serializer.toJson<String?>(groupSource),
      'groupOrder': serializer.toJson<int?>(groupOrder),
      'isGroupOriginal': serializer.toJson<bool>(isGroupOriginal),
      'ingredientsJson': serializer.toJson<String?>(ingredientsJson),
      'userInputText': serializer.toJson<String?>(userInputText),
      'originalFoodName': serializer.toJson<String?>(originalFoodName),
      'originalFoodNameEn': serializer.toJson<String?>(originalFoodNameEn),
      'originalCalories': serializer.toJson<double?>(originalCalories),
      'originalProtein': serializer.toJson<double?>(originalProtein),
      'originalCarbs': serializer.toJson<double?>(originalCarbs),
      'originalFat': serializer.toJson<double?>(originalFat),
      'originalIngredientsJson':
          serializer.toJson<String?>(originalIngredientsJson),
      'editCount': serializer.toJson<int>(editCount),
      'isUserCorrected': serializer.toJson<bool>(isUserCorrected),
      'correctionHistoryJson':
          serializer.toJson<String?>(correctionHistoryJson),
      'brandName': serializer.toJson<String?>(brandName),
      'brandNameEn': serializer.toJson<String?>(brandNameEn),
      'productName': serializer.toJson<String?>(productName),
      'productBarcode': serializer.toJson<String?>(productBarcode),
      'netWeight': serializer.toJson<double?>(netWeight),
      'netWeightUnit': serializer.toJson<String?>(netWeightUnit),
      'chainName': serializer.toJson<String?>(chainName),
      'productCategory': serializer.toJson<String?>(productCategory),
      'packageSize': serializer.toJson<String?>(packageSize),
      'nutritionSource': serializer.toJson<String?>(nutritionSource),
      'sceneContext': serializer.toJson<String?>(sceneContext),
      'detectedObjectsJson': serializer.toJson<String?>(detectedObjectsJson),
      'arBoundingBox': serializer.toJson<String?>(arBoundingBox),
      'estimatedWidthCm': serializer.toJson<double?>(estimatedWidthCm),
      'estimatedHeightCm': serializer.toJson<double?>(estimatedHeightCm),
      'estimatedDepthCm': serializer.toJson<double?>(estimatedDepthCm),
      'referenceObjectUsed': serializer.toJson<String?>(referenceObjectUsed),
      'referenceConfidence': serializer.toJson<double?>(referenceConfidence),
      'plateDiameterCm': serializer.toJson<double?>(plateDiameterCm),
      'estimatedVolumeMl': serializer.toJson<double?>(estimatedVolumeMl),
      'isCalibrated': serializer.toJson<bool>(isCalibrated),
      'arLabelsJson': serializer.toJson<String?>(arLabelsJson),
      'arImageWidth': serializer.toJson<double?>(arImageWidth),
      'arImageHeight': serializer.toJson<double?>(arImageHeight),
      'arPixelPerCm': serializer.toJson<double?>(arPixelPerCm),
      'healthConnectId': serializer.toJson<String?>(healthConnectId),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'firebaseDocId': serializer.toJson<String?>(firebaseDocId),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'thumbnailFirebasePath':
          serializer.toJson<String?>(thumbnailFirebasePath),
      'vitaminA': serializer.toJson<double?>(vitaminA),
      'vitaminC': serializer.toJson<double?>(vitaminC),
      'vitaminD': serializer.toJson<double?>(vitaminD),
      'vitaminE': serializer.toJson<double?>(vitaminE),
      'vitaminK': serializer.toJson<double?>(vitaminK),
      'thiamin': serializer.toJson<double?>(thiamin),
      'riboflavin': serializer.toJson<double?>(riboflavin),
      'niacin': serializer.toJson<double?>(niacin),
      'vitaminB6': serializer.toJson<double?>(vitaminB6),
      'folate': serializer.toJson<double?>(folate),
      'vitaminB12': serializer.toJson<double?>(vitaminB12),
      'calcium': serializer.toJson<double?>(calcium),
      'iron': serializer.toJson<double?>(iron),
      'magnesium': serializer.toJson<double?>(magnesium),
      'phosphorus': serializer.toJson<double?>(phosphorus),
      'zinc': serializer.toJson<double?>(zinc),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FoodEntryData copyWith(
          {int? id,
          String? foodName,
          Value<String?> foodNameEn = const Value.absent(),
          DateTime? timestamp,
          Value<String?> imagePath = const Value.absent(),
          MealType? mealType,
          double? servingSize,
          String? servingUnit,
          Value<double?> servingGrams = const Value.absent(),
          double? calories,
          double? protein,
          double? carbs,
          double? fat,
          double? baseCalories,
          double? baseProtein,
          double? baseCarbs,
          double? baseFat,
          Value<double?> fiber = const Value.absent(),
          Value<double?> sugar = const Value.absent(),
          Value<double?> sodium = const Value.absent(),
          Value<double?> cholesterol = const Value.absent(),
          Value<double?> saturatedFat = const Value.absent(),
          Value<double?> transFat = const Value.absent(),
          Value<double?> unsaturatedFat = const Value.absent(),
          Value<double?> monounsaturatedFat = const Value.absent(),
          Value<double?> polyunsaturatedFat = const Value.absent(),
          Value<double?> potassium = const Value.absent(),
          DataSource? source,
          FoodSearchMode? searchMode,
          Value<double?> aiConfidence = const Value.absent(),
          bool? isVerified,
          bool? isDeleted,
          Value<String?> notes = const Value.absent(),
          Value<int?> myMealId = const Value.absent(),
          Value<int?> ingredientId = const Value.absent(),
          Value<String?> groupId = const Value.absent(),
          Value<String?> groupSource = const Value.absent(),
          Value<int?> groupOrder = const Value.absent(),
          bool? isGroupOriginal,
          Value<String?> ingredientsJson = const Value.absent(),
          Value<String?> userInputText = const Value.absent(),
          Value<String?> originalFoodName = const Value.absent(),
          Value<String?> originalFoodNameEn = const Value.absent(),
          Value<double?> originalCalories = const Value.absent(),
          Value<double?> originalProtein = const Value.absent(),
          Value<double?> originalCarbs = const Value.absent(),
          Value<double?> originalFat = const Value.absent(),
          Value<String?> originalIngredientsJson = const Value.absent(),
          int? editCount,
          bool? isUserCorrected,
          Value<String?> correctionHistoryJson = const Value.absent(),
          Value<String?> brandName = const Value.absent(),
          Value<String?> brandNameEn = const Value.absent(),
          Value<String?> productName = const Value.absent(),
          Value<String?> productBarcode = const Value.absent(),
          Value<double?> netWeight = const Value.absent(),
          Value<String?> netWeightUnit = const Value.absent(),
          Value<String?> chainName = const Value.absent(),
          Value<String?> productCategory = const Value.absent(),
          Value<String?> packageSize = const Value.absent(),
          Value<String?> nutritionSource = const Value.absent(),
          Value<String?> sceneContext = const Value.absent(),
          Value<String?> detectedObjectsJson = const Value.absent(),
          Value<String?> arBoundingBox = const Value.absent(),
          Value<double?> estimatedWidthCm = const Value.absent(),
          Value<double?> estimatedHeightCm = const Value.absent(),
          Value<double?> estimatedDepthCm = const Value.absent(),
          Value<String?> referenceObjectUsed = const Value.absent(),
          Value<double?> referenceConfidence = const Value.absent(),
          Value<double?> plateDiameterCm = const Value.absent(),
          Value<double?> estimatedVolumeMl = const Value.absent(),
          bool? isCalibrated,
          Value<String?> arLabelsJson = const Value.absent(),
          Value<double?> arImageWidth = const Value.absent(),
          Value<double?> arImageHeight = const Value.absent(),
          Value<double?> arPixelPerCm = const Value.absent(),
          Value<String?> healthConnectId = const Value.absent(),
          Value<DateTime?> syncedAt = const Value.absent(),
          bool? isSynced,
          Value<String?> firebaseDocId = const Value.absent(),
          Value<DateTime?> lastSyncAt = const Value.absent(),
          Value<String?> thumbnailUrl = const Value.absent(),
          Value<String?> thumbnailFirebasePath = const Value.absent(),
          Value<double?> vitaminA = const Value.absent(),
          Value<double?> vitaminC = const Value.absent(),
          Value<double?> vitaminD = const Value.absent(),
          Value<double?> vitaminE = const Value.absent(),
          Value<double?> vitaminK = const Value.absent(),
          Value<double?> thiamin = const Value.absent(),
          Value<double?> riboflavin = const Value.absent(),
          Value<double?> niacin = const Value.absent(),
          Value<double?> vitaminB6 = const Value.absent(),
          Value<double?> folate = const Value.absent(),
          Value<double?> vitaminB12 = const Value.absent(),
          Value<double?> calcium = const Value.absent(),
          Value<double?> iron = const Value.absent(),
          Value<double?> magnesium = const Value.absent(),
          Value<double?> phosphorus = const Value.absent(),
          Value<double?> zinc = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      FoodEntryData(
        id: id ?? this.id,
        foodName: foodName ?? this.foodName,
        foodNameEn: foodNameEn.present ? foodNameEn.value : this.foodNameEn,
        timestamp: timestamp ?? this.timestamp,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        mealType: mealType ?? this.mealType,
        servingSize: servingSize ?? this.servingSize,
        servingUnit: servingUnit ?? this.servingUnit,
        servingGrams:
            servingGrams.present ? servingGrams.value : this.servingGrams,
        calories: calories ?? this.calories,
        protein: protein ?? this.protein,
        carbs: carbs ?? this.carbs,
        fat: fat ?? this.fat,
        baseCalories: baseCalories ?? this.baseCalories,
        baseProtein: baseProtein ?? this.baseProtein,
        baseCarbs: baseCarbs ?? this.baseCarbs,
        baseFat: baseFat ?? this.baseFat,
        fiber: fiber.present ? fiber.value : this.fiber,
        sugar: sugar.present ? sugar.value : this.sugar,
        sodium: sodium.present ? sodium.value : this.sodium,
        cholesterol: cholesterol.present ? cholesterol.value : this.cholesterol,
        saturatedFat:
            saturatedFat.present ? saturatedFat.value : this.saturatedFat,
        transFat: transFat.present ? transFat.value : this.transFat,
        unsaturatedFat:
            unsaturatedFat.present ? unsaturatedFat.value : this.unsaturatedFat,
        monounsaturatedFat: monounsaturatedFat.present
            ? monounsaturatedFat.value
            : this.monounsaturatedFat,
        polyunsaturatedFat: polyunsaturatedFat.present
            ? polyunsaturatedFat.value
            : this.polyunsaturatedFat,
        potassium: potassium.present ? potassium.value : this.potassium,
        source: source ?? this.source,
        searchMode: searchMode ?? this.searchMode,
        aiConfidence:
            aiConfidence.present ? aiConfidence.value : this.aiConfidence,
        isVerified: isVerified ?? this.isVerified,
        isDeleted: isDeleted ?? this.isDeleted,
        notes: notes.present ? notes.value : this.notes,
        myMealId: myMealId.present ? myMealId.value : this.myMealId,
        ingredientId:
            ingredientId.present ? ingredientId.value : this.ingredientId,
        groupId: groupId.present ? groupId.value : this.groupId,
        groupSource: groupSource.present ? groupSource.value : this.groupSource,
        groupOrder: groupOrder.present ? groupOrder.value : this.groupOrder,
        isGroupOriginal: isGroupOriginal ?? this.isGroupOriginal,
        ingredientsJson: ingredientsJson.present
            ? ingredientsJson.value
            : this.ingredientsJson,
        userInputText:
            userInputText.present ? userInputText.value : this.userInputText,
        originalFoodName: originalFoodName.present
            ? originalFoodName.value
            : this.originalFoodName,
        originalFoodNameEn: originalFoodNameEn.present
            ? originalFoodNameEn.value
            : this.originalFoodNameEn,
        originalCalories: originalCalories.present
            ? originalCalories.value
            : this.originalCalories,
        originalProtein: originalProtein.present
            ? originalProtein.value
            : this.originalProtein,
        originalCarbs:
            originalCarbs.present ? originalCarbs.value : this.originalCarbs,
        originalFat: originalFat.present ? originalFat.value : this.originalFat,
        originalIngredientsJson: originalIngredientsJson.present
            ? originalIngredientsJson.value
            : this.originalIngredientsJson,
        editCount: editCount ?? this.editCount,
        isUserCorrected: isUserCorrected ?? this.isUserCorrected,
        correctionHistoryJson: correctionHistoryJson.present
            ? correctionHistoryJson.value
            : this.correctionHistoryJson,
        brandName: brandName.present ? brandName.value : this.brandName,
        brandNameEn: brandNameEn.present ? brandNameEn.value : this.brandNameEn,
        productName: productName.present ? productName.value : this.productName,
        productBarcode:
            productBarcode.present ? productBarcode.value : this.productBarcode,
        netWeight: netWeight.present ? netWeight.value : this.netWeight,
        netWeightUnit:
            netWeightUnit.present ? netWeightUnit.value : this.netWeightUnit,
        chainName: chainName.present ? chainName.value : this.chainName,
        productCategory: productCategory.present
            ? productCategory.value
            : this.productCategory,
        packageSize: packageSize.present ? packageSize.value : this.packageSize,
        nutritionSource: nutritionSource.present
            ? nutritionSource.value
            : this.nutritionSource,
        sceneContext:
            sceneContext.present ? sceneContext.value : this.sceneContext,
        detectedObjectsJson: detectedObjectsJson.present
            ? detectedObjectsJson.value
            : this.detectedObjectsJson,
        arBoundingBox:
            arBoundingBox.present ? arBoundingBox.value : this.arBoundingBox,
        estimatedWidthCm: estimatedWidthCm.present
            ? estimatedWidthCm.value
            : this.estimatedWidthCm,
        estimatedHeightCm: estimatedHeightCm.present
            ? estimatedHeightCm.value
            : this.estimatedHeightCm,
        estimatedDepthCm: estimatedDepthCm.present
            ? estimatedDepthCm.value
            : this.estimatedDepthCm,
        referenceObjectUsed: referenceObjectUsed.present
            ? referenceObjectUsed.value
            : this.referenceObjectUsed,
        referenceConfidence: referenceConfidence.present
            ? referenceConfidence.value
            : this.referenceConfidence,
        plateDiameterCm: plateDiameterCm.present
            ? plateDiameterCm.value
            : this.plateDiameterCm,
        estimatedVolumeMl: estimatedVolumeMl.present
            ? estimatedVolumeMl.value
            : this.estimatedVolumeMl,
        isCalibrated: isCalibrated ?? this.isCalibrated,
        arLabelsJson:
            arLabelsJson.present ? arLabelsJson.value : this.arLabelsJson,
        arImageWidth:
            arImageWidth.present ? arImageWidth.value : this.arImageWidth,
        arImageHeight:
            arImageHeight.present ? arImageHeight.value : this.arImageHeight,
        arPixelPerCm:
            arPixelPerCm.present ? arPixelPerCm.value : this.arPixelPerCm,
        healthConnectId: healthConnectId.present
            ? healthConnectId.value
            : this.healthConnectId,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        isSynced: isSynced ?? this.isSynced,
        firebaseDocId:
            firebaseDocId.present ? firebaseDocId.value : this.firebaseDocId,
        lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
        thumbnailUrl:
            thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
        thumbnailFirebasePath: thumbnailFirebasePath.present
            ? thumbnailFirebasePath.value
            : this.thumbnailFirebasePath,
        vitaminA: vitaminA.present ? vitaminA.value : this.vitaminA,
        vitaminC: vitaminC.present ? vitaminC.value : this.vitaminC,
        vitaminD: vitaminD.present ? vitaminD.value : this.vitaminD,
        vitaminE: vitaminE.present ? vitaminE.value : this.vitaminE,
        vitaminK: vitaminK.present ? vitaminK.value : this.vitaminK,
        thiamin: thiamin.present ? thiamin.value : this.thiamin,
        riboflavin: riboflavin.present ? riboflavin.value : this.riboflavin,
        niacin: niacin.present ? niacin.value : this.niacin,
        vitaminB6: vitaminB6.present ? vitaminB6.value : this.vitaminB6,
        folate: folate.present ? folate.value : this.folate,
        vitaminB12: vitaminB12.present ? vitaminB12.value : this.vitaminB12,
        calcium: calcium.present ? calcium.value : this.calcium,
        iron: iron.present ? iron.value : this.iron,
        magnesium: magnesium.present ? magnesium.value : this.magnesium,
        phosphorus: phosphorus.present ? phosphorus.value : this.phosphorus,
        zinc: zinc.present ? zinc.value : this.zinc,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FoodEntryData copyWithCompanion(FoodEntriesCompanion data) {
    return FoodEntryData(
      id: data.id.present ? data.id.value : this.id,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      foodNameEn:
          data.foodNameEn.present ? data.foodNameEn.value : this.foodNameEn,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      servingSize:
          data.servingSize.present ? data.servingSize.value : this.servingSize,
      servingUnit:
          data.servingUnit.present ? data.servingUnit.value : this.servingUnit,
      servingGrams: data.servingGrams.present
          ? data.servingGrams.value
          : this.servingGrams,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      baseCalories: data.baseCalories.present
          ? data.baseCalories.value
          : this.baseCalories,
      baseProtein:
          data.baseProtein.present ? data.baseProtein.value : this.baseProtein,
      baseCarbs: data.baseCarbs.present ? data.baseCarbs.value : this.baseCarbs,
      baseFat: data.baseFat.present ? data.baseFat.value : this.baseFat,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      sugar: data.sugar.present ? data.sugar.value : this.sugar,
      sodium: data.sodium.present ? data.sodium.value : this.sodium,
      cholesterol:
          data.cholesterol.present ? data.cholesterol.value : this.cholesterol,
      saturatedFat: data.saturatedFat.present
          ? data.saturatedFat.value
          : this.saturatedFat,
      transFat: data.transFat.present ? data.transFat.value : this.transFat,
      unsaturatedFat: data.unsaturatedFat.present
          ? data.unsaturatedFat.value
          : this.unsaturatedFat,
      monounsaturatedFat: data.monounsaturatedFat.present
          ? data.monounsaturatedFat.value
          : this.monounsaturatedFat,
      polyunsaturatedFat: data.polyunsaturatedFat.present
          ? data.polyunsaturatedFat.value
          : this.polyunsaturatedFat,
      potassium: data.potassium.present ? data.potassium.value : this.potassium,
      source: data.source.present ? data.source.value : this.source,
      searchMode:
          data.searchMode.present ? data.searchMode.value : this.searchMode,
      aiConfidence: data.aiConfidence.present
          ? data.aiConfidence.value
          : this.aiConfidence,
      isVerified:
          data.isVerified.present ? data.isVerified.value : this.isVerified,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      notes: data.notes.present ? data.notes.value : this.notes,
      myMealId: data.myMealId.present ? data.myMealId.value : this.myMealId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      groupSource:
          data.groupSource.present ? data.groupSource.value : this.groupSource,
      groupOrder:
          data.groupOrder.present ? data.groupOrder.value : this.groupOrder,
      isGroupOriginal: data.isGroupOriginal.present
          ? data.isGroupOriginal.value
          : this.isGroupOriginal,
      ingredientsJson: data.ingredientsJson.present
          ? data.ingredientsJson.value
          : this.ingredientsJson,
      userInputText: data.userInputText.present
          ? data.userInputText.value
          : this.userInputText,
      originalFoodName: data.originalFoodName.present
          ? data.originalFoodName.value
          : this.originalFoodName,
      originalFoodNameEn: data.originalFoodNameEn.present
          ? data.originalFoodNameEn.value
          : this.originalFoodNameEn,
      originalCalories: data.originalCalories.present
          ? data.originalCalories.value
          : this.originalCalories,
      originalProtein: data.originalProtein.present
          ? data.originalProtein.value
          : this.originalProtein,
      originalCarbs: data.originalCarbs.present
          ? data.originalCarbs.value
          : this.originalCarbs,
      originalFat:
          data.originalFat.present ? data.originalFat.value : this.originalFat,
      originalIngredientsJson: data.originalIngredientsJson.present
          ? data.originalIngredientsJson.value
          : this.originalIngredientsJson,
      editCount: data.editCount.present ? data.editCount.value : this.editCount,
      isUserCorrected: data.isUserCorrected.present
          ? data.isUserCorrected.value
          : this.isUserCorrected,
      correctionHistoryJson: data.correctionHistoryJson.present
          ? data.correctionHistoryJson.value
          : this.correctionHistoryJson,
      brandName: data.brandName.present ? data.brandName.value : this.brandName,
      brandNameEn:
          data.brandNameEn.present ? data.brandNameEn.value : this.brandNameEn,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      productBarcode: data.productBarcode.present
          ? data.productBarcode.value
          : this.productBarcode,
      netWeight: data.netWeight.present ? data.netWeight.value : this.netWeight,
      netWeightUnit: data.netWeightUnit.present
          ? data.netWeightUnit.value
          : this.netWeightUnit,
      chainName: data.chainName.present ? data.chainName.value : this.chainName,
      productCategory: data.productCategory.present
          ? data.productCategory.value
          : this.productCategory,
      packageSize:
          data.packageSize.present ? data.packageSize.value : this.packageSize,
      nutritionSource: data.nutritionSource.present
          ? data.nutritionSource.value
          : this.nutritionSource,
      sceneContext: data.sceneContext.present
          ? data.sceneContext.value
          : this.sceneContext,
      detectedObjectsJson: data.detectedObjectsJson.present
          ? data.detectedObjectsJson.value
          : this.detectedObjectsJson,
      arBoundingBox: data.arBoundingBox.present
          ? data.arBoundingBox.value
          : this.arBoundingBox,
      estimatedWidthCm: data.estimatedWidthCm.present
          ? data.estimatedWidthCm.value
          : this.estimatedWidthCm,
      estimatedHeightCm: data.estimatedHeightCm.present
          ? data.estimatedHeightCm.value
          : this.estimatedHeightCm,
      estimatedDepthCm: data.estimatedDepthCm.present
          ? data.estimatedDepthCm.value
          : this.estimatedDepthCm,
      referenceObjectUsed: data.referenceObjectUsed.present
          ? data.referenceObjectUsed.value
          : this.referenceObjectUsed,
      referenceConfidence: data.referenceConfidence.present
          ? data.referenceConfidence.value
          : this.referenceConfidence,
      plateDiameterCm: data.plateDiameterCm.present
          ? data.plateDiameterCm.value
          : this.plateDiameterCm,
      estimatedVolumeMl: data.estimatedVolumeMl.present
          ? data.estimatedVolumeMl.value
          : this.estimatedVolumeMl,
      isCalibrated: data.isCalibrated.present
          ? data.isCalibrated.value
          : this.isCalibrated,
      arLabelsJson: data.arLabelsJson.present
          ? data.arLabelsJson.value
          : this.arLabelsJson,
      arImageWidth: data.arImageWidth.present
          ? data.arImageWidth.value
          : this.arImageWidth,
      arImageHeight: data.arImageHeight.present
          ? data.arImageHeight.value
          : this.arImageHeight,
      arPixelPerCm: data.arPixelPerCm.present
          ? data.arPixelPerCm.value
          : this.arPixelPerCm,
      healthConnectId: data.healthConnectId.present
          ? data.healthConnectId.value
          : this.healthConnectId,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      firebaseDocId: data.firebaseDocId.present
          ? data.firebaseDocId.value
          : this.firebaseDocId,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      thumbnailFirebasePath: data.thumbnailFirebasePath.present
          ? data.thumbnailFirebasePath.value
          : this.thumbnailFirebasePath,
      vitaminA: data.vitaminA.present ? data.vitaminA.value : this.vitaminA,
      vitaminC: data.vitaminC.present ? data.vitaminC.value : this.vitaminC,
      vitaminD: data.vitaminD.present ? data.vitaminD.value : this.vitaminD,
      vitaminE: data.vitaminE.present ? data.vitaminE.value : this.vitaminE,
      vitaminK: data.vitaminK.present ? data.vitaminK.value : this.vitaminK,
      thiamin: data.thiamin.present ? data.thiamin.value : this.thiamin,
      riboflavin:
          data.riboflavin.present ? data.riboflavin.value : this.riboflavin,
      niacin: data.niacin.present ? data.niacin.value : this.niacin,
      vitaminB6: data.vitaminB6.present ? data.vitaminB6.value : this.vitaminB6,
      folate: data.folate.present ? data.folate.value : this.folate,
      vitaminB12:
          data.vitaminB12.present ? data.vitaminB12.value : this.vitaminB12,
      calcium: data.calcium.present ? data.calcium.value : this.calcium,
      iron: data.iron.present ? data.iron.value : this.iron,
      magnesium: data.magnesium.present ? data.magnesium.value : this.magnesium,
      phosphorus:
          data.phosphorus.present ? data.phosphorus.value : this.phosphorus,
      zinc: data.zinc.present ? data.zinc.value : this.zinc,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodEntryData(')
          ..write('id: $id, ')
          ..write('foodName: $foodName, ')
          ..write('foodNameEn: $foodNameEn, ')
          ..write('timestamp: $timestamp, ')
          ..write('imagePath: $imagePath, ')
          ..write('mealType: $mealType, ')
          ..write('servingSize: $servingSize, ')
          ..write('servingUnit: $servingUnit, ')
          ..write('servingGrams: $servingGrams, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('baseCalories: $baseCalories, ')
          ..write('baseProtein: $baseProtein, ')
          ..write('baseCarbs: $baseCarbs, ')
          ..write('baseFat: $baseFat, ')
          ..write('fiber: $fiber, ')
          ..write('sugar: $sugar, ')
          ..write('sodium: $sodium, ')
          ..write('cholesterol: $cholesterol, ')
          ..write('saturatedFat: $saturatedFat, ')
          ..write('transFat: $transFat, ')
          ..write('unsaturatedFat: $unsaturatedFat, ')
          ..write('monounsaturatedFat: $monounsaturatedFat, ')
          ..write('polyunsaturatedFat: $polyunsaturatedFat, ')
          ..write('potassium: $potassium, ')
          ..write('source: $source, ')
          ..write('searchMode: $searchMode, ')
          ..write('aiConfidence: $aiConfidence, ')
          ..write('isVerified: $isVerified, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('notes: $notes, ')
          ..write('myMealId: $myMealId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('groupId: $groupId, ')
          ..write('groupSource: $groupSource, ')
          ..write('groupOrder: $groupOrder, ')
          ..write('isGroupOriginal: $isGroupOriginal, ')
          ..write('ingredientsJson: $ingredientsJson, ')
          ..write('userInputText: $userInputText, ')
          ..write('originalFoodName: $originalFoodName, ')
          ..write('originalFoodNameEn: $originalFoodNameEn, ')
          ..write('originalCalories: $originalCalories, ')
          ..write('originalProtein: $originalProtein, ')
          ..write('originalCarbs: $originalCarbs, ')
          ..write('originalFat: $originalFat, ')
          ..write('originalIngredientsJson: $originalIngredientsJson, ')
          ..write('editCount: $editCount, ')
          ..write('isUserCorrected: $isUserCorrected, ')
          ..write('correctionHistoryJson: $correctionHistoryJson, ')
          ..write('brandName: $brandName, ')
          ..write('brandNameEn: $brandNameEn, ')
          ..write('productName: $productName, ')
          ..write('productBarcode: $productBarcode, ')
          ..write('netWeight: $netWeight, ')
          ..write('netWeightUnit: $netWeightUnit, ')
          ..write('chainName: $chainName, ')
          ..write('productCategory: $productCategory, ')
          ..write('packageSize: $packageSize, ')
          ..write('nutritionSource: $nutritionSource, ')
          ..write('sceneContext: $sceneContext, ')
          ..write('detectedObjectsJson: $detectedObjectsJson, ')
          ..write('arBoundingBox: $arBoundingBox, ')
          ..write('estimatedWidthCm: $estimatedWidthCm, ')
          ..write('estimatedHeightCm: $estimatedHeightCm, ')
          ..write('estimatedDepthCm: $estimatedDepthCm, ')
          ..write('referenceObjectUsed: $referenceObjectUsed, ')
          ..write('referenceConfidence: $referenceConfidence, ')
          ..write('plateDiameterCm: $plateDiameterCm, ')
          ..write('estimatedVolumeMl: $estimatedVolumeMl, ')
          ..write('isCalibrated: $isCalibrated, ')
          ..write('arLabelsJson: $arLabelsJson, ')
          ..write('arImageWidth: $arImageWidth, ')
          ..write('arImageHeight: $arImageHeight, ')
          ..write('arPixelPerCm: $arPixelPerCm, ')
          ..write('healthConnectId: $healthConnectId, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('firebaseDocId: $firebaseDocId, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('thumbnailFirebasePath: $thumbnailFirebasePath, ')
          ..write('vitaminA: $vitaminA, ')
          ..write('vitaminC: $vitaminC, ')
          ..write('vitaminD: $vitaminD, ')
          ..write('vitaminE: $vitaminE, ')
          ..write('vitaminK: $vitaminK, ')
          ..write('thiamin: $thiamin, ')
          ..write('riboflavin: $riboflavin, ')
          ..write('niacin: $niacin, ')
          ..write('vitaminB6: $vitaminB6, ')
          ..write('folate: $folate, ')
          ..write('vitaminB12: $vitaminB12, ')
          ..write('calcium: $calcium, ')
          ..write('iron: $iron, ')
          ..write('magnesium: $magnesium, ')
          ..write('phosphorus: $phosphorus, ')
          ..write('zinc: $zinc, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        foodName,
        foodNameEn,
        timestamp,
        imagePath,
        mealType,
        servingSize,
        servingUnit,
        servingGrams,
        calories,
        protein,
        carbs,
        fat,
        baseCalories,
        baseProtein,
        baseCarbs,
        baseFat,
        fiber,
        sugar,
        sodium,
        cholesterol,
        saturatedFat,
        transFat,
        unsaturatedFat,
        monounsaturatedFat,
        polyunsaturatedFat,
        potassium,
        source,
        searchMode,
        aiConfidence,
        isVerified,
        isDeleted,
        notes,
        myMealId,
        ingredientId,
        groupId,
        groupSource,
        groupOrder,
        isGroupOriginal,
        ingredientsJson,
        userInputText,
        originalFoodName,
        originalFoodNameEn,
        originalCalories,
        originalProtein,
        originalCarbs,
        originalFat,
        originalIngredientsJson,
        editCount,
        isUserCorrected,
        correctionHistoryJson,
        brandName,
        brandNameEn,
        productName,
        productBarcode,
        netWeight,
        netWeightUnit,
        chainName,
        productCategory,
        packageSize,
        nutritionSource,
        sceneContext,
        detectedObjectsJson,
        arBoundingBox,
        estimatedWidthCm,
        estimatedHeightCm,
        estimatedDepthCm,
        referenceObjectUsed,
        referenceConfidence,
        plateDiameterCm,
        estimatedVolumeMl,
        isCalibrated,
        arLabelsJson,
        arImageWidth,
        arImageHeight,
        arPixelPerCm,
        healthConnectId,
        syncedAt,
        isSynced,
        firebaseDocId,
        lastSyncAt,
        thumbnailUrl,
        thumbnailFirebasePath,
        vitaminA,
        vitaminC,
        vitaminD,
        vitaminE,
        vitaminK,
        thiamin,
        riboflavin,
        niacin,
        vitaminB6,
        folate,
        vitaminB12,
        calcium,
        iron,
        magnesium,
        phosphorus,
        zinc,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodEntryData &&
          other.id == this.id &&
          other.foodName == this.foodName &&
          other.foodNameEn == this.foodNameEn &&
          other.timestamp == this.timestamp &&
          other.imagePath == this.imagePath &&
          other.mealType == this.mealType &&
          other.servingSize == this.servingSize &&
          other.servingUnit == this.servingUnit &&
          other.servingGrams == this.servingGrams &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.baseCalories == this.baseCalories &&
          other.baseProtein == this.baseProtein &&
          other.baseCarbs == this.baseCarbs &&
          other.baseFat == this.baseFat &&
          other.fiber == this.fiber &&
          other.sugar == this.sugar &&
          other.sodium == this.sodium &&
          other.cholesterol == this.cholesterol &&
          other.saturatedFat == this.saturatedFat &&
          other.transFat == this.transFat &&
          other.unsaturatedFat == this.unsaturatedFat &&
          other.monounsaturatedFat == this.monounsaturatedFat &&
          other.polyunsaturatedFat == this.polyunsaturatedFat &&
          other.potassium == this.potassium &&
          other.source == this.source &&
          other.searchMode == this.searchMode &&
          other.aiConfidence == this.aiConfidence &&
          other.isVerified == this.isVerified &&
          other.isDeleted == this.isDeleted &&
          other.notes == this.notes &&
          other.myMealId == this.myMealId &&
          other.ingredientId == this.ingredientId &&
          other.groupId == this.groupId &&
          other.groupSource == this.groupSource &&
          other.groupOrder == this.groupOrder &&
          other.isGroupOriginal == this.isGroupOriginal &&
          other.ingredientsJson == this.ingredientsJson &&
          other.userInputText == this.userInputText &&
          other.originalFoodName == this.originalFoodName &&
          other.originalFoodNameEn == this.originalFoodNameEn &&
          other.originalCalories == this.originalCalories &&
          other.originalProtein == this.originalProtein &&
          other.originalCarbs == this.originalCarbs &&
          other.originalFat == this.originalFat &&
          other.originalIngredientsJson == this.originalIngredientsJson &&
          other.editCount == this.editCount &&
          other.isUserCorrected == this.isUserCorrected &&
          other.correctionHistoryJson == this.correctionHistoryJson &&
          other.brandName == this.brandName &&
          other.brandNameEn == this.brandNameEn &&
          other.productName == this.productName &&
          other.productBarcode == this.productBarcode &&
          other.netWeight == this.netWeight &&
          other.netWeightUnit == this.netWeightUnit &&
          other.chainName == this.chainName &&
          other.productCategory == this.productCategory &&
          other.packageSize == this.packageSize &&
          other.nutritionSource == this.nutritionSource &&
          other.sceneContext == this.sceneContext &&
          other.detectedObjectsJson == this.detectedObjectsJson &&
          other.arBoundingBox == this.arBoundingBox &&
          other.estimatedWidthCm == this.estimatedWidthCm &&
          other.estimatedHeightCm == this.estimatedHeightCm &&
          other.estimatedDepthCm == this.estimatedDepthCm &&
          other.referenceObjectUsed == this.referenceObjectUsed &&
          other.referenceConfidence == this.referenceConfidence &&
          other.plateDiameterCm == this.plateDiameterCm &&
          other.estimatedVolumeMl == this.estimatedVolumeMl &&
          other.isCalibrated == this.isCalibrated &&
          other.arLabelsJson == this.arLabelsJson &&
          other.arImageWidth == this.arImageWidth &&
          other.arImageHeight == this.arImageHeight &&
          other.arPixelPerCm == this.arPixelPerCm &&
          other.healthConnectId == this.healthConnectId &&
          other.syncedAt == this.syncedAt &&
          other.isSynced == this.isSynced &&
          other.firebaseDocId == this.firebaseDocId &&
          other.lastSyncAt == this.lastSyncAt &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.thumbnailFirebasePath == this.thumbnailFirebasePath &&
          other.vitaminA == this.vitaminA &&
          other.vitaminC == this.vitaminC &&
          other.vitaminD == this.vitaminD &&
          other.vitaminE == this.vitaminE &&
          other.vitaminK == this.vitaminK &&
          other.thiamin == this.thiamin &&
          other.riboflavin == this.riboflavin &&
          other.niacin == this.niacin &&
          other.vitaminB6 == this.vitaminB6 &&
          other.folate == this.folate &&
          other.vitaminB12 == this.vitaminB12 &&
          other.calcium == this.calcium &&
          other.iron == this.iron &&
          other.magnesium == this.magnesium &&
          other.phosphorus == this.phosphorus &&
          other.zinc == this.zinc &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FoodEntriesCompanion extends UpdateCompanion<FoodEntryData> {
  Value<int> id;
  Value<String> foodName;
  Value<String?> foodNameEn;
  Value<DateTime> timestamp;
  Value<String?> imagePath;
  Value<MealType> mealType;
  Value<double> servingSize;
  Value<String> servingUnit;
  Value<double?> servingGrams;
  Value<double> calories;
  Value<double> protein;
  Value<double> carbs;
  Value<double> fat;
  Value<double> baseCalories;
  Value<double> baseProtein;
  Value<double> baseCarbs;
  Value<double> baseFat;
  Value<double?> fiber;
  Value<double?> sugar;
  Value<double?> sodium;
  Value<double?> cholesterol;
  Value<double?> saturatedFat;
  Value<double?> transFat;
  Value<double?> unsaturatedFat;
  Value<double?> monounsaturatedFat;
  Value<double?> polyunsaturatedFat;
  Value<double?> potassium;
  Value<DataSource> source;
  Value<FoodSearchMode> searchMode;
  Value<double?> aiConfidence;
  Value<bool> isVerified;
  Value<bool> isDeleted;
  Value<String?> notes;
  Value<int?> myMealId;
  Value<int?> ingredientId;
  Value<String?> groupId;
  Value<String?> groupSource;
  Value<int?> groupOrder;
  Value<bool> isGroupOriginal;
  Value<String?> ingredientsJson;
  Value<String?> userInputText;
  Value<String?> originalFoodName;
  Value<String?> originalFoodNameEn;
  Value<double?> originalCalories;
  Value<double?> originalProtein;
  Value<double?> originalCarbs;
  Value<double?> originalFat;
  Value<String?> originalIngredientsJson;
  Value<int> editCount;
  Value<bool> isUserCorrected;
  Value<String?> correctionHistoryJson;
  Value<String?> brandName;
  Value<String?> brandNameEn;
  Value<String?> productName;
  Value<String?> productBarcode;
  Value<double?> netWeight;
  Value<String?> netWeightUnit;
  Value<String?> chainName;
  Value<String?> productCategory;
  Value<String?> packageSize;
  Value<String?> nutritionSource;
  Value<String?> sceneContext;
  Value<String?> detectedObjectsJson;
  Value<String?> arBoundingBox;
  Value<double?> estimatedWidthCm;
  Value<double?> estimatedHeightCm;
  Value<double?> estimatedDepthCm;
  Value<String?> referenceObjectUsed;
  Value<double?> referenceConfidence;
  Value<double?> plateDiameterCm;
  Value<double?> estimatedVolumeMl;
  Value<bool> isCalibrated;
  Value<String?> arLabelsJson;
  Value<double?> arImageWidth;
  Value<double?> arImageHeight;
  Value<double?> arPixelPerCm;
  Value<String?> healthConnectId;
  Value<DateTime?> syncedAt;
  Value<bool> isSynced;
  Value<String?> firebaseDocId;
  Value<DateTime?> lastSyncAt;
  Value<String?> thumbnailUrl;
  Value<String?> thumbnailFirebasePath;
  Value<double?> vitaminA;
  Value<double?> vitaminC;
  Value<double?> vitaminD;
  Value<double?> vitaminE;
  Value<double?> vitaminK;
  Value<double?> thiamin;
  Value<double?> riboflavin;
  Value<double?> niacin;
  Value<double?> vitaminB6;
  Value<double?> folate;
  Value<double?> vitaminB12;
  Value<double?> calcium;
  Value<double?> iron;
  Value<double?> magnesium;
  Value<double?> phosphorus;
  Value<double?> zinc;
  Value<DateTime> createdAt;
  Value<DateTime> updatedAt;
  FoodEntriesCompanion({
    this.id = const Value.absent(),
    this.foodName = const Value.absent(),
    this.foodNameEn = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.mealType = const Value.absent(),
    this.servingSize = const Value.absent(),
    this.servingUnit = const Value.absent(),
    this.servingGrams = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.baseCalories = const Value.absent(),
    this.baseProtein = const Value.absent(),
    this.baseCarbs = const Value.absent(),
    this.baseFat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sugar = const Value.absent(),
    this.sodium = const Value.absent(),
    this.cholesterol = const Value.absent(),
    this.saturatedFat = const Value.absent(),
    this.transFat = const Value.absent(),
    this.unsaturatedFat = const Value.absent(),
    this.monounsaturatedFat = const Value.absent(),
    this.polyunsaturatedFat = const Value.absent(),
    this.potassium = const Value.absent(),
    this.source = const Value.absent(),
    this.searchMode = const Value.absent(),
    this.aiConfidence = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.notes = const Value.absent(),
    this.myMealId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.groupSource = const Value.absent(),
    this.groupOrder = const Value.absent(),
    this.isGroupOriginal = const Value.absent(),
    this.ingredientsJson = const Value.absent(),
    this.userInputText = const Value.absent(),
    this.originalFoodName = const Value.absent(),
    this.originalFoodNameEn = const Value.absent(),
    this.originalCalories = const Value.absent(),
    this.originalProtein = const Value.absent(),
    this.originalCarbs = const Value.absent(),
    this.originalFat = const Value.absent(),
    this.originalIngredientsJson = const Value.absent(),
    this.editCount = const Value.absent(),
    this.isUserCorrected = const Value.absent(),
    this.correctionHistoryJson = const Value.absent(),
    this.brandName = const Value.absent(),
    this.brandNameEn = const Value.absent(),
    this.productName = const Value.absent(),
    this.productBarcode = const Value.absent(),
    this.netWeight = const Value.absent(),
    this.netWeightUnit = const Value.absent(),
    this.chainName = const Value.absent(),
    this.productCategory = const Value.absent(),
    this.packageSize = const Value.absent(),
    this.nutritionSource = const Value.absent(),
    this.sceneContext = const Value.absent(),
    this.detectedObjectsJson = const Value.absent(),
    this.arBoundingBox = const Value.absent(),
    this.estimatedWidthCm = const Value.absent(),
    this.estimatedHeightCm = const Value.absent(),
    this.estimatedDepthCm = const Value.absent(),
    this.referenceObjectUsed = const Value.absent(),
    this.referenceConfidence = const Value.absent(),
    this.plateDiameterCm = const Value.absent(),
    this.estimatedVolumeMl = const Value.absent(),
    this.isCalibrated = const Value.absent(),
    this.arLabelsJson = const Value.absent(),
    this.arImageWidth = const Value.absent(),
    this.arImageHeight = const Value.absent(),
    this.arPixelPerCm = const Value.absent(),
    this.healthConnectId = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.firebaseDocId = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.thumbnailFirebasePath = const Value.absent(),
    this.vitaminA = const Value.absent(),
    this.vitaminC = const Value.absent(),
    this.vitaminD = const Value.absent(),
    this.vitaminE = const Value.absent(),
    this.vitaminK = const Value.absent(),
    this.thiamin = const Value.absent(),
    this.riboflavin = const Value.absent(),
    this.niacin = const Value.absent(),
    this.vitaminB6 = const Value.absent(),
    this.folate = const Value.absent(),
    this.vitaminB12 = const Value.absent(),
    this.calcium = const Value.absent(),
    this.iron = const Value.absent(),
    this.magnesium = const Value.absent(),
    this.phosphorus = const Value.absent(),
    this.zinc = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FoodEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String foodName,
    this.foodNameEn = const Value.absent(),
    required DateTime timestamp,
    this.imagePath = const Value.absent(),
    required MealType mealType,
    required double servingSize,
    required String servingUnit,
    this.servingGrams = const Value.absent(),
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    this.baseCalories = const Value.absent(),
    this.baseProtein = const Value.absent(),
    this.baseCarbs = const Value.absent(),
    this.baseFat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sugar = const Value.absent(),
    this.sodium = const Value.absent(),
    this.cholesterol = const Value.absent(),
    this.saturatedFat = const Value.absent(),
    this.transFat = const Value.absent(),
    this.unsaturatedFat = const Value.absent(),
    this.monounsaturatedFat = const Value.absent(),
    this.polyunsaturatedFat = const Value.absent(),
    this.potassium = const Value.absent(),
    required DataSource source,
    this.searchMode = const Value.absent(),
    this.aiConfidence = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.notes = const Value.absent(),
    this.myMealId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.groupSource = const Value.absent(),
    this.groupOrder = const Value.absent(),
    this.isGroupOriginal = const Value.absent(),
    this.ingredientsJson = const Value.absent(),
    this.userInputText = const Value.absent(),
    this.originalFoodName = const Value.absent(),
    this.originalFoodNameEn = const Value.absent(),
    this.originalCalories = const Value.absent(),
    this.originalProtein = const Value.absent(),
    this.originalCarbs = const Value.absent(),
    this.originalFat = const Value.absent(),
    this.originalIngredientsJson = const Value.absent(),
    this.editCount = const Value.absent(),
    this.isUserCorrected = const Value.absent(),
    this.correctionHistoryJson = const Value.absent(),
    this.brandName = const Value.absent(),
    this.brandNameEn = const Value.absent(),
    this.productName = const Value.absent(),
    this.productBarcode = const Value.absent(),
    this.netWeight = const Value.absent(),
    this.netWeightUnit = const Value.absent(),
    this.chainName = const Value.absent(),
    this.productCategory = const Value.absent(),
    this.packageSize = const Value.absent(),
    this.nutritionSource = const Value.absent(),
    this.sceneContext = const Value.absent(),
    this.detectedObjectsJson = const Value.absent(),
    this.arBoundingBox = const Value.absent(),
    this.estimatedWidthCm = const Value.absent(),
    this.estimatedHeightCm = const Value.absent(),
    this.estimatedDepthCm = const Value.absent(),
    this.referenceObjectUsed = const Value.absent(),
    this.referenceConfidence = const Value.absent(),
    this.plateDiameterCm = const Value.absent(),
    this.estimatedVolumeMl = const Value.absent(),
    this.isCalibrated = const Value.absent(),
    this.arLabelsJson = const Value.absent(),
    this.arImageWidth = const Value.absent(),
    this.arImageHeight = const Value.absent(),
    this.arPixelPerCm = const Value.absent(),
    this.healthConnectId = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.firebaseDocId = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.thumbnailFirebasePath = const Value.absent(),
    this.vitaminA = const Value.absent(),
    this.vitaminC = const Value.absent(),
    this.vitaminD = const Value.absent(),
    this.vitaminE = const Value.absent(),
    this.vitaminK = const Value.absent(),
    this.thiamin = const Value.absent(),
    this.riboflavin = const Value.absent(),
    this.niacin = const Value.absent(),
    this.vitaminB6 = const Value.absent(),
    this.folate = const Value.absent(),
    this.vitaminB12 = const Value.absent(),
    this.calcium = const Value.absent(),
    this.iron = const Value.absent(),
    this.magnesium = const Value.absent(),
    this.phosphorus = const Value.absent(),
    this.zinc = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : foodName = Value(foodName),
        timestamp = Value(timestamp),
        mealType = Value(mealType),
        servingSize = Value(servingSize),
        servingUnit = Value(servingUnit),
        calories = Value(calories),
        protein = Value(protein),
        carbs = Value(carbs),
        fat = Value(fat),
        source = Value(source);
  static Insertable<FoodEntryData> custom({
    Expression<int>? id,
    Expression<String>? foodName,
    Expression<String>? foodNameEn,
    Expression<DateTime>? timestamp,
    Expression<String>? imagePath,
    Expression<int>? mealType,
    Expression<double>? servingSize,
    Expression<String>? servingUnit,
    Expression<double>? servingGrams,
    Expression<double>? calories,
    Expression<double>? protein,
    Expression<double>? carbs,
    Expression<double>? fat,
    Expression<double>? baseCalories,
    Expression<double>? baseProtein,
    Expression<double>? baseCarbs,
    Expression<double>? baseFat,
    Expression<double>? fiber,
    Expression<double>? sugar,
    Expression<double>? sodium,
    Expression<double>? cholesterol,
    Expression<double>? saturatedFat,
    Expression<double>? transFat,
    Expression<double>? unsaturatedFat,
    Expression<double>? monounsaturatedFat,
    Expression<double>? polyunsaturatedFat,
    Expression<double>? potassium,
    Expression<int>? source,
    Expression<int>? searchMode,
    Expression<double>? aiConfidence,
    Expression<bool>? isVerified,
    Expression<bool>? isDeleted,
    Expression<String>? notes,
    Expression<int>? myMealId,
    Expression<int>? ingredientId,
    Expression<String>? groupId,
    Expression<String>? groupSource,
    Expression<int>? groupOrder,
    Expression<bool>? isGroupOriginal,
    Expression<String>? ingredientsJson,
    Expression<String>? userInputText,
    Expression<String>? originalFoodName,
    Expression<String>? originalFoodNameEn,
    Expression<double>? originalCalories,
    Expression<double>? originalProtein,
    Expression<double>? originalCarbs,
    Expression<double>? originalFat,
    Expression<String>? originalIngredientsJson,
    Expression<int>? editCount,
    Expression<bool>? isUserCorrected,
    Expression<String>? correctionHistoryJson,
    Expression<String>? brandName,
    Expression<String>? brandNameEn,
    Expression<String>? productName,
    Expression<String>? productBarcode,
    Expression<double>? netWeight,
    Expression<String>? netWeightUnit,
    Expression<String>? chainName,
    Expression<String>? productCategory,
    Expression<String>? packageSize,
    Expression<String>? nutritionSource,
    Expression<String>? sceneContext,
    Expression<String>? detectedObjectsJson,
    Expression<String>? arBoundingBox,
    Expression<double>? estimatedWidthCm,
    Expression<double>? estimatedHeightCm,
    Expression<double>? estimatedDepthCm,
    Expression<String>? referenceObjectUsed,
    Expression<double>? referenceConfidence,
    Expression<double>? plateDiameterCm,
    Expression<double>? estimatedVolumeMl,
    Expression<bool>? isCalibrated,
    Expression<String>? arLabelsJson,
    Expression<double>? arImageWidth,
    Expression<double>? arImageHeight,
    Expression<double>? arPixelPerCm,
    Expression<String>? healthConnectId,
    Expression<DateTime>? syncedAt,
    Expression<bool>? isSynced,
    Expression<String>? firebaseDocId,
    Expression<DateTime>? lastSyncAt,
    Expression<String>? thumbnailUrl,
    Expression<String>? thumbnailFirebasePath,
    Expression<double>? vitaminA,
    Expression<double>? vitaminC,
    Expression<double>? vitaminD,
    Expression<double>? vitaminE,
    Expression<double>? vitaminK,
    Expression<double>? thiamin,
    Expression<double>? riboflavin,
    Expression<double>? niacin,
    Expression<double>? vitaminB6,
    Expression<double>? folate,
    Expression<double>? vitaminB12,
    Expression<double>? calcium,
    Expression<double>? iron,
    Expression<double>? magnesium,
    Expression<double>? phosphorus,
    Expression<double>? zinc,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (foodName != null) 'food_name': foodName,
      if (foodNameEn != null) 'food_name_en': foodNameEn,
      if (timestamp != null) 'timestamp': timestamp,
      if (imagePath != null) 'image_path': imagePath,
      if (mealType != null) 'meal_type': mealType,
      if (servingSize != null) 'serving_size': servingSize,
      if (servingUnit != null) 'serving_unit': servingUnit,
      if (servingGrams != null) 'serving_grams': servingGrams,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (baseCalories != null) 'base_calories': baseCalories,
      if (baseProtein != null) 'base_protein': baseProtein,
      if (baseCarbs != null) 'base_carbs': baseCarbs,
      if (baseFat != null) 'base_fat': baseFat,
      if (fiber != null) 'fiber': fiber,
      if (sugar != null) 'sugar': sugar,
      if (sodium != null) 'sodium': sodium,
      if (cholesterol != null) 'cholesterol': cholesterol,
      if (saturatedFat != null) 'saturated_fat': saturatedFat,
      if (transFat != null) 'trans_fat': transFat,
      if (unsaturatedFat != null) 'unsaturated_fat': unsaturatedFat,
      if (monounsaturatedFat != null) 'monounsaturated_fat': monounsaturatedFat,
      if (polyunsaturatedFat != null) 'polyunsaturated_fat': polyunsaturatedFat,
      if (potassium != null) 'potassium': potassium,
      if (source != null) 'source': source,
      if (searchMode != null) 'search_mode': searchMode,
      if (aiConfidence != null) 'ai_confidence': aiConfidence,
      if (isVerified != null) 'is_verified': isVerified,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (notes != null) 'notes': notes,
      if (myMealId != null) 'my_meal_id': myMealId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (groupId != null) 'group_id': groupId,
      if (groupSource != null) 'group_source': groupSource,
      if (groupOrder != null) 'group_order': groupOrder,
      if (isGroupOriginal != null) 'is_group_original': isGroupOriginal,
      if (ingredientsJson != null) 'ingredients_json': ingredientsJson,
      if (userInputText != null) 'user_input_text': userInputText,
      if (originalFoodName != null) 'original_food_name': originalFoodName,
      if (originalFoodNameEn != null)
        'original_food_name_en': originalFoodNameEn,
      if (originalCalories != null) 'original_calories': originalCalories,
      if (originalProtein != null) 'original_protein': originalProtein,
      if (originalCarbs != null) 'original_carbs': originalCarbs,
      if (originalFat != null) 'original_fat': originalFat,
      if (originalIngredientsJson != null)
        'original_ingredients_json': originalIngredientsJson,
      if (editCount != null) 'edit_count': editCount,
      if (isUserCorrected != null) 'is_user_corrected': isUserCorrected,
      if (correctionHistoryJson != null)
        'correction_history_json': correctionHistoryJson,
      if (brandName != null) 'brand_name': brandName,
      if (brandNameEn != null) 'brand_name_en': brandNameEn,
      if (productName != null) 'product_name': productName,
      if (productBarcode != null) 'product_barcode': productBarcode,
      if (netWeight != null) 'net_weight': netWeight,
      if (netWeightUnit != null) 'net_weight_unit': netWeightUnit,
      if (chainName != null) 'chain_name': chainName,
      if (productCategory != null) 'product_category': productCategory,
      if (packageSize != null) 'package_size': packageSize,
      if (nutritionSource != null) 'nutrition_source': nutritionSource,
      if (sceneContext != null) 'scene_context': sceneContext,
      if (detectedObjectsJson != null)
        'detected_objects_json': detectedObjectsJson,
      if (arBoundingBox != null) 'ar_bounding_box': arBoundingBox,
      if (estimatedWidthCm != null) 'estimated_width_cm': estimatedWidthCm,
      if (estimatedHeightCm != null) 'estimated_height_cm': estimatedHeightCm,
      if (estimatedDepthCm != null) 'estimated_depth_cm': estimatedDepthCm,
      if (referenceObjectUsed != null)
        'reference_object_used': referenceObjectUsed,
      if (referenceConfidence != null)
        'reference_confidence': referenceConfidence,
      if (plateDiameterCm != null) 'plate_diameter_cm': plateDiameterCm,
      if (estimatedVolumeMl != null) 'estimated_volume_ml': estimatedVolumeMl,
      if (isCalibrated != null) 'is_calibrated': isCalibrated,
      if (arLabelsJson != null) 'ar_labels_json': arLabelsJson,
      if (arImageWidth != null) 'ar_image_width': arImageWidth,
      if (arImageHeight != null) 'ar_image_height': arImageHeight,
      if (arPixelPerCm != null) 'ar_pixel_per_cm': arPixelPerCm,
      if (healthConnectId != null) 'health_connect_id': healthConnectId,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (firebaseDocId != null) 'firebase_doc_id': firebaseDocId,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (thumbnailFirebasePath != null)
        'thumbnail_firebase_path': thumbnailFirebasePath,
      if (vitaminA != null) 'vitamin_a': vitaminA,
      if (vitaminC != null) 'vitamin_c': vitaminC,
      if (vitaminD != null) 'vitamin_d': vitaminD,
      if (vitaminE != null) 'vitamin_e': vitaminE,
      if (vitaminK != null) 'vitamin_k': vitaminK,
      if (thiamin != null) 'thiamin': thiamin,
      if (riboflavin != null) 'riboflavin': riboflavin,
      if (niacin != null) 'niacin': niacin,
      if (vitaminB6 != null) 'vitamin_b6': vitaminB6,
      if (folate != null) 'folate': folate,
      if (vitaminB12 != null) 'vitamin_b12': vitaminB12,
      if (calcium != null) 'calcium': calcium,
      if (iron != null) 'iron': iron,
      if (magnesium != null) 'magnesium': magnesium,
      if (phosphorus != null) 'phosphorus': phosphorus,
      if (zinc != null) 'zinc': zinc,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FoodEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? foodName,
      Value<String?>? foodNameEn,
      Value<DateTime>? timestamp,
      Value<String?>? imagePath,
      Value<MealType>? mealType,
      Value<double>? servingSize,
      Value<String>? servingUnit,
      Value<double?>? servingGrams,
      Value<double>? calories,
      Value<double>? protein,
      Value<double>? carbs,
      Value<double>? fat,
      Value<double>? baseCalories,
      Value<double>? baseProtein,
      Value<double>? baseCarbs,
      Value<double>? baseFat,
      Value<double?>? fiber,
      Value<double?>? sugar,
      Value<double?>? sodium,
      Value<double?>? cholesterol,
      Value<double?>? saturatedFat,
      Value<double?>? transFat,
      Value<double?>? unsaturatedFat,
      Value<double?>? monounsaturatedFat,
      Value<double?>? polyunsaturatedFat,
      Value<double?>? potassium,
      Value<DataSource>? source,
      Value<FoodSearchMode>? searchMode,
      Value<double?>? aiConfidence,
      Value<bool>? isVerified,
      Value<bool>? isDeleted,
      Value<String?>? notes,
      Value<int?>? myMealId,
      Value<int?>? ingredientId,
      Value<String?>? groupId,
      Value<String?>? groupSource,
      Value<int?>? groupOrder,
      Value<bool>? isGroupOriginal,
      Value<String?>? ingredientsJson,
      Value<String?>? userInputText,
      Value<String?>? originalFoodName,
      Value<String?>? originalFoodNameEn,
      Value<double?>? originalCalories,
      Value<double?>? originalProtein,
      Value<double?>? originalCarbs,
      Value<double?>? originalFat,
      Value<String?>? originalIngredientsJson,
      Value<int>? editCount,
      Value<bool>? isUserCorrected,
      Value<String?>? correctionHistoryJson,
      Value<String?>? brandName,
      Value<String?>? brandNameEn,
      Value<String?>? productName,
      Value<String?>? productBarcode,
      Value<double?>? netWeight,
      Value<String?>? netWeightUnit,
      Value<String?>? chainName,
      Value<String?>? productCategory,
      Value<String?>? packageSize,
      Value<String?>? nutritionSource,
      Value<String?>? sceneContext,
      Value<String?>? detectedObjectsJson,
      Value<String?>? arBoundingBox,
      Value<double?>? estimatedWidthCm,
      Value<double?>? estimatedHeightCm,
      Value<double?>? estimatedDepthCm,
      Value<String?>? referenceObjectUsed,
      Value<double?>? referenceConfidence,
      Value<double?>? plateDiameterCm,
      Value<double?>? estimatedVolumeMl,
      Value<bool>? isCalibrated,
      Value<String?>? arLabelsJson,
      Value<double?>? arImageWidth,
      Value<double?>? arImageHeight,
      Value<double?>? arPixelPerCm,
      Value<String?>? healthConnectId,
      Value<DateTime?>? syncedAt,
      Value<bool>? isSynced,
      Value<String?>? firebaseDocId,
      Value<DateTime?>? lastSyncAt,
      Value<String?>? thumbnailUrl,
      Value<String?>? thumbnailFirebasePath,
      Value<double?>? vitaminA,
      Value<double?>? vitaminC,
      Value<double?>? vitaminD,
      Value<double?>? vitaminE,
      Value<double?>? vitaminK,
      Value<double?>? thiamin,
      Value<double?>? riboflavin,
      Value<double?>? niacin,
      Value<double?>? vitaminB6,
      Value<double?>? folate,
      Value<double?>? vitaminB12,
      Value<double?>? calcium,
      Value<double?>? iron,
      Value<double?>? magnesium,
      Value<double?>? phosphorus,
      Value<double?>? zinc,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return FoodEntriesCompanion(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      foodNameEn: foodNameEn ?? this.foodNameEn,
      timestamp: timestamp ?? this.timestamp,
      imagePath: imagePath ?? this.imagePath,
      mealType: mealType ?? this.mealType,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      servingGrams: servingGrams ?? this.servingGrams,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      baseCalories: baseCalories ?? this.baseCalories,
      baseProtein: baseProtein ?? this.baseProtein,
      baseCarbs: baseCarbs ?? this.baseCarbs,
      baseFat: baseFat ?? this.baseFat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      cholesterol: cholesterol ?? this.cholesterol,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      transFat: transFat ?? this.transFat,
      unsaturatedFat: unsaturatedFat ?? this.unsaturatedFat,
      monounsaturatedFat: monounsaturatedFat ?? this.monounsaturatedFat,
      polyunsaturatedFat: polyunsaturatedFat ?? this.polyunsaturatedFat,
      potassium: potassium ?? this.potassium,
      source: source ?? this.source,
      searchMode: searchMode ?? this.searchMode,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      isVerified: isVerified ?? this.isVerified,
      isDeleted: isDeleted ?? this.isDeleted,
      notes: notes ?? this.notes,
      myMealId: myMealId ?? this.myMealId,
      ingredientId: ingredientId ?? this.ingredientId,
      groupId: groupId ?? this.groupId,
      groupSource: groupSource ?? this.groupSource,
      groupOrder: groupOrder ?? this.groupOrder,
      isGroupOriginal: isGroupOriginal ?? this.isGroupOriginal,
      ingredientsJson: ingredientsJson ?? this.ingredientsJson,
      userInputText: userInputText ?? this.userInputText,
      originalFoodName: originalFoodName ?? this.originalFoodName,
      originalFoodNameEn: originalFoodNameEn ?? this.originalFoodNameEn,
      originalCalories: originalCalories ?? this.originalCalories,
      originalProtein: originalProtein ?? this.originalProtein,
      originalCarbs: originalCarbs ?? this.originalCarbs,
      originalFat: originalFat ?? this.originalFat,
      originalIngredientsJson:
          originalIngredientsJson ?? this.originalIngredientsJson,
      editCount: editCount ?? this.editCount,
      isUserCorrected: isUserCorrected ?? this.isUserCorrected,
      correctionHistoryJson:
          correctionHistoryJson ?? this.correctionHistoryJson,
      brandName: brandName ?? this.brandName,
      brandNameEn: brandNameEn ?? this.brandNameEn,
      productName: productName ?? this.productName,
      productBarcode: productBarcode ?? this.productBarcode,
      netWeight: netWeight ?? this.netWeight,
      netWeightUnit: netWeightUnit ?? this.netWeightUnit,
      chainName: chainName ?? this.chainName,
      productCategory: productCategory ?? this.productCategory,
      packageSize: packageSize ?? this.packageSize,
      nutritionSource: nutritionSource ?? this.nutritionSource,
      sceneContext: sceneContext ?? this.sceneContext,
      detectedObjectsJson: detectedObjectsJson ?? this.detectedObjectsJson,
      arBoundingBox: arBoundingBox ?? this.arBoundingBox,
      estimatedWidthCm: estimatedWidthCm ?? this.estimatedWidthCm,
      estimatedHeightCm: estimatedHeightCm ?? this.estimatedHeightCm,
      estimatedDepthCm: estimatedDepthCm ?? this.estimatedDepthCm,
      referenceObjectUsed: referenceObjectUsed ?? this.referenceObjectUsed,
      referenceConfidence: referenceConfidence ?? this.referenceConfidence,
      plateDiameterCm: plateDiameterCm ?? this.plateDiameterCm,
      estimatedVolumeMl: estimatedVolumeMl ?? this.estimatedVolumeMl,
      isCalibrated: isCalibrated ?? this.isCalibrated,
      arLabelsJson: arLabelsJson ?? this.arLabelsJson,
      arImageWidth: arImageWidth ?? this.arImageWidth,
      arImageHeight: arImageHeight ?? this.arImageHeight,
      arPixelPerCm: arPixelPerCm ?? this.arPixelPerCm,
      healthConnectId: healthConnectId ?? this.healthConnectId,
      syncedAt: syncedAt ?? this.syncedAt,
      isSynced: isSynced ?? this.isSynced,
      firebaseDocId: firebaseDocId ?? this.firebaseDocId,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      thumbnailFirebasePath:
          thumbnailFirebasePath ?? this.thumbnailFirebasePath,
      vitaminA: vitaminA ?? this.vitaminA,
      vitaminC: vitaminC ?? this.vitaminC,
      vitaminD: vitaminD ?? this.vitaminD,
      vitaminE: vitaminE ?? this.vitaminE,
      vitaminK: vitaminK ?? this.vitaminK,
      thiamin: thiamin ?? this.thiamin,
      riboflavin: riboflavin ?? this.riboflavin,
      niacin: niacin ?? this.niacin,
      vitaminB6: vitaminB6 ?? this.vitaminB6,
      folate: folate ?? this.folate,
      vitaminB12: vitaminB12 ?? this.vitaminB12,
      calcium: calcium ?? this.calcium,
      iron: iron ?? this.iron,
      magnesium: magnesium ?? this.magnesium,
      phosphorus: phosphorus ?? this.phosphorus,
      zinc: zinc ?? this.zinc,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (foodNameEn.present) {
      map['food_name_en'] = Variable<String>(foodNameEn.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<int>(
          $FoodEntriesTable.$convertermealType.toSql(mealType.value));
    }
    if (servingSize.present) {
      map['serving_size'] = Variable<double>(servingSize.value);
    }
    if (servingUnit.present) {
      map['serving_unit'] = Variable<String>(servingUnit.value);
    }
    if (servingGrams.present) {
      map['serving_grams'] = Variable<double>(servingGrams.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (baseCalories.present) {
      map['base_calories'] = Variable<double>(baseCalories.value);
    }
    if (baseProtein.present) {
      map['base_protein'] = Variable<double>(baseProtein.value);
    }
    if (baseCarbs.present) {
      map['base_carbs'] = Variable<double>(baseCarbs.value);
    }
    if (baseFat.present) {
      map['base_fat'] = Variable<double>(baseFat.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<double>(fiber.value);
    }
    if (sugar.present) {
      map['sugar'] = Variable<double>(sugar.value);
    }
    if (sodium.present) {
      map['sodium'] = Variable<double>(sodium.value);
    }
    if (cholesterol.present) {
      map['cholesterol'] = Variable<double>(cholesterol.value);
    }
    if (saturatedFat.present) {
      map['saturated_fat'] = Variable<double>(saturatedFat.value);
    }
    if (transFat.present) {
      map['trans_fat'] = Variable<double>(transFat.value);
    }
    if (unsaturatedFat.present) {
      map['unsaturated_fat'] = Variable<double>(unsaturatedFat.value);
    }
    if (monounsaturatedFat.present) {
      map['monounsaturated_fat'] = Variable<double>(monounsaturatedFat.value);
    }
    if (polyunsaturatedFat.present) {
      map['polyunsaturated_fat'] = Variable<double>(polyunsaturatedFat.value);
    }
    if (potassium.present) {
      map['potassium'] = Variable<double>(potassium.value);
    }
    if (source.present) {
      map['source'] =
          Variable<int>($FoodEntriesTable.$convertersource.toSql(source.value));
    }
    if (searchMode.present) {
      map['search_mode'] = Variable<int>(
          $FoodEntriesTable.$convertersearchMode.toSql(searchMode.value));
    }
    if (aiConfidence.present) {
      map['ai_confidence'] = Variable<double>(aiConfidence.value);
    }
    if (isVerified.present) {
      map['is_verified'] = Variable<bool>(isVerified.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (myMealId.present) {
      map['my_meal_id'] = Variable<int>(myMealId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<int>(ingredientId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (groupSource.present) {
      map['group_source'] = Variable<String>(groupSource.value);
    }
    if (groupOrder.present) {
      map['group_order'] = Variable<int>(groupOrder.value);
    }
    if (isGroupOriginal.present) {
      map['is_group_original'] = Variable<bool>(isGroupOriginal.value);
    }
    if (ingredientsJson.present) {
      map['ingredients_json'] = Variable<String>(ingredientsJson.value);
    }
    if (userInputText.present) {
      map['user_input_text'] = Variable<String>(userInputText.value);
    }
    if (originalFoodName.present) {
      map['original_food_name'] = Variable<String>(originalFoodName.value);
    }
    if (originalFoodNameEn.present) {
      map['original_food_name_en'] = Variable<String>(originalFoodNameEn.value);
    }
    if (originalCalories.present) {
      map['original_calories'] = Variable<double>(originalCalories.value);
    }
    if (originalProtein.present) {
      map['original_protein'] = Variable<double>(originalProtein.value);
    }
    if (originalCarbs.present) {
      map['original_carbs'] = Variable<double>(originalCarbs.value);
    }
    if (originalFat.present) {
      map['original_fat'] = Variable<double>(originalFat.value);
    }
    if (originalIngredientsJson.present) {
      map['original_ingredients_json'] =
          Variable<String>(originalIngredientsJson.value);
    }
    if (editCount.present) {
      map['edit_count'] = Variable<int>(editCount.value);
    }
    if (isUserCorrected.present) {
      map['is_user_corrected'] = Variable<bool>(isUserCorrected.value);
    }
    if (correctionHistoryJson.present) {
      map['correction_history_json'] =
          Variable<String>(correctionHistoryJson.value);
    }
    if (brandName.present) {
      map['brand_name'] = Variable<String>(brandName.value);
    }
    if (brandNameEn.present) {
      map['brand_name_en'] = Variable<String>(brandNameEn.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (productBarcode.present) {
      map['product_barcode'] = Variable<String>(productBarcode.value);
    }
    if (netWeight.present) {
      map['net_weight'] = Variable<double>(netWeight.value);
    }
    if (netWeightUnit.present) {
      map['net_weight_unit'] = Variable<String>(netWeightUnit.value);
    }
    if (chainName.present) {
      map['chain_name'] = Variable<String>(chainName.value);
    }
    if (productCategory.present) {
      map['product_category'] = Variable<String>(productCategory.value);
    }
    if (packageSize.present) {
      map['package_size'] = Variable<String>(packageSize.value);
    }
    if (nutritionSource.present) {
      map['nutrition_source'] = Variable<String>(nutritionSource.value);
    }
    if (sceneContext.present) {
      map['scene_context'] = Variable<String>(sceneContext.value);
    }
    if (detectedObjectsJson.present) {
      map['detected_objects_json'] =
          Variable<String>(detectedObjectsJson.value);
    }
    if (arBoundingBox.present) {
      map['ar_bounding_box'] = Variable<String>(arBoundingBox.value);
    }
    if (estimatedWidthCm.present) {
      map['estimated_width_cm'] = Variable<double>(estimatedWidthCm.value);
    }
    if (estimatedHeightCm.present) {
      map['estimated_height_cm'] = Variable<double>(estimatedHeightCm.value);
    }
    if (estimatedDepthCm.present) {
      map['estimated_depth_cm'] = Variable<double>(estimatedDepthCm.value);
    }
    if (referenceObjectUsed.present) {
      map['reference_object_used'] =
          Variable<String>(referenceObjectUsed.value);
    }
    if (referenceConfidence.present) {
      map['reference_confidence'] = Variable<double>(referenceConfidence.value);
    }
    if (plateDiameterCm.present) {
      map['plate_diameter_cm'] = Variable<double>(plateDiameterCm.value);
    }
    if (estimatedVolumeMl.present) {
      map['estimated_volume_ml'] = Variable<double>(estimatedVolumeMl.value);
    }
    if (isCalibrated.present) {
      map['is_calibrated'] = Variable<bool>(isCalibrated.value);
    }
    if (arLabelsJson.present) {
      map['ar_labels_json'] = Variable<String>(arLabelsJson.value);
    }
    if (arImageWidth.present) {
      map['ar_image_width'] = Variable<double>(arImageWidth.value);
    }
    if (arImageHeight.present) {
      map['ar_image_height'] = Variable<double>(arImageHeight.value);
    }
    if (arPixelPerCm.present) {
      map['ar_pixel_per_cm'] = Variable<double>(arPixelPerCm.value);
    }
    if (healthConnectId.present) {
      map['health_connect_id'] = Variable<String>(healthConnectId.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (firebaseDocId.present) {
      map['firebase_doc_id'] = Variable<String>(firebaseDocId.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (thumbnailFirebasePath.present) {
      map['thumbnail_firebase_path'] =
          Variable<String>(thumbnailFirebasePath.value);
    }
    if (vitaminA.present) {
      map['vitamin_a'] = Variable<double>(vitaminA.value);
    }
    if (vitaminC.present) {
      map['vitamin_c'] = Variable<double>(vitaminC.value);
    }
    if (vitaminD.present) {
      map['vitamin_d'] = Variable<double>(vitaminD.value);
    }
    if (vitaminE.present) {
      map['vitamin_e'] = Variable<double>(vitaminE.value);
    }
    if (vitaminK.present) {
      map['vitamin_k'] = Variable<double>(vitaminK.value);
    }
    if (thiamin.present) {
      map['thiamin'] = Variable<double>(thiamin.value);
    }
    if (riboflavin.present) {
      map['riboflavin'] = Variable<double>(riboflavin.value);
    }
    if (niacin.present) {
      map['niacin'] = Variable<double>(niacin.value);
    }
    if (vitaminB6.present) {
      map['vitamin_b6'] = Variable<double>(vitaminB6.value);
    }
    if (folate.present) {
      map['folate'] = Variable<double>(folate.value);
    }
    if (vitaminB12.present) {
      map['vitamin_b12'] = Variable<double>(vitaminB12.value);
    }
    if (calcium.present) {
      map['calcium'] = Variable<double>(calcium.value);
    }
    if (iron.present) {
      map['iron'] = Variable<double>(iron.value);
    }
    if (magnesium.present) {
      map['magnesium'] = Variable<double>(magnesium.value);
    }
    if (phosphorus.present) {
      map['phosphorus'] = Variable<double>(phosphorus.value);
    }
    if (zinc.present) {
      map['zinc'] = Variable<double>(zinc.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodEntriesCompanion(')
          ..write('id: $id, ')
          ..write('foodName: $foodName, ')
          ..write('foodNameEn: $foodNameEn, ')
          ..write('timestamp: $timestamp, ')
          ..write('imagePath: $imagePath, ')
          ..write('mealType: $mealType, ')
          ..write('servingSize: $servingSize, ')
          ..write('servingUnit: $servingUnit, ')
          ..write('servingGrams: $servingGrams, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('baseCalories: $baseCalories, ')
          ..write('baseProtein: $baseProtein, ')
          ..write('baseCarbs: $baseCarbs, ')
          ..write('baseFat: $baseFat, ')
          ..write('fiber: $fiber, ')
          ..write('sugar: $sugar, ')
          ..write('sodium: $sodium, ')
          ..write('cholesterol: $cholesterol, ')
          ..write('saturatedFat: $saturatedFat, ')
          ..write('transFat: $transFat, ')
          ..write('unsaturatedFat: $unsaturatedFat, ')
          ..write('monounsaturatedFat: $monounsaturatedFat, ')
          ..write('polyunsaturatedFat: $polyunsaturatedFat, ')
          ..write('potassium: $potassium, ')
          ..write('source: $source, ')
          ..write('searchMode: $searchMode, ')
          ..write('aiConfidence: $aiConfidence, ')
          ..write('isVerified: $isVerified, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('notes: $notes, ')
          ..write('myMealId: $myMealId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('groupId: $groupId, ')
          ..write('groupSource: $groupSource, ')
          ..write('groupOrder: $groupOrder, ')
          ..write('isGroupOriginal: $isGroupOriginal, ')
          ..write('ingredientsJson: $ingredientsJson, ')
          ..write('userInputText: $userInputText, ')
          ..write('originalFoodName: $originalFoodName, ')
          ..write('originalFoodNameEn: $originalFoodNameEn, ')
          ..write('originalCalories: $originalCalories, ')
          ..write('originalProtein: $originalProtein, ')
          ..write('originalCarbs: $originalCarbs, ')
          ..write('originalFat: $originalFat, ')
          ..write('originalIngredientsJson: $originalIngredientsJson, ')
          ..write('editCount: $editCount, ')
          ..write('isUserCorrected: $isUserCorrected, ')
          ..write('correctionHistoryJson: $correctionHistoryJson, ')
          ..write('brandName: $brandName, ')
          ..write('brandNameEn: $brandNameEn, ')
          ..write('productName: $productName, ')
          ..write('productBarcode: $productBarcode, ')
          ..write('netWeight: $netWeight, ')
          ..write('netWeightUnit: $netWeightUnit, ')
          ..write('chainName: $chainName, ')
          ..write('productCategory: $productCategory, ')
          ..write('packageSize: $packageSize, ')
          ..write('nutritionSource: $nutritionSource, ')
          ..write('sceneContext: $sceneContext, ')
          ..write('detectedObjectsJson: $detectedObjectsJson, ')
          ..write('arBoundingBox: $arBoundingBox, ')
          ..write('estimatedWidthCm: $estimatedWidthCm, ')
          ..write('estimatedHeightCm: $estimatedHeightCm, ')
          ..write('estimatedDepthCm: $estimatedDepthCm, ')
          ..write('referenceObjectUsed: $referenceObjectUsed, ')
          ..write('referenceConfidence: $referenceConfidence, ')
          ..write('plateDiameterCm: $plateDiameterCm, ')
          ..write('estimatedVolumeMl: $estimatedVolumeMl, ')
          ..write('isCalibrated: $isCalibrated, ')
          ..write('arLabelsJson: $arLabelsJson, ')
          ..write('arImageWidth: $arImageWidth, ')
          ..write('arImageHeight: $arImageHeight, ')
          ..write('arPixelPerCm: $arPixelPerCm, ')
          ..write('healthConnectId: $healthConnectId, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('firebaseDocId: $firebaseDocId, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('thumbnailFirebasePath: $thumbnailFirebasePath, ')
          ..write('vitaminA: $vitaminA, ')
          ..write('vitaminC: $vitaminC, ')
          ..write('vitaminD: $vitaminD, ')
          ..write('vitaminE: $vitaminE, ')
          ..write('vitaminK: $vitaminK, ')
          ..write('thiamin: $thiamin, ')
          ..write('riboflavin: $riboflavin, ')
          ..write('niacin: $niacin, ')
          ..write('vitaminB6: $vitaminB6, ')
          ..write('folate: $folate, ')
          ..write('vitaminB12: $vitaminB12, ')
          ..write('calcium: $calcium, ')
          ..write('iron: $iron, ')
          ..write('magnesium: $magnesium, ')
          ..write('phosphorus: $phosphorus, ')
          ..write('zinc: $zinc, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, IngredientData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
      'name_en', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _baseAmountMeta =
      const VerificationMeta('baseAmount');
  @override
  late final GeneratedColumn<double> baseAmount = GeneratedColumn<double>(
      'base_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _baseUnitMeta =
      const VerificationMeta('baseUnit');
  @override
  late final GeneratedColumn<String> baseUnit = GeneratedColumn<String>(
      'base_unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _caloriesPerBaseMeta =
      const VerificationMeta('caloriesPerBase');
  @override
  late final GeneratedColumn<double> caloriesPerBase = GeneratedColumn<double>(
      'calories_per_base', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _proteinPerBaseMeta =
      const VerificationMeta('proteinPerBase');
  @override
  late final GeneratedColumn<double> proteinPerBase = GeneratedColumn<double>(
      'protein_per_base', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _carbsPerBaseMeta =
      const VerificationMeta('carbsPerBase');
  @override
  late final GeneratedColumn<double> carbsPerBase = GeneratedColumn<double>(
      'carbs_per_base', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fatPerBaseMeta =
      const VerificationMeta('fatPerBase');
  @override
  late final GeneratedColumn<double> fatPerBase = GeneratedColumn<double>(
      'fat_per_base', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fiberPerBaseMeta =
      const VerificationMeta('fiberPerBase');
  @override
  late final GeneratedColumn<double> fiberPerBase = GeneratedColumn<double>(
      'fiber_per_base', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sugarPerBaseMeta =
      const VerificationMeta('sugarPerBase');
  @override
  late final GeneratedColumn<double> sugarPerBase = GeneratedColumn<double>(
      'sugar_per_base', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sodiumPerBaseMeta =
      const VerificationMeta('sodiumPerBase');
  @override
  late final GeneratedColumn<double> sodiumPerBase = GeneratedColumn<double>(
      'sodium_per_base', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usageCountMeta =
      const VerificationMeta('usageCount');
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
      'usage_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        nameEn,
        baseAmount,
        baseUnit,
        caloriesPerBase,
        proteinPerBase,
        carbsPerBase,
        fatPerBase,
        fiberPerBase,
        sugarPerBase,
        sodiumPerBase,
        source,
        usageCount,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(Insertable<IngredientData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(_nameEnMeta,
          nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta));
    }
    if (data.containsKey('base_amount')) {
      context.handle(
          _baseAmountMeta,
          baseAmount.isAcceptableOrUnknown(
              data['base_amount']!, _baseAmountMeta));
    } else if (isInserting) {
      context.missing(_baseAmountMeta);
    }
    if (data.containsKey('base_unit')) {
      context.handle(_baseUnitMeta,
          baseUnit.isAcceptableOrUnknown(data['base_unit']!, _baseUnitMeta));
    } else if (isInserting) {
      context.missing(_baseUnitMeta);
    }
    if (data.containsKey('calories_per_base')) {
      context.handle(
          _caloriesPerBaseMeta,
          caloriesPerBase.isAcceptableOrUnknown(
              data['calories_per_base']!, _caloriesPerBaseMeta));
    } else if (isInserting) {
      context.missing(_caloriesPerBaseMeta);
    }
    if (data.containsKey('protein_per_base')) {
      context.handle(
          _proteinPerBaseMeta,
          proteinPerBase.isAcceptableOrUnknown(
              data['protein_per_base']!, _proteinPerBaseMeta));
    } else if (isInserting) {
      context.missing(_proteinPerBaseMeta);
    }
    if (data.containsKey('carbs_per_base')) {
      context.handle(
          _carbsPerBaseMeta,
          carbsPerBase.isAcceptableOrUnknown(
              data['carbs_per_base']!, _carbsPerBaseMeta));
    } else if (isInserting) {
      context.missing(_carbsPerBaseMeta);
    }
    if (data.containsKey('fat_per_base')) {
      context.handle(
          _fatPerBaseMeta,
          fatPerBase.isAcceptableOrUnknown(
              data['fat_per_base']!, _fatPerBaseMeta));
    } else if (isInserting) {
      context.missing(_fatPerBaseMeta);
    }
    if (data.containsKey('fiber_per_base')) {
      context.handle(
          _fiberPerBaseMeta,
          fiberPerBase.isAcceptableOrUnknown(
              data['fiber_per_base']!, _fiberPerBaseMeta));
    }
    if (data.containsKey('sugar_per_base')) {
      context.handle(
          _sugarPerBaseMeta,
          sugarPerBase.isAcceptableOrUnknown(
              data['sugar_per_base']!, _sugarPerBaseMeta));
    }
    if (data.containsKey('sodium_per_base')) {
      context.handle(
          _sodiumPerBaseMeta,
          sodiumPerBase.isAcceptableOrUnknown(
              data['sodium_per_base']!, _sodiumPerBaseMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('usage_count')) {
      context.handle(
          _usageCountMeta,
          usageCount.isAcceptableOrUnknown(
              data['usage_count']!, _usageCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IngredientData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      nameEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_en']),
      baseAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}base_amount'])!,
      baseUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}base_unit'])!,
      caloriesPerBase: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}calories_per_base'])!,
      proteinPerBase: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}protein_per_base'])!,
      carbsPerBase: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs_per_base'])!,
      fatPerBase: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat_per_base'])!,
      fiberPerBase: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fiber_per_base']),
      sugarPerBase: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sugar_per_base']),
      sodiumPerBase: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sodium_per_base']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      usageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }
}

class IngredientData extends DataClass implements Insertable<IngredientData> {
  int id;
  String name;
  String? nameEn;
  double baseAmount;
  String baseUnit;
  double caloriesPerBase;
  double proteinPerBase;
  double carbsPerBase;
  double fatPerBase;
  double? fiberPerBase;
  double? sugarPerBase;
  double? sodiumPerBase;
  String source;
  int usageCount;
  DateTime createdAt;
  DateTime updatedAt;
  IngredientData(
      {required this.id,
      required this.name,
      this.nameEn,
      required this.baseAmount,
      required this.baseUnit,
      required this.caloriesPerBase,
      required this.proteinPerBase,
      required this.carbsPerBase,
      required this.fatPerBase,
      this.fiberPerBase,
      this.sugarPerBase,
      this.sodiumPerBase,
      required this.source,
      required this.usageCount,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nameEn != null) {
      map['name_en'] = Variable<String>(nameEn);
    }
    map['base_amount'] = Variable<double>(baseAmount);
    map['base_unit'] = Variable<String>(baseUnit);
    map['calories_per_base'] = Variable<double>(caloriesPerBase);
    map['protein_per_base'] = Variable<double>(proteinPerBase);
    map['carbs_per_base'] = Variable<double>(carbsPerBase);
    map['fat_per_base'] = Variable<double>(fatPerBase);
    if (!nullToAbsent || fiberPerBase != null) {
      map['fiber_per_base'] = Variable<double>(fiberPerBase);
    }
    if (!nullToAbsent || sugarPerBase != null) {
      map['sugar_per_base'] = Variable<double>(sugarPerBase);
    }
    if (!nullToAbsent || sodiumPerBase != null) {
      map['sodium_per_base'] = Variable<double>(sodiumPerBase);
    }
    map['source'] = Variable<String>(source);
    map['usage_count'] = Variable<int>(usageCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      id: Value(id),
      name: Value(name),
      nameEn:
          nameEn == null && nullToAbsent ? const Value.absent() : Value(nameEn),
      baseAmount: Value(baseAmount),
      baseUnit: Value(baseUnit),
      caloriesPerBase: Value(caloriesPerBase),
      proteinPerBase: Value(proteinPerBase),
      carbsPerBase: Value(carbsPerBase),
      fatPerBase: Value(fatPerBase),
      fiberPerBase: fiberPerBase == null && nullToAbsent
          ? const Value.absent()
          : Value(fiberPerBase),
      sugarPerBase: sugarPerBase == null && nullToAbsent
          ? const Value.absent()
          : Value(sugarPerBase),
      sodiumPerBase: sodiumPerBase == null && nullToAbsent
          ? const Value.absent()
          : Value(sodiumPerBase),
      source: Value(source),
      usageCount: Value(usageCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory IngredientData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameEn: serializer.fromJson<String?>(json['nameEn']),
      baseAmount: serializer.fromJson<double>(json['baseAmount']),
      baseUnit: serializer.fromJson<String>(json['baseUnit']),
      caloriesPerBase: serializer.fromJson<double>(json['caloriesPerBase']),
      proteinPerBase: serializer.fromJson<double>(json['proteinPerBase']),
      carbsPerBase: serializer.fromJson<double>(json['carbsPerBase']),
      fatPerBase: serializer.fromJson<double>(json['fatPerBase']),
      fiberPerBase: serializer.fromJson<double?>(json['fiberPerBase']),
      sugarPerBase: serializer.fromJson<double?>(json['sugarPerBase']),
      sodiumPerBase: serializer.fromJson<double?>(json['sodiumPerBase']),
      source: serializer.fromJson<String>(json['source']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameEn': serializer.toJson<String?>(nameEn),
      'baseAmount': serializer.toJson<double>(baseAmount),
      'baseUnit': serializer.toJson<String>(baseUnit),
      'caloriesPerBase': serializer.toJson<double>(caloriesPerBase),
      'proteinPerBase': serializer.toJson<double>(proteinPerBase),
      'carbsPerBase': serializer.toJson<double>(carbsPerBase),
      'fatPerBase': serializer.toJson<double>(fatPerBase),
      'fiberPerBase': serializer.toJson<double?>(fiberPerBase),
      'sugarPerBase': serializer.toJson<double?>(sugarPerBase),
      'sodiumPerBase': serializer.toJson<double?>(sodiumPerBase),
      'source': serializer.toJson<String>(source),
      'usageCount': serializer.toJson<int>(usageCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  IngredientData copyWith(
          {int? id,
          String? name,
          Value<String?> nameEn = const Value.absent(),
          double? baseAmount,
          String? baseUnit,
          double? caloriesPerBase,
          double? proteinPerBase,
          double? carbsPerBase,
          double? fatPerBase,
          Value<double?> fiberPerBase = const Value.absent(),
          Value<double?> sugarPerBase = const Value.absent(),
          Value<double?> sodiumPerBase = const Value.absent(),
          String? source,
          int? usageCount,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      IngredientData(
        id: id ?? this.id,
        name: name ?? this.name,
        nameEn: nameEn.present ? nameEn.value : this.nameEn,
        baseAmount: baseAmount ?? this.baseAmount,
        baseUnit: baseUnit ?? this.baseUnit,
        caloriesPerBase: caloriesPerBase ?? this.caloriesPerBase,
        proteinPerBase: proteinPerBase ?? this.proteinPerBase,
        carbsPerBase: carbsPerBase ?? this.carbsPerBase,
        fatPerBase: fatPerBase ?? this.fatPerBase,
        fiberPerBase:
            fiberPerBase.present ? fiberPerBase.value : this.fiberPerBase,
        sugarPerBase:
            sugarPerBase.present ? sugarPerBase.value : this.sugarPerBase,
        sodiumPerBase:
            sodiumPerBase.present ? sodiumPerBase.value : this.sodiumPerBase,
        source: source ?? this.source,
        usageCount: usageCount ?? this.usageCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  IngredientData copyWithCompanion(IngredientsCompanion data) {
    return IngredientData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      baseAmount:
          data.baseAmount.present ? data.baseAmount.value : this.baseAmount,
      baseUnit: data.baseUnit.present ? data.baseUnit.value : this.baseUnit,
      caloriesPerBase: data.caloriesPerBase.present
          ? data.caloriesPerBase.value
          : this.caloriesPerBase,
      proteinPerBase: data.proteinPerBase.present
          ? data.proteinPerBase.value
          : this.proteinPerBase,
      carbsPerBase: data.carbsPerBase.present
          ? data.carbsPerBase.value
          : this.carbsPerBase,
      fatPerBase:
          data.fatPerBase.present ? data.fatPerBase.value : this.fatPerBase,
      fiberPerBase: data.fiberPerBase.present
          ? data.fiberPerBase.value
          : this.fiberPerBase,
      sugarPerBase: data.sugarPerBase.present
          ? data.sugarPerBase.value
          : this.sugarPerBase,
      sodiumPerBase: data.sodiumPerBase.present
          ? data.sodiumPerBase.value
          : this.sodiumPerBase,
      source: data.source.present ? data.source.value : this.source,
      usageCount:
          data.usageCount.present ? data.usageCount.value : this.usageCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameEn: $nameEn, ')
          ..write('baseAmount: $baseAmount, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('caloriesPerBase: $caloriesPerBase, ')
          ..write('proteinPerBase: $proteinPerBase, ')
          ..write('carbsPerBase: $carbsPerBase, ')
          ..write('fatPerBase: $fatPerBase, ')
          ..write('fiberPerBase: $fiberPerBase, ')
          ..write('sugarPerBase: $sugarPerBase, ')
          ..write('sodiumPerBase: $sodiumPerBase, ')
          ..write('source: $source, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      nameEn,
      baseAmount,
      baseUnit,
      caloriesPerBase,
      proteinPerBase,
      carbsPerBase,
      fatPerBase,
      fiberPerBase,
      sugarPerBase,
      sodiumPerBase,
      source,
      usageCount,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientData &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameEn == this.nameEn &&
          other.baseAmount == this.baseAmount &&
          other.baseUnit == this.baseUnit &&
          other.caloriesPerBase == this.caloriesPerBase &&
          other.proteinPerBase == this.proteinPerBase &&
          other.carbsPerBase == this.carbsPerBase &&
          other.fatPerBase == this.fatPerBase &&
          other.fiberPerBase == this.fiberPerBase &&
          other.sugarPerBase == this.sugarPerBase &&
          other.sodiumPerBase == this.sodiumPerBase &&
          other.source == this.source &&
          other.usageCount == this.usageCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class IngredientsCompanion extends UpdateCompanion<IngredientData> {
  Value<int> id;
  Value<String> name;
  Value<String?> nameEn;
  Value<double> baseAmount;
  Value<String> baseUnit;
  Value<double> caloriesPerBase;
  Value<double> proteinPerBase;
  Value<double> carbsPerBase;
  Value<double> fatPerBase;
  Value<double?> fiberPerBase;
  Value<double?> sugarPerBase;
  Value<double?> sodiumPerBase;
  Value<String> source;
  Value<int> usageCount;
  Value<DateTime> createdAt;
  Value<DateTime> updatedAt;
  IngredientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.baseAmount = const Value.absent(),
    this.baseUnit = const Value.absent(),
    this.caloriesPerBase = const Value.absent(),
    this.proteinPerBase = const Value.absent(),
    this.carbsPerBase = const Value.absent(),
    this.fatPerBase = const Value.absent(),
    this.fiberPerBase = const Value.absent(),
    this.sugarPerBase = const Value.absent(),
    this.sodiumPerBase = const Value.absent(),
    this.source = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  IngredientsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.nameEn = const Value.absent(),
    required double baseAmount,
    required String baseUnit,
    required double caloriesPerBase,
    required double proteinPerBase,
    required double carbsPerBase,
    required double fatPerBase,
    this.fiberPerBase = const Value.absent(),
    this.sugarPerBase = const Value.absent(),
    this.sodiumPerBase = const Value.absent(),
    required String source,
    this.usageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        baseAmount = Value(baseAmount),
        baseUnit = Value(baseUnit),
        caloriesPerBase = Value(caloriesPerBase),
        proteinPerBase = Value(proteinPerBase),
        carbsPerBase = Value(carbsPerBase),
        fatPerBase = Value(fatPerBase),
        source = Value(source);
  static Insertable<IngredientData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameEn,
    Expression<double>? baseAmount,
    Expression<String>? baseUnit,
    Expression<double>? caloriesPerBase,
    Expression<double>? proteinPerBase,
    Expression<double>? carbsPerBase,
    Expression<double>? fatPerBase,
    Expression<double>? fiberPerBase,
    Expression<double>? sugarPerBase,
    Expression<double>? sodiumPerBase,
    Expression<String>? source,
    Expression<int>? usageCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameEn != null) 'name_en': nameEn,
      if (baseAmount != null) 'base_amount': baseAmount,
      if (baseUnit != null) 'base_unit': baseUnit,
      if (caloriesPerBase != null) 'calories_per_base': caloriesPerBase,
      if (proteinPerBase != null) 'protein_per_base': proteinPerBase,
      if (carbsPerBase != null) 'carbs_per_base': carbsPerBase,
      if (fatPerBase != null) 'fat_per_base': fatPerBase,
      if (fiberPerBase != null) 'fiber_per_base': fiberPerBase,
      if (sugarPerBase != null) 'sugar_per_base': sugarPerBase,
      if (sodiumPerBase != null) 'sodium_per_base': sodiumPerBase,
      if (source != null) 'source': source,
      if (usageCount != null) 'usage_count': usageCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  IngredientsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? nameEn,
      Value<double>? baseAmount,
      Value<String>? baseUnit,
      Value<double>? caloriesPerBase,
      Value<double>? proteinPerBase,
      Value<double>? carbsPerBase,
      Value<double>? fatPerBase,
      Value<double?>? fiberPerBase,
      Value<double?>? sugarPerBase,
      Value<double?>? sodiumPerBase,
      Value<String>? source,
      Value<int>? usageCount,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return IngredientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      baseAmount: baseAmount ?? this.baseAmount,
      baseUnit: baseUnit ?? this.baseUnit,
      caloriesPerBase: caloriesPerBase ?? this.caloriesPerBase,
      proteinPerBase: proteinPerBase ?? this.proteinPerBase,
      carbsPerBase: carbsPerBase ?? this.carbsPerBase,
      fatPerBase: fatPerBase ?? this.fatPerBase,
      fiberPerBase: fiberPerBase ?? this.fiberPerBase,
      sugarPerBase: sugarPerBase ?? this.sugarPerBase,
      sodiumPerBase: sodiumPerBase ?? this.sodiumPerBase,
      source: source ?? this.source,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (baseAmount.present) {
      map['base_amount'] = Variable<double>(baseAmount.value);
    }
    if (baseUnit.present) {
      map['base_unit'] = Variable<String>(baseUnit.value);
    }
    if (caloriesPerBase.present) {
      map['calories_per_base'] = Variable<double>(caloriesPerBase.value);
    }
    if (proteinPerBase.present) {
      map['protein_per_base'] = Variable<double>(proteinPerBase.value);
    }
    if (carbsPerBase.present) {
      map['carbs_per_base'] = Variable<double>(carbsPerBase.value);
    }
    if (fatPerBase.present) {
      map['fat_per_base'] = Variable<double>(fatPerBase.value);
    }
    if (fiberPerBase.present) {
      map['fiber_per_base'] = Variable<double>(fiberPerBase.value);
    }
    if (sugarPerBase.present) {
      map['sugar_per_base'] = Variable<double>(sugarPerBase.value);
    }
    if (sodiumPerBase.present) {
      map['sodium_per_base'] = Variable<double>(sodiumPerBase.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameEn: $nameEn, ')
          ..write('baseAmount: $baseAmount, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('caloriesPerBase: $caloriesPerBase, ')
          ..write('proteinPerBase: $proteinPerBase, ')
          ..write('carbsPerBase: $carbsPerBase, ')
          ..write('fatPerBase: $fatPerBase, ')
          ..write('fiberPerBase: $fiberPerBase, ')
          ..write('sugarPerBase: $sugarPerBase, ')
          ..write('sodiumPerBase: $sodiumPerBase, ')
          ..write('source: $source, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MyMealsTable extends MyMeals with TableInfo<$MyMealsTable, MyMealData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MyMealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
      'name_en', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalCaloriesMeta =
      const VerificationMeta('totalCalories');
  @override
  late final GeneratedColumn<double> totalCalories = GeneratedColumn<double>(
      'total_calories', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalProteinMeta =
      const VerificationMeta('totalProtein');
  @override
  late final GeneratedColumn<double> totalProtein = GeneratedColumn<double>(
      'total_protein', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalCarbsMeta =
      const VerificationMeta('totalCarbs');
  @override
  late final GeneratedColumn<double> totalCarbs = GeneratedColumn<double>(
      'total_carbs', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalFatMeta =
      const VerificationMeta('totalFat');
  @override
  late final GeneratedColumn<double> totalFat = GeneratedColumn<double>(
      'total_fat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _baseServingDescriptionMeta =
      const VerificationMeta('baseServingDescription');
  @override
  late final GeneratedColumn<String> baseServingDescription =
      GeneratedColumn<String>('base_serving_description', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usageCountMeta =
      const VerificationMeta('usageCount');
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
      'usage_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        nameEn,
        totalCalories,
        totalProtein,
        totalCarbs,
        totalFat,
        baseServingDescription,
        imagePath,
        source,
        usageCount,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'my_meals';
  @override
  VerificationContext validateIntegrity(Insertable<MyMealData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(_nameEnMeta,
          nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta));
    }
    if (data.containsKey('total_calories')) {
      context.handle(
          _totalCaloriesMeta,
          totalCalories.isAcceptableOrUnknown(
              data['total_calories']!, _totalCaloriesMeta));
    } else if (isInserting) {
      context.missing(_totalCaloriesMeta);
    }
    if (data.containsKey('total_protein')) {
      context.handle(
          _totalProteinMeta,
          totalProtein.isAcceptableOrUnknown(
              data['total_protein']!, _totalProteinMeta));
    } else if (isInserting) {
      context.missing(_totalProteinMeta);
    }
    if (data.containsKey('total_carbs')) {
      context.handle(
          _totalCarbsMeta,
          totalCarbs.isAcceptableOrUnknown(
              data['total_carbs']!, _totalCarbsMeta));
    } else if (isInserting) {
      context.missing(_totalCarbsMeta);
    }
    if (data.containsKey('total_fat')) {
      context.handle(_totalFatMeta,
          totalFat.isAcceptableOrUnknown(data['total_fat']!, _totalFatMeta));
    } else if (isInserting) {
      context.missing(_totalFatMeta);
    }
    if (data.containsKey('base_serving_description')) {
      context.handle(
          _baseServingDescriptionMeta,
          baseServingDescription.isAcceptableOrUnknown(
              data['base_serving_description']!, _baseServingDescriptionMeta));
    } else if (isInserting) {
      context.missing(_baseServingDescriptionMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('usage_count')) {
      context.handle(
          _usageCountMeta,
          usageCount.isAcceptableOrUnknown(
              data['usage_count']!, _usageCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MyMealData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MyMealData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      nameEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_en']),
      totalCalories: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_calories'])!,
      totalProtein: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_protein'])!,
      totalCarbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_carbs'])!,
      totalFat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_fat'])!,
      baseServingDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}base_serving_description'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      usageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MyMealsTable createAlias(String alias) {
    return $MyMealsTable(attachedDatabase, alias);
  }
}

class MyMealData extends DataClass implements Insertable<MyMealData> {
  int id;
  String name;
  String? nameEn;
  double totalCalories;
  double totalProtein;
  double totalCarbs;
  double totalFat;
  String baseServingDescription;
  String? imagePath;
  String source;
  int usageCount;
  DateTime createdAt;
  DateTime updatedAt;
  MyMealData(
      {required this.id,
      required this.name,
      this.nameEn,
      required this.totalCalories,
      required this.totalProtein,
      required this.totalCarbs,
      required this.totalFat,
      required this.baseServingDescription,
      this.imagePath,
      required this.source,
      required this.usageCount,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nameEn != null) {
      map['name_en'] = Variable<String>(nameEn);
    }
    map['total_calories'] = Variable<double>(totalCalories);
    map['total_protein'] = Variable<double>(totalProtein);
    map['total_carbs'] = Variable<double>(totalCarbs);
    map['total_fat'] = Variable<double>(totalFat);
    map['base_serving_description'] = Variable<String>(baseServingDescription);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['source'] = Variable<String>(source);
    map['usage_count'] = Variable<int>(usageCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MyMealsCompanion toCompanion(bool nullToAbsent) {
    return MyMealsCompanion(
      id: Value(id),
      name: Value(name),
      nameEn:
          nameEn == null && nullToAbsent ? const Value.absent() : Value(nameEn),
      totalCalories: Value(totalCalories),
      totalProtein: Value(totalProtein),
      totalCarbs: Value(totalCarbs),
      totalFat: Value(totalFat),
      baseServingDescription: Value(baseServingDescription),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      source: Value(source),
      usageCount: Value(usageCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MyMealData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MyMealData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameEn: serializer.fromJson<String?>(json['nameEn']),
      totalCalories: serializer.fromJson<double>(json['totalCalories']),
      totalProtein: serializer.fromJson<double>(json['totalProtein']),
      totalCarbs: serializer.fromJson<double>(json['totalCarbs']),
      totalFat: serializer.fromJson<double>(json['totalFat']),
      baseServingDescription:
          serializer.fromJson<String>(json['baseServingDescription']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      source: serializer.fromJson<String>(json['source']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameEn': serializer.toJson<String?>(nameEn),
      'totalCalories': serializer.toJson<double>(totalCalories),
      'totalProtein': serializer.toJson<double>(totalProtein),
      'totalCarbs': serializer.toJson<double>(totalCarbs),
      'totalFat': serializer.toJson<double>(totalFat),
      'baseServingDescription':
          serializer.toJson<String>(baseServingDescription),
      'imagePath': serializer.toJson<String?>(imagePath),
      'source': serializer.toJson<String>(source),
      'usageCount': serializer.toJson<int>(usageCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MyMealData copyWith(
          {int? id,
          String? name,
          Value<String?> nameEn = const Value.absent(),
          double? totalCalories,
          double? totalProtein,
          double? totalCarbs,
          double? totalFat,
          String? baseServingDescription,
          Value<String?> imagePath = const Value.absent(),
          String? source,
          int? usageCount,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      MyMealData(
        id: id ?? this.id,
        name: name ?? this.name,
        nameEn: nameEn.present ? nameEn.value : this.nameEn,
        totalCalories: totalCalories ?? this.totalCalories,
        totalProtein: totalProtein ?? this.totalProtein,
        totalCarbs: totalCarbs ?? this.totalCarbs,
        totalFat: totalFat ?? this.totalFat,
        baseServingDescription:
            baseServingDescription ?? this.baseServingDescription,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        source: source ?? this.source,
        usageCount: usageCount ?? this.usageCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MyMealData copyWithCompanion(MyMealsCompanion data) {
    return MyMealData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      totalCalories: data.totalCalories.present
          ? data.totalCalories.value
          : this.totalCalories,
      totalProtein: data.totalProtein.present
          ? data.totalProtein.value
          : this.totalProtein,
      totalCarbs:
          data.totalCarbs.present ? data.totalCarbs.value : this.totalCarbs,
      totalFat: data.totalFat.present ? data.totalFat.value : this.totalFat,
      baseServingDescription: data.baseServingDescription.present
          ? data.baseServingDescription.value
          : this.baseServingDescription,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      source: data.source.present ? data.source.value : this.source,
      usageCount:
          data.usageCount.present ? data.usageCount.value : this.usageCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MyMealData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameEn: $nameEn, ')
          ..write('totalCalories: $totalCalories, ')
          ..write('totalProtein: $totalProtein, ')
          ..write('totalCarbs: $totalCarbs, ')
          ..write('totalFat: $totalFat, ')
          ..write('baseServingDescription: $baseServingDescription, ')
          ..write('imagePath: $imagePath, ')
          ..write('source: $source, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      nameEn,
      totalCalories,
      totalProtein,
      totalCarbs,
      totalFat,
      baseServingDescription,
      imagePath,
      source,
      usageCount,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MyMealData &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameEn == this.nameEn &&
          other.totalCalories == this.totalCalories &&
          other.totalProtein == this.totalProtein &&
          other.totalCarbs == this.totalCarbs &&
          other.totalFat == this.totalFat &&
          other.baseServingDescription == this.baseServingDescription &&
          other.imagePath == this.imagePath &&
          other.source == this.source &&
          other.usageCount == this.usageCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MyMealsCompanion extends UpdateCompanion<MyMealData> {
  Value<int> id;
  Value<String> name;
  Value<String?> nameEn;
  Value<double> totalCalories;
  Value<double> totalProtein;
  Value<double> totalCarbs;
  Value<double> totalFat;
  Value<String> baseServingDescription;
  Value<String?> imagePath;
  Value<String> source;
  Value<int> usageCount;
  Value<DateTime> createdAt;
  Value<DateTime> updatedAt;
  MyMealsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.totalCalories = const Value.absent(),
    this.totalProtein = const Value.absent(),
    this.totalCarbs = const Value.absent(),
    this.totalFat = const Value.absent(),
    this.baseServingDescription = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.source = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MyMealsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.nameEn = const Value.absent(),
    required double totalCalories,
    required double totalProtein,
    required double totalCarbs,
    required double totalFat,
    required String baseServingDescription,
    this.imagePath = const Value.absent(),
    required String source,
    this.usageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        totalCalories = Value(totalCalories),
        totalProtein = Value(totalProtein),
        totalCarbs = Value(totalCarbs),
        totalFat = Value(totalFat),
        baseServingDescription = Value(baseServingDescription),
        source = Value(source);
  static Insertable<MyMealData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameEn,
    Expression<double>? totalCalories,
    Expression<double>? totalProtein,
    Expression<double>? totalCarbs,
    Expression<double>? totalFat,
    Expression<String>? baseServingDescription,
    Expression<String>? imagePath,
    Expression<String>? source,
    Expression<int>? usageCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameEn != null) 'name_en': nameEn,
      if (totalCalories != null) 'total_calories': totalCalories,
      if (totalProtein != null) 'total_protein': totalProtein,
      if (totalCarbs != null) 'total_carbs': totalCarbs,
      if (totalFat != null) 'total_fat': totalFat,
      if (baseServingDescription != null)
        'base_serving_description': baseServingDescription,
      if (imagePath != null) 'image_path': imagePath,
      if (source != null) 'source': source,
      if (usageCount != null) 'usage_count': usageCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MyMealsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? nameEn,
      Value<double>? totalCalories,
      Value<double>? totalProtein,
      Value<double>? totalCarbs,
      Value<double>? totalFat,
      Value<String>? baseServingDescription,
      Value<String?>? imagePath,
      Value<String>? source,
      Value<int>? usageCount,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return MyMealsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      baseServingDescription:
          baseServingDescription ?? this.baseServingDescription,
      imagePath: imagePath ?? this.imagePath,
      source: source ?? this.source,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (totalCalories.present) {
      map['total_calories'] = Variable<double>(totalCalories.value);
    }
    if (totalProtein.present) {
      map['total_protein'] = Variable<double>(totalProtein.value);
    }
    if (totalCarbs.present) {
      map['total_carbs'] = Variable<double>(totalCarbs.value);
    }
    if (totalFat.present) {
      map['total_fat'] = Variable<double>(totalFat.value);
    }
    if (baseServingDescription.present) {
      map['base_serving_description'] =
          Variable<String>(baseServingDescription.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MyMealsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameEn: $nameEn, ')
          ..write('totalCalories: $totalCalories, ')
          ..write('totalProtein: $totalProtein, ')
          ..write('totalCarbs: $totalCarbs, ')
          ..write('totalFat: $totalFat, ')
          ..write('baseServingDescription: $baseServingDescription, ')
          ..write('imagePath: $imagePath, ')
          ..write('source: $source, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MyMealIngredientsTable extends MyMealIngredients
    with TableInfo<$MyMealIngredientsTable, MyMealIngredientData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MyMealIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _myMealIdMeta =
      const VerificationMeta('myMealId');
  @override
  late final GeneratedColumn<int> myMealId = GeneratedColumn<int>(
      'my_meal_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ingredientIdMeta =
      const VerificationMeta('ingredientId');
  @override
  late final GeneratedColumn<int> ingredientId = GeneratedColumn<int>(
      'ingredient_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ingredientNameMeta =
      const VerificationMeta('ingredientName');
  @override
  late final GeneratedColumn<String> ingredientName = GeneratedColumn<String>(
      'ingredient_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _caloriesMeta =
      const VerificationMeta('calories');
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
      'calories', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _proteinMeta =
      const VerificationMeta('protein');
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
      'protein', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
      'carbs', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
      'fat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _depthMeta = const VerificationMeta('depth');
  @override
  late final GeneratedColumn<int> depth = GeneratedColumn<int>(
      'depth', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isCompositeMeta =
      const VerificationMeta('isComposite');
  @override
  late final GeneratedColumn<bool> isComposite = GeneratedColumn<bool>(
      'is_composite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_composite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
      'detail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        myMealId,
        ingredientId,
        ingredientName,
        amount,
        unit,
        calories,
        protein,
        carbs,
        fat,
        sortOrder,
        parentId,
        depth,
        isComposite,
        detail
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'my_meal_ingredients';
  @override
  VerificationContext validateIntegrity(
      Insertable<MyMealIngredientData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('my_meal_id')) {
      context.handle(_myMealIdMeta,
          myMealId.isAcceptableOrUnknown(data['my_meal_id']!, _myMealIdMeta));
    } else if (isInserting) {
      context.missing(_myMealIdMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
          _ingredientIdMeta,
          ingredientId.isAcceptableOrUnknown(
              data['ingredient_id']!, _ingredientIdMeta));
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('ingredient_name')) {
      context.handle(
          _ingredientNameMeta,
          ingredientName.isAcceptableOrUnknown(
              data['ingredient_name']!, _ingredientNameMeta));
    } else if (isInserting) {
      context.missing(_ingredientNameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(_caloriesMeta,
          calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta));
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(_proteinMeta,
          protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta));
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
          _carbsMeta, carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta));
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
          _fatMeta, fat.isAcceptableOrUnknown(data['fat']!, _fatMeta));
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('depth')) {
      context.handle(
          _depthMeta, depth.isAcceptableOrUnknown(data['depth']!, _depthMeta));
    }
    if (data.containsKey('is_composite')) {
      context.handle(
          _isCompositeMeta,
          isComposite.isAcceptableOrUnknown(
              data['is_composite']!, _isCompositeMeta));
    }
    if (data.containsKey('detail')) {
      context.handle(_detailMeta,
          detail.isAcceptableOrUnknown(data['detail']!, _detailMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MyMealIngredientData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MyMealIngredientData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      myMealId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}my_meal_id'])!,
      ingredientId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ingredient_id'])!,
      ingredientName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ingredient_name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      calories: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calories'])!,
      protein: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}protein'])!,
      carbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs'])!,
      fat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parent_id']),
      depth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}depth'])!,
      isComposite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_composite'])!,
      detail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detail']),
    );
  }

  @override
  $MyMealIngredientsTable createAlias(String alias) {
    return $MyMealIngredientsTable(attachedDatabase, alias);
  }
}

class MyMealIngredientData extends DataClass
    implements Insertable<MyMealIngredientData> {
  int id;
  int myMealId;
  int ingredientId;
  String ingredientName;
  double amount;
  String unit;
  double calories;
  double protein;
  double carbs;
  double fat;
  int sortOrder;
  int? parentId;
  int depth;
  bool isComposite;
  String? detail;
  MyMealIngredientData(
      {required this.id,
      required this.myMealId,
      required this.ingredientId,
      required this.ingredientName,
      required this.amount,
      required this.unit,
      required this.calories,
      required this.protein,
      required this.carbs,
      required this.fat,
      required this.sortOrder,
      this.parentId,
      required this.depth,
      required this.isComposite,
      this.detail});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['my_meal_id'] = Variable<int>(myMealId);
    map['ingredient_id'] = Variable<int>(ingredientId);
    map['ingredient_name'] = Variable<String>(ingredientName);
    map['amount'] = Variable<double>(amount);
    map['unit'] = Variable<String>(unit);
    map['calories'] = Variable<double>(calories);
    map['protein'] = Variable<double>(protein);
    map['carbs'] = Variable<double>(carbs);
    map['fat'] = Variable<double>(fat);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['depth'] = Variable<int>(depth);
    map['is_composite'] = Variable<bool>(isComposite);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    return map;
  }

  MyMealIngredientsCompanion toCompanion(bool nullToAbsent) {
    return MyMealIngredientsCompanion(
      id: Value(id),
      myMealId: Value(myMealId),
      ingredientId: Value(ingredientId),
      ingredientName: Value(ingredientName),
      amount: Value(amount),
      unit: Value(unit),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
      sortOrder: Value(sortOrder),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      depth: Value(depth),
      isComposite: Value(isComposite),
      detail:
          detail == null && nullToAbsent ? const Value.absent() : Value(detail),
    );
  }

  factory MyMealIngredientData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MyMealIngredientData(
      id: serializer.fromJson<int>(json['id']),
      myMealId: serializer.fromJson<int>(json['myMealId']),
      ingredientId: serializer.fromJson<int>(json['ingredientId']),
      ingredientName: serializer.fromJson<String>(json['ingredientName']),
      amount: serializer.fromJson<double>(json['amount']),
      unit: serializer.fromJson<String>(json['unit']),
      calories: serializer.fromJson<double>(json['calories']),
      protein: serializer.fromJson<double>(json['protein']),
      carbs: serializer.fromJson<double>(json['carbs']),
      fat: serializer.fromJson<double>(json['fat']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      depth: serializer.fromJson<int>(json['depth']),
      isComposite: serializer.fromJson<bool>(json['isComposite']),
      detail: serializer.fromJson<String?>(json['detail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'myMealId': serializer.toJson<int>(myMealId),
      'ingredientId': serializer.toJson<int>(ingredientId),
      'ingredientName': serializer.toJson<String>(ingredientName),
      'amount': serializer.toJson<double>(amount),
      'unit': serializer.toJson<String>(unit),
      'calories': serializer.toJson<double>(calories),
      'protein': serializer.toJson<double>(protein),
      'carbs': serializer.toJson<double>(carbs),
      'fat': serializer.toJson<double>(fat),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'parentId': serializer.toJson<int?>(parentId),
      'depth': serializer.toJson<int>(depth),
      'isComposite': serializer.toJson<bool>(isComposite),
      'detail': serializer.toJson<String?>(detail),
    };
  }

  MyMealIngredientData copyWith(
          {int? id,
          int? myMealId,
          int? ingredientId,
          String? ingredientName,
          double? amount,
          String? unit,
          double? calories,
          double? protein,
          double? carbs,
          double? fat,
          int? sortOrder,
          Value<int?> parentId = const Value.absent(),
          int? depth,
          bool? isComposite,
          Value<String?> detail = const Value.absent()}) =>
      MyMealIngredientData(
        id: id ?? this.id,
        myMealId: myMealId ?? this.myMealId,
        ingredientId: ingredientId ?? this.ingredientId,
        ingredientName: ingredientName ?? this.ingredientName,
        amount: amount ?? this.amount,
        unit: unit ?? this.unit,
        calories: calories ?? this.calories,
        protein: protein ?? this.protein,
        carbs: carbs ?? this.carbs,
        fat: fat ?? this.fat,
        sortOrder: sortOrder ?? this.sortOrder,
        parentId: parentId.present ? parentId.value : this.parentId,
        depth: depth ?? this.depth,
        isComposite: isComposite ?? this.isComposite,
        detail: detail.present ? detail.value : this.detail,
      );
  MyMealIngredientData copyWithCompanion(MyMealIngredientsCompanion data) {
    return MyMealIngredientData(
      id: data.id.present ? data.id.value : this.id,
      myMealId: data.myMealId.present ? data.myMealId.value : this.myMealId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      ingredientName: data.ingredientName.present
          ? data.ingredientName.value
          : this.ingredientName,
      amount: data.amount.present ? data.amount.value : this.amount,
      unit: data.unit.present ? data.unit.value : this.unit,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      depth: data.depth.present ? data.depth.value : this.depth,
      isComposite:
          data.isComposite.present ? data.isComposite.value : this.isComposite,
      detail: data.detail.present ? data.detail.value : this.detail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MyMealIngredientData(')
          ..write('id: $id, ')
          ..write('myMealId: $myMealId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('ingredientName: $ingredientName, ')
          ..write('amount: $amount, ')
          ..write('unit: $unit, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('parentId: $parentId, ')
          ..write('depth: $depth, ')
          ..write('isComposite: $isComposite, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      myMealId,
      ingredientId,
      ingredientName,
      amount,
      unit,
      calories,
      protein,
      carbs,
      fat,
      sortOrder,
      parentId,
      depth,
      isComposite,
      detail);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MyMealIngredientData &&
          other.id == this.id &&
          other.myMealId == this.myMealId &&
          other.ingredientId == this.ingredientId &&
          other.ingredientName == this.ingredientName &&
          other.amount == this.amount &&
          other.unit == this.unit &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.sortOrder == this.sortOrder &&
          other.parentId == this.parentId &&
          other.depth == this.depth &&
          other.isComposite == this.isComposite &&
          other.detail == this.detail);
}

class MyMealIngredientsCompanion extends UpdateCompanion<MyMealIngredientData> {
  Value<int> id;
  Value<int> myMealId;
  Value<int> ingredientId;
  Value<String> ingredientName;
  Value<double> amount;
  Value<String> unit;
  Value<double> calories;
  Value<double> protein;
  Value<double> carbs;
  Value<double> fat;
  Value<int> sortOrder;
  Value<int?> parentId;
  Value<int> depth;
  Value<bool> isComposite;
  Value<String?> detail;
  MyMealIngredientsCompanion({
    this.id = const Value.absent(),
    this.myMealId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.ingredientName = const Value.absent(),
    this.amount = const Value.absent(),
    this.unit = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.parentId = const Value.absent(),
    this.depth = const Value.absent(),
    this.isComposite = const Value.absent(),
    this.detail = const Value.absent(),
  });
  MyMealIngredientsCompanion.insert({
    this.id = const Value.absent(),
    required int myMealId,
    required int ingredientId,
    required String ingredientName,
    required double amount,
    required String unit,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    this.sortOrder = const Value.absent(),
    this.parentId = const Value.absent(),
    this.depth = const Value.absent(),
    this.isComposite = const Value.absent(),
    this.detail = const Value.absent(),
  })  : myMealId = Value(myMealId),
        ingredientId = Value(ingredientId),
        ingredientName = Value(ingredientName),
        amount = Value(amount),
        unit = Value(unit),
        calories = Value(calories),
        protein = Value(protein),
        carbs = Value(carbs),
        fat = Value(fat);
  static Insertable<MyMealIngredientData> custom({
    Expression<int>? id,
    Expression<int>? myMealId,
    Expression<int>? ingredientId,
    Expression<String>? ingredientName,
    Expression<double>? amount,
    Expression<String>? unit,
    Expression<double>? calories,
    Expression<double>? protein,
    Expression<double>? carbs,
    Expression<double>? fat,
    Expression<int>? sortOrder,
    Expression<int>? parentId,
    Expression<int>? depth,
    Expression<bool>? isComposite,
    Expression<String>? detail,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (myMealId != null) 'my_meal_id': myMealId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (ingredientName != null) 'ingredient_name': ingredientName,
      if (amount != null) 'amount': amount,
      if (unit != null) 'unit': unit,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (parentId != null) 'parent_id': parentId,
      if (depth != null) 'depth': depth,
      if (isComposite != null) 'is_composite': isComposite,
      if (detail != null) 'detail': detail,
    });
  }

  MyMealIngredientsCompanion copyWith(
      {Value<int>? id,
      Value<int>? myMealId,
      Value<int>? ingredientId,
      Value<String>? ingredientName,
      Value<double>? amount,
      Value<String>? unit,
      Value<double>? calories,
      Value<double>? protein,
      Value<double>? carbs,
      Value<double>? fat,
      Value<int>? sortOrder,
      Value<int?>? parentId,
      Value<int>? depth,
      Value<bool>? isComposite,
      Value<String?>? detail}) {
    return MyMealIngredientsCompanion(
      id: id ?? this.id,
      myMealId: myMealId ?? this.myMealId,
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientName: ingredientName ?? this.ingredientName,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      sortOrder: sortOrder ?? this.sortOrder,
      parentId: parentId ?? this.parentId,
      depth: depth ?? this.depth,
      isComposite: isComposite ?? this.isComposite,
      detail: detail ?? this.detail,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (myMealId.present) {
      map['my_meal_id'] = Variable<int>(myMealId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<int>(ingredientId.value);
    }
    if (ingredientName.present) {
      map['ingredient_name'] = Variable<String>(ingredientName.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (depth.present) {
      map['depth'] = Variable<int>(depth.value);
    }
    if (isComposite.present) {
      map['is_composite'] = Variable<bool>(isComposite.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MyMealIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('myMealId: $myMealId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('ingredientName: $ingredientName, ')
          ..write('amount: $amount, ')
          ..write('unit: $unit, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('parentId: $parentId, ')
          ..write('depth: $depth, ')
          ..write('isComposite: $isComposite, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }
}

class $DailySummariesTable extends DailySummaries
    with TableInfo<$DailySummariesTable, DailySummaryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailySummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _caloriesEatenMeta =
      const VerificationMeta('caloriesEaten');
  @override
  late final GeneratedColumn<double> caloriesEaten = GeneratedColumn<double>(
      'calories_eaten', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _proteinEatenMeta =
      const VerificationMeta('proteinEaten');
  @override
  late final GeneratedColumn<double> proteinEaten = GeneratedColumn<double>(
      'protein_eaten', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _carbsEatenMeta =
      const VerificationMeta('carbsEaten');
  @override
  late final GeneratedColumn<double> carbsEaten = GeneratedColumn<double>(
      'carbs_eaten', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fatEatenMeta =
      const VerificationMeta('fatEaten');
  @override
  late final GeneratedColumn<double> fatEaten = GeneratedColumn<double>(
      'fat_eaten', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _tdeeMeta = const VerificationMeta('tdee');
  @override
  late final GeneratedColumn<double> tdee = GeneratedColumn<double>(
      'tdee', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _netEnergyMeta =
      const VerificationMeta('netEnergy');
  @override
  late final GeneratedColumn<double> netEnergy = GeneratedColumn<double>(
      'net_energy', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _deficitZoneMeta =
      const VerificationMeta('deficitZone');
  @override
  late final GeneratedColumn<String> deficitZone = GeneratedColumn<String>(
      'deficit_zone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('maintain'));
  static const VerificationMeta _entryCountMeta =
      const VerificationMeta('entryCount');
  @override
  late final GeneratedColumn<int> entryCount = GeneratedColumn<int>(
      'entry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _correctionCountMeta =
      const VerificationMeta('correctionCount');
  @override
  late final GeneratedColumn<int> correctionCount = GeneratedColumn<int>(
      'correction_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _calorieGoalMeta =
      const VerificationMeta('calorieGoal');
  @override
  late final GeneratedColumn<double> calorieGoal = GeneratedColumn<double>(
      'calorie_goal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        caloriesEaten,
        proteinEaten,
        carbsEaten,
        fatEaten,
        tdee,
        netEnergy,
        deficitZone,
        entryCount,
        correctionCount,
        calorieGoal,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_summaries';
  @override
  VerificationContext validateIntegrity(Insertable<DailySummaryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('calories_eaten')) {
      context.handle(
          _caloriesEatenMeta,
          caloriesEaten.isAcceptableOrUnknown(
              data['calories_eaten']!, _caloriesEatenMeta));
    }
    if (data.containsKey('protein_eaten')) {
      context.handle(
          _proteinEatenMeta,
          proteinEaten.isAcceptableOrUnknown(
              data['protein_eaten']!, _proteinEatenMeta));
    }
    if (data.containsKey('carbs_eaten')) {
      context.handle(
          _carbsEatenMeta,
          carbsEaten.isAcceptableOrUnknown(
              data['carbs_eaten']!, _carbsEatenMeta));
    }
    if (data.containsKey('fat_eaten')) {
      context.handle(_fatEatenMeta,
          fatEaten.isAcceptableOrUnknown(data['fat_eaten']!, _fatEatenMeta));
    }
    if (data.containsKey('tdee')) {
      context.handle(
          _tdeeMeta, tdee.isAcceptableOrUnknown(data['tdee']!, _tdeeMeta));
    }
    if (data.containsKey('net_energy')) {
      context.handle(_netEnergyMeta,
          netEnergy.isAcceptableOrUnknown(data['net_energy']!, _netEnergyMeta));
    }
    if (data.containsKey('deficit_zone')) {
      context.handle(
          _deficitZoneMeta,
          deficitZone.isAcceptableOrUnknown(
              data['deficit_zone']!, _deficitZoneMeta));
    }
    if (data.containsKey('entry_count')) {
      context.handle(
          _entryCountMeta,
          entryCount.isAcceptableOrUnknown(
              data['entry_count']!, _entryCountMeta));
    }
    if (data.containsKey('correction_count')) {
      context.handle(
          _correctionCountMeta,
          correctionCount.isAcceptableOrUnknown(
              data['correction_count']!, _correctionCountMeta));
    }
    if (data.containsKey('calorie_goal')) {
      context.handle(
          _calorieGoalMeta,
          calorieGoal.isAcceptableOrUnknown(
              data['calorie_goal']!, _calorieGoalMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailySummaryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailySummaryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      caloriesEaten: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calories_eaten'])!,
      proteinEaten: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}protein_eaten'])!,
      carbsEaten: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs_eaten'])!,
      fatEaten: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat_eaten'])!,
      tdee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tdee'])!,
      netEnergy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}net_energy'])!,
      deficitZone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deficit_zone'])!,
      entryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}entry_count'])!,
      correctionCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}correction_count'])!,
      calorieGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calorie_goal'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DailySummariesTable createAlias(String alias) {
    return $DailySummariesTable(attachedDatabase, alias);
  }
}

class DailySummaryData extends DataClass
    implements Insertable<DailySummaryData> {
  int id;
  DateTime date;
  double caloriesEaten;
  double proteinEaten;
  double carbsEaten;
  double fatEaten;
  double tdee;
  double netEnergy;
  String deficitZone;
  int entryCount;
  int correctionCount;
  double calorieGoal;
  DateTime createdAt;
  DateTime updatedAt;
  DailySummaryData(
      {required this.id,
      required this.date,
      required this.caloriesEaten,
      required this.proteinEaten,
      required this.carbsEaten,
      required this.fatEaten,
      required this.tdee,
      required this.netEnergy,
      required this.deficitZone,
      required this.entryCount,
      required this.correctionCount,
      required this.calorieGoal,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['calories_eaten'] = Variable<double>(caloriesEaten);
    map['protein_eaten'] = Variable<double>(proteinEaten);
    map['carbs_eaten'] = Variable<double>(carbsEaten);
    map['fat_eaten'] = Variable<double>(fatEaten);
    map['tdee'] = Variable<double>(tdee);
    map['net_energy'] = Variable<double>(netEnergy);
    map['deficit_zone'] = Variable<String>(deficitZone);
    map['entry_count'] = Variable<int>(entryCount);
    map['correction_count'] = Variable<int>(correctionCount);
    map['calorie_goal'] = Variable<double>(calorieGoal);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailySummariesCompanion toCompanion(bool nullToAbsent) {
    return DailySummariesCompanion(
      id: Value(id),
      date: Value(date),
      caloriesEaten: Value(caloriesEaten),
      proteinEaten: Value(proteinEaten),
      carbsEaten: Value(carbsEaten),
      fatEaten: Value(fatEaten),
      tdee: Value(tdee),
      netEnergy: Value(netEnergy),
      deficitZone: Value(deficitZone),
      entryCount: Value(entryCount),
      correctionCount: Value(correctionCount),
      calorieGoal: Value(calorieGoal),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailySummaryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailySummaryData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      caloriesEaten: serializer.fromJson<double>(json['caloriesEaten']),
      proteinEaten: serializer.fromJson<double>(json['proteinEaten']),
      carbsEaten: serializer.fromJson<double>(json['carbsEaten']),
      fatEaten: serializer.fromJson<double>(json['fatEaten']),
      tdee: serializer.fromJson<double>(json['tdee']),
      netEnergy: serializer.fromJson<double>(json['netEnergy']),
      deficitZone: serializer.fromJson<String>(json['deficitZone']),
      entryCount: serializer.fromJson<int>(json['entryCount']),
      correctionCount: serializer.fromJson<int>(json['correctionCount']),
      calorieGoal: serializer.fromJson<double>(json['calorieGoal']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'caloriesEaten': serializer.toJson<double>(caloriesEaten),
      'proteinEaten': serializer.toJson<double>(proteinEaten),
      'carbsEaten': serializer.toJson<double>(carbsEaten),
      'fatEaten': serializer.toJson<double>(fatEaten),
      'tdee': serializer.toJson<double>(tdee),
      'netEnergy': serializer.toJson<double>(netEnergy),
      'deficitZone': serializer.toJson<String>(deficitZone),
      'entryCount': serializer.toJson<int>(entryCount),
      'correctionCount': serializer.toJson<int>(correctionCount),
      'calorieGoal': serializer.toJson<double>(calorieGoal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailySummaryData copyWith(
          {int? id,
          DateTime? date,
          double? caloriesEaten,
          double? proteinEaten,
          double? carbsEaten,
          double? fatEaten,
          double? tdee,
          double? netEnergy,
          String? deficitZone,
          int? entryCount,
          int? correctionCount,
          double? calorieGoal,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DailySummaryData(
        id: id ?? this.id,
        date: date ?? this.date,
        caloriesEaten: caloriesEaten ?? this.caloriesEaten,
        proteinEaten: proteinEaten ?? this.proteinEaten,
        carbsEaten: carbsEaten ?? this.carbsEaten,
        fatEaten: fatEaten ?? this.fatEaten,
        tdee: tdee ?? this.tdee,
        netEnergy: netEnergy ?? this.netEnergy,
        deficitZone: deficitZone ?? this.deficitZone,
        entryCount: entryCount ?? this.entryCount,
        correctionCount: correctionCount ?? this.correctionCount,
        calorieGoal: calorieGoal ?? this.calorieGoal,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DailySummaryData copyWithCompanion(DailySummariesCompanion data) {
    return DailySummaryData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      caloriesEaten: data.caloriesEaten.present
          ? data.caloriesEaten.value
          : this.caloriesEaten,
      proteinEaten: data.proteinEaten.present
          ? data.proteinEaten.value
          : this.proteinEaten,
      carbsEaten:
          data.carbsEaten.present ? data.carbsEaten.value : this.carbsEaten,
      fatEaten: data.fatEaten.present ? data.fatEaten.value : this.fatEaten,
      tdee: data.tdee.present ? data.tdee.value : this.tdee,
      netEnergy: data.netEnergy.present ? data.netEnergy.value : this.netEnergy,
      deficitZone:
          data.deficitZone.present ? data.deficitZone.value : this.deficitZone,
      entryCount:
          data.entryCount.present ? data.entryCount.value : this.entryCount,
      correctionCount: data.correctionCount.present
          ? data.correctionCount.value
          : this.correctionCount,
      calorieGoal:
          data.calorieGoal.present ? data.calorieGoal.value : this.calorieGoal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailySummaryData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('caloriesEaten: $caloriesEaten, ')
          ..write('proteinEaten: $proteinEaten, ')
          ..write('carbsEaten: $carbsEaten, ')
          ..write('fatEaten: $fatEaten, ')
          ..write('tdee: $tdee, ')
          ..write('netEnergy: $netEnergy, ')
          ..write('deficitZone: $deficitZone, ')
          ..write('entryCount: $entryCount, ')
          ..write('correctionCount: $correctionCount, ')
          ..write('calorieGoal: $calorieGoal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      date,
      caloriesEaten,
      proteinEaten,
      carbsEaten,
      fatEaten,
      tdee,
      netEnergy,
      deficitZone,
      entryCount,
      correctionCount,
      calorieGoal,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailySummaryData &&
          other.id == this.id &&
          other.date == this.date &&
          other.caloriesEaten == this.caloriesEaten &&
          other.proteinEaten == this.proteinEaten &&
          other.carbsEaten == this.carbsEaten &&
          other.fatEaten == this.fatEaten &&
          other.tdee == this.tdee &&
          other.netEnergy == this.netEnergy &&
          other.deficitZone == this.deficitZone &&
          other.entryCount == this.entryCount &&
          other.correctionCount == this.correctionCount &&
          other.calorieGoal == this.calorieGoal &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailySummariesCompanion extends UpdateCompanion<DailySummaryData> {
  Value<int> id;
  Value<DateTime> date;
  Value<double> caloriesEaten;
  Value<double> proteinEaten;
  Value<double> carbsEaten;
  Value<double> fatEaten;
  Value<double> tdee;
  Value<double> netEnergy;
  Value<String> deficitZone;
  Value<int> entryCount;
  Value<int> correctionCount;
  Value<double> calorieGoal;
  Value<DateTime> createdAt;
  Value<DateTime> updatedAt;
  DailySummariesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.caloriesEaten = const Value.absent(),
    this.proteinEaten = const Value.absent(),
    this.carbsEaten = const Value.absent(),
    this.fatEaten = const Value.absent(),
    this.tdee = const Value.absent(),
    this.netEnergy = const Value.absent(),
    this.deficitZone = const Value.absent(),
    this.entryCount = const Value.absent(),
    this.correctionCount = const Value.absent(),
    this.calorieGoal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DailySummariesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    this.caloriesEaten = const Value.absent(),
    this.proteinEaten = const Value.absent(),
    this.carbsEaten = const Value.absent(),
    this.fatEaten = const Value.absent(),
    this.tdee = const Value.absent(),
    this.netEnergy = const Value.absent(),
    this.deficitZone = const Value.absent(),
    this.entryCount = const Value.absent(),
    this.correctionCount = const Value.absent(),
    this.calorieGoal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DailySummaryData> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? caloriesEaten,
    Expression<double>? proteinEaten,
    Expression<double>? carbsEaten,
    Expression<double>? fatEaten,
    Expression<double>? tdee,
    Expression<double>? netEnergy,
    Expression<String>? deficitZone,
    Expression<int>? entryCount,
    Expression<int>? correctionCount,
    Expression<double>? calorieGoal,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (caloriesEaten != null) 'calories_eaten': caloriesEaten,
      if (proteinEaten != null) 'protein_eaten': proteinEaten,
      if (carbsEaten != null) 'carbs_eaten': carbsEaten,
      if (fatEaten != null) 'fat_eaten': fatEaten,
      if (tdee != null) 'tdee': tdee,
      if (netEnergy != null) 'net_energy': netEnergy,
      if (deficitZone != null) 'deficit_zone': deficitZone,
      if (entryCount != null) 'entry_count': entryCount,
      if (correctionCount != null) 'correction_count': correctionCount,
      if (calorieGoal != null) 'calorie_goal': calorieGoal,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DailySummariesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<double>? caloriesEaten,
      Value<double>? proteinEaten,
      Value<double>? carbsEaten,
      Value<double>? fatEaten,
      Value<double>? tdee,
      Value<double>? netEnergy,
      Value<String>? deficitZone,
      Value<int>? entryCount,
      Value<int>? correctionCount,
      Value<double>? calorieGoal,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return DailySummariesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      caloriesEaten: caloriesEaten ?? this.caloriesEaten,
      proteinEaten: proteinEaten ?? this.proteinEaten,
      carbsEaten: carbsEaten ?? this.carbsEaten,
      fatEaten: fatEaten ?? this.fatEaten,
      tdee: tdee ?? this.tdee,
      netEnergy: netEnergy ?? this.netEnergy,
      deficitZone: deficitZone ?? this.deficitZone,
      entryCount: entryCount ?? this.entryCount,
      correctionCount: correctionCount ?? this.correctionCount,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (caloriesEaten.present) {
      map['calories_eaten'] = Variable<double>(caloriesEaten.value);
    }
    if (proteinEaten.present) {
      map['protein_eaten'] = Variable<double>(proteinEaten.value);
    }
    if (carbsEaten.present) {
      map['carbs_eaten'] = Variable<double>(carbsEaten.value);
    }
    if (fatEaten.present) {
      map['fat_eaten'] = Variable<double>(fatEaten.value);
    }
    if (tdee.present) {
      map['tdee'] = Variable<double>(tdee.value);
    }
    if (netEnergy.present) {
      map['net_energy'] = Variable<double>(netEnergy.value);
    }
    if (deficitZone.present) {
      map['deficit_zone'] = Variable<String>(deficitZone.value);
    }
    if (entryCount.present) {
      map['entry_count'] = Variable<int>(entryCount.value);
    }
    if (correctionCount.present) {
      map['correction_count'] = Variable<int>(correctionCount.value);
    }
    if (calorieGoal.present) {
      map['calorie_goal'] = Variable<double>(calorieGoal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailySummariesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('caloriesEaten: $caloriesEaten, ')
          ..write('proteinEaten: $proteinEaten, ')
          ..write('carbsEaten: $carbsEaten, ')
          ..write('fatEaten: $fatEaten, ')
          ..write('tdee: $tdee, ')
          ..write('netEnergy: $netEnergy, ')
          ..write('deficitZone: $deficitZone, ')
          ..write('entryCount: $entryCount, ')
          ..write('correctionCount: $correctionCount, ')
          ..write('calorieGoal: $calorieGoal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<MessageRole, int> role =
      GeneratedColumn<int>('role', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<MessageRole>($ChatMessagesTable.$converterrole);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _responseTypeMeta =
      const VerificationMeta('responseType');
  @override
  late final GeneratedColumn<String> responseType = GeneratedColumn<String>(
      'response_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cardDataJsonMeta =
      const VerificationMeta('cardDataJson');
  @override
  late final GeneratedColumn<String> cardDataJson = GeneratedColumn<String>(
      'card_data_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actionsJsonMeta =
      const VerificationMeta('actionsJson');
  @override
  late final GeneratedColumn<String> actionsJson = GeneratedColumn<String>(
      'actions_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _detectedIntentMeta =
      const VerificationMeta('detectedIntent');
  @override
  late final GeneratedColumn<String> detectedIntent = GeneratedColumn<String>(
      'detected_intent', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        role,
        content,
        responseType,
        cardDataJson,
        actionsJson,
        detectedIntent,
        confidence,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(Insertable<ChatMessageData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('response_type')) {
      context.handle(
          _responseTypeMeta,
          responseType.isAcceptableOrUnknown(
              data['response_type']!, _responseTypeMeta));
    }
    if (data.containsKey('card_data_json')) {
      context.handle(
          _cardDataJsonMeta,
          cardDataJson.isAcceptableOrUnknown(
              data['card_data_json']!, _cardDataJsonMeta));
    }
    if (data.containsKey('actions_json')) {
      context.handle(
          _actionsJsonMeta,
          actionsJson.isAcceptableOrUnknown(
              data['actions_json']!, _actionsJsonMeta));
    }
    if (data.containsKey('detected_intent')) {
      context.handle(
          _detectedIntentMeta,
          detectedIntent.isAcceptableOrUnknown(
              data['detected_intent']!, _detectedIntentMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      role: $ChatMessagesTable.$converterrole.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}role'])!),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      responseType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}response_type']),
      cardDataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_data_json']),
      actionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}actions_json']),
      detectedIntent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detected_intent']),
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MessageRole, int, int> $converterrole =
      const EnumIndexConverter<MessageRole>(MessageRole.values);
}

class ChatMessageData extends DataClass implements Insertable<ChatMessageData> {
  int id;
  String sessionId;
  MessageRole role;
  String content;
  String? responseType;
  String? cardDataJson;
  String? actionsJson;
  String? detectedIntent;
  double? confidence;
  DateTime createdAt;
  ChatMessageData(
      {required this.id,
      required this.sessionId,
      required this.role,
      required this.content,
      this.responseType,
      this.cardDataJson,
      this.actionsJson,
      this.detectedIntent,
      this.confidence,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    {
      map['role'] =
          Variable<int>($ChatMessagesTable.$converterrole.toSql(role));
    }
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || responseType != null) {
      map['response_type'] = Variable<String>(responseType);
    }
    if (!nullToAbsent || cardDataJson != null) {
      map['card_data_json'] = Variable<String>(cardDataJson);
    }
    if (!nullToAbsent || actionsJson != null) {
      map['actions_json'] = Variable<String>(actionsJson);
    }
    if (!nullToAbsent || detectedIntent != null) {
      map['detected_intent'] = Variable<String>(detectedIntent);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      role: Value(role),
      content: Value(content),
      responseType: responseType == null && nullToAbsent
          ? const Value.absent()
          : Value(responseType),
      cardDataJson: cardDataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(cardDataJson),
      actionsJson: actionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(actionsJson),
      detectedIntent: detectedIntent == null && nullToAbsent
          ? const Value.absent()
          : Value(detectedIntent),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessageData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageData(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      role: $ChatMessagesTable.$converterrole
          .fromJson(serializer.fromJson<int>(json['role'])),
      content: serializer.fromJson<String>(json['content']),
      responseType: serializer.fromJson<String?>(json['responseType']),
      cardDataJson: serializer.fromJson<String?>(json['cardDataJson']),
      actionsJson: serializer.fromJson<String?>(json['actionsJson']),
      detectedIntent: serializer.fromJson<String?>(json['detectedIntent']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'role': serializer
          .toJson<int>($ChatMessagesTable.$converterrole.toJson(role)),
      'content': serializer.toJson<String>(content),
      'responseType': serializer.toJson<String?>(responseType),
      'cardDataJson': serializer.toJson<String?>(cardDataJson),
      'actionsJson': serializer.toJson<String?>(actionsJson),
      'detectedIntent': serializer.toJson<String?>(detectedIntent),
      'confidence': serializer.toJson<double?>(confidence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatMessageData copyWith(
          {int? id,
          String? sessionId,
          MessageRole? role,
          String? content,
          Value<String?> responseType = const Value.absent(),
          Value<String?> cardDataJson = const Value.absent(),
          Value<String?> actionsJson = const Value.absent(),
          Value<String?> detectedIntent = const Value.absent(),
          Value<double?> confidence = const Value.absent(),
          DateTime? createdAt}) =>
      ChatMessageData(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        role: role ?? this.role,
        content: content ?? this.content,
        responseType:
            responseType.present ? responseType.value : this.responseType,
        cardDataJson:
            cardDataJson.present ? cardDataJson.value : this.cardDataJson,
        actionsJson: actionsJson.present ? actionsJson.value : this.actionsJson,
        detectedIntent:
            detectedIntent.present ? detectedIntent.value : this.detectedIntent,
        confidence: confidence.present ? confidence.value : this.confidence,
        createdAt: createdAt ?? this.createdAt,
      );
  ChatMessageData copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessageData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      responseType: data.responseType.present
          ? data.responseType.value
          : this.responseType,
      cardDataJson: data.cardDataJson.present
          ? data.cardDataJson.value
          : this.cardDataJson,
      actionsJson:
          data.actionsJson.present ? data.actionsJson.value : this.actionsJson,
      detectedIntent: data.detectedIntent.present
          ? data.detectedIntent.value
          : this.detectedIntent,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('responseType: $responseType, ')
          ..write('cardDataJson: $cardDataJson, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('detectedIntent: $detectedIntent, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, role, content, responseType,
      cardDataJson, actionsJson, detectedIntent, confidence, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.role == this.role &&
          other.content == this.content &&
          other.responseType == this.responseType &&
          other.cardDataJson == this.cardDataJson &&
          other.actionsJson == this.actionsJson &&
          other.detectedIntent == this.detectedIntent &&
          other.confidence == this.confidence &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessageData> {
  Value<int> id;
  Value<String> sessionId;
  Value<MessageRole> role;
  Value<String> content;
  Value<String?> responseType;
  Value<String?> cardDataJson;
  Value<String?> actionsJson;
  Value<String?> detectedIntent;
  Value<double?> confidence;
  Value<DateTime> createdAt;
  ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.responseType = const Value.absent(),
    this.cardDataJson = const Value.absent(),
    this.actionsJson = const Value.absent(),
    this.detectedIntent = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required MessageRole role,
    required String content,
    this.responseType = const Value.absent(),
    this.cardDataJson = const Value.absent(),
    this.actionsJson = const Value.absent(),
    this.detectedIntent = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : sessionId = Value(sessionId),
        role = Value(role),
        content = Value(content);
  static Insertable<ChatMessageData> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<int>? role,
    Expression<String>? content,
    Expression<String>? responseType,
    Expression<String>? cardDataJson,
    Expression<String>? actionsJson,
    Expression<String>? detectedIntent,
    Expression<double>? confidence,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (responseType != null) 'response_type': responseType,
      if (cardDataJson != null) 'card_data_json': cardDataJson,
      if (actionsJson != null) 'actions_json': actionsJson,
      if (detectedIntent != null) 'detected_intent': detectedIntent,
      if (confidence != null) 'confidence': confidence,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChatMessagesCompanion copyWith(
      {Value<int>? id,
      Value<String>? sessionId,
      Value<MessageRole>? role,
      Value<String>? content,
      Value<String?>? responseType,
      Value<String?>? cardDataJson,
      Value<String?>? actionsJson,
      Value<String?>? detectedIntent,
      Value<double?>? confidence,
      Value<DateTime>? createdAt}) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      responseType: responseType ?? this.responseType,
      cardDataJson: cardDataJson ?? this.cardDataJson,
      actionsJson: actionsJson ?? this.actionsJson,
      detectedIntent: detectedIntent ?? this.detectedIntent,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (role.present) {
      map['role'] =
          Variable<int>($ChatMessagesTable.$converterrole.toSql(role.value));
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (responseType.present) {
      map['response_type'] = Variable<String>(responseType.value);
    }
    if (cardDataJson.present) {
      map['card_data_json'] = Variable<String>(cardDataJson.value);
    }
    if (actionsJson.present) {
      map['actions_json'] = Variable<String>(actionsJson.value);
    }
    if (detectedIntent.present) {
      map['detected_intent'] = Variable<String>(detectedIntent.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('responseType: $responseType, ')
          ..write('cardDataJson: $cardDataJson, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('detectedIntent: $detectedIntent, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ChatSessionsTable extends ChatSessions
    with TableInfo<$ChatSessionsTable, ChatSessionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, sessionId, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<ChatSessionData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatSessionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatSessionData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ChatSessionsTable createAlias(String alias) {
    return $ChatSessionsTable(attachedDatabase, alias);
  }
}

class ChatSessionData extends DataClass implements Insertable<ChatSessionData> {
  int id;
  String title;
  String? sessionId;
  DateTime createdAt;
  DateTime updatedAt;
  ChatSessionData(
      {required this.id,
      required this.title,
      this.sessionId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChatSessionsCompanion toCompanion(bool nullToAbsent) {
    return ChatSessionsCompanion(
      id: Value(id),
      title: Value(title),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChatSessionData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatSessionData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'sessionId': serializer.toJson<String?>(sessionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChatSessionData copyWith(
          {int? id,
          String? title,
          Value<String?> sessionId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ChatSessionData(
        id: id ?? this.id,
        title: title ?? this.title,
        sessionId: sessionId.present ? sessionId.value : this.sessionId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ChatSessionData copyWithCompanion(ChatSessionsCompanion data) {
    return ChatSessionData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatSessionData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sessionId: $sessionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, sessionId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatSessionData &&
          other.id == this.id &&
          other.title == this.title &&
          other.sessionId == this.sessionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ChatSessionsCompanion extends UpdateCompanion<ChatSessionData> {
  Value<int> id;
  Value<String> title;
  Value<String?> sessionId;
  Value<DateTime> createdAt;
  Value<DateTime> updatedAt;
  ChatSessionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ChatSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.sessionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<ChatSessionData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? sessionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (sessionId != null) 'session_id': sessionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ChatSessionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? sessionId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return ChatSessionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      sessionId: sessionId ?? this.sessionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatSessionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sessionId: $sessionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarPathMeta =
      const VerificationMeta('avatarPath');
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
      'avatar_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _calorieGoalMeta =
      const VerificationMeta('calorieGoal');
  @override
  late final GeneratedColumn<double> calorieGoal = GeneratedColumn<double>(
      'calorie_goal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(2000));
  static const VerificationMeta _proteinGoalMeta =
      const VerificationMeta('proteinGoal');
  @override
  late final GeneratedColumn<double> proteinGoal = GeneratedColumn<double>(
      'protein_goal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(120));
  static const VerificationMeta _carbGoalMeta =
      const VerificationMeta('carbGoal');
  @override
  late final GeneratedColumn<double> carbGoal = GeneratedColumn<double>(
      'carb_goal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(250));
  static const VerificationMeta _fatGoalMeta =
      const VerificationMeta('fatGoal');
  @override
  late final GeneratedColumn<double> fatGoal = GeneratedColumn<double>(
      'fat_goal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(65));
  static const VerificationMeta _waterGoalMeta =
      const VerificationMeta('waterGoal');
  @override
  late final GeneratedColumn<double> waterGoal = GeneratedColumn<double>(
      'water_goal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(2500));
  static const VerificationMeta _breakfastBudgetMeta =
      const VerificationMeta('breakfastBudget');
  @override
  late final GeneratedColumn<double> breakfastBudget = GeneratedColumn<double>(
      'breakfast_budget', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(560));
  static const VerificationMeta _lunchBudgetMeta =
      const VerificationMeta('lunchBudget');
  @override
  late final GeneratedColumn<double> lunchBudget = GeneratedColumn<double>(
      'lunch_budget', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(700));
  static const VerificationMeta _dinnerBudgetMeta =
      const VerificationMeta('dinnerBudget');
  @override
  late final GeneratedColumn<double> dinnerBudget = GeneratedColumn<double>(
      'dinner_budget', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(600));
  static const VerificationMeta _snackBudgetMeta =
      const VerificationMeta('snackBudget');
  @override
  late final GeneratedColumn<double> snackBudget = GeneratedColumn<double>(
      'snack_budget', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(140));
  static const VerificationMeta _suggestionThresholdMeta =
      const VerificationMeta('suggestionThreshold');
  @override
  late final GeneratedColumn<double> suggestionThreshold =
      GeneratedColumn<double>('suggestion_threshold', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(100));
  static const VerificationMeta _mealSuggestionsEnabledMeta =
      const VerificationMeta('mealSuggestionsEnabled');
  @override
  late final GeneratedColumn<bool> mealSuggestionsEnabled =
      GeneratedColumn<bool>('meal_suggestions_enabled', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("meal_suggestions_enabled" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _isDarkModeMeta =
      const VerificationMeta('isDarkMode');
  @override
  late final GeneratedColumn<bool> isDarkMode = GeneratedColumn<bool>(
      'is_dark_mode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_dark_mode" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
      'locale', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cuisinePreferenceMeta =
      const VerificationMeta('cuisinePreference');
  @override
  late final GeneratedColumn<String> cuisinePreference =
      GeneratedColumn<String>('cuisine_preference', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('international'));
  static const VerificationMeta _hasGeminiApiKeyMeta =
      const VerificationMeta('hasGeminiApiKey');
  @override
  late final GeneratedColumn<bool> hasGeminiApiKey = GeneratedColumn<bool>(
      'has_gemini_api_key', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_gemini_api_key" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isGoogleCalendarConnectedMeta =
      const VerificationMeta('isGoogleCalendarConnected');
  @override
  late final GeneratedColumn<bool> isGoogleCalendarConnected =
      GeneratedColumn<bool>('is_google_calendar_connected', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("is_google_calendar_connected" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _isHealthConnectConnectedMeta =
      const VerificationMeta('isHealthConnectConnected');
  @override
  late final GeneratedColumn<bool> isHealthConnectConnected =
      GeneratedColumn<bool>(
          'is_health_connect_connected', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("is_health_connect_connected" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _customBmrMeta =
      const VerificationMeta('customBmr');
  @override
  late final GeneratedColumn<double> customBmr = GeneratedColumn<double>(
      'custom_bmr', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1500));
  static const VerificationMeta _tdeeMeta = const VerificationMeta('tdee');
  @override
  late final GeneratedColumn<double> tdee = GeneratedColumn<double>(
      'tdee', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
      'height', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _targetWeightMeta =
      const VerificationMeta('targetWeight');
  @override
  late final GeneratedColumn<double> targetWeight = GeneratedColumn<double>(
      'target_weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _activityLevelMeta =
      const VerificationMeta('activityLevel');
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
      'activity_level', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _onboardingCompleteMeta =
      const VerificationMeta('onboardingComplete');
  @override
  late final GeneratedColumn<bool> onboardingComplete = GeneratedColumn<bool>(
      'onboarding_complete', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("onboarding_complete" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _foodResearchConsentMeta =
      const VerificationMeta('foodResearchConsent');
  @override
  late final GeneratedColumn<bool> foodResearchConsent = GeneratedColumn<bool>(
      'food_research_consent', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("food_research_consent" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _foodResearchConsentAtMeta =
      const VerificationMeta('foodResearchConsentAt');
  @override
  late final GeneratedColumn<DateTime> foodResearchConsentAt =
      GeneratedColumn<DateTime>('food_research_consent_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _platformMeta =
      const VerificationMeta('platform');
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        avatarPath,
        calorieGoal,
        proteinGoal,
        carbGoal,
        fatGoal,
        waterGoal,
        breakfastBudget,
        lunchBudget,
        dinnerBudget,
        snackBudget,
        suggestionThreshold,
        mealSuggestionsEnabled,
        isDarkMode,
        locale,
        cuisinePreference,
        hasGeminiApiKey,
        isGoogleCalendarConnected,
        isHealthConnectConnected,
        customBmr,
        tdee,
        gender,
        age,
        weight,
        height,
        targetWeight,
        activityLevel,
        onboardingComplete,
        foodResearchConsent,
        foodResearchConsentAt,
        platform,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfileData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
          _avatarPathMeta,
          avatarPath.isAcceptableOrUnknown(
              data['avatar_path']!, _avatarPathMeta));
    }
    if (data.containsKey('calorie_goal')) {
      context.handle(
          _calorieGoalMeta,
          calorieGoal.isAcceptableOrUnknown(
              data['calorie_goal']!, _calorieGoalMeta));
    }
    if (data.containsKey('protein_goal')) {
      context.handle(
          _proteinGoalMeta,
          proteinGoal.isAcceptableOrUnknown(
              data['protein_goal']!, _proteinGoalMeta));
    }
    if (data.containsKey('carb_goal')) {
      context.handle(_carbGoalMeta,
          carbGoal.isAcceptableOrUnknown(data['carb_goal']!, _carbGoalMeta));
    }
    if (data.containsKey('fat_goal')) {
      context.handle(_fatGoalMeta,
          fatGoal.isAcceptableOrUnknown(data['fat_goal']!, _fatGoalMeta));
    }
    if (data.containsKey('water_goal')) {
      context.handle(_waterGoalMeta,
          waterGoal.isAcceptableOrUnknown(data['water_goal']!, _waterGoalMeta));
    }
    if (data.containsKey('breakfast_budget')) {
      context.handle(
          _breakfastBudgetMeta,
          breakfastBudget.isAcceptableOrUnknown(
              data['breakfast_budget']!, _breakfastBudgetMeta));
    }
    if (data.containsKey('lunch_budget')) {
      context.handle(
          _lunchBudgetMeta,
          lunchBudget.isAcceptableOrUnknown(
              data['lunch_budget']!, _lunchBudgetMeta));
    }
    if (data.containsKey('dinner_budget')) {
      context.handle(
          _dinnerBudgetMeta,
          dinnerBudget.isAcceptableOrUnknown(
              data['dinner_budget']!, _dinnerBudgetMeta));
    }
    if (data.containsKey('snack_budget')) {
      context.handle(
          _snackBudgetMeta,
          snackBudget.isAcceptableOrUnknown(
              data['snack_budget']!, _snackBudgetMeta));
    }
    if (data.containsKey('suggestion_threshold')) {
      context.handle(
          _suggestionThresholdMeta,
          suggestionThreshold.isAcceptableOrUnknown(
              data['suggestion_threshold']!, _suggestionThresholdMeta));
    }
    if (data.containsKey('meal_suggestions_enabled')) {
      context.handle(
          _mealSuggestionsEnabledMeta,
          mealSuggestionsEnabled.isAcceptableOrUnknown(
              data['meal_suggestions_enabled']!, _mealSuggestionsEnabledMeta));
    }
    if (data.containsKey('is_dark_mode')) {
      context.handle(
          _isDarkModeMeta,
          isDarkMode.isAcceptableOrUnknown(
              data['is_dark_mode']!, _isDarkModeMeta));
    }
    if (data.containsKey('locale')) {
      context.handle(_localeMeta,
          locale.isAcceptableOrUnknown(data['locale']!, _localeMeta));
    }
    if (data.containsKey('cuisine_preference')) {
      context.handle(
          _cuisinePreferenceMeta,
          cuisinePreference.isAcceptableOrUnknown(
              data['cuisine_preference']!, _cuisinePreferenceMeta));
    }
    if (data.containsKey('has_gemini_api_key')) {
      context.handle(
          _hasGeminiApiKeyMeta,
          hasGeminiApiKey.isAcceptableOrUnknown(
              data['has_gemini_api_key']!, _hasGeminiApiKeyMeta));
    }
    if (data.containsKey('is_google_calendar_connected')) {
      context.handle(
          _isGoogleCalendarConnectedMeta,
          isGoogleCalendarConnected.isAcceptableOrUnknown(
              data['is_google_calendar_connected']!,
              _isGoogleCalendarConnectedMeta));
    }
    if (data.containsKey('is_health_connect_connected')) {
      context.handle(
          _isHealthConnectConnectedMeta,
          isHealthConnectConnected.isAcceptableOrUnknown(
              data['is_health_connect_connected']!,
              _isHealthConnectConnectedMeta));
    }
    if (data.containsKey('custom_bmr')) {
      context.handle(_customBmrMeta,
          customBmr.isAcceptableOrUnknown(data['custom_bmr']!, _customBmrMeta));
    }
    if (data.containsKey('tdee')) {
      context.handle(
          _tdeeMeta, tdee.isAcceptableOrUnknown(data['tdee']!, _tdeeMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    }
    if (data.containsKey('target_weight')) {
      context.handle(
          _targetWeightMeta,
          targetWeight.isAcceptableOrUnknown(
              data['target_weight']!, _targetWeightMeta));
    }
    if (data.containsKey('activity_level')) {
      context.handle(
          _activityLevelMeta,
          activityLevel.isAcceptableOrUnknown(
              data['activity_level']!, _activityLevelMeta));
    }
    if (data.containsKey('onboarding_complete')) {
      context.handle(
          _onboardingCompleteMeta,
          onboardingComplete.isAcceptableOrUnknown(
              data['onboarding_complete']!, _onboardingCompleteMeta));
    }
    if (data.containsKey('food_research_consent')) {
      context.handle(
          _foodResearchConsentMeta,
          foodResearchConsent.isAcceptableOrUnknown(
              data['food_research_consent']!, _foodResearchConsentMeta));
    }
    if (data.containsKey('food_research_consent_at')) {
      context.handle(
          _foodResearchConsentAtMeta,
          foodResearchConsentAt.isAcceptableOrUnknown(
              data['food_research_consent_at']!, _foodResearchConsentAtMeta));
    }
    if (data.containsKey('platform')) {
      context.handle(_platformMeta,
          platform.isAcceptableOrUnknown(data['platform']!, _platformMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      avatarPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_path']),
      calorieGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calorie_goal'])!,
      proteinGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}protein_goal'])!,
      carbGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carb_goal'])!,
      fatGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat_goal'])!,
      waterGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}water_goal'])!,
      breakfastBudget: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}breakfast_budget'])!,
      lunchBudget: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lunch_budget'])!,
      dinnerBudget: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}dinner_budget'])!,
      snackBudget: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}snack_budget'])!,
      suggestionThreshold: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}suggestion_threshold'])!,
      mealSuggestionsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}meal_suggestions_enabled'])!,
      isDarkMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dark_mode'])!,
      locale: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}locale']),
      cuisinePreference: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}cuisine_preference'])!,
      hasGeminiApiKey: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}has_gemini_api_key'])!,
      isGoogleCalendarConnected: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}is_google_calendar_connected'])!,
      isHealthConnectConnected: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}is_health_connect_connected'])!,
      customBmr: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}custom_bmr'])!,
      tdee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tdee'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender']),
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age']),
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight']),
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height']),
      targetWeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_weight']),
      activityLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_level']),
      onboardingComplete: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}onboarding_complete'])!,
      foodResearchConsent: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}food_research_consent'])!,
      foodResearchConsentAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}food_research_consent_at']),
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfileData extends DataClass implements Insertable<UserProfileData> {
  int id;
  String? name;
  String? avatarPath;
  double calorieGoal;
  double proteinGoal;
  double carbGoal;
  double fatGoal;
  double waterGoal;
  double breakfastBudget;
  double lunchBudget;
  double dinnerBudget;
  double snackBudget;
  double suggestionThreshold;
  bool mealSuggestionsEnabled;
  bool isDarkMode;
  String? locale;
  String cuisinePreference;
  bool hasGeminiApiKey;
  bool isGoogleCalendarConnected;
  bool isHealthConnectConnected;
  double customBmr;
  double tdee;
  String? gender;
  int? age;
  double? weight;
  double? height;
  double? targetWeight;
  String? activityLevel;
  bool onboardingComplete;
  bool foodResearchConsent;
  DateTime? foodResearchConsentAt;
  String? platform;
  DateTime createdAt;
  DateTime updatedAt;
  UserProfileData(
      {required this.id,
      this.name,
      this.avatarPath,
      required this.calorieGoal,
      required this.proteinGoal,
      required this.carbGoal,
      required this.fatGoal,
      required this.waterGoal,
      required this.breakfastBudget,
      required this.lunchBudget,
      required this.dinnerBudget,
      required this.snackBudget,
      required this.suggestionThreshold,
      required this.mealSuggestionsEnabled,
      required this.isDarkMode,
      this.locale,
      required this.cuisinePreference,
      required this.hasGeminiApiKey,
      required this.isGoogleCalendarConnected,
      required this.isHealthConnectConnected,
      required this.customBmr,
      required this.tdee,
      this.gender,
      this.age,
      this.weight,
      this.height,
      this.targetWeight,
      this.activityLevel,
      required this.onboardingComplete,
      required this.foodResearchConsent,
      this.foodResearchConsentAt,
      this.platform,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    map['calorie_goal'] = Variable<double>(calorieGoal);
    map['protein_goal'] = Variable<double>(proteinGoal);
    map['carb_goal'] = Variable<double>(carbGoal);
    map['fat_goal'] = Variable<double>(fatGoal);
    map['water_goal'] = Variable<double>(waterGoal);
    map['breakfast_budget'] = Variable<double>(breakfastBudget);
    map['lunch_budget'] = Variable<double>(lunchBudget);
    map['dinner_budget'] = Variable<double>(dinnerBudget);
    map['snack_budget'] = Variable<double>(snackBudget);
    map['suggestion_threshold'] = Variable<double>(suggestionThreshold);
    map['meal_suggestions_enabled'] = Variable<bool>(mealSuggestionsEnabled);
    map['is_dark_mode'] = Variable<bool>(isDarkMode);
    if (!nullToAbsent || locale != null) {
      map['locale'] = Variable<String>(locale);
    }
    map['cuisine_preference'] = Variable<String>(cuisinePreference);
    map['has_gemini_api_key'] = Variable<bool>(hasGeminiApiKey);
    map['is_google_calendar_connected'] =
        Variable<bool>(isGoogleCalendarConnected);
    map['is_health_connect_connected'] =
        Variable<bool>(isHealthConnectConnected);
    map['custom_bmr'] = Variable<double>(customBmr);
    map['tdee'] = Variable<double>(tdee);
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<double>(height);
    }
    if (!nullToAbsent || targetWeight != null) {
      map['target_weight'] = Variable<double>(targetWeight);
    }
    if (!nullToAbsent || activityLevel != null) {
      map['activity_level'] = Variable<String>(activityLevel);
    }
    map['onboarding_complete'] = Variable<bool>(onboardingComplete);
    map['food_research_consent'] = Variable<bool>(foodResearchConsent);
    if (!nullToAbsent || foodResearchConsentAt != null) {
      map['food_research_consent_at'] =
          Variable<DateTime>(foodResearchConsentAt);
    }
    if (!nullToAbsent || platform != null) {
      map['platform'] = Variable<String>(platform);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      calorieGoal: Value(calorieGoal),
      proteinGoal: Value(proteinGoal),
      carbGoal: Value(carbGoal),
      fatGoal: Value(fatGoal),
      waterGoal: Value(waterGoal),
      breakfastBudget: Value(breakfastBudget),
      lunchBudget: Value(lunchBudget),
      dinnerBudget: Value(dinnerBudget),
      snackBudget: Value(snackBudget),
      suggestionThreshold: Value(suggestionThreshold),
      mealSuggestionsEnabled: Value(mealSuggestionsEnabled),
      isDarkMode: Value(isDarkMode),
      locale:
          locale == null && nullToAbsent ? const Value.absent() : Value(locale),
      cuisinePreference: Value(cuisinePreference),
      hasGeminiApiKey: Value(hasGeminiApiKey),
      isGoogleCalendarConnected: Value(isGoogleCalendarConnected),
      isHealthConnectConnected: Value(isHealthConnectConnected),
      customBmr: Value(customBmr),
      tdee: Value(tdee),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      weight:
          weight == null && nullToAbsent ? const Value.absent() : Value(weight),
      height:
          height == null && nullToAbsent ? const Value.absent() : Value(height),
      targetWeight: targetWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeight),
      activityLevel: activityLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(activityLevel),
      onboardingComplete: Value(onboardingComplete),
      foodResearchConsent: Value(foodResearchConsent),
      foodResearchConsentAt: foodResearchConsentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(foodResearchConsentAt),
      platform: platform == null && nullToAbsent
          ? const Value.absent()
          : Value(platform),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      calorieGoal: serializer.fromJson<double>(json['calorieGoal']),
      proteinGoal: serializer.fromJson<double>(json['proteinGoal']),
      carbGoal: serializer.fromJson<double>(json['carbGoal']),
      fatGoal: serializer.fromJson<double>(json['fatGoal']),
      waterGoal: serializer.fromJson<double>(json['waterGoal']),
      breakfastBudget: serializer.fromJson<double>(json['breakfastBudget']),
      lunchBudget: serializer.fromJson<double>(json['lunchBudget']),
      dinnerBudget: serializer.fromJson<double>(json['dinnerBudget']),
      snackBudget: serializer.fromJson<double>(json['snackBudget']),
      suggestionThreshold:
          serializer.fromJson<double>(json['suggestionThreshold']),
      mealSuggestionsEnabled:
          serializer.fromJson<bool>(json['mealSuggestionsEnabled']),
      isDarkMode: serializer.fromJson<bool>(json['isDarkMode']),
      locale: serializer.fromJson<String?>(json['locale']),
      cuisinePreference: serializer.fromJson<String>(json['cuisinePreference']),
      hasGeminiApiKey: serializer.fromJson<bool>(json['hasGeminiApiKey']),
      isGoogleCalendarConnected:
          serializer.fromJson<bool>(json['isGoogleCalendarConnected']),
      isHealthConnectConnected:
          serializer.fromJson<bool>(json['isHealthConnectConnected']),
      customBmr: serializer.fromJson<double>(json['customBmr']),
      tdee: serializer.fromJson<double>(json['tdee']),
      gender: serializer.fromJson<String?>(json['gender']),
      age: serializer.fromJson<int?>(json['age']),
      weight: serializer.fromJson<double?>(json['weight']),
      height: serializer.fromJson<double?>(json['height']),
      targetWeight: serializer.fromJson<double?>(json['targetWeight']),
      activityLevel: serializer.fromJson<String?>(json['activityLevel']),
      onboardingComplete: serializer.fromJson<bool>(json['onboardingComplete']),
      foodResearchConsent:
          serializer.fromJson<bool>(json['foodResearchConsent']),
      foodResearchConsentAt:
          serializer.fromJson<DateTime?>(json['foodResearchConsentAt']),
      platform: serializer.fromJson<String?>(json['platform']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'calorieGoal': serializer.toJson<double>(calorieGoal),
      'proteinGoal': serializer.toJson<double>(proteinGoal),
      'carbGoal': serializer.toJson<double>(carbGoal),
      'fatGoal': serializer.toJson<double>(fatGoal),
      'waterGoal': serializer.toJson<double>(waterGoal),
      'breakfastBudget': serializer.toJson<double>(breakfastBudget),
      'lunchBudget': serializer.toJson<double>(lunchBudget),
      'dinnerBudget': serializer.toJson<double>(dinnerBudget),
      'snackBudget': serializer.toJson<double>(snackBudget),
      'suggestionThreshold': serializer.toJson<double>(suggestionThreshold),
      'mealSuggestionsEnabled': serializer.toJson<bool>(mealSuggestionsEnabled),
      'isDarkMode': serializer.toJson<bool>(isDarkMode),
      'locale': serializer.toJson<String?>(locale),
      'cuisinePreference': serializer.toJson<String>(cuisinePreference),
      'hasGeminiApiKey': serializer.toJson<bool>(hasGeminiApiKey),
      'isGoogleCalendarConnected':
          serializer.toJson<bool>(isGoogleCalendarConnected),
      'isHealthConnectConnected':
          serializer.toJson<bool>(isHealthConnectConnected),
      'customBmr': serializer.toJson<double>(customBmr),
      'tdee': serializer.toJson<double>(tdee),
      'gender': serializer.toJson<String?>(gender),
      'age': serializer.toJson<int?>(age),
      'weight': serializer.toJson<double?>(weight),
      'height': serializer.toJson<double?>(height),
      'targetWeight': serializer.toJson<double?>(targetWeight),
      'activityLevel': serializer.toJson<String?>(activityLevel),
      'onboardingComplete': serializer.toJson<bool>(onboardingComplete),
      'foodResearchConsent': serializer.toJson<bool>(foodResearchConsent),
      'foodResearchConsentAt':
          serializer.toJson<DateTime?>(foodResearchConsentAt),
      'platform': serializer.toJson<String?>(platform),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfileData copyWith(
          {int? id,
          Value<String?> name = const Value.absent(),
          Value<String?> avatarPath = const Value.absent(),
          double? calorieGoal,
          double? proteinGoal,
          double? carbGoal,
          double? fatGoal,
          double? waterGoal,
          double? breakfastBudget,
          double? lunchBudget,
          double? dinnerBudget,
          double? snackBudget,
          double? suggestionThreshold,
          bool? mealSuggestionsEnabled,
          bool? isDarkMode,
          Value<String?> locale = const Value.absent(),
          String? cuisinePreference,
          bool? hasGeminiApiKey,
          bool? isGoogleCalendarConnected,
          bool? isHealthConnectConnected,
          double? customBmr,
          double? tdee,
          Value<String?> gender = const Value.absent(),
          Value<int?> age = const Value.absent(),
          Value<double?> weight = const Value.absent(),
          Value<double?> height = const Value.absent(),
          Value<double?> targetWeight = const Value.absent(),
          Value<String?> activityLevel = const Value.absent(),
          bool? onboardingComplete,
          bool? foodResearchConsent,
          Value<DateTime?> foodResearchConsentAt = const Value.absent(),
          Value<String?> platform = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      UserProfileData(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
        avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
        calorieGoal: calorieGoal ?? this.calorieGoal,
        proteinGoal: proteinGoal ?? this.proteinGoal,
        carbGoal: carbGoal ?? this.carbGoal,
        fatGoal: fatGoal ?? this.fatGoal,
        waterGoal: waterGoal ?? this.waterGoal,
        breakfastBudget: breakfastBudget ?? this.breakfastBudget,
        lunchBudget: lunchBudget ?? this.lunchBudget,
        dinnerBudget: dinnerBudget ?? this.dinnerBudget,
        snackBudget: snackBudget ?? this.snackBudget,
        suggestionThreshold: suggestionThreshold ?? this.suggestionThreshold,
        mealSuggestionsEnabled:
            mealSuggestionsEnabled ?? this.mealSuggestionsEnabled,
        isDarkMode: isDarkMode ?? this.isDarkMode,
        locale: locale.present ? locale.value : this.locale,
        cuisinePreference: cuisinePreference ?? this.cuisinePreference,
        hasGeminiApiKey: hasGeminiApiKey ?? this.hasGeminiApiKey,
        isGoogleCalendarConnected:
            isGoogleCalendarConnected ?? this.isGoogleCalendarConnected,
        isHealthConnectConnected:
            isHealthConnectConnected ?? this.isHealthConnectConnected,
        customBmr: customBmr ?? this.customBmr,
        tdee: tdee ?? this.tdee,
        gender: gender.present ? gender.value : this.gender,
        age: age.present ? age.value : this.age,
        weight: weight.present ? weight.value : this.weight,
        height: height.present ? height.value : this.height,
        targetWeight:
            targetWeight.present ? targetWeight.value : this.targetWeight,
        activityLevel:
            activityLevel.present ? activityLevel.value : this.activityLevel,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        foodResearchConsent: foodResearchConsent ?? this.foodResearchConsent,
        foodResearchConsentAt: foodResearchConsentAt.present
            ? foodResearchConsentAt.value
            : this.foodResearchConsentAt,
        platform: platform.present ? platform.value : this.platform,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserProfileData copyWithCompanion(UserProfilesCompanion data) {
    return UserProfileData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatarPath:
          data.avatarPath.present ? data.avatarPath.value : this.avatarPath,
      calorieGoal:
          data.calorieGoal.present ? data.calorieGoal.value : this.calorieGoal,
      proteinGoal:
          data.proteinGoal.present ? data.proteinGoal.value : this.proteinGoal,
      carbGoal: data.carbGoal.present ? data.carbGoal.value : this.carbGoal,
      fatGoal: data.fatGoal.present ? data.fatGoal.value : this.fatGoal,
      waterGoal: data.waterGoal.present ? data.waterGoal.value : this.waterGoal,
      breakfastBudget: data.breakfastBudget.present
          ? data.breakfastBudget.value
          : this.breakfastBudget,
      lunchBudget:
          data.lunchBudget.present ? data.lunchBudget.value : this.lunchBudget,
      dinnerBudget: data.dinnerBudget.present
          ? data.dinnerBudget.value
          : this.dinnerBudget,
      snackBudget:
          data.snackBudget.present ? data.snackBudget.value : this.snackBudget,
      suggestionThreshold: data.suggestionThreshold.present
          ? data.suggestionThreshold.value
          : this.suggestionThreshold,
      mealSuggestionsEnabled: data.mealSuggestionsEnabled.present
          ? data.mealSuggestionsEnabled.value
          : this.mealSuggestionsEnabled,
      isDarkMode:
          data.isDarkMode.present ? data.isDarkMode.value : this.isDarkMode,
      locale: data.locale.present ? data.locale.value : this.locale,
      cuisinePreference: data.cuisinePreference.present
          ? data.cuisinePreference.value
          : this.cuisinePreference,
      hasGeminiApiKey: data.hasGeminiApiKey.present
          ? data.hasGeminiApiKey.value
          : this.hasGeminiApiKey,
      isGoogleCalendarConnected: data.isGoogleCalendarConnected.present
          ? data.isGoogleCalendarConnected.value
          : this.isGoogleCalendarConnected,
      isHealthConnectConnected: data.isHealthConnectConnected.present
          ? data.isHealthConnectConnected.value
          : this.isHealthConnectConnected,
      customBmr: data.customBmr.present ? data.customBmr.value : this.customBmr,
      tdee: data.tdee.present ? data.tdee.value : this.tdee,
      gender: data.gender.present ? data.gender.value : this.gender,
      age: data.age.present ? data.age.value : this.age,
      weight: data.weight.present ? data.weight.value : this.weight,
      height: data.height.present ? data.height.value : this.height,
      targetWeight: data.targetWeight.present
          ? data.targetWeight.value
          : this.targetWeight,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      onboardingComplete: data.onboardingComplete.present
          ? data.onboardingComplete.value
          : this.onboardingComplete,
      foodResearchConsent: data.foodResearchConsent.present
          ? data.foodResearchConsent.value
          : this.foodResearchConsent,
      foodResearchConsentAt: data.foodResearchConsentAt.present
          ? data.foodResearchConsentAt.value
          : this.foodResearchConsentAt,
      platform: data.platform.present ? data.platform.value : this.platform,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('calorieGoal: $calorieGoal, ')
          ..write('proteinGoal: $proteinGoal, ')
          ..write('carbGoal: $carbGoal, ')
          ..write('fatGoal: $fatGoal, ')
          ..write('waterGoal: $waterGoal, ')
          ..write('breakfastBudget: $breakfastBudget, ')
          ..write('lunchBudget: $lunchBudget, ')
          ..write('dinnerBudget: $dinnerBudget, ')
          ..write('snackBudget: $snackBudget, ')
          ..write('suggestionThreshold: $suggestionThreshold, ')
          ..write('mealSuggestionsEnabled: $mealSuggestionsEnabled, ')
          ..write('isDarkMode: $isDarkMode, ')
          ..write('locale: $locale, ')
          ..write('cuisinePreference: $cuisinePreference, ')
          ..write('hasGeminiApiKey: $hasGeminiApiKey, ')
          ..write('isGoogleCalendarConnected: $isGoogleCalendarConnected, ')
          ..write('isHealthConnectConnected: $isHealthConnectConnected, ')
          ..write('customBmr: $customBmr, ')
          ..write('tdee: $tdee, ')
          ..write('gender: $gender, ')
          ..write('age: $age, ')
          ..write('weight: $weight, ')
          ..write('height: $height, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('foodResearchConsent: $foodResearchConsent, ')
          ..write('foodResearchConsentAt: $foodResearchConsentAt, ')
          ..write('platform: $platform, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        avatarPath,
        calorieGoal,
        proteinGoal,
        carbGoal,
        fatGoal,
        waterGoal,
        breakfastBudget,
        lunchBudget,
        dinnerBudget,
        snackBudget,
        suggestionThreshold,
        mealSuggestionsEnabled,
        isDarkMode,
        locale,
        cuisinePreference,
        hasGeminiApiKey,
        isGoogleCalendarConnected,
        isHealthConnectConnected,
        customBmr,
        tdee,
        gender,
        age,
        weight,
        height,
        targetWeight,
        activityLevel,
        onboardingComplete,
        foodResearchConsent,
        foodResearchConsentAt,
        platform,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileData &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatarPath == this.avatarPath &&
          other.calorieGoal == this.calorieGoal &&
          other.proteinGoal == this.proteinGoal &&
          other.carbGoal == this.carbGoal &&
          other.fatGoal == this.fatGoal &&
          other.waterGoal == this.waterGoal &&
          other.breakfastBudget == this.breakfastBudget &&
          other.lunchBudget == this.lunchBudget &&
          other.dinnerBudget == this.dinnerBudget &&
          other.snackBudget == this.snackBudget &&
          other.suggestionThreshold == this.suggestionThreshold &&
          other.mealSuggestionsEnabled == this.mealSuggestionsEnabled &&
          other.isDarkMode == this.isDarkMode &&
          other.locale == this.locale &&
          other.cuisinePreference == this.cuisinePreference &&
          other.hasGeminiApiKey == this.hasGeminiApiKey &&
          other.isGoogleCalendarConnected == this.isGoogleCalendarConnected &&
          other.isHealthConnectConnected == this.isHealthConnectConnected &&
          other.customBmr == this.customBmr &&
          other.tdee == this.tdee &&
          other.gender == this.gender &&
          other.age == this.age &&
          other.weight == this.weight &&
          other.height == this.height &&
          other.targetWeight == this.targetWeight &&
          other.activityLevel == this.activityLevel &&
          other.onboardingComplete == this.onboardingComplete &&
          other.foodResearchConsent == this.foodResearchConsent &&
          other.foodResearchConsentAt == this.foodResearchConsentAt &&
          other.platform == this.platform &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfileData> {
  Value<int> id;
  Value<String?> name;
  Value<String?> avatarPath;
  Value<double> calorieGoal;
  Value<double> proteinGoal;
  Value<double> carbGoal;
  Value<double> fatGoal;
  Value<double> waterGoal;
  Value<double> breakfastBudget;
  Value<double> lunchBudget;
  Value<double> dinnerBudget;
  Value<double> snackBudget;
  Value<double> suggestionThreshold;
  Value<bool> mealSuggestionsEnabled;
  Value<bool> isDarkMode;
  Value<String?> locale;
  Value<String> cuisinePreference;
  Value<bool> hasGeminiApiKey;
  Value<bool> isGoogleCalendarConnected;
  Value<bool> isHealthConnectConnected;
  Value<double> customBmr;
  Value<double> tdee;
  Value<String?> gender;
  Value<int?> age;
  Value<double?> weight;
  Value<double?> height;
  Value<double?> targetWeight;
  Value<String?> activityLevel;
  Value<bool> onboardingComplete;
  Value<bool> foodResearchConsent;
  Value<DateTime?> foodResearchConsentAt;
  Value<String?> platform;
  Value<DateTime> createdAt;
  Value<DateTime> updatedAt;
  UserProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.calorieGoal = const Value.absent(),
    this.proteinGoal = const Value.absent(),
    this.carbGoal = const Value.absent(),
    this.fatGoal = const Value.absent(),
    this.waterGoal = const Value.absent(),
    this.breakfastBudget = const Value.absent(),
    this.lunchBudget = const Value.absent(),
    this.dinnerBudget = const Value.absent(),
    this.snackBudget = const Value.absent(),
    this.suggestionThreshold = const Value.absent(),
    this.mealSuggestionsEnabled = const Value.absent(),
    this.isDarkMode = const Value.absent(),
    this.locale = const Value.absent(),
    this.cuisinePreference = const Value.absent(),
    this.hasGeminiApiKey = const Value.absent(),
    this.isGoogleCalendarConnected = const Value.absent(),
    this.isHealthConnectConnected = const Value.absent(),
    this.customBmr = const Value.absent(),
    this.tdee = const Value.absent(),
    this.gender = const Value.absent(),
    this.age = const Value.absent(),
    this.weight = const Value.absent(),
    this.height = const Value.absent(),
    this.targetWeight = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.foodResearchConsent = const Value.absent(),
    this.foodResearchConsentAt = const Value.absent(),
    this.platform = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.calorieGoal = const Value.absent(),
    this.proteinGoal = const Value.absent(),
    this.carbGoal = const Value.absent(),
    this.fatGoal = const Value.absent(),
    this.waterGoal = const Value.absent(),
    this.breakfastBudget = const Value.absent(),
    this.lunchBudget = const Value.absent(),
    this.dinnerBudget = const Value.absent(),
    this.snackBudget = const Value.absent(),
    this.suggestionThreshold = const Value.absent(),
    this.mealSuggestionsEnabled = const Value.absent(),
    this.isDarkMode = const Value.absent(),
    this.locale = const Value.absent(),
    this.cuisinePreference = const Value.absent(),
    this.hasGeminiApiKey = const Value.absent(),
    this.isGoogleCalendarConnected = const Value.absent(),
    this.isHealthConnectConnected = const Value.absent(),
    this.customBmr = const Value.absent(),
    this.tdee = const Value.absent(),
    this.gender = const Value.absent(),
    this.age = const Value.absent(),
    this.weight = const Value.absent(),
    this.height = const Value.absent(),
    this.targetWeight = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.foodResearchConsent = const Value.absent(),
    this.foodResearchConsentAt = const Value.absent(),
    this.platform = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<UserProfileData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? avatarPath,
    Expression<double>? calorieGoal,
    Expression<double>? proteinGoal,
    Expression<double>? carbGoal,
    Expression<double>? fatGoal,
    Expression<double>? waterGoal,
    Expression<double>? breakfastBudget,
    Expression<double>? lunchBudget,
    Expression<double>? dinnerBudget,
    Expression<double>? snackBudget,
    Expression<double>? suggestionThreshold,
    Expression<bool>? mealSuggestionsEnabled,
    Expression<bool>? isDarkMode,
    Expression<String>? locale,
    Expression<String>? cuisinePreference,
    Expression<bool>? hasGeminiApiKey,
    Expression<bool>? isGoogleCalendarConnected,
    Expression<bool>? isHealthConnectConnected,
    Expression<double>? customBmr,
    Expression<double>? tdee,
    Expression<String>? gender,
    Expression<int>? age,
    Expression<double>? weight,
    Expression<double>? height,
    Expression<double>? targetWeight,
    Expression<String>? activityLevel,
    Expression<bool>? onboardingComplete,
    Expression<bool>? foodResearchConsent,
    Expression<DateTime>? foodResearchConsentAt,
    Expression<String>? platform,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (calorieGoal != null) 'calorie_goal': calorieGoal,
      if (proteinGoal != null) 'protein_goal': proteinGoal,
      if (carbGoal != null) 'carb_goal': carbGoal,
      if (fatGoal != null) 'fat_goal': fatGoal,
      if (waterGoal != null) 'water_goal': waterGoal,
      if (breakfastBudget != null) 'breakfast_budget': breakfastBudget,
      if (lunchBudget != null) 'lunch_budget': lunchBudget,
      if (dinnerBudget != null) 'dinner_budget': dinnerBudget,
      if (snackBudget != null) 'snack_budget': snackBudget,
      if (suggestionThreshold != null)
        'suggestion_threshold': suggestionThreshold,
      if (mealSuggestionsEnabled != null)
        'meal_suggestions_enabled': mealSuggestionsEnabled,
      if (isDarkMode != null) 'is_dark_mode': isDarkMode,
      if (locale != null) 'locale': locale,
      if (cuisinePreference != null) 'cuisine_preference': cuisinePreference,
      if (hasGeminiApiKey != null) 'has_gemini_api_key': hasGeminiApiKey,
      if (isGoogleCalendarConnected != null)
        'is_google_calendar_connected': isGoogleCalendarConnected,
      if (isHealthConnectConnected != null)
        'is_health_connect_connected': isHealthConnectConnected,
      if (customBmr != null) 'custom_bmr': customBmr,
      if (tdee != null) 'tdee': tdee,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (targetWeight != null) 'target_weight': targetWeight,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (onboardingComplete != null) 'onboarding_complete': onboardingComplete,
      if (foodResearchConsent != null)
        'food_research_consent': foodResearchConsent,
      if (foodResearchConsentAt != null)
        'food_research_consent_at': foodResearchConsentAt,
      if (platform != null) 'platform': platform,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String?>? name,
      Value<String?>? avatarPath,
      Value<double>? calorieGoal,
      Value<double>? proteinGoal,
      Value<double>? carbGoal,
      Value<double>? fatGoal,
      Value<double>? waterGoal,
      Value<double>? breakfastBudget,
      Value<double>? lunchBudget,
      Value<double>? dinnerBudget,
      Value<double>? snackBudget,
      Value<double>? suggestionThreshold,
      Value<bool>? mealSuggestionsEnabled,
      Value<bool>? isDarkMode,
      Value<String?>? locale,
      Value<String>? cuisinePreference,
      Value<bool>? hasGeminiApiKey,
      Value<bool>? isGoogleCalendarConnected,
      Value<bool>? isHealthConnectConnected,
      Value<double>? customBmr,
      Value<double>? tdee,
      Value<String?>? gender,
      Value<int?>? age,
      Value<double?>? weight,
      Value<double?>? height,
      Value<double?>? targetWeight,
      Value<String?>? activityLevel,
      Value<bool>? onboardingComplete,
      Value<bool>? foodResearchConsent,
      Value<DateTime?>? foodResearchConsentAt,
      Value<String?>? platform,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbGoal: carbGoal ?? this.carbGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      waterGoal: waterGoal ?? this.waterGoal,
      breakfastBudget: breakfastBudget ?? this.breakfastBudget,
      lunchBudget: lunchBudget ?? this.lunchBudget,
      dinnerBudget: dinnerBudget ?? this.dinnerBudget,
      snackBudget: snackBudget ?? this.snackBudget,
      suggestionThreshold: suggestionThreshold ?? this.suggestionThreshold,
      mealSuggestionsEnabled:
          mealSuggestionsEnabled ?? this.mealSuggestionsEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      locale: locale ?? this.locale,
      cuisinePreference: cuisinePreference ?? this.cuisinePreference,
      hasGeminiApiKey: hasGeminiApiKey ?? this.hasGeminiApiKey,
      isGoogleCalendarConnected:
          isGoogleCalendarConnected ?? this.isGoogleCalendarConnected,
      isHealthConnectConnected:
          isHealthConnectConnected ?? this.isHealthConnectConnected,
      customBmr: customBmr ?? this.customBmr,
      tdee: tdee ?? this.tdee,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      targetWeight: targetWeight ?? this.targetWeight,
      activityLevel: activityLevel ?? this.activityLevel,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      foodResearchConsent: foodResearchConsent ?? this.foodResearchConsent,
      foodResearchConsentAt:
          foodResearchConsentAt ?? this.foodResearchConsentAt,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (calorieGoal.present) {
      map['calorie_goal'] = Variable<double>(calorieGoal.value);
    }
    if (proteinGoal.present) {
      map['protein_goal'] = Variable<double>(proteinGoal.value);
    }
    if (carbGoal.present) {
      map['carb_goal'] = Variable<double>(carbGoal.value);
    }
    if (fatGoal.present) {
      map['fat_goal'] = Variable<double>(fatGoal.value);
    }
    if (waterGoal.present) {
      map['water_goal'] = Variable<double>(waterGoal.value);
    }
    if (breakfastBudget.present) {
      map['breakfast_budget'] = Variable<double>(breakfastBudget.value);
    }
    if (lunchBudget.present) {
      map['lunch_budget'] = Variable<double>(lunchBudget.value);
    }
    if (dinnerBudget.present) {
      map['dinner_budget'] = Variable<double>(dinnerBudget.value);
    }
    if (snackBudget.present) {
      map['snack_budget'] = Variable<double>(snackBudget.value);
    }
    if (suggestionThreshold.present) {
      map['suggestion_threshold'] = Variable<double>(suggestionThreshold.value);
    }
    if (mealSuggestionsEnabled.present) {
      map['meal_suggestions_enabled'] =
          Variable<bool>(mealSuggestionsEnabled.value);
    }
    if (isDarkMode.present) {
      map['is_dark_mode'] = Variable<bool>(isDarkMode.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (cuisinePreference.present) {
      map['cuisine_preference'] = Variable<String>(cuisinePreference.value);
    }
    if (hasGeminiApiKey.present) {
      map['has_gemini_api_key'] = Variable<bool>(hasGeminiApiKey.value);
    }
    if (isGoogleCalendarConnected.present) {
      map['is_google_calendar_connected'] =
          Variable<bool>(isGoogleCalendarConnected.value);
    }
    if (isHealthConnectConnected.present) {
      map['is_health_connect_connected'] =
          Variable<bool>(isHealthConnectConnected.value);
    }
    if (customBmr.present) {
      map['custom_bmr'] = Variable<double>(customBmr.value);
    }
    if (tdee.present) {
      map['tdee'] = Variable<double>(tdee.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (targetWeight.present) {
      map['target_weight'] = Variable<double>(targetWeight.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (onboardingComplete.present) {
      map['onboarding_complete'] = Variable<bool>(onboardingComplete.value);
    }
    if (foodResearchConsent.present) {
      map['food_research_consent'] = Variable<bool>(foodResearchConsent.value);
    }
    if (foodResearchConsentAt.present) {
      map['food_research_consent_at'] =
          Variable<DateTime>(foodResearchConsentAt.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('calorieGoal: $calorieGoal, ')
          ..write('proteinGoal: $proteinGoal, ')
          ..write('carbGoal: $carbGoal, ')
          ..write('fatGoal: $fatGoal, ')
          ..write('waterGoal: $waterGoal, ')
          ..write('breakfastBudget: $breakfastBudget, ')
          ..write('lunchBudget: $lunchBudget, ')
          ..write('dinnerBudget: $dinnerBudget, ')
          ..write('snackBudget: $snackBudget, ')
          ..write('suggestionThreshold: $suggestionThreshold, ')
          ..write('mealSuggestionsEnabled: $mealSuggestionsEnabled, ')
          ..write('isDarkMode: $isDarkMode, ')
          ..write('locale: $locale, ')
          ..write('cuisinePreference: $cuisinePreference, ')
          ..write('hasGeminiApiKey: $hasGeminiApiKey, ')
          ..write('isGoogleCalendarConnected: $isGoogleCalendarConnected, ')
          ..write('isHealthConnectConnected: $isHealthConnectConnected, ')
          ..write('customBmr: $customBmr, ')
          ..write('tdee: $tdee, ')
          ..write('gender: $gender, ')
          ..write('age: $age, ')
          ..write('weight: $weight, ')
          ..write('height: $height, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('foodResearchConsent: $foodResearchConsent, ')
          ..write('foodResearchConsentAt: $foodResearchConsentAt, ')
          ..write('platform: $platform, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EnergyTransactionsTable extends EnergyTransactions
    with TableInfo<$EnergyTransactionsTable, EnergyTransactionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnergyTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _balanceAfterMeta =
      const VerificationMeta('balanceAfter');
  @override
  late final GeneratedColumn<int> balanceAfter = GeneratedColumn<int>(
      'balance_after', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _packageIdMeta =
      const VerificationMeta('packageId');
  @override
  late final GeneratedColumn<String> packageId = GeneratedColumn<String>(
      'package_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purchaseTokenMeta =
      const VerificationMeta('purchaseToken');
  @override
  late final GeneratedColumn<String> purchaseToken = GeneratedColumn<String>(
      'purchase_token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        amount,
        balanceAfter,
        packageId,
        description,
        purchaseToken,
        deviceId,
        timestamp
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'energy_transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<EnergyTransactionData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('balance_after')) {
      context.handle(
          _balanceAfterMeta,
          balanceAfter.isAcceptableOrUnknown(
              data['balance_after']!, _balanceAfterMeta));
    } else if (isInserting) {
      context.missing(_balanceAfterMeta);
    }
    if (data.containsKey('package_id')) {
      context.handle(_packageIdMeta,
          packageId.isAcceptableOrUnknown(data['package_id']!, _packageIdMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('purchase_token')) {
      context.handle(
          _purchaseTokenMeta,
          purchaseToken.isAcceptableOrUnknown(
              data['purchase_token']!, _purchaseTokenMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnergyTransactionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnergyTransactionData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      balanceAfter: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}balance_after'])!,
      packageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}package_id']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      purchaseToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_token']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $EnergyTransactionsTable createAlias(String alias) {
    return $EnergyTransactionsTable(attachedDatabase, alias);
  }
}

class EnergyTransactionData extends DataClass
    implements Insertable<EnergyTransactionData> {
  int id;
  String type;
  int amount;
  int balanceAfter;
  String? packageId;
  String? description;
  String? purchaseToken;
  String? deviceId;
  DateTime timestamp;
  EnergyTransactionData(
      {required this.id,
      required this.type,
      required this.amount,
      required this.balanceAfter,
      this.packageId,
      this.description,
      this.purchaseToken,
      this.deviceId,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<int>(amount);
    map['balance_after'] = Variable<int>(balanceAfter);
    if (!nullToAbsent || packageId != null) {
      map['package_id'] = Variable<String>(packageId);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || purchaseToken != null) {
      map['purchase_token'] = Variable<String>(purchaseToken);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  EnergyTransactionsCompanion toCompanion(bool nullToAbsent) {
    return EnergyTransactionsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      balanceAfter: Value(balanceAfter),
      packageId: packageId == null && nullToAbsent
          ? const Value.absent()
          : Value(packageId),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      purchaseToken: purchaseToken == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseToken),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      timestamp: Value(timestamp),
    );
  }

  factory EnergyTransactionData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnergyTransactionData(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<int>(json['amount']),
      balanceAfter: serializer.fromJson<int>(json['balanceAfter']),
      packageId: serializer.fromJson<String?>(json['packageId']),
      description: serializer.fromJson<String?>(json['description']),
      purchaseToken: serializer.fromJson<String?>(json['purchaseToken']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<int>(amount),
      'balanceAfter': serializer.toJson<int>(balanceAfter),
      'packageId': serializer.toJson<String?>(packageId),
      'description': serializer.toJson<String?>(description),
      'purchaseToken': serializer.toJson<String?>(purchaseToken),
      'deviceId': serializer.toJson<String?>(deviceId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  EnergyTransactionData copyWith(
          {int? id,
          String? type,
          int? amount,
          int? balanceAfter,
          Value<String?> packageId = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> purchaseToken = const Value.absent(),
          Value<String?> deviceId = const Value.absent(),
          DateTime? timestamp}) =>
      EnergyTransactionData(
        id: id ?? this.id,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        balanceAfter: balanceAfter ?? this.balanceAfter,
        packageId: packageId.present ? packageId.value : this.packageId,
        description: description.present ? description.value : this.description,
        purchaseToken:
            purchaseToken.present ? purchaseToken.value : this.purchaseToken,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        timestamp: timestamp ?? this.timestamp,
      );
  EnergyTransactionData copyWithCompanion(EnergyTransactionsCompanion data) {
    return EnergyTransactionData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      packageId: data.packageId.present ? data.packageId.value : this.packageId,
      description:
          data.description.present ? data.description.value : this.description,
      purchaseToken: data.purchaseToken.present
          ? data.purchaseToken.value
          : this.purchaseToken,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnergyTransactionData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('packageId: $packageId, ')
          ..write('description: $description, ')
          ..write('purchaseToken: $purchaseToken, ')
          ..write('deviceId: $deviceId, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, amount, balanceAfter, packageId,
      description, purchaseToken, deviceId, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnergyTransactionData &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.balanceAfter == this.balanceAfter &&
          other.packageId == this.packageId &&
          other.description == this.description &&
          other.purchaseToken == this.purchaseToken &&
          other.deviceId == this.deviceId &&
          other.timestamp == this.timestamp);
}

class EnergyTransactionsCompanion
    extends UpdateCompanion<EnergyTransactionData> {
  Value<int> id;
  Value<String> type;
  Value<int> amount;
  Value<int> balanceAfter;
  Value<String?> packageId;
  Value<String?> description;
  Value<String?> purchaseToken;
  Value<String?> deviceId;
  Value<DateTime> timestamp;
  EnergyTransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.packageId = const Value.absent(),
    this.description = const Value.absent(),
    this.purchaseToken = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  EnergyTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required int amount,
    required int balanceAfter,
    this.packageId = const Value.absent(),
    this.description = const Value.absent(),
    this.purchaseToken = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.timestamp = const Value.absent(),
  })  : type = Value(type),
        amount = Value(amount),
        balanceAfter = Value(balanceAfter);
  static Insertable<EnergyTransactionData> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<int>? amount,
    Expression<int>? balanceAfter,
    Expression<String>? packageId,
    Expression<String>? description,
    Expression<String>? purchaseToken,
    Expression<String>? deviceId,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (packageId != null) 'package_id': packageId,
      if (description != null) 'description': description,
      if (purchaseToken != null) 'purchase_token': purchaseToken,
      if (deviceId != null) 'device_id': deviceId,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  EnergyTransactionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? type,
      Value<int>? amount,
      Value<int>? balanceAfter,
      Value<String?>? packageId,
      Value<String?>? description,
      Value<String?>? purchaseToken,
      Value<String?>? deviceId,
      Value<DateTime>? timestamp}) {
    return EnergyTransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      packageId: packageId ?? this.packageId,
      description: description ?? this.description,
      purchaseToken: purchaseToken ?? this.purchaseToken,
      deviceId: deviceId ?? this.deviceId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<int>(balanceAfter.value);
    }
    if (packageId.present) {
      map['package_id'] = Variable<String>(packageId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (purchaseToken.present) {
      map['purchase_token'] = Variable<String>(purchaseToken.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnergyTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('packageId: $packageId, ')
          ..write('description: $description, ')
          ..write('purchaseToken: $purchaseToken, ')
          ..write('deviceId: $deviceId, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoodEntriesTable foodEntries = $FoodEntriesTable(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  late final $MyMealsTable myMeals = $MyMealsTable(this);
  late final $MyMealIngredientsTable myMealIngredients =
      $MyMealIngredientsTable(this);
  late final $DailySummariesTable dailySummaries = $DailySummariesTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $ChatSessionsTable chatSessions = $ChatSessionsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $EnergyTransactionsTable energyTransactions =
      $EnergyTransactionsTable(this);
  late final Index idxFoodTimestamp = Index('idx_food_timestamp',
      'CREATE INDEX idx_food_timestamp ON food_entries (timestamp)');
  late final Index idxFoodDeleted = Index('idx_food_deleted',
      'CREATE INDEX idx_food_deleted ON food_entries (is_deleted)');
  late final Index idxFoodSynced = Index('idx_food_synced',
      'CREATE INDEX idx_food_synced ON food_entries (is_synced, is_deleted)');
  late final Index idxFoodMealType = Index('idx_food_meal_type',
      'CREATE INDEX idx_food_meal_type ON food_entries (meal_type, timestamp)');
  late final Index idxIngredientName = Index('idx_ingredient_name',
      'CREATE INDEX idx_ingredient_name ON ingredients (name)');
  late final Index idxMmiMeal = Index('idx_mmi_meal',
      'CREATE INDEX idx_mmi_meal ON my_meal_ingredients (my_meal_id)');
  late final Index idxChatSession = Index('idx_chat_session',
      'CREATE INDEX idx_chat_session ON chat_messages (session_id)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        foodEntries,
        ingredients,
        myMeals,
        myMealIngredients,
        dailySummaries,
        chatMessages,
        chatSessions,
        userProfiles,
        energyTransactions,
        idxFoodTimestamp,
        idxFoodDeleted,
        idxFoodSynced,
        idxFoodMealType,
        idxIngredientName,
        idxMmiMeal,
        idxChatSession
      ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$FoodEntriesTableCreateCompanionBuilder = FoodEntriesCompanion
    Function({
  Value<int> id,
  required String foodName,
  Value<String?> foodNameEn,
  required DateTime timestamp,
  Value<String?> imagePath,
  required MealType mealType,
  required double servingSize,
  required String servingUnit,
  Value<double?> servingGrams,
  required double calories,
  required double protein,
  required double carbs,
  required double fat,
  Value<double> baseCalories,
  Value<double> baseProtein,
  Value<double> baseCarbs,
  Value<double> baseFat,
  Value<double?> fiber,
  Value<double?> sugar,
  Value<double?> sodium,
  Value<double?> cholesterol,
  Value<double?> saturatedFat,
  Value<double?> transFat,
  Value<double?> unsaturatedFat,
  Value<double?> monounsaturatedFat,
  Value<double?> polyunsaturatedFat,
  Value<double?> potassium,
  required DataSource source,
  Value<FoodSearchMode> searchMode,
  Value<double?> aiConfidence,
  Value<bool> isVerified,
  Value<bool> isDeleted,
  Value<String?> notes,
  Value<int?> myMealId,
  Value<int?> ingredientId,
  Value<String?> groupId,
  Value<String?> groupSource,
  Value<int?> groupOrder,
  Value<bool> isGroupOriginal,
  Value<String?> ingredientsJson,
  Value<String?> userInputText,
  Value<String?> originalFoodName,
  Value<String?> originalFoodNameEn,
  Value<double?> originalCalories,
  Value<double?> originalProtein,
  Value<double?> originalCarbs,
  Value<double?> originalFat,
  Value<String?> originalIngredientsJson,
  Value<int> editCount,
  Value<bool> isUserCorrected,
  Value<String?> correctionHistoryJson,
  Value<String?> brandName,
  Value<String?> brandNameEn,
  Value<String?> productName,
  Value<String?> productBarcode,
  Value<double?> netWeight,
  Value<String?> netWeightUnit,
  Value<String?> chainName,
  Value<String?> productCategory,
  Value<String?> packageSize,
  Value<String?> nutritionSource,
  Value<String?> sceneContext,
  Value<String?> detectedObjectsJson,
  Value<String?> arBoundingBox,
  Value<double?> estimatedWidthCm,
  Value<double?> estimatedHeightCm,
  Value<double?> estimatedDepthCm,
  Value<String?> referenceObjectUsed,
  Value<double?> referenceConfidence,
  Value<double?> plateDiameterCm,
  Value<double?> estimatedVolumeMl,
  Value<bool> isCalibrated,
  Value<String?> arLabelsJson,
  Value<double?> arImageWidth,
  Value<double?> arImageHeight,
  Value<double?> arPixelPerCm,
  Value<String?> healthConnectId,
  Value<DateTime?> syncedAt,
  Value<bool> isSynced,
  Value<String?> firebaseDocId,
  Value<DateTime?> lastSyncAt,
  Value<String?> thumbnailUrl,
  Value<String?> thumbnailFirebasePath,
  Value<double?> vitaminA,
  Value<double?> vitaminC,
  Value<double?> vitaminD,
  Value<double?> vitaminE,
  Value<double?> vitaminK,
  Value<double?> thiamin,
  Value<double?> riboflavin,
  Value<double?> niacin,
  Value<double?> vitaminB6,
  Value<double?> folate,
  Value<double?> vitaminB12,
  Value<double?> calcium,
  Value<double?> iron,
  Value<double?> magnesium,
  Value<double?> phosphorus,
  Value<double?> zinc,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$FoodEntriesTableUpdateCompanionBuilder = FoodEntriesCompanion
    Function({
  Value<int> id,
  Value<String> foodName,
  Value<String?> foodNameEn,
  Value<DateTime> timestamp,
  Value<String?> imagePath,
  Value<MealType> mealType,
  Value<double> servingSize,
  Value<String> servingUnit,
  Value<double?> servingGrams,
  Value<double> calories,
  Value<double> protein,
  Value<double> carbs,
  Value<double> fat,
  Value<double> baseCalories,
  Value<double> baseProtein,
  Value<double> baseCarbs,
  Value<double> baseFat,
  Value<double?> fiber,
  Value<double?> sugar,
  Value<double?> sodium,
  Value<double?> cholesterol,
  Value<double?> saturatedFat,
  Value<double?> transFat,
  Value<double?> unsaturatedFat,
  Value<double?> monounsaturatedFat,
  Value<double?> polyunsaturatedFat,
  Value<double?> potassium,
  Value<DataSource> source,
  Value<FoodSearchMode> searchMode,
  Value<double?> aiConfidence,
  Value<bool> isVerified,
  Value<bool> isDeleted,
  Value<String?> notes,
  Value<int?> myMealId,
  Value<int?> ingredientId,
  Value<String?> groupId,
  Value<String?> groupSource,
  Value<int?> groupOrder,
  Value<bool> isGroupOriginal,
  Value<String?> ingredientsJson,
  Value<String?> userInputText,
  Value<String?> originalFoodName,
  Value<String?> originalFoodNameEn,
  Value<double?> originalCalories,
  Value<double?> originalProtein,
  Value<double?> originalCarbs,
  Value<double?> originalFat,
  Value<String?> originalIngredientsJson,
  Value<int> editCount,
  Value<bool> isUserCorrected,
  Value<String?> correctionHistoryJson,
  Value<String?> brandName,
  Value<String?> brandNameEn,
  Value<String?> productName,
  Value<String?> productBarcode,
  Value<double?> netWeight,
  Value<String?> netWeightUnit,
  Value<String?> chainName,
  Value<String?> productCategory,
  Value<String?> packageSize,
  Value<String?> nutritionSource,
  Value<String?> sceneContext,
  Value<String?> detectedObjectsJson,
  Value<String?> arBoundingBox,
  Value<double?> estimatedWidthCm,
  Value<double?> estimatedHeightCm,
  Value<double?> estimatedDepthCm,
  Value<String?> referenceObjectUsed,
  Value<double?> referenceConfidence,
  Value<double?> plateDiameterCm,
  Value<double?> estimatedVolumeMl,
  Value<bool> isCalibrated,
  Value<String?> arLabelsJson,
  Value<double?> arImageWidth,
  Value<double?> arImageHeight,
  Value<double?> arPixelPerCm,
  Value<String?> healthConnectId,
  Value<DateTime?> syncedAt,
  Value<bool> isSynced,
  Value<String?> firebaseDocId,
  Value<DateTime?> lastSyncAt,
  Value<String?> thumbnailUrl,
  Value<String?> thumbnailFirebasePath,
  Value<double?> vitaminA,
  Value<double?> vitaminC,
  Value<double?> vitaminD,
  Value<double?> vitaminE,
  Value<double?> vitaminK,
  Value<double?> thiamin,
  Value<double?> riboflavin,
  Value<double?> niacin,
  Value<double?> vitaminB6,
  Value<double?> folate,
  Value<double?> vitaminB12,
  Value<double?> calcium,
  Value<double?> iron,
  Value<double?> magnesium,
  Value<double?> phosphorus,
  Value<double?> zinc,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$FoodEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $FoodEntriesTable> {
  $$FoodEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get foodName => $composableBuilder(
      column: $table.foodName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get foodNameEn => $composableBuilder(
      column: $table.foodNameEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MealType, MealType, int> get mealType =>
      $composableBuilder(
          column: $table.mealType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get servingSize => $composableBuilder(
      column: $table.servingSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get servingUnit => $composableBuilder(
      column: $table.servingUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get servingGrams => $composableBuilder(
      column: $table.servingGrams, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get baseCalories => $composableBuilder(
      column: $table.baseCalories, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get baseProtein => $composableBuilder(
      column: $table.baseProtein, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get baseCarbs => $composableBuilder(
      column: $table.baseCarbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get baseFat => $composableBuilder(
      column: $table.baseFat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fiber => $composableBuilder(
      column: $table.fiber, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sugar => $composableBuilder(
      column: $table.sugar, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sodium => $composableBuilder(
      column: $table.sodium, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cholesterol => $composableBuilder(
      column: $table.cholesterol, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get saturatedFat => $composableBuilder(
      column: $table.saturatedFat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get transFat => $composableBuilder(
      column: $table.transFat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unsaturatedFat => $composableBuilder(
      column: $table.unsaturatedFat,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monounsaturatedFat => $composableBuilder(
      column: $table.monounsaturatedFat,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get polyunsaturatedFat => $composableBuilder(
      column: $table.polyunsaturatedFat,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get potassium => $composableBuilder(
      column: $table.potassium, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DataSource, DataSource, int> get source =>
      $composableBuilder(
          column: $table.source,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<FoodSearchMode, FoodSearchMode, int>
      get searchMode => $composableBuilder(
          column: $table.searchMode,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get aiConfidence => $composableBuilder(
      column: $table.aiConfidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get myMealId => $composableBuilder(
      column: $table.myMealId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupSource => $composableBuilder(
      column: $table.groupSource, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get groupOrder => $composableBuilder(
      column: $table.groupOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isGroupOriginal => $composableBuilder(
      column: $table.isGroupOriginal,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ingredientsJson => $composableBuilder(
      column: $table.ingredientsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userInputText => $composableBuilder(
      column: $table.userInputText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalFoodName => $composableBuilder(
      column: $table.originalFoodName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalFoodNameEn => $composableBuilder(
      column: $table.originalFoodNameEn,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get originalCalories => $composableBuilder(
      column: $table.originalCalories,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get originalProtein => $composableBuilder(
      column: $table.originalProtein,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get originalCarbs => $composableBuilder(
      column: $table.originalCarbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get originalFat => $composableBuilder(
      column: $table.originalFat, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalIngredientsJson => $composableBuilder(
      column: $table.originalIngredientsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get editCount => $composableBuilder(
      column: $table.editCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUserCorrected => $composableBuilder(
      column: $table.isUserCorrected,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correctionHistoryJson => $composableBuilder(
      column: $table.correctionHistoryJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brandName => $composableBuilder(
      column: $table.brandName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brandNameEn => $composableBuilder(
      column: $table.brandNameEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productBarcode => $composableBuilder(
      column: $table.productBarcode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get netWeight => $composableBuilder(
      column: $table.netWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get netWeightUnit => $composableBuilder(
      column: $table.netWeightUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chainName => $composableBuilder(
      column: $table.chainName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productCategory => $composableBuilder(
      column: $table.productCategory,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get packageSize => $composableBuilder(
      column: $table.packageSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nutritionSource => $composableBuilder(
      column: $table.nutritionSource,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sceneContext => $composableBuilder(
      column: $table.sceneContext, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detectedObjectsJson => $composableBuilder(
      column: $table.detectedObjectsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get arBoundingBox => $composableBuilder(
      column: $table.arBoundingBox, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get estimatedWidthCm => $composableBuilder(
      column: $table.estimatedWidthCm,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get estimatedHeightCm => $composableBuilder(
      column: $table.estimatedHeightCm,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get estimatedDepthCm => $composableBuilder(
      column: $table.estimatedDepthCm,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceObjectUsed => $composableBuilder(
      column: $table.referenceObjectUsed,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get referenceConfidence => $composableBuilder(
      column: $table.referenceConfidence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get plateDiameterCm => $composableBuilder(
      column: $table.plateDiameterCm,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get estimatedVolumeMl => $composableBuilder(
      column: $table.estimatedVolumeMl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCalibrated => $composableBuilder(
      column: $table.isCalibrated, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get arLabelsJson => $composableBuilder(
      column: $table.arLabelsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get arImageWidth => $composableBuilder(
      column: $table.arImageWidth, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get arImageHeight => $composableBuilder(
      column: $table.arImageHeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get arPixelPerCm => $composableBuilder(
      column: $table.arPixelPerCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get healthConnectId => $composableBuilder(
      column: $table.healthConnectId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firebaseDocId => $composableBuilder(
      column: $table.firebaseDocId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailFirebasePath => $composableBuilder(
      column: $table.thumbnailFirebasePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get vitaminA => $composableBuilder(
      column: $table.vitaminA, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get vitaminC => $composableBuilder(
      column: $table.vitaminC, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get vitaminD => $composableBuilder(
      column: $table.vitaminD, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get vitaminE => $composableBuilder(
      column: $table.vitaminE, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get vitaminK => $composableBuilder(
      column: $table.vitaminK, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get thiamin => $composableBuilder(
      column: $table.thiamin, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get riboflavin => $composableBuilder(
      column: $table.riboflavin, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get niacin => $composableBuilder(
      column: $table.niacin, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get vitaminB6 => $composableBuilder(
      column: $table.vitaminB6, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get folate => $composableBuilder(
      column: $table.folate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get vitaminB12 => $composableBuilder(
      column: $table.vitaminB12, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calcium => $composableBuilder(
      column: $table.calcium, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get iron => $composableBuilder(
      column: $table.iron, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get magnesium => $composableBuilder(
      column: $table.magnesium, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get phosphorus => $composableBuilder(
      column: $table.phosphorus, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get zinc => $composableBuilder(
      column: $table.zinc, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$FoodEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodEntriesTable> {
  $$FoodEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get foodName => $composableBuilder(
      column: $table.foodName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get foodNameEn => $composableBuilder(
      column: $table.foodNameEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get servingSize => $composableBuilder(
      column: $table.servingSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get servingUnit => $composableBuilder(
      column: $table.servingUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get servingGrams => $composableBuilder(
      column: $table.servingGrams,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get baseCalories => $composableBuilder(
      column: $table.baseCalories,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get baseProtein => $composableBuilder(
      column: $table.baseProtein, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get baseCarbs => $composableBuilder(
      column: $table.baseCarbs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get baseFat => $composableBuilder(
      column: $table.baseFat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fiber => $composableBuilder(
      column: $table.fiber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sugar => $composableBuilder(
      column: $table.sugar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sodium => $composableBuilder(
      column: $table.sodium, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cholesterol => $composableBuilder(
      column: $table.cholesterol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get saturatedFat => $composableBuilder(
      column: $table.saturatedFat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get transFat => $composableBuilder(
      column: $table.transFat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unsaturatedFat => $composableBuilder(
      column: $table.unsaturatedFat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monounsaturatedFat => $composableBuilder(
      column: $table.monounsaturatedFat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get polyunsaturatedFat => $composableBuilder(
      column: $table.polyunsaturatedFat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get potassium => $composableBuilder(
      column: $table.potassium, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get searchMode => $composableBuilder(
      column: $table.searchMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get aiConfidence => $composableBuilder(
      column: $table.aiConfidence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get myMealId => $composableBuilder(
      column: $table.myMealId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ingredientId => $composableBuilder(
      column: $table.ingredientId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupSource => $composableBuilder(
      column: $table.groupSource, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get groupOrder => $composableBuilder(
      column: $table.groupOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isGroupOriginal => $composableBuilder(
      column: $table.isGroupOriginal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ingredientsJson => $composableBuilder(
      column: $table.ingredientsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userInputText => $composableBuilder(
      column: $table.userInputText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalFoodName => $composableBuilder(
      column: $table.originalFoodName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalFoodNameEn => $composableBuilder(
      column: $table.originalFoodNameEn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get originalCalories => $composableBuilder(
      column: $table.originalCalories,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get originalProtein => $composableBuilder(
      column: $table.originalProtein,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get originalCarbs => $composableBuilder(
      column: $table.originalCarbs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get originalFat => $composableBuilder(
      column: $table.originalFat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalIngredientsJson => $composableBuilder(
      column: $table.originalIngredientsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get editCount => $composableBuilder(
      column: $table.editCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUserCorrected => $composableBuilder(
      column: $table.isUserCorrected,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correctionHistoryJson => $composableBuilder(
      column: $table.correctionHistoryJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brandName => $composableBuilder(
      column: $table.brandName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brandNameEn => $composableBuilder(
      column: $table.brandNameEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productBarcode => $composableBuilder(
      column: $table.productBarcode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get netWeight => $composableBuilder(
      column: $table.netWeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get netWeightUnit => $composableBuilder(
      column: $table.netWeightUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chainName => $composableBuilder(
      column: $table.chainName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productCategory => $composableBuilder(
      column: $table.productCategory,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get packageSize => $composableBuilder(
      column: $table.packageSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nutritionSource => $composableBuilder(
      column: $table.nutritionSource,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sceneContext => $composableBuilder(
      column: $table.sceneContext,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detectedObjectsJson => $composableBuilder(
      column: $table.detectedObjectsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get arBoundingBox => $composableBuilder(
      column: $table.arBoundingBox,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get estimatedWidthCm => $composableBuilder(
      column: $table.estimatedWidthCm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get estimatedHeightCm => $composableBuilder(
      column: $table.estimatedHeightCm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get estimatedDepthCm => $composableBuilder(
      column: $table.estimatedDepthCm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceObjectUsed => $composableBuilder(
      column: $table.referenceObjectUsed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get referenceConfidence => $composableBuilder(
      column: $table.referenceConfidence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get plateDiameterCm => $composableBuilder(
      column: $table.plateDiameterCm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get estimatedVolumeMl => $composableBuilder(
      column: $table.estimatedVolumeMl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCalibrated => $composableBuilder(
      column: $table.isCalibrated,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get arLabelsJson => $composableBuilder(
      column: $table.arLabelsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get arImageWidth => $composableBuilder(
      column: $table.arImageWidth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get arImageHeight => $composableBuilder(
      column: $table.arImageHeight,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get arPixelPerCm => $composableBuilder(
      column: $table.arPixelPerCm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get healthConnectId => $composableBuilder(
      column: $table.healthConnectId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firebaseDocId => $composableBuilder(
      column: $table.firebaseDocId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailFirebasePath => $composableBuilder(
      column: $table.thumbnailFirebasePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get vitaminA => $composableBuilder(
      column: $table.vitaminA, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get vitaminC => $composableBuilder(
      column: $table.vitaminC, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get vitaminD => $composableBuilder(
      column: $table.vitaminD, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get vitaminE => $composableBuilder(
      column: $table.vitaminE, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get vitaminK => $composableBuilder(
      column: $table.vitaminK, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get thiamin => $composableBuilder(
      column: $table.thiamin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get riboflavin => $composableBuilder(
      column: $table.riboflavin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get niacin => $composableBuilder(
      column: $table.niacin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get vitaminB6 => $composableBuilder(
      column: $table.vitaminB6, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get folate => $composableBuilder(
      column: $table.folate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get vitaminB12 => $composableBuilder(
      column: $table.vitaminB12, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calcium => $composableBuilder(
      column: $table.calcium, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get iron => $composableBuilder(
      column: $table.iron, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get magnesium => $composableBuilder(
      column: $table.magnesium, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get phosphorus => $composableBuilder(
      column: $table.phosphorus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get zinc => $composableBuilder(
      column: $table.zinc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FoodEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodEntriesTable> {
  $$FoodEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<String> get foodNameEn => $composableBuilder(
      column: $table.foodNameEn, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MealType, int> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<double> get servingSize => $composableBuilder(
      column: $table.servingSize, builder: (column) => column);

  GeneratedColumn<String> get servingUnit => $composableBuilder(
      column: $table.servingUnit, builder: (column) => column);

  GeneratedColumn<double> get servingGrams => $composableBuilder(
      column: $table.servingGrams, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get baseCalories => $composableBuilder(
      column: $table.baseCalories, builder: (column) => column);

  GeneratedColumn<double> get baseProtein => $composableBuilder(
      column: $table.baseProtein, builder: (column) => column);

  GeneratedColumn<double> get baseCarbs =>
      $composableBuilder(column: $table.baseCarbs, builder: (column) => column);

  GeneratedColumn<double> get baseFat =>
      $composableBuilder(column: $table.baseFat, builder: (column) => column);

  GeneratedColumn<double> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<double> get sugar =>
      $composableBuilder(column: $table.sugar, builder: (column) => column);

  GeneratedColumn<double> get sodium =>
      $composableBuilder(column: $table.sodium, builder: (column) => column);

  GeneratedColumn<double> get cholesterol => $composableBuilder(
      column: $table.cholesterol, builder: (column) => column);

  GeneratedColumn<double> get saturatedFat => $composableBuilder(
      column: $table.saturatedFat, builder: (column) => column);

  GeneratedColumn<double> get transFat =>
      $composableBuilder(column: $table.transFat, builder: (column) => column);

  GeneratedColumn<double> get unsaturatedFat => $composableBuilder(
      column: $table.unsaturatedFat, builder: (column) => column);

  GeneratedColumn<double> get monounsaturatedFat => $composableBuilder(
      column: $table.monounsaturatedFat, builder: (column) => column);

  GeneratedColumn<double> get polyunsaturatedFat => $composableBuilder(
      column: $table.polyunsaturatedFat, builder: (column) => column);

  GeneratedColumn<double> get potassium =>
      $composableBuilder(column: $table.potassium, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DataSource, int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FoodSearchMode, int> get searchMode =>
      $composableBuilder(
          column: $table.searchMode, builder: (column) => column);

  GeneratedColumn<double> get aiConfidence => $composableBuilder(
      column: $table.aiConfidence, builder: (column) => column);

  GeneratedColumn<bool> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get myMealId =>
      $composableBuilder(column: $table.myMealId, builder: (column) => column);

  GeneratedColumn<int> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get groupSource => $composableBuilder(
      column: $table.groupSource, builder: (column) => column);

  GeneratedColumn<int> get groupOrder => $composableBuilder(
      column: $table.groupOrder, builder: (column) => column);

  GeneratedColumn<bool> get isGroupOriginal => $composableBuilder(
      column: $table.isGroupOriginal, builder: (column) => column);

  GeneratedColumn<String> get ingredientsJson => $composableBuilder(
      column: $table.ingredientsJson, builder: (column) => column);

  GeneratedColumn<String> get userInputText => $composableBuilder(
      column: $table.userInputText, builder: (column) => column);

  GeneratedColumn<String> get originalFoodName => $composableBuilder(
      column: $table.originalFoodName, builder: (column) => column);

  GeneratedColumn<String> get originalFoodNameEn => $composableBuilder(
      column: $table.originalFoodNameEn, builder: (column) => column);

  GeneratedColumn<double> get originalCalories => $composableBuilder(
      column: $table.originalCalories, builder: (column) => column);

  GeneratedColumn<double> get originalProtein => $composableBuilder(
      column: $table.originalProtein, builder: (column) => column);

  GeneratedColumn<double> get originalCarbs => $composableBuilder(
      column: $table.originalCarbs, builder: (column) => column);

  GeneratedColumn<double> get originalFat => $composableBuilder(
      column: $table.originalFat, builder: (column) => column);

  GeneratedColumn<String> get originalIngredientsJson => $composableBuilder(
      column: $table.originalIngredientsJson, builder: (column) => column);

  GeneratedColumn<int> get editCount =>
      $composableBuilder(column: $table.editCount, builder: (column) => column);

  GeneratedColumn<bool> get isUserCorrected => $composableBuilder(
      column: $table.isUserCorrected, builder: (column) => column);

  GeneratedColumn<String> get correctionHistoryJson => $composableBuilder(
      column: $table.correctionHistoryJson, builder: (column) => column);

  GeneratedColumn<String> get brandName =>
      $composableBuilder(column: $table.brandName, builder: (column) => column);

  GeneratedColumn<String> get brandNameEn => $composableBuilder(
      column: $table.brandNameEn, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<String> get productBarcode => $composableBuilder(
      column: $table.productBarcode, builder: (column) => column);

  GeneratedColumn<double> get netWeight =>
      $composableBuilder(column: $table.netWeight, builder: (column) => column);

  GeneratedColumn<String> get netWeightUnit => $composableBuilder(
      column: $table.netWeightUnit, builder: (column) => column);

  GeneratedColumn<String> get chainName =>
      $composableBuilder(column: $table.chainName, builder: (column) => column);

  GeneratedColumn<String> get productCategory => $composableBuilder(
      column: $table.productCategory, builder: (column) => column);

  GeneratedColumn<String> get packageSize => $composableBuilder(
      column: $table.packageSize, builder: (column) => column);

  GeneratedColumn<String> get nutritionSource => $composableBuilder(
      column: $table.nutritionSource, builder: (column) => column);

  GeneratedColumn<String> get sceneContext => $composableBuilder(
      column: $table.sceneContext, builder: (column) => column);

  GeneratedColumn<String> get detectedObjectsJson => $composableBuilder(
      column: $table.detectedObjectsJson, builder: (column) => column);

  GeneratedColumn<String> get arBoundingBox => $composableBuilder(
      column: $table.arBoundingBox, builder: (column) => column);

  GeneratedColumn<double> get estimatedWidthCm => $composableBuilder(
      column: $table.estimatedWidthCm, builder: (column) => column);

  GeneratedColumn<double> get estimatedHeightCm => $composableBuilder(
      column: $table.estimatedHeightCm, builder: (column) => column);

  GeneratedColumn<double> get estimatedDepthCm => $composableBuilder(
      column: $table.estimatedDepthCm, builder: (column) => column);

  GeneratedColumn<String> get referenceObjectUsed => $composableBuilder(
      column: $table.referenceObjectUsed, builder: (column) => column);

  GeneratedColumn<double> get referenceConfidence => $composableBuilder(
      column: $table.referenceConfidence, builder: (column) => column);

  GeneratedColumn<double> get plateDiameterCm => $composableBuilder(
      column: $table.plateDiameterCm, builder: (column) => column);

  GeneratedColumn<double> get estimatedVolumeMl => $composableBuilder(
      column: $table.estimatedVolumeMl, builder: (column) => column);

  GeneratedColumn<bool> get isCalibrated => $composableBuilder(
      column: $table.isCalibrated, builder: (column) => column);

  GeneratedColumn<String> get arLabelsJson => $composableBuilder(
      column: $table.arLabelsJson, builder: (column) => column);

  GeneratedColumn<double> get arImageWidth => $composableBuilder(
      column: $table.arImageWidth, builder: (column) => column);

  GeneratedColumn<double> get arImageHeight => $composableBuilder(
      column: $table.arImageHeight, builder: (column) => column);

  GeneratedColumn<double> get arPixelPerCm => $composableBuilder(
      column: $table.arPixelPerCm, builder: (column) => column);

  GeneratedColumn<String> get healthConnectId => $composableBuilder(
      column: $table.healthConnectId, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get firebaseDocId => $composableBuilder(
      column: $table.firebaseDocId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailFirebasePath => $composableBuilder(
      column: $table.thumbnailFirebasePath, builder: (column) => column);

  GeneratedColumn<double> get vitaminA =>
      $composableBuilder(column: $table.vitaminA, builder: (column) => column);

  GeneratedColumn<double> get vitaminC =>
      $composableBuilder(column: $table.vitaminC, builder: (column) => column);

  GeneratedColumn<double> get vitaminD =>
      $composableBuilder(column: $table.vitaminD, builder: (column) => column);

  GeneratedColumn<double> get vitaminE =>
      $composableBuilder(column: $table.vitaminE, builder: (column) => column);

  GeneratedColumn<double> get vitaminK =>
      $composableBuilder(column: $table.vitaminK, builder: (column) => column);

  GeneratedColumn<double> get thiamin =>
      $composableBuilder(column: $table.thiamin, builder: (column) => column);

  GeneratedColumn<double> get riboflavin => $composableBuilder(
      column: $table.riboflavin, builder: (column) => column);

  GeneratedColumn<double> get niacin =>
      $composableBuilder(column: $table.niacin, builder: (column) => column);

  GeneratedColumn<double> get vitaminB6 =>
      $composableBuilder(column: $table.vitaminB6, builder: (column) => column);

  GeneratedColumn<double> get folate =>
      $composableBuilder(column: $table.folate, builder: (column) => column);

  GeneratedColumn<double> get vitaminB12 => $composableBuilder(
      column: $table.vitaminB12, builder: (column) => column);

  GeneratedColumn<double> get calcium =>
      $composableBuilder(column: $table.calcium, builder: (column) => column);

  GeneratedColumn<double> get iron =>
      $composableBuilder(column: $table.iron, builder: (column) => column);

  GeneratedColumn<double> get magnesium =>
      $composableBuilder(column: $table.magnesium, builder: (column) => column);

  GeneratedColumn<double> get phosphorus => $composableBuilder(
      column: $table.phosphorus, builder: (column) => column);

  GeneratedColumn<double> get zinc =>
      $composableBuilder(column: $table.zinc, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FoodEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FoodEntriesTable,
    FoodEntryData,
    $$FoodEntriesTableFilterComposer,
    $$FoodEntriesTableOrderingComposer,
    $$FoodEntriesTableAnnotationComposer,
    $$FoodEntriesTableCreateCompanionBuilder,
    $$FoodEntriesTableUpdateCompanionBuilder,
    (
      FoodEntryData,
      BaseReferences<_$AppDatabase, $FoodEntriesTable, FoodEntryData>
    ),
    FoodEntryData,
    PrefetchHooks Function()> {
  $$FoodEntriesTableTableManager(_$AppDatabase db, $FoodEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> foodName = const Value.absent(),
            Value<String?> foodNameEn = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<MealType> mealType = const Value.absent(),
            Value<double> servingSize = const Value.absent(),
            Value<String> servingUnit = const Value.absent(),
            Value<double?> servingGrams = const Value.absent(),
            Value<double> calories = const Value.absent(),
            Value<double> protein = const Value.absent(),
            Value<double> carbs = const Value.absent(),
            Value<double> fat = const Value.absent(),
            Value<double> baseCalories = const Value.absent(),
            Value<double> baseProtein = const Value.absent(),
            Value<double> baseCarbs = const Value.absent(),
            Value<double> baseFat = const Value.absent(),
            Value<double?> fiber = const Value.absent(),
            Value<double?> sugar = const Value.absent(),
            Value<double?> sodium = const Value.absent(),
            Value<double?> cholesterol = const Value.absent(),
            Value<double?> saturatedFat = const Value.absent(),
            Value<double?> transFat = const Value.absent(),
            Value<double?> unsaturatedFat = const Value.absent(),
            Value<double?> monounsaturatedFat = const Value.absent(),
            Value<double?> polyunsaturatedFat = const Value.absent(),
            Value<double?> potassium = const Value.absent(),
            Value<DataSource> source = const Value.absent(),
            Value<FoodSearchMode> searchMode = const Value.absent(),
            Value<double?> aiConfidence = const Value.absent(),
            Value<bool> isVerified = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> myMealId = const Value.absent(),
            Value<int?> ingredientId = const Value.absent(),
            Value<String?> groupId = const Value.absent(),
            Value<String?> groupSource = const Value.absent(),
            Value<int?> groupOrder = const Value.absent(),
            Value<bool> isGroupOriginal = const Value.absent(),
            Value<String?> ingredientsJson = const Value.absent(),
            Value<String?> userInputText = const Value.absent(),
            Value<String?> originalFoodName = const Value.absent(),
            Value<String?> originalFoodNameEn = const Value.absent(),
            Value<double?> originalCalories = const Value.absent(),
            Value<double?> originalProtein = const Value.absent(),
            Value<double?> originalCarbs = const Value.absent(),
            Value<double?> originalFat = const Value.absent(),
            Value<String?> originalIngredientsJson = const Value.absent(),
            Value<int> editCount = const Value.absent(),
            Value<bool> isUserCorrected = const Value.absent(),
            Value<String?> correctionHistoryJson = const Value.absent(),
            Value<String?> brandName = const Value.absent(),
            Value<String?> brandNameEn = const Value.absent(),
            Value<String?> productName = const Value.absent(),
            Value<String?> productBarcode = const Value.absent(),
            Value<double?> netWeight = const Value.absent(),
            Value<String?> netWeightUnit = const Value.absent(),
            Value<String?> chainName = const Value.absent(),
            Value<String?> productCategory = const Value.absent(),
            Value<String?> packageSize = const Value.absent(),
            Value<String?> nutritionSource = const Value.absent(),
            Value<String?> sceneContext = const Value.absent(),
            Value<String?> detectedObjectsJson = const Value.absent(),
            Value<String?> arBoundingBox = const Value.absent(),
            Value<double?> estimatedWidthCm = const Value.absent(),
            Value<double?> estimatedHeightCm = const Value.absent(),
            Value<double?> estimatedDepthCm = const Value.absent(),
            Value<String?> referenceObjectUsed = const Value.absent(),
            Value<double?> referenceConfidence = const Value.absent(),
            Value<double?> plateDiameterCm = const Value.absent(),
            Value<double?> estimatedVolumeMl = const Value.absent(),
            Value<bool> isCalibrated = const Value.absent(),
            Value<String?> arLabelsJson = const Value.absent(),
            Value<double?> arImageWidth = const Value.absent(),
            Value<double?> arImageHeight = const Value.absent(),
            Value<double?> arPixelPerCm = const Value.absent(),
            Value<String?> healthConnectId = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String?> firebaseDocId = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<String?> thumbnailFirebasePath = const Value.absent(),
            Value<double?> vitaminA = const Value.absent(),
            Value<double?> vitaminC = const Value.absent(),
            Value<double?> vitaminD = const Value.absent(),
            Value<double?> vitaminE = const Value.absent(),
            Value<double?> vitaminK = const Value.absent(),
            Value<double?> thiamin = const Value.absent(),
            Value<double?> riboflavin = const Value.absent(),
            Value<double?> niacin = const Value.absent(),
            Value<double?> vitaminB6 = const Value.absent(),
            Value<double?> folate = const Value.absent(),
            Value<double?> vitaminB12 = const Value.absent(),
            Value<double?> calcium = const Value.absent(),
            Value<double?> iron = const Value.absent(),
            Value<double?> magnesium = const Value.absent(),
            Value<double?> phosphorus = const Value.absent(),
            Value<double?> zinc = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              FoodEntriesCompanion(
            id: id,
            foodName: foodName,
            foodNameEn: foodNameEn,
            timestamp: timestamp,
            imagePath: imagePath,
            mealType: mealType,
            servingSize: servingSize,
            servingUnit: servingUnit,
            servingGrams: servingGrams,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            baseCalories: baseCalories,
            baseProtein: baseProtein,
            baseCarbs: baseCarbs,
            baseFat: baseFat,
            fiber: fiber,
            sugar: sugar,
            sodium: sodium,
            cholesterol: cholesterol,
            saturatedFat: saturatedFat,
            transFat: transFat,
            unsaturatedFat: unsaturatedFat,
            monounsaturatedFat: monounsaturatedFat,
            polyunsaturatedFat: polyunsaturatedFat,
            potassium: potassium,
            source: source,
            searchMode: searchMode,
            aiConfidence: aiConfidence,
            isVerified: isVerified,
            isDeleted: isDeleted,
            notes: notes,
            myMealId: myMealId,
            ingredientId: ingredientId,
            groupId: groupId,
            groupSource: groupSource,
            groupOrder: groupOrder,
            isGroupOriginal: isGroupOriginal,
            ingredientsJson: ingredientsJson,
            userInputText: userInputText,
            originalFoodName: originalFoodName,
            originalFoodNameEn: originalFoodNameEn,
            originalCalories: originalCalories,
            originalProtein: originalProtein,
            originalCarbs: originalCarbs,
            originalFat: originalFat,
            originalIngredientsJson: originalIngredientsJson,
            editCount: editCount,
            isUserCorrected: isUserCorrected,
            correctionHistoryJson: correctionHistoryJson,
            brandName: brandName,
            brandNameEn: brandNameEn,
            productName: productName,
            productBarcode: productBarcode,
            netWeight: netWeight,
            netWeightUnit: netWeightUnit,
            chainName: chainName,
            productCategory: productCategory,
            packageSize: packageSize,
            nutritionSource: nutritionSource,
            sceneContext: sceneContext,
            detectedObjectsJson: detectedObjectsJson,
            arBoundingBox: arBoundingBox,
            estimatedWidthCm: estimatedWidthCm,
            estimatedHeightCm: estimatedHeightCm,
            estimatedDepthCm: estimatedDepthCm,
            referenceObjectUsed: referenceObjectUsed,
            referenceConfidence: referenceConfidence,
            plateDiameterCm: plateDiameterCm,
            estimatedVolumeMl: estimatedVolumeMl,
            isCalibrated: isCalibrated,
            arLabelsJson: arLabelsJson,
            arImageWidth: arImageWidth,
            arImageHeight: arImageHeight,
            arPixelPerCm: arPixelPerCm,
            healthConnectId: healthConnectId,
            syncedAt: syncedAt,
            isSynced: isSynced,
            firebaseDocId: firebaseDocId,
            lastSyncAt: lastSyncAt,
            thumbnailUrl: thumbnailUrl,
            thumbnailFirebasePath: thumbnailFirebasePath,
            vitaminA: vitaminA,
            vitaminC: vitaminC,
            vitaminD: vitaminD,
            vitaminE: vitaminE,
            vitaminK: vitaminK,
            thiamin: thiamin,
            riboflavin: riboflavin,
            niacin: niacin,
            vitaminB6: vitaminB6,
            folate: folate,
            vitaminB12: vitaminB12,
            calcium: calcium,
            iron: iron,
            magnesium: magnesium,
            phosphorus: phosphorus,
            zinc: zinc,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String foodName,
            Value<String?> foodNameEn = const Value.absent(),
            required DateTime timestamp,
            Value<String?> imagePath = const Value.absent(),
            required MealType mealType,
            required double servingSize,
            required String servingUnit,
            Value<double?> servingGrams = const Value.absent(),
            required double calories,
            required double protein,
            required double carbs,
            required double fat,
            Value<double> baseCalories = const Value.absent(),
            Value<double> baseProtein = const Value.absent(),
            Value<double> baseCarbs = const Value.absent(),
            Value<double> baseFat = const Value.absent(),
            Value<double?> fiber = const Value.absent(),
            Value<double?> sugar = const Value.absent(),
            Value<double?> sodium = const Value.absent(),
            Value<double?> cholesterol = const Value.absent(),
            Value<double?> saturatedFat = const Value.absent(),
            Value<double?> transFat = const Value.absent(),
            Value<double?> unsaturatedFat = const Value.absent(),
            Value<double?> monounsaturatedFat = const Value.absent(),
            Value<double?> polyunsaturatedFat = const Value.absent(),
            Value<double?> potassium = const Value.absent(),
            required DataSource source,
            Value<FoodSearchMode> searchMode = const Value.absent(),
            Value<double?> aiConfidence = const Value.absent(),
            Value<bool> isVerified = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> myMealId = const Value.absent(),
            Value<int?> ingredientId = const Value.absent(),
            Value<String?> groupId = const Value.absent(),
            Value<String?> groupSource = const Value.absent(),
            Value<int?> groupOrder = const Value.absent(),
            Value<bool> isGroupOriginal = const Value.absent(),
            Value<String?> ingredientsJson = const Value.absent(),
            Value<String?> userInputText = const Value.absent(),
            Value<String?> originalFoodName = const Value.absent(),
            Value<String?> originalFoodNameEn = const Value.absent(),
            Value<double?> originalCalories = const Value.absent(),
            Value<double?> originalProtein = const Value.absent(),
            Value<double?> originalCarbs = const Value.absent(),
            Value<double?> originalFat = const Value.absent(),
            Value<String?> originalIngredientsJson = const Value.absent(),
            Value<int> editCount = const Value.absent(),
            Value<bool> isUserCorrected = const Value.absent(),
            Value<String?> correctionHistoryJson = const Value.absent(),
            Value<String?> brandName = const Value.absent(),
            Value<String?> brandNameEn = const Value.absent(),
            Value<String?> productName = const Value.absent(),
            Value<String?> productBarcode = const Value.absent(),
            Value<double?> netWeight = const Value.absent(),
            Value<String?> netWeightUnit = const Value.absent(),
            Value<String?> chainName = const Value.absent(),
            Value<String?> productCategory = const Value.absent(),
            Value<String?> packageSize = const Value.absent(),
            Value<String?> nutritionSource = const Value.absent(),
            Value<String?> sceneContext = const Value.absent(),
            Value<String?> detectedObjectsJson = const Value.absent(),
            Value<String?> arBoundingBox = const Value.absent(),
            Value<double?> estimatedWidthCm = const Value.absent(),
            Value<double?> estimatedHeightCm = const Value.absent(),
            Value<double?> estimatedDepthCm = const Value.absent(),
            Value<String?> referenceObjectUsed = const Value.absent(),
            Value<double?> referenceConfidence = const Value.absent(),
            Value<double?> plateDiameterCm = const Value.absent(),
            Value<double?> estimatedVolumeMl = const Value.absent(),
            Value<bool> isCalibrated = const Value.absent(),
            Value<String?> arLabelsJson = const Value.absent(),
            Value<double?> arImageWidth = const Value.absent(),
            Value<double?> arImageHeight = const Value.absent(),
            Value<double?> arPixelPerCm = const Value.absent(),
            Value<String?> healthConnectId = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String?> firebaseDocId = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<String?> thumbnailFirebasePath = const Value.absent(),
            Value<double?> vitaminA = const Value.absent(),
            Value<double?> vitaminC = const Value.absent(),
            Value<double?> vitaminD = const Value.absent(),
            Value<double?> vitaminE = const Value.absent(),
            Value<double?> vitaminK = const Value.absent(),
            Value<double?> thiamin = const Value.absent(),
            Value<double?> riboflavin = const Value.absent(),
            Value<double?> niacin = const Value.absent(),
            Value<double?> vitaminB6 = const Value.absent(),
            Value<double?> folate = const Value.absent(),
            Value<double?> vitaminB12 = const Value.absent(),
            Value<double?> calcium = const Value.absent(),
            Value<double?> iron = const Value.absent(),
            Value<double?> magnesium = const Value.absent(),
            Value<double?> phosphorus = const Value.absent(),
            Value<double?> zinc = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              FoodEntriesCompanion.insert(
            id: id,
            foodName: foodName,
            foodNameEn: foodNameEn,
            timestamp: timestamp,
            imagePath: imagePath,
            mealType: mealType,
            servingSize: servingSize,
            servingUnit: servingUnit,
            servingGrams: servingGrams,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            baseCalories: baseCalories,
            baseProtein: baseProtein,
            baseCarbs: baseCarbs,
            baseFat: baseFat,
            fiber: fiber,
            sugar: sugar,
            sodium: sodium,
            cholesterol: cholesterol,
            saturatedFat: saturatedFat,
            transFat: transFat,
            unsaturatedFat: unsaturatedFat,
            monounsaturatedFat: monounsaturatedFat,
            polyunsaturatedFat: polyunsaturatedFat,
            potassium: potassium,
            source: source,
            searchMode: searchMode,
            aiConfidence: aiConfidence,
            isVerified: isVerified,
            isDeleted: isDeleted,
            notes: notes,
            myMealId: myMealId,
            ingredientId: ingredientId,
            groupId: groupId,
            groupSource: groupSource,
            groupOrder: groupOrder,
            isGroupOriginal: isGroupOriginal,
            ingredientsJson: ingredientsJson,
            userInputText: userInputText,
            originalFoodName: originalFoodName,
            originalFoodNameEn: originalFoodNameEn,
            originalCalories: originalCalories,
            originalProtein: originalProtein,
            originalCarbs: originalCarbs,
            originalFat: originalFat,
            originalIngredientsJson: originalIngredientsJson,
            editCount: editCount,
            isUserCorrected: isUserCorrected,
            correctionHistoryJson: correctionHistoryJson,
            brandName: brandName,
            brandNameEn: brandNameEn,
            productName: productName,
            productBarcode: productBarcode,
            netWeight: netWeight,
            netWeightUnit: netWeightUnit,
            chainName: chainName,
            productCategory: productCategory,
            packageSize: packageSize,
            nutritionSource: nutritionSource,
            sceneContext: sceneContext,
            detectedObjectsJson: detectedObjectsJson,
            arBoundingBox: arBoundingBox,
            estimatedWidthCm: estimatedWidthCm,
            estimatedHeightCm: estimatedHeightCm,
            estimatedDepthCm: estimatedDepthCm,
            referenceObjectUsed: referenceObjectUsed,
            referenceConfidence: referenceConfidence,
            plateDiameterCm: plateDiameterCm,
            estimatedVolumeMl: estimatedVolumeMl,
            isCalibrated: isCalibrated,
            arLabelsJson: arLabelsJson,
            arImageWidth: arImageWidth,
            arImageHeight: arImageHeight,
            arPixelPerCm: arPixelPerCm,
            healthConnectId: healthConnectId,
            syncedAt: syncedAt,
            isSynced: isSynced,
            firebaseDocId: firebaseDocId,
            lastSyncAt: lastSyncAt,
            thumbnailUrl: thumbnailUrl,
            thumbnailFirebasePath: thumbnailFirebasePath,
            vitaminA: vitaminA,
            vitaminC: vitaminC,
            vitaminD: vitaminD,
            vitaminE: vitaminE,
            vitaminK: vitaminK,
            thiamin: thiamin,
            riboflavin: riboflavin,
            niacin: niacin,
            vitaminB6: vitaminB6,
            folate: folate,
            vitaminB12: vitaminB12,
            calcium: calcium,
            iron: iron,
            magnesium: magnesium,
            phosphorus: phosphorus,
            zinc: zinc,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FoodEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FoodEntriesTable,
    FoodEntryData,
    $$FoodEntriesTableFilterComposer,
    $$FoodEntriesTableOrderingComposer,
    $$FoodEntriesTableAnnotationComposer,
    $$FoodEntriesTableCreateCompanionBuilder,
    $$FoodEntriesTableUpdateCompanionBuilder,
    (
      FoodEntryData,
      BaseReferences<_$AppDatabase, $FoodEntriesTable, FoodEntryData>
    ),
    FoodEntryData,
    PrefetchHooks Function()>;
typedef $$IngredientsTableCreateCompanionBuilder = IngredientsCompanion
    Function({
  Value<int> id,
  required String name,
  Value<String?> nameEn,
  required double baseAmount,
  required String baseUnit,
  required double caloriesPerBase,
  required double proteinPerBase,
  required double carbsPerBase,
  required double fatPerBase,
  Value<double?> fiberPerBase,
  Value<double?> sugarPerBase,
  Value<double?> sodiumPerBase,
  required String source,
  Value<int> usageCount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$IngredientsTableUpdateCompanionBuilder = IngredientsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String?> nameEn,
  Value<double> baseAmount,
  Value<String> baseUnit,
  Value<double> caloriesPerBase,
  Value<double> proteinPerBase,
  Value<double> carbsPerBase,
  Value<double> fatPerBase,
  Value<double?> fiberPerBase,
  Value<double?> sugarPerBase,
  Value<double?> sodiumPerBase,
  Value<String> source,
  Value<int> usageCount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$IngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get baseAmount => $composableBuilder(
      column: $table.baseAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get baseUnit => $composableBuilder(
      column: $table.baseUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get caloriesPerBase => $composableBuilder(
      column: $table.caloriesPerBase,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteinPerBase => $composableBuilder(
      column: $table.proteinPerBase,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbsPerBase => $composableBuilder(
      column: $table.carbsPerBase, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fatPerBase => $composableBuilder(
      column: $table.fatPerBase, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fiberPerBase => $composableBuilder(
      column: $table.fiberPerBase, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sugarPerBase => $composableBuilder(
      column: $table.sugarPerBase, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sodiumPerBase => $composableBuilder(
      column: $table.sodiumPerBase, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$IngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get baseAmount => $composableBuilder(
      column: $table.baseAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get baseUnit => $composableBuilder(
      column: $table.baseUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get caloriesPerBase => $composableBuilder(
      column: $table.caloriesPerBase,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteinPerBase => $composableBuilder(
      column: $table.proteinPerBase,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbsPerBase => $composableBuilder(
      column: $table.carbsPerBase,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fatPerBase => $composableBuilder(
      column: $table.fatPerBase, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fiberPerBase => $composableBuilder(
      column: $table.fiberPerBase,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sugarPerBase => $composableBuilder(
      column: $table.sugarPerBase,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sodiumPerBase => $composableBuilder(
      column: $table.sodiumPerBase,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$IngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<double> get baseAmount => $composableBuilder(
      column: $table.baseAmount, builder: (column) => column);

  GeneratedColumn<String> get baseUnit =>
      $composableBuilder(column: $table.baseUnit, builder: (column) => column);

  GeneratedColumn<double> get caloriesPerBase => $composableBuilder(
      column: $table.caloriesPerBase, builder: (column) => column);

  GeneratedColumn<double> get proteinPerBase => $composableBuilder(
      column: $table.proteinPerBase, builder: (column) => column);

  GeneratedColumn<double> get carbsPerBase => $composableBuilder(
      column: $table.carbsPerBase, builder: (column) => column);

  GeneratedColumn<double> get fatPerBase => $composableBuilder(
      column: $table.fatPerBase, builder: (column) => column);

  GeneratedColumn<double> get fiberPerBase => $composableBuilder(
      column: $table.fiberPerBase, builder: (column) => column);

  GeneratedColumn<double> get sugarPerBase => $composableBuilder(
      column: $table.sugarPerBase, builder: (column) => column);

  GeneratedColumn<double> get sodiumPerBase => $composableBuilder(
      column: $table.sodiumPerBase, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$IngredientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IngredientsTable,
    IngredientData,
    $$IngredientsTableFilterComposer,
    $$IngredientsTableOrderingComposer,
    $$IngredientsTableAnnotationComposer,
    $$IngredientsTableCreateCompanionBuilder,
    $$IngredientsTableUpdateCompanionBuilder,
    (
      IngredientData,
      BaseReferences<_$AppDatabase, $IngredientsTable, IngredientData>
    ),
    IngredientData,
    PrefetchHooks Function()> {
  $$IngredientsTableTableManager(_$AppDatabase db, $IngredientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> nameEn = const Value.absent(),
            Value<double> baseAmount = const Value.absent(),
            Value<String> baseUnit = const Value.absent(),
            Value<double> caloriesPerBase = const Value.absent(),
            Value<double> proteinPerBase = const Value.absent(),
            Value<double> carbsPerBase = const Value.absent(),
            Value<double> fatPerBase = const Value.absent(),
            Value<double?> fiberPerBase = const Value.absent(),
            Value<double?> sugarPerBase = const Value.absent(),
            Value<double?> sodiumPerBase = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              IngredientsCompanion(
            id: id,
            name: name,
            nameEn: nameEn,
            baseAmount: baseAmount,
            baseUnit: baseUnit,
            caloriesPerBase: caloriesPerBase,
            proteinPerBase: proteinPerBase,
            carbsPerBase: carbsPerBase,
            fatPerBase: fatPerBase,
            fiberPerBase: fiberPerBase,
            sugarPerBase: sugarPerBase,
            sodiumPerBase: sodiumPerBase,
            source: source,
            usageCount: usageCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> nameEn = const Value.absent(),
            required double baseAmount,
            required String baseUnit,
            required double caloriesPerBase,
            required double proteinPerBase,
            required double carbsPerBase,
            required double fatPerBase,
            Value<double?> fiberPerBase = const Value.absent(),
            Value<double?> sugarPerBase = const Value.absent(),
            Value<double?> sodiumPerBase = const Value.absent(),
            required String source,
            Value<int> usageCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              IngredientsCompanion.insert(
            id: id,
            name: name,
            nameEn: nameEn,
            baseAmount: baseAmount,
            baseUnit: baseUnit,
            caloriesPerBase: caloriesPerBase,
            proteinPerBase: proteinPerBase,
            carbsPerBase: carbsPerBase,
            fatPerBase: fatPerBase,
            fiberPerBase: fiberPerBase,
            sugarPerBase: sugarPerBase,
            sodiumPerBase: sodiumPerBase,
            source: source,
            usageCount: usageCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$IngredientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $IngredientsTable,
    IngredientData,
    $$IngredientsTableFilterComposer,
    $$IngredientsTableOrderingComposer,
    $$IngredientsTableAnnotationComposer,
    $$IngredientsTableCreateCompanionBuilder,
    $$IngredientsTableUpdateCompanionBuilder,
    (
      IngredientData,
      BaseReferences<_$AppDatabase, $IngredientsTable, IngredientData>
    ),
    IngredientData,
    PrefetchHooks Function()>;
typedef $$MyMealsTableCreateCompanionBuilder = MyMealsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> nameEn,
  required double totalCalories,
  required double totalProtein,
  required double totalCarbs,
  required double totalFat,
  required String baseServingDescription,
  Value<String?> imagePath,
  required String source,
  Value<int> usageCount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$MyMealsTableUpdateCompanionBuilder = MyMealsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> nameEn,
  Value<double> totalCalories,
  Value<double> totalProtein,
  Value<double> totalCarbs,
  Value<double> totalFat,
  Value<String> baseServingDescription,
  Value<String?> imagePath,
  Value<String> source,
  Value<int> usageCount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$MyMealsTableFilterComposer
    extends Composer<_$AppDatabase, $MyMealsTable> {
  $$MyMealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalCalories => $composableBuilder(
      column: $table.totalCalories, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalProtein => $composableBuilder(
      column: $table.totalProtein, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalCarbs => $composableBuilder(
      column: $table.totalCarbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalFat => $composableBuilder(
      column: $table.totalFat, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get baseServingDescription => $composableBuilder(
      column: $table.baseServingDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MyMealsTableOrderingComposer
    extends Composer<_$AppDatabase, $MyMealsTable> {
  $$MyMealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalCalories => $composableBuilder(
      column: $table.totalCalories,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalProtein => $composableBuilder(
      column: $table.totalProtein,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalCarbs => $composableBuilder(
      column: $table.totalCarbs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalFat => $composableBuilder(
      column: $table.totalFat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get baseServingDescription => $composableBuilder(
      column: $table.baseServingDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MyMealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MyMealsTable> {
  $$MyMealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<double> get totalCalories => $composableBuilder(
      column: $table.totalCalories, builder: (column) => column);

  GeneratedColumn<double> get totalProtein => $composableBuilder(
      column: $table.totalProtein, builder: (column) => column);

  GeneratedColumn<double> get totalCarbs => $composableBuilder(
      column: $table.totalCarbs, builder: (column) => column);

  GeneratedColumn<double> get totalFat =>
      $composableBuilder(column: $table.totalFat, builder: (column) => column);

  GeneratedColumn<String> get baseServingDescription => $composableBuilder(
      column: $table.baseServingDescription, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MyMealsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MyMealsTable,
    MyMealData,
    $$MyMealsTableFilterComposer,
    $$MyMealsTableOrderingComposer,
    $$MyMealsTableAnnotationComposer,
    $$MyMealsTableCreateCompanionBuilder,
    $$MyMealsTableUpdateCompanionBuilder,
    (MyMealData, BaseReferences<_$AppDatabase, $MyMealsTable, MyMealData>),
    MyMealData,
    PrefetchHooks Function()> {
  $$MyMealsTableTableManager(_$AppDatabase db, $MyMealsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MyMealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MyMealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MyMealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> nameEn = const Value.absent(),
            Value<double> totalCalories = const Value.absent(),
            Value<double> totalProtein = const Value.absent(),
            Value<double> totalCarbs = const Value.absent(),
            Value<double> totalFat = const Value.absent(),
            Value<String> baseServingDescription = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MyMealsCompanion(
            id: id,
            name: name,
            nameEn: nameEn,
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            baseServingDescription: baseServingDescription,
            imagePath: imagePath,
            source: source,
            usageCount: usageCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> nameEn = const Value.absent(),
            required double totalCalories,
            required double totalProtein,
            required double totalCarbs,
            required double totalFat,
            required String baseServingDescription,
            Value<String?> imagePath = const Value.absent(),
            required String source,
            Value<int> usageCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MyMealsCompanion.insert(
            id: id,
            name: name,
            nameEn: nameEn,
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            baseServingDescription: baseServingDescription,
            imagePath: imagePath,
            source: source,
            usageCount: usageCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MyMealsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MyMealsTable,
    MyMealData,
    $$MyMealsTableFilterComposer,
    $$MyMealsTableOrderingComposer,
    $$MyMealsTableAnnotationComposer,
    $$MyMealsTableCreateCompanionBuilder,
    $$MyMealsTableUpdateCompanionBuilder,
    (MyMealData, BaseReferences<_$AppDatabase, $MyMealsTable, MyMealData>),
    MyMealData,
    PrefetchHooks Function()>;
typedef $$MyMealIngredientsTableCreateCompanionBuilder
    = MyMealIngredientsCompanion Function({
  Value<int> id,
  required int myMealId,
  required int ingredientId,
  required String ingredientName,
  required double amount,
  required String unit,
  required double calories,
  required double protein,
  required double carbs,
  required double fat,
  Value<int> sortOrder,
  Value<int?> parentId,
  Value<int> depth,
  Value<bool> isComposite,
  Value<String?> detail,
});
typedef $$MyMealIngredientsTableUpdateCompanionBuilder
    = MyMealIngredientsCompanion Function({
  Value<int> id,
  Value<int> myMealId,
  Value<int> ingredientId,
  Value<String> ingredientName,
  Value<double> amount,
  Value<String> unit,
  Value<double> calories,
  Value<double> protein,
  Value<double> carbs,
  Value<double> fat,
  Value<int> sortOrder,
  Value<int?> parentId,
  Value<int> depth,
  Value<bool> isComposite,
  Value<String?> detail,
});

class $$MyMealIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $MyMealIngredientsTable> {
  $$MyMealIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get myMealId => $composableBuilder(
      column: $table.myMealId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ingredientName => $composableBuilder(
      column: $table.ingredientName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get depth => $composableBuilder(
      column: $table.depth, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isComposite => $composableBuilder(
      column: $table.isComposite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnFilters(column));
}

class $$MyMealIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $MyMealIngredientsTable> {
  $$MyMealIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get myMealId => $composableBuilder(
      column: $table.myMealId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ingredientId => $composableBuilder(
      column: $table.ingredientId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ingredientName => $composableBuilder(
      column: $table.ingredientName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get depth => $composableBuilder(
      column: $table.depth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isComposite => $composableBuilder(
      column: $table.isComposite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnOrderings(column));
}

class $$MyMealIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MyMealIngredientsTable> {
  $$MyMealIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get myMealId =>
      $composableBuilder(column: $table.myMealId, builder: (column) => column);

  GeneratedColumn<int> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => column);

  GeneratedColumn<String> get ingredientName => $composableBuilder(
      column: $table.ingredientName, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get depth =>
      $composableBuilder(column: $table.depth, builder: (column) => column);

  GeneratedColumn<bool> get isComposite => $composableBuilder(
      column: $table.isComposite, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);
}

class $$MyMealIngredientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MyMealIngredientsTable,
    MyMealIngredientData,
    $$MyMealIngredientsTableFilterComposer,
    $$MyMealIngredientsTableOrderingComposer,
    $$MyMealIngredientsTableAnnotationComposer,
    $$MyMealIngredientsTableCreateCompanionBuilder,
    $$MyMealIngredientsTableUpdateCompanionBuilder,
    (
      MyMealIngredientData,
      BaseReferences<_$AppDatabase, $MyMealIngredientsTable,
          MyMealIngredientData>
    ),
    MyMealIngredientData,
    PrefetchHooks Function()> {
  $$MyMealIngredientsTableTableManager(
      _$AppDatabase db, $MyMealIngredientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MyMealIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MyMealIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MyMealIngredientsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> myMealId = const Value.absent(),
            Value<int> ingredientId = const Value.absent(),
            Value<String> ingredientName = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> calories = const Value.absent(),
            Value<double> protein = const Value.absent(),
            Value<double> carbs = const Value.absent(),
            Value<double> fat = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int?> parentId = const Value.absent(),
            Value<int> depth = const Value.absent(),
            Value<bool> isComposite = const Value.absent(),
            Value<String?> detail = const Value.absent(),
          }) =>
              MyMealIngredientsCompanion(
            id: id,
            myMealId: myMealId,
            ingredientId: ingredientId,
            ingredientName: ingredientName,
            amount: amount,
            unit: unit,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            sortOrder: sortOrder,
            parentId: parentId,
            depth: depth,
            isComposite: isComposite,
            detail: detail,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int myMealId,
            required int ingredientId,
            required String ingredientName,
            required double amount,
            required String unit,
            required double calories,
            required double protein,
            required double carbs,
            required double fat,
            Value<int> sortOrder = const Value.absent(),
            Value<int?> parentId = const Value.absent(),
            Value<int> depth = const Value.absent(),
            Value<bool> isComposite = const Value.absent(),
            Value<String?> detail = const Value.absent(),
          }) =>
              MyMealIngredientsCompanion.insert(
            id: id,
            myMealId: myMealId,
            ingredientId: ingredientId,
            ingredientName: ingredientName,
            amount: amount,
            unit: unit,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            sortOrder: sortOrder,
            parentId: parentId,
            depth: depth,
            isComposite: isComposite,
            detail: detail,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MyMealIngredientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MyMealIngredientsTable,
    MyMealIngredientData,
    $$MyMealIngredientsTableFilterComposer,
    $$MyMealIngredientsTableOrderingComposer,
    $$MyMealIngredientsTableAnnotationComposer,
    $$MyMealIngredientsTableCreateCompanionBuilder,
    $$MyMealIngredientsTableUpdateCompanionBuilder,
    (
      MyMealIngredientData,
      BaseReferences<_$AppDatabase, $MyMealIngredientsTable,
          MyMealIngredientData>
    ),
    MyMealIngredientData,
    PrefetchHooks Function()>;
typedef $$DailySummariesTableCreateCompanionBuilder = DailySummariesCompanion
    Function({
  Value<int> id,
  required DateTime date,
  Value<double> caloriesEaten,
  Value<double> proteinEaten,
  Value<double> carbsEaten,
  Value<double> fatEaten,
  Value<double> tdee,
  Value<double> netEnergy,
  Value<String> deficitZone,
  Value<int> entryCount,
  Value<int> correctionCount,
  Value<double> calorieGoal,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$DailySummariesTableUpdateCompanionBuilder = DailySummariesCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  Value<double> caloriesEaten,
  Value<double> proteinEaten,
  Value<double> carbsEaten,
  Value<double> fatEaten,
  Value<double> tdee,
  Value<double> netEnergy,
  Value<String> deficitZone,
  Value<int> entryCount,
  Value<int> correctionCount,
  Value<double> calorieGoal,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$DailySummariesTableFilterComposer
    extends Composer<_$AppDatabase, $DailySummariesTable> {
  $$DailySummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get caloriesEaten => $composableBuilder(
      column: $table.caloriesEaten, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteinEaten => $composableBuilder(
      column: $table.proteinEaten, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbsEaten => $composableBuilder(
      column: $table.carbsEaten, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fatEaten => $composableBuilder(
      column: $table.fatEaten, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get tdee => $composableBuilder(
      column: $table.tdee, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get netEnergy => $composableBuilder(
      column: $table.netEnergy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deficitZone => $composableBuilder(
      column: $table.deficitZone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get entryCount => $composableBuilder(
      column: $table.entryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get correctionCount => $composableBuilder(
      column: $table.correctionCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calorieGoal => $composableBuilder(
      column: $table.calorieGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DailySummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailySummariesTable> {
  $$DailySummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get caloriesEaten => $composableBuilder(
      column: $table.caloriesEaten,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteinEaten => $composableBuilder(
      column: $table.proteinEaten,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbsEaten => $composableBuilder(
      column: $table.carbsEaten, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fatEaten => $composableBuilder(
      column: $table.fatEaten, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get tdee => $composableBuilder(
      column: $table.tdee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get netEnergy => $composableBuilder(
      column: $table.netEnergy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deficitZone => $composableBuilder(
      column: $table.deficitZone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get entryCount => $composableBuilder(
      column: $table.entryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get correctionCount => $composableBuilder(
      column: $table.correctionCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calorieGoal => $composableBuilder(
      column: $table.calorieGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DailySummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailySummariesTable> {
  $$DailySummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get caloriesEaten => $composableBuilder(
      column: $table.caloriesEaten, builder: (column) => column);

  GeneratedColumn<double> get proteinEaten => $composableBuilder(
      column: $table.proteinEaten, builder: (column) => column);

  GeneratedColumn<double> get carbsEaten => $composableBuilder(
      column: $table.carbsEaten, builder: (column) => column);

  GeneratedColumn<double> get fatEaten =>
      $composableBuilder(column: $table.fatEaten, builder: (column) => column);

  GeneratedColumn<double> get tdee =>
      $composableBuilder(column: $table.tdee, builder: (column) => column);

  GeneratedColumn<double> get netEnergy =>
      $composableBuilder(column: $table.netEnergy, builder: (column) => column);

  GeneratedColumn<String> get deficitZone => $composableBuilder(
      column: $table.deficitZone, builder: (column) => column);

  GeneratedColumn<int> get entryCount => $composableBuilder(
      column: $table.entryCount, builder: (column) => column);

  GeneratedColumn<int> get correctionCount => $composableBuilder(
      column: $table.correctionCount, builder: (column) => column);

  GeneratedColumn<double> get calorieGoal => $composableBuilder(
      column: $table.calorieGoal, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailySummariesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailySummariesTable,
    DailySummaryData,
    $$DailySummariesTableFilterComposer,
    $$DailySummariesTableOrderingComposer,
    $$DailySummariesTableAnnotationComposer,
    $$DailySummariesTableCreateCompanionBuilder,
    $$DailySummariesTableUpdateCompanionBuilder,
    (
      DailySummaryData,
      BaseReferences<_$AppDatabase, $DailySummariesTable, DailySummaryData>
    ),
    DailySummaryData,
    PrefetchHooks Function()> {
  $$DailySummariesTableTableManager(
      _$AppDatabase db, $DailySummariesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailySummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailySummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailySummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> caloriesEaten = const Value.absent(),
            Value<double> proteinEaten = const Value.absent(),
            Value<double> carbsEaten = const Value.absent(),
            Value<double> fatEaten = const Value.absent(),
            Value<double> tdee = const Value.absent(),
            Value<double> netEnergy = const Value.absent(),
            Value<String> deficitZone = const Value.absent(),
            Value<int> entryCount = const Value.absent(),
            Value<int> correctionCount = const Value.absent(),
            Value<double> calorieGoal = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DailySummariesCompanion(
            id: id,
            date: date,
            caloriesEaten: caloriesEaten,
            proteinEaten: proteinEaten,
            carbsEaten: carbsEaten,
            fatEaten: fatEaten,
            tdee: tdee,
            netEnergy: netEnergy,
            deficitZone: deficitZone,
            entryCount: entryCount,
            correctionCount: correctionCount,
            calorieGoal: calorieGoal,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            Value<double> caloriesEaten = const Value.absent(),
            Value<double> proteinEaten = const Value.absent(),
            Value<double> carbsEaten = const Value.absent(),
            Value<double> fatEaten = const Value.absent(),
            Value<double> tdee = const Value.absent(),
            Value<double> netEnergy = const Value.absent(),
            Value<String> deficitZone = const Value.absent(),
            Value<int> entryCount = const Value.absent(),
            Value<int> correctionCount = const Value.absent(),
            Value<double> calorieGoal = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DailySummariesCompanion.insert(
            id: id,
            date: date,
            caloriesEaten: caloriesEaten,
            proteinEaten: proteinEaten,
            carbsEaten: carbsEaten,
            fatEaten: fatEaten,
            tdee: tdee,
            netEnergy: netEnergy,
            deficitZone: deficitZone,
            entryCount: entryCount,
            correctionCount: correctionCount,
            calorieGoal: calorieGoal,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailySummariesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailySummariesTable,
    DailySummaryData,
    $$DailySummariesTableFilterComposer,
    $$DailySummariesTableOrderingComposer,
    $$DailySummariesTableAnnotationComposer,
    $$DailySummariesTableCreateCompanionBuilder,
    $$DailySummariesTableUpdateCompanionBuilder,
    (
      DailySummaryData,
      BaseReferences<_$AppDatabase, $DailySummariesTable, DailySummaryData>
    ),
    DailySummaryData,
    PrefetchHooks Function()>;
typedef $$ChatMessagesTableCreateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<int> id,
  required String sessionId,
  required MessageRole role,
  required String content,
  Value<String?> responseType,
  Value<String?> cardDataJson,
  Value<String?> actionsJson,
  Value<String?> detectedIntent,
  Value<double?> confidence,
  Value<DateTime> createdAt,
});
typedef $$ChatMessagesTableUpdateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<int> id,
  Value<String> sessionId,
  Value<MessageRole> role,
  Value<String> content,
  Value<String?> responseType,
  Value<String?> cardDataJson,
  Value<String?> actionsJson,
  Value<String?> detectedIntent,
  Value<double?> confidence,
  Value<DateTime> createdAt,
});

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MessageRole, MessageRole, int> get role =>
      $composableBuilder(
          column: $table.role,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get responseType => $composableBuilder(
      column: $table.responseType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cardDataJson => $composableBuilder(
      column: $table.cardDataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionsJson => $composableBuilder(
      column: $table.actionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detectedIntent => $composableBuilder(
      column: $table.detectedIntent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get responseType => $composableBuilder(
      column: $table.responseType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cardDataJson => $composableBuilder(
      column: $table.cardDataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionsJson => $composableBuilder(
      column: $table.actionsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detectedIntent => $composableBuilder(
      column: $table.detectedIntent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MessageRole, int> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get responseType => $composableBuilder(
      column: $table.responseType, builder: (column) => column);

  GeneratedColumn<String> get cardDataJson => $composableBuilder(
      column: $table.cardDataJson, builder: (column) => column);

  GeneratedColumn<String> get actionsJson => $composableBuilder(
      column: $table.actionsJson, builder: (column) => column);

  GeneratedColumn<String> get detectedIntent => $composableBuilder(
      column: $table.detectedIntent, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChatMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessageData,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessageData,
      BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessageData>
    ),
    ChatMessageData,
    PrefetchHooks Function()> {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<MessageRole> role = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> responseType = const Value.absent(),
            Value<String?> cardDataJson = const Value.absent(),
            Value<String?> actionsJson = const Value.absent(),
            Value<String?> detectedIntent = const Value.absent(),
            Value<double?> confidence = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ChatMessagesCompanion(
            id: id,
            sessionId: sessionId,
            role: role,
            content: content,
            responseType: responseType,
            cardDataJson: cardDataJson,
            actionsJson: actionsJson,
            detectedIntent: detectedIntent,
            confidence: confidence,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String sessionId,
            required MessageRole role,
            required String content,
            Value<String?> responseType = const Value.absent(),
            Value<String?> cardDataJson = const Value.absent(),
            Value<String?> actionsJson = const Value.absent(),
            Value<String?> detectedIntent = const Value.absent(),
            Value<double?> confidence = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ChatMessagesCompanion.insert(
            id: id,
            sessionId: sessionId,
            role: role,
            content: content,
            responseType: responseType,
            cardDataJson: cardDataJson,
            actionsJson: actionsJson,
            detectedIntent: detectedIntent,
            confidence: confidence,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatMessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessageData,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessageData,
      BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessageData>
    ),
    ChatMessageData,
    PrefetchHooks Function()>;
typedef $$ChatSessionsTableCreateCompanionBuilder = ChatSessionsCompanion
    Function({
  Value<int> id,
  required String title,
  Value<String?> sessionId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$ChatSessionsTableUpdateCompanionBuilder = ChatSessionsCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<String?> sessionId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$ChatSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ChatSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ChatSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ChatSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatSessionsTable,
    ChatSessionData,
    $$ChatSessionsTableFilterComposer,
    $$ChatSessionsTableOrderingComposer,
    $$ChatSessionsTableAnnotationComposer,
    $$ChatSessionsTableCreateCompanionBuilder,
    $$ChatSessionsTableUpdateCompanionBuilder,
    (
      ChatSessionData,
      BaseReferences<_$AppDatabase, $ChatSessionsTable, ChatSessionData>
    ),
    ChatSessionData,
    PrefetchHooks Function()> {
  $$ChatSessionsTableTableManager(_$AppDatabase db, $ChatSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> sessionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ChatSessionsCompanion(
            id: id,
            title: title,
            sessionId: sessionId,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> sessionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ChatSessionsCompanion.insert(
            id: id,
            title: title,
            sessionId: sessionId,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatSessionsTable,
    ChatSessionData,
    $$ChatSessionsTableFilterComposer,
    $$ChatSessionsTableOrderingComposer,
    $$ChatSessionsTableAnnotationComposer,
    $$ChatSessionsTableCreateCompanionBuilder,
    $$ChatSessionsTableUpdateCompanionBuilder,
    (
      ChatSessionData,
      BaseReferences<_$AppDatabase, $ChatSessionsTable, ChatSessionData>
    ),
    ChatSessionData,
    PrefetchHooks Function()>;
typedef $$UserProfilesTableCreateCompanionBuilder = UserProfilesCompanion
    Function({
  Value<int> id,
  Value<String?> name,
  Value<String?> avatarPath,
  Value<double> calorieGoal,
  Value<double> proteinGoal,
  Value<double> carbGoal,
  Value<double> fatGoal,
  Value<double> waterGoal,
  Value<double> breakfastBudget,
  Value<double> lunchBudget,
  Value<double> dinnerBudget,
  Value<double> snackBudget,
  Value<double> suggestionThreshold,
  Value<bool> mealSuggestionsEnabled,
  Value<bool> isDarkMode,
  Value<String?> locale,
  Value<String> cuisinePreference,
  Value<bool> hasGeminiApiKey,
  Value<bool> isGoogleCalendarConnected,
  Value<bool> isHealthConnectConnected,
  Value<double> customBmr,
  Value<double> tdee,
  Value<String?> gender,
  Value<int?> age,
  Value<double?> weight,
  Value<double?> height,
  Value<double?> targetWeight,
  Value<String?> activityLevel,
  Value<bool> onboardingComplete,
  Value<bool> foodResearchConsent,
  Value<DateTime?> foodResearchConsentAt,
  Value<String?> platform,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$UserProfilesTableUpdateCompanionBuilder = UserProfilesCompanion
    Function({
  Value<int> id,
  Value<String?> name,
  Value<String?> avatarPath,
  Value<double> calorieGoal,
  Value<double> proteinGoal,
  Value<double> carbGoal,
  Value<double> fatGoal,
  Value<double> waterGoal,
  Value<double> breakfastBudget,
  Value<double> lunchBudget,
  Value<double> dinnerBudget,
  Value<double> snackBudget,
  Value<double> suggestionThreshold,
  Value<bool> mealSuggestionsEnabled,
  Value<bool> isDarkMode,
  Value<String?> locale,
  Value<String> cuisinePreference,
  Value<bool> hasGeminiApiKey,
  Value<bool> isGoogleCalendarConnected,
  Value<bool> isHealthConnectConnected,
  Value<double> customBmr,
  Value<double> tdee,
  Value<String?> gender,
  Value<int?> age,
  Value<double?> weight,
  Value<double?> height,
  Value<double?> targetWeight,
  Value<String?> activityLevel,
  Value<bool> onboardingComplete,
  Value<bool> foodResearchConsent,
  Value<DateTime?> foodResearchConsentAt,
  Value<String?> platform,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarPath => $composableBuilder(
      column: $table.avatarPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calorieGoal => $composableBuilder(
      column: $table.calorieGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteinGoal => $composableBuilder(
      column: $table.proteinGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbGoal => $composableBuilder(
      column: $table.carbGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fatGoal => $composableBuilder(
      column: $table.fatGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get waterGoal => $composableBuilder(
      column: $table.waterGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get breakfastBudget => $composableBuilder(
      column: $table.breakfastBudget,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lunchBudget => $composableBuilder(
      column: $table.lunchBudget, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get dinnerBudget => $composableBuilder(
      column: $table.dinnerBudget, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get snackBudget => $composableBuilder(
      column: $table.snackBudget, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get suggestionThreshold => $composableBuilder(
      column: $table.suggestionThreshold,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get mealSuggestionsEnabled => $composableBuilder(
      column: $table.mealSuggestionsEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDarkMode => $composableBuilder(
      column: $table.isDarkMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locale => $composableBuilder(
      column: $table.locale, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cuisinePreference => $composableBuilder(
      column: $table.cuisinePreference,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasGeminiApiKey => $composableBuilder(
      column: $table.hasGeminiApiKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isGoogleCalendarConnected => $composableBuilder(
      column: $table.isGoogleCalendarConnected,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isHealthConnectConnected => $composableBuilder(
      column: $table.isHealthConnectConnected,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get customBmr => $composableBuilder(
      column: $table.customBmr, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get tdee => $composableBuilder(
      column: $table.tdee, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetWeight => $composableBuilder(
      column: $table.targetWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityLevel => $composableBuilder(
      column: $table.activityLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onboardingComplete => $composableBuilder(
      column: $table.onboardingComplete,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get foodResearchConsent => $composableBuilder(
      column: $table.foodResearchConsent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get foodResearchConsentAt => $composableBuilder(
      column: $table.foodResearchConsentAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarPath => $composableBuilder(
      column: $table.avatarPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calorieGoal => $composableBuilder(
      column: $table.calorieGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteinGoal => $composableBuilder(
      column: $table.proteinGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbGoal => $composableBuilder(
      column: $table.carbGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fatGoal => $composableBuilder(
      column: $table.fatGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get waterGoal => $composableBuilder(
      column: $table.waterGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get breakfastBudget => $composableBuilder(
      column: $table.breakfastBudget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lunchBudget => $composableBuilder(
      column: $table.lunchBudget, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get dinnerBudget => $composableBuilder(
      column: $table.dinnerBudget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get snackBudget => $composableBuilder(
      column: $table.snackBudget, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get suggestionThreshold => $composableBuilder(
      column: $table.suggestionThreshold,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get mealSuggestionsEnabled => $composableBuilder(
      column: $table.mealSuggestionsEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDarkMode => $composableBuilder(
      column: $table.isDarkMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locale => $composableBuilder(
      column: $table.locale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cuisinePreference => $composableBuilder(
      column: $table.cuisinePreference,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasGeminiApiKey => $composableBuilder(
      column: $table.hasGeminiApiKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isGoogleCalendarConnected => $composableBuilder(
      column: $table.isGoogleCalendarConnected,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isHealthConnectConnected => $composableBuilder(
      column: $table.isHealthConnectConnected,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get customBmr => $composableBuilder(
      column: $table.customBmr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get tdee => $composableBuilder(
      column: $table.tdee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetWeight => $composableBuilder(
      column: $table.targetWeight,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityLevel => $composableBuilder(
      column: $table.activityLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onboardingComplete => $composableBuilder(
      column: $table.onboardingComplete,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get foodResearchConsent => $composableBuilder(
      column: $table.foodResearchConsent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get foodResearchConsentAt => $composableBuilder(
      column: $table.foodResearchConsentAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
      column: $table.avatarPath, builder: (column) => column);

  GeneratedColumn<double> get calorieGoal => $composableBuilder(
      column: $table.calorieGoal, builder: (column) => column);

  GeneratedColumn<double> get proteinGoal => $composableBuilder(
      column: $table.proteinGoal, builder: (column) => column);

  GeneratedColumn<double> get carbGoal =>
      $composableBuilder(column: $table.carbGoal, builder: (column) => column);

  GeneratedColumn<double> get fatGoal =>
      $composableBuilder(column: $table.fatGoal, builder: (column) => column);

  GeneratedColumn<double> get waterGoal =>
      $composableBuilder(column: $table.waterGoal, builder: (column) => column);

  GeneratedColumn<double> get breakfastBudget => $composableBuilder(
      column: $table.breakfastBudget, builder: (column) => column);

  GeneratedColumn<double> get lunchBudget => $composableBuilder(
      column: $table.lunchBudget, builder: (column) => column);

  GeneratedColumn<double> get dinnerBudget => $composableBuilder(
      column: $table.dinnerBudget, builder: (column) => column);

  GeneratedColumn<double> get snackBudget => $composableBuilder(
      column: $table.snackBudget, builder: (column) => column);

  GeneratedColumn<double> get suggestionThreshold => $composableBuilder(
      column: $table.suggestionThreshold, builder: (column) => column);

  GeneratedColumn<bool> get mealSuggestionsEnabled => $composableBuilder(
      column: $table.mealSuggestionsEnabled, builder: (column) => column);

  GeneratedColumn<bool> get isDarkMode => $composableBuilder(
      column: $table.isDarkMode, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get cuisinePreference => $composableBuilder(
      column: $table.cuisinePreference, builder: (column) => column);

  GeneratedColumn<bool> get hasGeminiApiKey => $composableBuilder(
      column: $table.hasGeminiApiKey, builder: (column) => column);

  GeneratedColumn<bool> get isGoogleCalendarConnected => $composableBuilder(
      column: $table.isGoogleCalendarConnected, builder: (column) => column);

  GeneratedColumn<bool> get isHealthConnectConnected => $composableBuilder(
      column: $table.isHealthConnectConnected, builder: (column) => column);

  GeneratedColumn<double> get customBmr =>
      $composableBuilder(column: $table.customBmr, builder: (column) => column);

  GeneratedColumn<double> get tdee =>
      $composableBuilder(column: $table.tdee, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<double> get targetWeight => $composableBuilder(
      column: $table.targetWeight, builder: (column) => column);

  GeneratedColumn<String> get activityLevel => $composableBuilder(
      column: $table.activityLevel, builder: (column) => column);

  GeneratedColumn<bool> get onboardingComplete => $composableBuilder(
      column: $table.onboardingComplete, builder: (column) => column);

  GeneratedColumn<bool> get foodResearchConsent => $composableBuilder(
      column: $table.foodResearchConsent, builder: (column) => column);

  GeneratedColumn<DateTime> get foodResearchConsentAt => $composableBuilder(
      column: $table.foodResearchConsentAt, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfileData,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfileData,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileData>
    ),
    UserProfileData,
    PrefetchHooks Function()> {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> avatarPath = const Value.absent(),
            Value<double> calorieGoal = const Value.absent(),
            Value<double> proteinGoal = const Value.absent(),
            Value<double> carbGoal = const Value.absent(),
            Value<double> fatGoal = const Value.absent(),
            Value<double> waterGoal = const Value.absent(),
            Value<double> breakfastBudget = const Value.absent(),
            Value<double> lunchBudget = const Value.absent(),
            Value<double> dinnerBudget = const Value.absent(),
            Value<double> snackBudget = const Value.absent(),
            Value<double> suggestionThreshold = const Value.absent(),
            Value<bool> mealSuggestionsEnabled = const Value.absent(),
            Value<bool> isDarkMode = const Value.absent(),
            Value<String?> locale = const Value.absent(),
            Value<String> cuisinePreference = const Value.absent(),
            Value<bool> hasGeminiApiKey = const Value.absent(),
            Value<bool> isGoogleCalendarConnected = const Value.absent(),
            Value<bool> isHealthConnectConnected = const Value.absent(),
            Value<double> customBmr = const Value.absent(),
            Value<double> tdee = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<double?> weight = const Value.absent(),
            Value<double?> height = const Value.absent(),
            Value<double?> targetWeight = const Value.absent(),
            Value<String?> activityLevel = const Value.absent(),
            Value<bool> onboardingComplete = const Value.absent(),
            Value<bool> foodResearchConsent = const Value.absent(),
            Value<DateTime?> foodResearchConsentAt = const Value.absent(),
            Value<String?> platform = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserProfilesCompanion(
            id: id,
            name: name,
            avatarPath: avatarPath,
            calorieGoal: calorieGoal,
            proteinGoal: proteinGoal,
            carbGoal: carbGoal,
            fatGoal: fatGoal,
            waterGoal: waterGoal,
            breakfastBudget: breakfastBudget,
            lunchBudget: lunchBudget,
            dinnerBudget: dinnerBudget,
            snackBudget: snackBudget,
            suggestionThreshold: suggestionThreshold,
            mealSuggestionsEnabled: mealSuggestionsEnabled,
            isDarkMode: isDarkMode,
            locale: locale,
            cuisinePreference: cuisinePreference,
            hasGeminiApiKey: hasGeminiApiKey,
            isGoogleCalendarConnected: isGoogleCalendarConnected,
            isHealthConnectConnected: isHealthConnectConnected,
            customBmr: customBmr,
            tdee: tdee,
            gender: gender,
            age: age,
            weight: weight,
            height: height,
            targetWeight: targetWeight,
            activityLevel: activityLevel,
            onboardingComplete: onboardingComplete,
            foodResearchConsent: foodResearchConsent,
            foodResearchConsentAt: foodResearchConsentAt,
            platform: platform,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> avatarPath = const Value.absent(),
            Value<double> calorieGoal = const Value.absent(),
            Value<double> proteinGoal = const Value.absent(),
            Value<double> carbGoal = const Value.absent(),
            Value<double> fatGoal = const Value.absent(),
            Value<double> waterGoal = const Value.absent(),
            Value<double> breakfastBudget = const Value.absent(),
            Value<double> lunchBudget = const Value.absent(),
            Value<double> dinnerBudget = const Value.absent(),
            Value<double> snackBudget = const Value.absent(),
            Value<double> suggestionThreshold = const Value.absent(),
            Value<bool> mealSuggestionsEnabled = const Value.absent(),
            Value<bool> isDarkMode = const Value.absent(),
            Value<String?> locale = const Value.absent(),
            Value<String> cuisinePreference = const Value.absent(),
            Value<bool> hasGeminiApiKey = const Value.absent(),
            Value<bool> isGoogleCalendarConnected = const Value.absent(),
            Value<bool> isHealthConnectConnected = const Value.absent(),
            Value<double> customBmr = const Value.absent(),
            Value<double> tdee = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<double?> weight = const Value.absent(),
            Value<double?> height = const Value.absent(),
            Value<double?> targetWeight = const Value.absent(),
            Value<String?> activityLevel = const Value.absent(),
            Value<bool> onboardingComplete = const Value.absent(),
            Value<bool> foodResearchConsent = const Value.absent(),
            Value<DateTime?> foodResearchConsentAt = const Value.absent(),
            Value<String?> platform = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserProfilesCompanion.insert(
            id: id,
            name: name,
            avatarPath: avatarPath,
            calorieGoal: calorieGoal,
            proteinGoal: proteinGoal,
            carbGoal: carbGoal,
            fatGoal: fatGoal,
            waterGoal: waterGoal,
            breakfastBudget: breakfastBudget,
            lunchBudget: lunchBudget,
            dinnerBudget: dinnerBudget,
            snackBudget: snackBudget,
            suggestionThreshold: suggestionThreshold,
            mealSuggestionsEnabled: mealSuggestionsEnabled,
            isDarkMode: isDarkMode,
            locale: locale,
            cuisinePreference: cuisinePreference,
            hasGeminiApiKey: hasGeminiApiKey,
            isGoogleCalendarConnected: isGoogleCalendarConnected,
            isHealthConnectConnected: isHealthConnectConnected,
            customBmr: customBmr,
            tdee: tdee,
            gender: gender,
            age: age,
            weight: weight,
            height: height,
            targetWeight: targetWeight,
            activityLevel: activityLevel,
            onboardingComplete: onboardingComplete,
            foodResearchConsent: foodResearchConsent,
            foodResearchConsentAt: foodResearchConsentAt,
            platform: platform,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfileData,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfileData,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileData>
    ),
    UserProfileData,
    PrefetchHooks Function()>;
typedef $$EnergyTransactionsTableCreateCompanionBuilder
    = EnergyTransactionsCompanion Function({
  Value<int> id,
  required String type,
  required int amount,
  required int balanceAfter,
  Value<String?> packageId,
  Value<String?> description,
  Value<String?> purchaseToken,
  Value<String?> deviceId,
  Value<DateTime> timestamp,
});
typedef $$EnergyTransactionsTableUpdateCompanionBuilder
    = EnergyTransactionsCompanion Function({
  Value<int> id,
  Value<String> type,
  Value<int> amount,
  Value<int> balanceAfter,
  Value<String?> packageId,
  Value<String?> description,
  Value<String?> purchaseToken,
  Value<String?> deviceId,
  Value<DateTime> timestamp,
});

class $$EnergyTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $EnergyTransactionsTable> {
  $$EnergyTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get packageId => $composableBuilder(
      column: $table.packageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchaseToken => $composableBuilder(
      column: $table.purchaseToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$EnergyTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnergyTransactionsTable> {
  $$EnergyTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get packageId => $composableBuilder(
      column: $table.packageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseToken => $composableBuilder(
      column: $table.purchaseToken,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$EnergyTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnergyTransactionsTable> {
  $$EnergyTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter, builder: (column) => column);

  GeneratedColumn<String> get packageId =>
      $composableBuilder(column: $table.packageId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get purchaseToken => $composableBuilder(
      column: $table.purchaseToken, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$EnergyTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EnergyTransactionsTable,
    EnergyTransactionData,
    $$EnergyTransactionsTableFilterComposer,
    $$EnergyTransactionsTableOrderingComposer,
    $$EnergyTransactionsTableAnnotationComposer,
    $$EnergyTransactionsTableCreateCompanionBuilder,
    $$EnergyTransactionsTableUpdateCompanionBuilder,
    (
      EnergyTransactionData,
      BaseReferences<_$AppDatabase, $EnergyTransactionsTable,
          EnergyTransactionData>
    ),
    EnergyTransactionData,
    PrefetchHooks Function()> {
  $$EnergyTransactionsTableTableManager(
      _$AppDatabase db, $EnergyTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnergyTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnergyTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnergyTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<int> balanceAfter = const Value.absent(),
            Value<String?> packageId = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> purchaseToken = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              EnergyTransactionsCompanion(
            id: id,
            type: type,
            amount: amount,
            balanceAfter: balanceAfter,
            packageId: packageId,
            description: description,
            purchaseToken: purchaseToken,
            deviceId: deviceId,
            timestamp: timestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String type,
            required int amount,
            required int balanceAfter,
            Value<String?> packageId = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> purchaseToken = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              EnergyTransactionsCompanion.insert(
            id: id,
            type: type,
            amount: amount,
            balanceAfter: balanceAfter,
            packageId: packageId,
            description: description,
            purchaseToken: purchaseToken,
            deviceId: deviceId,
            timestamp: timestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EnergyTransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EnergyTransactionsTable,
    EnergyTransactionData,
    $$EnergyTransactionsTableFilterComposer,
    $$EnergyTransactionsTableOrderingComposer,
    $$EnergyTransactionsTableAnnotationComposer,
    $$EnergyTransactionsTableCreateCompanionBuilder,
    $$EnergyTransactionsTableUpdateCompanionBuilder,
    (
      EnergyTransactionData,
      BaseReferences<_$AppDatabase, $EnergyTransactionsTable,
          EnergyTransactionData>
    ),
    EnergyTransactionData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoodEntriesTableTableManager get foodEntries =>
      $$FoodEntriesTableTableManager(_db, _db.foodEntries);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db, _db.ingredients);
  $$MyMealsTableTableManager get myMeals =>
      $$MyMealsTableTableManager(_db, _db.myMeals);
  $$MyMealIngredientsTableTableManager get myMealIngredients =>
      $$MyMealIngredientsTableTableManager(_db, _db.myMealIngredients);
  $$DailySummariesTableTableManager get dailySummaries =>
      $$DailySummariesTableTableManager(_db, _db.dailySummaries);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$ChatSessionsTableTableManager get chatSessions =>
      $$ChatSessionsTableTableManager(_db, _db.chatSessions);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$EnergyTransactionsTableTableManager get energyTransactions =>
      $$EnergyTransactionsTableTableManager(_db, _db.energyTransactions);
}
