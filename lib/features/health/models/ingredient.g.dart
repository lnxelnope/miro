// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIngredientCollection on Isar {
  IsarCollection<Ingredient> get ingredients => this.collection();
}

const IngredientSchema = CollectionSchema(
  name: r'Ingredient',
  id: 800151778681338436,
  properties: {
    r'baseAmount': PropertySchema(
      id: 0,
      name: r'baseAmount',
      type: IsarType.double,
    ),
    r'baseUnit': PropertySchema(
      id: 1,
      name: r'baseUnit',
      type: IsarType.string,
    ),
    r'caloriesPerBase': PropertySchema(
      id: 2,
      name: r'caloriesPerBase',
      type: IsarType.double,
    ),
    r'carbsPerBase': PropertySchema(
      id: 3,
      name: r'carbsPerBase',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'fatPerBase': PropertySchema(
      id: 5,
      name: r'fatPerBase',
      type: IsarType.double,
    ),
    r'fiberPerBase': PropertySchema(
      id: 6,
      name: r'fiberPerBase',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 7,
      name: r'name',
      type: IsarType.string,
    ),
    r'nameEn': PropertySchema(
      id: 8,
      name: r'nameEn',
      type: IsarType.string,
    ),
    r'proteinPerBase': PropertySchema(
      id: 9,
      name: r'proteinPerBase',
      type: IsarType.double,
    ),
    r'sodiumPerBase': PropertySchema(
      id: 10,
      name: r'sodiumPerBase',
      type: IsarType.double,
    ),
    r'source': PropertySchema(
      id: 11,
      name: r'source',
      type: IsarType.string,
    ),
    r'sugarPerBase': PropertySchema(
      id: 12,
      name: r'sugarPerBase',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 13,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'usageCount': PropertySchema(
      id: 14,
      name: r'usageCount',
      type: IsarType.long,
    )
  },
  estimateSize: _ingredientEstimateSize,
  serialize: _ingredientSerialize,
  deserialize: _ingredientDeserialize,
  deserializeProp: _ingredientDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _ingredientGetId,
  getLinks: _ingredientGetLinks,
  attach: _ingredientAttach,
  version: '3.1.0+1',
);

int _ingredientEstimateSize(
  Ingredient object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.baseUnit.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.nameEn;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.source.length * 3;
  return bytesCount;
}

void _ingredientSerialize(
  Ingredient object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.baseAmount);
  writer.writeString(offsets[1], object.baseUnit);
  writer.writeDouble(offsets[2], object.caloriesPerBase);
  writer.writeDouble(offsets[3], object.carbsPerBase);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeDouble(offsets[5], object.fatPerBase);
  writer.writeDouble(offsets[6], object.fiberPerBase);
  writer.writeString(offsets[7], object.name);
  writer.writeString(offsets[8], object.nameEn);
  writer.writeDouble(offsets[9], object.proteinPerBase);
  writer.writeDouble(offsets[10], object.sodiumPerBase);
  writer.writeString(offsets[11], object.source);
  writer.writeDouble(offsets[12], object.sugarPerBase);
  writer.writeDateTime(offsets[13], object.updatedAt);
  writer.writeLong(offsets[14], object.usageCount);
}

Ingredient _ingredientDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Ingredient();
  object.baseAmount = reader.readDouble(offsets[0]);
  object.baseUnit = reader.readString(offsets[1]);
  object.caloriesPerBase = reader.readDouble(offsets[2]);
  object.carbsPerBase = reader.readDouble(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.fatPerBase = reader.readDouble(offsets[5]);
  object.fiberPerBase = reader.readDoubleOrNull(offsets[6]);
  object.id = id;
  object.name = reader.readString(offsets[7]);
  object.nameEn = reader.readStringOrNull(offsets[8]);
  object.proteinPerBase = reader.readDouble(offsets[9]);
  object.sodiumPerBase = reader.readDoubleOrNull(offsets[10]);
  object.source = reader.readString(offsets[11]);
  object.sugarPerBase = reader.readDoubleOrNull(offsets[12]);
  object.updatedAt = reader.readDateTime(offsets[13]);
  object.usageCount = reader.readLong(offsets[14]);
  return object;
}

P _ingredientDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDoubleOrNull(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ingredientGetId(Ingredient object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _ingredientGetLinks(Ingredient object) {
  return [];
}

void _ingredientAttach(IsarCollection<dynamic> col, Id id, Ingredient object) {
  object.id = id;
}

extension IngredientQueryWhereSort
    on QueryBuilder<Ingredient, Ingredient, QWhere> {
  QueryBuilder<Ingredient, Ingredient, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IngredientQueryWhere
    on QueryBuilder<Ingredient, Ingredient, QWhereClause> {
  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> idBetween(
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

extension IngredientQueryFilter
    on QueryBuilder<Ingredient, Ingredient, QFilterCondition> {
  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> baseAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      baseAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      baseAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> baseAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> baseUnitEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      baseUnitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> baseUnitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> baseUnitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      baseUnitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'baseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> baseUnitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'baseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> baseUnitContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'baseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> baseUnitMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'baseUnit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      baseUnitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseUnit',
        value: '',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      baseUnitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'baseUnit',
        value: '',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      caloriesPerBaseEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'caloriesPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      caloriesPerBaseGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'caloriesPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      caloriesPerBaseLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'caloriesPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      caloriesPerBaseBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'caloriesPerBase',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      carbsPerBaseEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carbsPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      carbsPerBaseGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carbsPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      carbsPerBaseLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carbsPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      carbsPerBaseBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carbsPerBase',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> fatPerBaseEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      fatPerBaseGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      fatPerBaseLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> fatPerBaseBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatPerBase',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      fiberPerBaseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fiberPerBase',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      fiberPerBaseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fiberPerBase',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      fiberPerBaseEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fiberPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      fiberPerBaseGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fiberPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      fiberPerBaseLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fiberPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      fiberPerBaseBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fiberPerBase',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameEnIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nameEn',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      nameEnIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nameEn',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameEnEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameEnGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameEnLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameEnBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nameEn',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameEnStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameEnEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameEnContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameEnMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nameEn',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameEnIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameEn',
        value: '',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      nameEnIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nameEn',
        value: '',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      proteinPerBaseEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proteinPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      proteinPerBaseGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proteinPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      proteinPerBaseLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proteinPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      proteinPerBaseBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proteinPerBase',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      sodiumPerBaseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sodiumPerBase',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      sodiumPerBaseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sodiumPerBase',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      sodiumPerBaseEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sodiumPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      sodiumPerBaseGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sodiumPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      sodiumPerBaseLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sodiumPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      sodiumPerBaseBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sodiumPerBase',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> sourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> sourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> sourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> sourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> sourceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> sourceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      sugarPerBaseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sugarPerBase',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      sugarPerBaseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sugarPerBase',
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      sugarPerBaseEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sugarPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      sugarPerBaseGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sugarPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      sugarPerBaseLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sugarPerBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      sugarPerBaseBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sugarPerBase',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> usageCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      usageCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
      usageCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> usageCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usageCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IngredientQueryObject
    on QueryBuilder<Ingredient, Ingredient, QFilterCondition> {}

extension IngredientQueryLinks
    on QueryBuilder<Ingredient, Ingredient, QFilterCondition> {}

extension IngredientQuerySortBy
    on QueryBuilder<Ingredient, Ingredient, QSortBy> {
  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByBaseAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseAmount', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByBaseAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseAmount', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByBaseUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUnit', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByBaseUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUnit', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByCaloriesPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesPerBase', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
      sortByCaloriesPerBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesPerBase', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByCarbsPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsPerBase', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByCarbsPerBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsPerBase', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByFatPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPerBase', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByFatPerBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPerBase', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByFiberPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberPerBase', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByFiberPerBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberPerBase', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByNameEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByNameEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByProteinPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPerBase', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
      sortByProteinPerBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPerBase', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortBySodiumPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumPerBase', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortBySodiumPerBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumPerBase', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortBySugarPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarPerBase', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortBySugarPerBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarPerBase', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByUsageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usageCount', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByUsageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usageCount', Sort.desc);
    });
  }
}

extension IngredientQuerySortThenBy
    on QueryBuilder<Ingredient, Ingredient, QSortThenBy> {
  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByBaseAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseAmount', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByBaseAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseAmount', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByBaseUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUnit', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByBaseUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUnit', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByCaloriesPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesPerBase', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
      thenByCaloriesPerBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesPerBase', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByCarbsPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsPerBase', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByCarbsPerBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsPerBase', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByFatPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPerBase', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByFatPerBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPerBase', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByFiberPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberPerBase', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByFiberPerBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberPerBase', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByNameEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByNameEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByProteinPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPerBase', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
      thenByProteinPerBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPerBase', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenBySodiumPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumPerBase', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenBySodiumPerBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumPerBase', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenBySugarPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarPerBase', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenBySugarPerBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarPerBase', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByUsageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usageCount', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByUsageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usageCount', Sort.desc);
    });
  }
}

extension IngredientQueryWhereDistinct
    on QueryBuilder<Ingredient, Ingredient, QDistinct> {
  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByBaseAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseAmount');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByBaseUnit(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseUnit', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByCaloriesPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caloriesPerBase');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByCarbsPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbsPerBase');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByFatPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatPerBase');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByFiberPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fiberPerBase');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByNameEn(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameEn', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByProteinPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteinPerBase');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctBySodiumPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sodiumPerBase');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctBySugarPerBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sugarPerBase');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByUsageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usageCount');
    });
  }
}

extension IngredientQueryProperty
    on QueryBuilder<Ingredient, Ingredient, QQueryProperty> {
  QueryBuilder<Ingredient, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Ingredient, double, QQueryOperations> baseAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseAmount');
    });
  }

  QueryBuilder<Ingredient, String, QQueryOperations> baseUnitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseUnit');
    });
  }

  QueryBuilder<Ingredient, double, QQueryOperations> caloriesPerBaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caloriesPerBase');
    });
  }

  QueryBuilder<Ingredient, double, QQueryOperations> carbsPerBaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbsPerBase');
    });
  }

  QueryBuilder<Ingredient, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Ingredient, double, QQueryOperations> fatPerBaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatPerBase');
    });
  }

  QueryBuilder<Ingredient, double?, QQueryOperations> fiberPerBaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fiberPerBase');
    });
  }

  QueryBuilder<Ingredient, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Ingredient, String?, QQueryOperations> nameEnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameEn');
    });
  }

  QueryBuilder<Ingredient, double, QQueryOperations> proteinPerBaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteinPerBase');
    });
  }

  QueryBuilder<Ingredient, double?, QQueryOperations> sodiumPerBaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sodiumPerBase');
    });
  }

  QueryBuilder<Ingredient, String, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<Ingredient, double?, QQueryOperations> sugarPerBaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sugarPerBase');
    });
  }

  QueryBuilder<Ingredient, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<Ingredient, int, QQueryOperations> usageCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usageCount');
    });
  }
}
