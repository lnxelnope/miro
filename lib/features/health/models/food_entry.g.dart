// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFoodEntryCollection on Isar {
  IsarCollection<FoodEntry> get foodEntrys => this.collection();
}

const FoodEntrySchema = CollectionSchema(
  name: r'FoodEntry',
  id: -3633015723928946904,
  properties: {
    r'aiConfidence': PropertySchema(
      id: 0,
      name: r'aiConfidence',
      type: IsarType.double,
    ),
    r'baseCalories': PropertySchema(
      id: 1,
      name: r'baseCalories',
      type: IsarType.double,
    ),
    r'baseCarbs': PropertySchema(
      id: 2,
      name: r'baseCarbs',
      type: IsarType.double,
    ),
    r'baseFat': PropertySchema(
      id: 3,
      name: r'baseFat',
      type: IsarType.double,
    ),
    r'baseProtein': PropertySchema(
      id: 4,
      name: r'baseProtein',
      type: IsarType.double,
    ),
    r'calories': PropertySchema(
      id: 5,
      name: r'calories',
      type: IsarType.double,
    ),
    r'carbs': PropertySchema(
      id: 6,
      name: r'carbs',
      type: IsarType.double,
    ),
    r'cholesterol': PropertySchema(
      id: 7,
      name: r'cholesterol',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 8,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'fat': PropertySchema(
      id: 9,
      name: r'fat',
      type: IsarType.double,
    ),
    r'fiber': PropertySchema(
      id: 10,
      name: r'fiber',
      type: IsarType.double,
    ),
    r'foodName': PropertySchema(
      id: 11,
      name: r'foodName',
      type: IsarType.string,
    ),
    r'foodNameEn': PropertySchema(
      id: 12,
      name: r'foodNameEn',
      type: IsarType.string,
    ),
    r'groupId': PropertySchema(
      id: 13,
      name: r'groupId',
      type: IsarType.string,
    ),
    r'hasBaseValues': PropertySchema(
      id: 14,
      name: r'hasBaseValues',
      type: IsarType.bool,
    ),
    r'hasNutritionData': PropertySchema(
      id: 15,
      name: r'hasNutritionData',
      type: IsarType.bool,
    ),
    r'healthConnectId': PropertySchema(
      id: 16,
      name: r'healthConnectId',
      type: IsarType.string,
    ),
    r'imagePath': PropertySchema(
      id: 17,
      name: r'imagePath',
      type: IsarType.string,
    ),
    r'ingredientId': PropertySchema(
      id: 18,
      name: r'ingredientId',
      type: IsarType.long,
    ),
    r'ingredientsJson': PropertySchema(
      id: 19,
      name: r'ingredientsJson',
      type: IsarType.string,
    ),
    r'isDeleted': PropertySchema(
      id: 20,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isVerified': PropertySchema(
      id: 21,
      name: r'isVerified',
      type: IsarType.bool,
    ),
    r'mealType': PropertySchema(
      id: 22,
      name: r'mealType',
      type: IsarType.byte,
      enumMap: _FoodEntrymealTypeEnumValueMap,
    ),
    r'myMealId': PropertySchema(
      id: 23,
      name: r'myMealId',
      type: IsarType.long,
    ),
    r'notes': PropertySchema(
      id: 24,
      name: r'notes',
      type: IsarType.string,
    ),
    r'protein': PropertySchema(
      id: 25,
      name: r'protein',
      type: IsarType.double,
    ),
    r'saturatedFat': PropertySchema(
      id: 26,
      name: r'saturatedFat',
      type: IsarType.double,
    ),
    r'searchMode': PropertySchema(
      id: 27,
      name: r'searchMode',
      type: IsarType.byte,
      enumMap: _FoodEntrysearchModeEnumValueMap,
    ),
    r'servingGrams': PropertySchema(
      id: 28,
      name: r'servingGrams',
      type: IsarType.double,
    ),
    r'servingSize': PropertySchema(
      id: 29,
      name: r'servingSize',
      type: IsarType.double,
    ),
    r'servingUnit': PropertySchema(
      id: 30,
      name: r'servingUnit',
      type: IsarType.string,
    ),
    r'sodium': PropertySchema(
      id: 31,
      name: r'sodium',
      type: IsarType.double,
    ),
    r'source': PropertySchema(
      id: 32,
      name: r'source',
      type: IsarType.byte,
      enumMap: _FoodEntrysourceEnumValueMap,
    ),
    r'sugar': PropertySchema(
      id: 33,
      name: r'sugar',
      type: IsarType.double,
    ),
    r'syncedAt': PropertySchema(
      id: 34,
      name: r'syncedAt',
      type: IsarType.dateTime,
    ),
    r'timestamp': PropertySchema(
      id: 35,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 36,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _foodEntryEstimateSize,
  serialize: _foodEntrySerialize,
  deserialize: _foodEntryDeserialize,
  deserializeProp: _foodEntryDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _foodEntryGetId,
  getLinks: _foodEntryGetLinks,
  attach: _foodEntryAttach,
  version: '3.1.0+1',
);

int _foodEntryEstimateSize(
  FoodEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.foodName.length * 3;
  {
    final value = object.foodNameEn;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.groupId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.healthConnectId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.imagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ingredientsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.servingUnit.length * 3;
  return bytesCount;
}

void _foodEntrySerialize(
  FoodEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.aiConfidence);
  writer.writeDouble(offsets[1], object.baseCalories);
  writer.writeDouble(offsets[2], object.baseCarbs);
  writer.writeDouble(offsets[3], object.baseFat);
  writer.writeDouble(offsets[4], object.baseProtein);
  writer.writeDouble(offsets[5], object.calories);
  writer.writeDouble(offsets[6], object.carbs);
  writer.writeDouble(offsets[7], object.cholesterol);
  writer.writeDateTime(offsets[8], object.createdAt);
  writer.writeDouble(offsets[9], object.fat);
  writer.writeDouble(offsets[10], object.fiber);
  writer.writeString(offsets[11], object.foodName);
  writer.writeString(offsets[12], object.foodNameEn);
  writer.writeString(offsets[13], object.groupId);
  writer.writeBool(offsets[14], object.hasBaseValues);
  writer.writeBool(offsets[15], object.hasNutritionData);
  writer.writeString(offsets[16], object.healthConnectId);
  writer.writeString(offsets[17], object.imagePath);
  writer.writeLong(offsets[18], object.ingredientId);
  writer.writeString(offsets[19], object.ingredientsJson);
  writer.writeBool(offsets[20], object.isDeleted);
  writer.writeBool(offsets[21], object.isVerified);
  writer.writeByte(offsets[22], object.mealType.index);
  writer.writeLong(offsets[23], object.myMealId);
  writer.writeString(offsets[24], object.notes);
  writer.writeDouble(offsets[25], object.protein);
  writer.writeDouble(offsets[26], object.saturatedFat);
  writer.writeByte(offsets[27], object.searchMode.index);
  writer.writeDouble(offsets[28], object.servingGrams);
  writer.writeDouble(offsets[29], object.servingSize);
  writer.writeString(offsets[30], object.servingUnit);
  writer.writeDouble(offsets[31], object.sodium);
  writer.writeByte(offsets[32], object.source.index);
  writer.writeDouble(offsets[33], object.sugar);
  writer.writeDateTime(offsets[34], object.syncedAt);
  writer.writeDateTime(offsets[35], object.timestamp);
  writer.writeDateTime(offsets[36], object.updatedAt);
}

FoodEntry _foodEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FoodEntry();
  object.aiConfidence = reader.readDoubleOrNull(offsets[0]);
  object.baseCalories = reader.readDouble(offsets[1]);
  object.baseCarbs = reader.readDouble(offsets[2]);
  object.baseFat = reader.readDouble(offsets[3]);
  object.baseProtein = reader.readDouble(offsets[4]);
  object.calories = reader.readDouble(offsets[5]);
  object.carbs = reader.readDouble(offsets[6]);
  object.cholesterol = reader.readDoubleOrNull(offsets[7]);
  object.createdAt = reader.readDateTime(offsets[8]);
  object.fat = reader.readDouble(offsets[9]);
  object.fiber = reader.readDoubleOrNull(offsets[10]);
  object.foodName = reader.readString(offsets[11]);
  object.foodNameEn = reader.readStringOrNull(offsets[12]);
  object.groupId = reader.readStringOrNull(offsets[13]);
  object.healthConnectId = reader.readStringOrNull(offsets[16]);
  object.id = id;
  object.imagePath = reader.readStringOrNull(offsets[17]);
  object.ingredientId = reader.readLongOrNull(offsets[18]);
  object.ingredientsJson = reader.readStringOrNull(offsets[19]);
  object.isDeleted = reader.readBool(offsets[20]);
  object.isVerified = reader.readBool(offsets[21]);
  object.mealType =
      _FoodEntrymealTypeValueEnumMap[reader.readByteOrNull(offsets[22])] ??
          MealType.breakfast;
  object.myMealId = reader.readLongOrNull(offsets[23]);
  object.notes = reader.readStringOrNull(offsets[24]);
  object.protein = reader.readDouble(offsets[25]);
  object.saturatedFat = reader.readDoubleOrNull(offsets[26]);
  object.searchMode =
      _FoodEntrysearchModeValueEnumMap[reader.readByteOrNull(offsets[27])] ??
          FoodSearchMode.normal;
  object.servingGrams = reader.readDoubleOrNull(offsets[28]);
  object.servingSize = reader.readDouble(offsets[29]);
  object.servingUnit = reader.readString(offsets[30]);
  object.sodium = reader.readDoubleOrNull(offsets[31]);
  object.source =
      _FoodEntrysourceValueEnumMap[reader.readByteOrNull(offsets[32])] ??
          DataSource.manual;
  object.sugar = reader.readDoubleOrNull(offsets[33]);
  object.syncedAt = reader.readDateTimeOrNull(offsets[34]);
  object.timestamp = reader.readDateTime(offsets[35]);
  object.updatedAt = reader.readDateTime(offsets[36]);
  return object;
}

P _foodEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readLongOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readBool(offset)) as P;
    case 22:
      return (_FoodEntrymealTypeValueEnumMap[reader.readByteOrNull(offset)] ??
          MealType.breakfast) as P;
    case 23:
      return (reader.readLongOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readDouble(offset)) as P;
    case 26:
      return (reader.readDoubleOrNull(offset)) as P;
    case 27:
      return (_FoodEntrysearchModeValueEnumMap[reader.readByteOrNull(offset)] ??
          FoodSearchMode.normal) as P;
    case 28:
      return (reader.readDoubleOrNull(offset)) as P;
    case 29:
      return (reader.readDouble(offset)) as P;
    case 30:
      return (reader.readString(offset)) as P;
    case 31:
      return (reader.readDoubleOrNull(offset)) as P;
    case 32:
      return (_FoodEntrysourceValueEnumMap[reader.readByteOrNull(offset)] ??
          DataSource.manual) as P;
    case 33:
      return (reader.readDoubleOrNull(offset)) as P;
    case 34:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 35:
      return (reader.readDateTime(offset)) as P;
    case 36:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _FoodEntrymealTypeEnumValueMap = {
  'breakfast': 0,
  'lunch': 1,
  'dinner': 2,
  'snack': 3,
};
const _FoodEntrymealTypeValueEnumMap = {
  0: MealType.breakfast,
  1: MealType.lunch,
  2: MealType.dinner,
  3: MealType.snack,
};
const _FoodEntrysearchModeEnumValueMap = {
  'normal': 0,
  'product': 1,
};
const _FoodEntrysearchModeValueEnumMap = {
  0: FoodSearchMode.normal,
  1: FoodSearchMode.product,
};
const _FoodEntrysourceEnumValueMap = {
  'manual': 0,
  'aiAnalyzed': 1,
  'database': 2,
  'slipScan': 3,
  'healthConnect': 4,
  'googleCalendar': 5,
  'barcode': 6,
  'galleryScanned': 7,
};
const _FoodEntrysourceValueEnumMap = {
  0: DataSource.manual,
  1: DataSource.aiAnalyzed,
  2: DataSource.database,
  3: DataSource.slipScan,
  4: DataSource.healthConnect,
  5: DataSource.googleCalendar,
  6: DataSource.barcode,
  7: DataSource.galleryScanned,
};

Id _foodEntryGetId(FoodEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _foodEntryGetLinks(FoodEntry object) {
  return [];
}

void _foodEntryAttach(IsarCollection<dynamic> col, Id id, FoodEntry object) {
  object.id = id;
}

extension FoodEntryQueryWhereSort
    on QueryBuilder<FoodEntry, FoodEntry, QWhere> {
  QueryBuilder<FoodEntry, FoodEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FoodEntryQueryWhere
    on QueryBuilder<FoodEntry, FoodEntry, QWhereClause> {
  QueryBuilder<FoodEntry, FoodEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FoodEntryQueryFilter
    on QueryBuilder<FoodEntry, FoodEntry, QFilterCondition> {
  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      aiConfidenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiConfidence',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      aiConfidenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiConfidence',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> aiConfidenceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiConfidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      aiConfidenceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiConfidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      aiConfidenceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiConfidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> aiConfidenceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiConfidence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> baseCaloriesEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      baseCaloriesGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      baseCaloriesLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> baseCaloriesBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseCalories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> baseCarbsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseCarbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      baseCarbsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseCarbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> baseCarbsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseCarbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> baseCarbsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseCarbs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> baseFatEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> baseFatGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> baseFatLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> baseFatBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseFat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> baseProteinEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseProtein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      baseProteinGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseProtein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> baseProteinLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseProtein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> baseProteinBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseProtein',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> caloriesEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> caloriesGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> caloriesLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> caloriesBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> carbsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> carbsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> carbsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> carbsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carbs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      cholesterolIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cholesterol',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      cholesterolIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cholesterol',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> cholesterolEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cholesterol',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      cholesterolGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cholesterol',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> cholesterolLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cholesterol',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> cholesterolBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cholesterol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> fatEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> fatGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> fatLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> fatBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> fiberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fiber',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> fiberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fiber',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> fiberEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fiber',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> fiberGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fiber',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> fiberLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fiber',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> fiberBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fiber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'foodName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'foodName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'foodName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'foodName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'foodName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'foodName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'foodName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodName',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      foodNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'foodName',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameEnIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'foodNameEn',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      foodNameEnIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'foodNameEn',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameEnEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodNameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      foodNameEnGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'foodNameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameEnLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'foodNameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameEnBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'foodNameEn',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      foodNameEnStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'foodNameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameEnEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'foodNameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameEnContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'foodNameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> foodNameEnMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'foodNameEn',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      foodNameEnIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodNameEn',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      foodNameEnIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'foodNameEn',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> groupIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'groupId',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> groupIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'groupId',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> groupIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> groupIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'groupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> groupIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'groupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> groupIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'groupId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> groupIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'groupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> groupIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'groupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> groupIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'groupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> groupIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'groupId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> groupIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupId',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      groupIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'groupId',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      hasBaseValuesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasBaseValues',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      hasNutritionDataEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasNutritionData',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      healthConnectIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'healthConnectId',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      healthConnectIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'healthConnectId',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      healthConnectIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'healthConnectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      healthConnectIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'healthConnectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      healthConnectIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'healthConnectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      healthConnectIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'healthConnectId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      healthConnectIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'healthConnectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      healthConnectIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'healthConnectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      healthConnectIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'healthConnectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      healthConnectIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'healthConnectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      healthConnectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'healthConnectId',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      healthConnectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'healthConnectId',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> imagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imagePath',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      imagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imagePath',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> imagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      imagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> imagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> imagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> imagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> imagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> imagePathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> imagePathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> imagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      imagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ingredientId',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ingredientId',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> ingredientIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ingredientId',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ingredientId',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ingredientId',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> ingredientIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ingredientId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ingredientsJson',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ingredientsJson',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientsJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ingredientsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ingredientsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ingredientsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ingredientsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ingredientsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ingredientsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ingredientsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ingredientsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ingredientsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      ingredientsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ingredientsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> isDeletedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> isVerifiedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isVerified',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> mealTypeEqualTo(
      MealType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealType',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> mealTypeGreaterThan(
    MealType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mealType',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> mealTypeLessThan(
    MealType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mealType',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> mealTypeBetween(
    MealType lower,
    MealType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mealType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> myMealIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'myMealId',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      myMealIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'myMealId',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> myMealIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'myMealId',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> myMealIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'myMealId',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> myMealIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'myMealId',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> myMealIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'myMealId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> proteinEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'protein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> proteinGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'protein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> proteinLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'protein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> proteinBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'protein',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      saturatedFatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'saturatedFat',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      saturatedFatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'saturatedFat',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> saturatedFatEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saturatedFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      saturatedFatGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'saturatedFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      saturatedFatLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'saturatedFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> saturatedFatBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'saturatedFat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> searchModeEqualTo(
      FoodSearchMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchMode',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      searchModeGreaterThan(
    FoodSearchMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'searchMode',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> searchModeLessThan(
    FoodSearchMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'searchMode',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> searchModeBetween(
    FoodSearchMode lower,
    FoodSearchMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'searchMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      servingGramsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'servingGrams',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      servingGramsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'servingGrams',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> servingGramsEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'servingGrams',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      servingGramsGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'servingGrams',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      servingGramsLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'servingGrams',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> servingGramsBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'servingGrams',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> servingSizeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'servingSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      servingSizeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'servingSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> servingSizeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'servingSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> servingSizeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'servingSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> servingUnitEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'servingUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      servingUnitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'servingUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> servingUnitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'servingUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> servingUnitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'servingUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      servingUnitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'servingUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> servingUnitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'servingUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> servingUnitContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'servingUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> servingUnitMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'servingUnit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      servingUnitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'servingUnit',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      servingUnitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'servingUnit',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sodiumIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sodium',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sodiumIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sodium',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sodiumEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sodium',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sodiumGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sodium',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sodiumLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sodium',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sodiumBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sodium',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sourceEqualTo(
      DataSource value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sourceGreaterThan(
    DataSource value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sourceLessThan(
    DataSource value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sourceBetween(
    DataSource lower,
    DataSource upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sugarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sugar',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sugarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sugar',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sugarEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sugar',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sugarGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sugar',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sugarLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sugar',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> sugarBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sugar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> syncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      syncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> syncedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> syncedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> syncedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> syncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> timestampEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FoodEntryQueryObject
    on QueryBuilder<FoodEntry, FoodEntry, QFilterCondition> {}

extension FoodEntryQueryLinks
    on QueryBuilder<FoodEntry, FoodEntry, QFilterCondition> {}

extension FoodEntryQuerySortBy on QueryBuilder<FoodEntry, FoodEntry, QSortBy> {
  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByAiConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByAiConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByBaseCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseCalories', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByBaseCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseCalories', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByBaseCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseCarbs', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByBaseCarbsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseCarbs', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByBaseFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseFat', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByBaseFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseFat', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByBaseProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseProtein', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByBaseProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseProtein', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbs', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByCarbsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbs', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByCholesterol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cholesterol', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByCholesterolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cholesterol', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByFiber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiber', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByFiberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiber', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByFoodName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodName', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByFoodNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodName', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByFoodNameEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodNameEn', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByFoodNameEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodNameEn', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByHasBaseValues() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasBaseValues', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByHasBaseValuesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasBaseValues', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByHasNutritionData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasNutritionData', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy>
      sortByHasNutritionDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasNutritionData', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByHealthConnectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthConnectId', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByHealthConnectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthConnectId', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByIngredientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientId', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByIngredientIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientId', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByIngredientsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientsJson', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByIngredientsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientsJson', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByIsVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVerified', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByIsVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVerified', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByMealType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByMealTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByMyMealId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'myMealId', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByMyMealIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'myMealId', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protein', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protein', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortBySaturatedFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saturatedFat', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortBySaturatedFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saturatedFat', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortBySearchMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchMode', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortBySearchModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchMode', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByServingGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingGrams', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByServingGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingGrams', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByServingSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingSize', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByServingSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingSize', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByServingUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingUnit', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByServingUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingUnit', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortBySodium() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodium', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortBySodiumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodium', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortBySugar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugar', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortBySugarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugar', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension FoodEntryQuerySortThenBy
    on QueryBuilder<FoodEntry, FoodEntry, QSortThenBy> {
  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByAiConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByAiConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByBaseCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseCalories', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByBaseCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseCalories', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByBaseCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseCarbs', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByBaseCarbsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseCarbs', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByBaseFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseFat', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByBaseFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseFat', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByBaseProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseProtein', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByBaseProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseProtein', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbs', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByCarbsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbs', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByCholesterol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cholesterol', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByCholesterolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cholesterol', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByFiber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiber', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByFiberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiber', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByFoodName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodName', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByFoodNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodName', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByFoodNameEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodNameEn', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByFoodNameEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodNameEn', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByHasBaseValues() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasBaseValues', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByHasBaseValuesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasBaseValues', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByHasNutritionData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasNutritionData', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy>
      thenByHasNutritionDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasNutritionData', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByHealthConnectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthConnectId', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByHealthConnectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthConnectId', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByIngredientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientId', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByIngredientIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientId', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByIngredientsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientsJson', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByIngredientsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientsJson', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByIsVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVerified', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByIsVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVerified', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByMealType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByMealTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByMyMealId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'myMealId', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByMyMealIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'myMealId', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protein', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protein', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenBySaturatedFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saturatedFat', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenBySaturatedFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saturatedFat', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenBySearchMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchMode', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenBySearchModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchMode', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByServingGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingGrams', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByServingGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingGrams', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByServingSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingSize', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByServingSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingSize', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByServingUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingUnit', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByServingUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingUnit', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenBySodium() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodium', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenBySodiumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodium', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenBySugar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugar', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenBySugarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugar', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension FoodEntryQueryWhereDistinct
    on QueryBuilder<FoodEntry, FoodEntry, QDistinct> {
  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByAiConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiConfidence');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByBaseCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseCalories');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByBaseCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseCarbs');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByBaseFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseFat');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByBaseProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseProtein');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calories');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbs');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByCholesterol() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cholesterol');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fat');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByFiber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fiber');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByFoodName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'foodName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByFoodNameEn(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'foodNameEn', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByGroupId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByHasBaseValues() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasBaseValues');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByHasNutritionData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasNutritionData');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByHealthConnectId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'healthConnectId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByImagePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByIngredientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ingredientId');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByIngredientsJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ingredientsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByIsVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isVerified');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByMealType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mealType');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByMyMealId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'myMealId');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'protein');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctBySaturatedFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saturatedFat');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctBySearchMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchMode');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByServingGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'servingGrams');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByServingSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'servingSize');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByServingUnit(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'servingUnit', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctBySodium() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sodium');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctBySugar() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sugar');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncedAt');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<FoodEntry, FoodEntry, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension FoodEntryQueryProperty
    on QueryBuilder<FoodEntry, FoodEntry, QQueryProperty> {
  QueryBuilder<FoodEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FoodEntry, double?, QQueryOperations> aiConfidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiConfidence');
    });
  }

  QueryBuilder<FoodEntry, double, QQueryOperations> baseCaloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseCalories');
    });
  }

  QueryBuilder<FoodEntry, double, QQueryOperations> baseCarbsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseCarbs');
    });
  }

  QueryBuilder<FoodEntry, double, QQueryOperations> baseFatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseFat');
    });
  }

  QueryBuilder<FoodEntry, double, QQueryOperations> baseProteinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseProtein');
    });
  }

  QueryBuilder<FoodEntry, double, QQueryOperations> caloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calories');
    });
  }

  QueryBuilder<FoodEntry, double, QQueryOperations> carbsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbs');
    });
  }

  QueryBuilder<FoodEntry, double?, QQueryOperations> cholesterolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cholesterol');
    });
  }

  QueryBuilder<FoodEntry, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<FoodEntry, double, QQueryOperations> fatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fat');
    });
  }

  QueryBuilder<FoodEntry, double?, QQueryOperations> fiberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fiber');
    });
  }

  QueryBuilder<FoodEntry, String, QQueryOperations> foodNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foodName');
    });
  }

  QueryBuilder<FoodEntry, String?, QQueryOperations> foodNameEnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foodNameEn');
    });
  }

  QueryBuilder<FoodEntry, String?, QQueryOperations> groupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupId');
    });
  }

  QueryBuilder<FoodEntry, bool, QQueryOperations> hasBaseValuesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasBaseValues');
    });
  }

  QueryBuilder<FoodEntry, bool, QQueryOperations> hasNutritionDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasNutritionData');
    });
  }

  QueryBuilder<FoodEntry, String?, QQueryOperations> healthConnectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'healthConnectId');
    });
  }

  QueryBuilder<FoodEntry, String?, QQueryOperations> imagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagePath');
    });
  }

  QueryBuilder<FoodEntry, int?, QQueryOperations> ingredientIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ingredientId');
    });
  }

  QueryBuilder<FoodEntry, String?, QQueryOperations> ingredientsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ingredientsJson');
    });
  }

  QueryBuilder<FoodEntry, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<FoodEntry, bool, QQueryOperations> isVerifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isVerified');
    });
  }

  QueryBuilder<FoodEntry, MealType, QQueryOperations> mealTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mealType');
    });
  }

  QueryBuilder<FoodEntry, int?, QQueryOperations> myMealIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'myMealId');
    });
  }

  QueryBuilder<FoodEntry, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<FoodEntry, double, QQueryOperations> proteinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'protein');
    });
  }

  QueryBuilder<FoodEntry, double?, QQueryOperations> saturatedFatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saturatedFat');
    });
  }

  QueryBuilder<FoodEntry, FoodSearchMode, QQueryOperations>
      searchModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchMode');
    });
  }

  QueryBuilder<FoodEntry, double?, QQueryOperations> servingGramsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'servingGrams');
    });
  }

  QueryBuilder<FoodEntry, double, QQueryOperations> servingSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'servingSize');
    });
  }

  QueryBuilder<FoodEntry, String, QQueryOperations> servingUnitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'servingUnit');
    });
  }

  QueryBuilder<FoodEntry, double?, QQueryOperations> sodiumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sodium');
    });
  }

  QueryBuilder<FoodEntry, DataSource, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<FoodEntry, double?, QQueryOperations> sugarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sugar');
    });
  }

  QueryBuilder<FoodEntry, DateTime?, QQueryOperations> syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncedAt');
    });
  }

  QueryBuilder<FoodEntry, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<FoodEntry, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
