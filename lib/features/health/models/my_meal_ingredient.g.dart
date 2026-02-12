// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_meal_ingredient.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMyMealIngredientCollection on Isar {
  IsarCollection<MyMealIngredient> get myMealIngredients => this.collection();
}

const MyMealIngredientSchema = CollectionSchema(
  name: r'MyMealIngredient',
  id: 8233813829696519222,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'calories': PropertySchema(
      id: 1,
      name: r'calories',
      type: IsarType.double,
    ),
    r'carbs': PropertySchema(
      id: 2,
      name: r'carbs',
      type: IsarType.double,
    ),
    r'fat': PropertySchema(
      id: 3,
      name: r'fat',
      type: IsarType.double,
    ),
    r'ingredientId': PropertySchema(
      id: 4,
      name: r'ingredientId',
      type: IsarType.long,
    ),
    r'ingredientName': PropertySchema(
      id: 5,
      name: r'ingredientName',
      type: IsarType.string,
    ),
    r'myMealId': PropertySchema(
      id: 6,
      name: r'myMealId',
      type: IsarType.long,
    ),
    r'protein': PropertySchema(
      id: 7,
      name: r'protein',
      type: IsarType.double,
    ),
    r'sortOrder': PropertySchema(
      id: 8,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'unit': PropertySchema(
      id: 9,
      name: r'unit',
      type: IsarType.string,
    )
  },
  estimateSize: _myMealIngredientEstimateSize,
  serialize: _myMealIngredientSerialize,
  deserialize: _myMealIngredientDeserialize,
  deserializeProp: _myMealIngredientDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _myMealIngredientGetId,
  getLinks: _myMealIngredientGetLinks,
  attach: _myMealIngredientAttach,
  version: '3.1.0+1',
);

int _myMealIngredientEstimateSize(
  MyMealIngredient object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.ingredientName.length * 3;
  bytesCount += 3 + object.unit.length * 3;
  return bytesCount;
}

void _myMealIngredientSerialize(
  MyMealIngredient object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeDouble(offsets[1], object.calories);
  writer.writeDouble(offsets[2], object.carbs);
  writer.writeDouble(offsets[3], object.fat);
  writer.writeLong(offsets[4], object.ingredientId);
  writer.writeString(offsets[5], object.ingredientName);
  writer.writeLong(offsets[6], object.myMealId);
  writer.writeDouble(offsets[7], object.protein);
  writer.writeLong(offsets[8], object.sortOrder);
  writer.writeString(offsets[9], object.unit);
}

MyMealIngredient _myMealIngredientDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MyMealIngredient();
  object.amount = reader.readDouble(offsets[0]);
  object.calories = reader.readDouble(offsets[1]);
  object.carbs = reader.readDouble(offsets[2]);
  object.fat = reader.readDouble(offsets[3]);
  object.id = id;
  object.ingredientId = reader.readLong(offsets[4]);
  object.ingredientName = reader.readString(offsets[5]);
  object.myMealId = reader.readLong(offsets[6]);
  object.protein = reader.readDouble(offsets[7]);
  object.sortOrder = reader.readLong(offsets[8]);
  object.unit = reader.readString(offsets[9]);
  return object;
}

P _myMealIngredientDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _myMealIngredientGetId(MyMealIngredient object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _myMealIngredientGetLinks(MyMealIngredient object) {
  return [];
}

void _myMealIngredientAttach(
    IsarCollection<dynamic> col, Id id, MyMealIngredient object) {
  object.id = id;
}

extension MyMealIngredientQueryWhereSort
    on QueryBuilder<MyMealIngredient, MyMealIngredient, QWhere> {
  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MyMealIngredientQueryWhere
    on QueryBuilder<MyMealIngredient, MyMealIngredient, QWhereClause> {
  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterWhereClause> idBetween(
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

extension MyMealIngredientQueryFilter
    on QueryBuilder<MyMealIngredient, MyMealIngredient, QFilterCondition> {
  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      caloriesEqualTo(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      caloriesGreaterThan(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      caloriesLessThan(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      caloriesBetween(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      carbsEqualTo(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      carbsGreaterThan(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      carbsLessThan(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      carbsBetween(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      fatEqualTo(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      fatGreaterThan(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      fatLessThan(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      fatBetween(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      ingredientIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ingredientId',
        value: value,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      ingredientIdGreaterThan(
    int value, {
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      ingredientIdLessThan(
    int value, {
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      ingredientIdBetween(
    int lower,
    int upper, {
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      ingredientNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ingredientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      ingredientNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ingredientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      ingredientNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ingredientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      ingredientNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ingredientName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      ingredientNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ingredientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      ingredientNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ingredientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      ingredientNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ingredientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      ingredientNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ingredientName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      ingredientNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ingredientName',
        value: '',
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      ingredientNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ingredientName',
        value: '',
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      myMealIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'myMealId',
        value: value,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      myMealIdGreaterThan(
    int value, {
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      myMealIdLessThan(
    int value, {
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      myMealIdBetween(
    int lower,
    int upper, {
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      proteinEqualTo(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      proteinGreaterThan(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      proteinLessThan(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      proteinBetween(
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

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      sortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      unitEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      unitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      unitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      unitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      unitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      unitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      unitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      unitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterFilterCondition>
      unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unit',
        value: '',
      ));
    });
  }
}

extension MyMealIngredientQueryObject
    on QueryBuilder<MyMealIngredient, MyMealIngredient, QFilterCondition> {}

extension MyMealIngredientQueryLinks
    on QueryBuilder<MyMealIngredient, MyMealIngredient, QFilterCondition> {}

extension MyMealIngredientQuerySortBy
    on QueryBuilder<MyMealIngredient, MyMealIngredient, QSortBy> {
  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy> sortByCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbs', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortByCarbsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbs', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy> sortByFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortByFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortByIngredientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientId', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortByIngredientIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientId', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortByIngredientName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientName', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortByIngredientNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientName', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortByMyMealId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'myMealId', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortByMyMealIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'myMealId', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortByProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protein', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortByProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protein', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy> sortByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      sortByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }
}

extension MyMealIngredientQuerySortThenBy
    on QueryBuilder<MyMealIngredient, MyMealIngredient, QSortThenBy> {
  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy> thenByCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbs', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByCarbsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbs', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy> thenByFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByIngredientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientId', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByIngredientIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientId', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByIngredientName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientName', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByIngredientNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientName', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByMyMealId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'myMealId', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByMyMealIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'myMealId', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protein', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protein', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy> thenByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QAfterSortBy>
      thenByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }
}

extension MyMealIngredientQueryWhereDistinct
    on QueryBuilder<MyMealIngredient, MyMealIngredient, QDistinct> {
  QueryBuilder<MyMealIngredient, MyMealIngredient, QDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QDistinct>
      distinctByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calories');
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QDistinct>
      distinctByCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbs');
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QDistinct> distinctByFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fat');
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QDistinct>
      distinctByIngredientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ingredientId');
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QDistinct>
      distinctByIngredientName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ingredientName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QDistinct>
      distinctByMyMealId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'myMealId');
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QDistinct>
      distinctByProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'protein');
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QDistinct>
      distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<MyMealIngredient, MyMealIngredient, QDistinct> distinctByUnit(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unit', caseSensitive: caseSensitive);
    });
  }
}

extension MyMealIngredientQueryProperty
    on QueryBuilder<MyMealIngredient, MyMealIngredient, QQueryProperty> {
  QueryBuilder<MyMealIngredient, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MyMealIngredient, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<MyMealIngredient, double, QQueryOperations> caloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calories');
    });
  }

  QueryBuilder<MyMealIngredient, double, QQueryOperations> carbsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbs');
    });
  }

  QueryBuilder<MyMealIngredient, double, QQueryOperations> fatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fat');
    });
  }

  QueryBuilder<MyMealIngredient, int, QQueryOperations> ingredientIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ingredientId');
    });
  }

  QueryBuilder<MyMealIngredient, String, QQueryOperations>
      ingredientNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ingredientName');
    });
  }

  QueryBuilder<MyMealIngredient, int, QQueryOperations> myMealIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'myMealId');
    });
  }

  QueryBuilder<MyMealIngredient, double, QQueryOperations> proteinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'protein');
    });
  }

  QueryBuilder<MyMealIngredient, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<MyMealIngredient, String, QQueryOperations> unitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unit');
    });
  }
}
