// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserProfileCollection on Isar {
  IsarCollection<UserProfile> get userProfiles => this.collection();
}

const UserProfileSchema = CollectionSchema(
  name: r'UserProfile',
  id: 4738427352541298891,
  properties: {
    r'activityLevel': PropertySchema(
      id: 0,
      name: r'activityLevel',
      type: IsarType.string,
    ),
    r'age': PropertySchema(
      id: 1,
      name: r'age',
      type: IsarType.long,
    ),
    r'avatarPath': PropertySchema(
      id: 2,
      name: r'avatarPath',
      type: IsarType.string,
    ),
    r'calorieGoal': PropertySchema(
      id: 3,
      name: r'calorieGoal',
      type: IsarType.double,
    ),
    r'carbGoal': PropertySchema(
      id: 4,
      name: r'carbGoal',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'fatGoal': PropertySchema(
      id: 6,
      name: r'fatGoal',
      type: IsarType.double,
    ),
    r'gender': PropertySchema(
      id: 7,
      name: r'gender',
      type: IsarType.string,
    ),
    r'hasGeminiApiKey': PropertySchema(
      id: 8,
      name: r'hasGeminiApiKey',
      type: IsarType.bool,
    ),
    r'height': PropertySchema(
      id: 9,
      name: r'height',
      type: IsarType.double,
    ),
    r'isDarkMode': PropertySchema(
      id: 10,
      name: r'isDarkMode',
      type: IsarType.bool,
    ),
    r'isGoogleCalendarConnected': PropertySchema(
      id: 11,
      name: r'isGoogleCalendarConnected',
      type: IsarType.bool,
    ),
    r'isHealthConnectConnected': PropertySchema(
      id: 12,
      name: r'isHealthConnectConnected',
      type: IsarType.bool,
    ),
    r'locale': PropertySchema(
      id: 13,
      name: r'locale',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 14,
      name: r'name',
      type: IsarType.string,
    ),
    r'onboardingComplete': PropertySchema(
      id: 15,
      name: r'onboardingComplete',
      type: IsarType.bool,
    ),
    r'proteinGoal': PropertySchema(
      id: 16,
      name: r'proteinGoal',
      type: IsarType.double,
    ),
    r'targetWeight': PropertySchema(
      id: 17,
      name: r'targetWeight',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 18,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'waterGoal': PropertySchema(
      id: 19,
      name: r'waterGoal',
      type: IsarType.double,
    ),
    r'weight': PropertySchema(
      id: 20,
      name: r'weight',
      type: IsarType.double,
    )
  },
  estimateSize: _userProfileEstimateSize,
  serialize: _userProfileSerialize,
  deserialize: _userProfileDeserialize,
  deserializeProp: _userProfileDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userProfileGetId,
  getLinks: _userProfileGetLinks,
  attach: _userProfileAttach,
  version: '3.1.0+1',
);

int _userProfileEstimateSize(
  UserProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.activityLevel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.avatarPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.gender;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.locale;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _userProfileSerialize(
  UserProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activityLevel);
  writer.writeLong(offsets[1], object.age);
  writer.writeString(offsets[2], object.avatarPath);
  writer.writeDouble(offsets[3], object.calorieGoal);
  writer.writeDouble(offsets[4], object.carbGoal);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeDouble(offsets[6], object.fatGoal);
  writer.writeString(offsets[7], object.gender);
  writer.writeBool(offsets[8], object.hasGeminiApiKey);
  writer.writeDouble(offsets[9], object.height);
  writer.writeBool(offsets[10], object.isDarkMode);
  writer.writeBool(offsets[11], object.isGoogleCalendarConnected);
  writer.writeBool(offsets[12], object.isHealthConnectConnected);
  writer.writeString(offsets[13], object.locale);
  writer.writeString(offsets[14], object.name);
  writer.writeBool(offsets[15], object.onboardingComplete);
  writer.writeDouble(offsets[16], object.proteinGoal);
  writer.writeDouble(offsets[17], object.targetWeight);
  writer.writeDateTime(offsets[18], object.updatedAt);
  writer.writeDouble(offsets[19], object.waterGoal);
  writer.writeDouble(offsets[20], object.weight);
}

UserProfile _userProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserProfile();
  object.activityLevel = reader.readStringOrNull(offsets[0]);
  object.age = reader.readLongOrNull(offsets[1]);
  object.avatarPath = reader.readStringOrNull(offsets[2]);
  object.calorieGoal = reader.readDouble(offsets[3]);
  object.carbGoal = reader.readDouble(offsets[4]);
  object.createdAt = reader.readDateTime(offsets[5]);
  object.fatGoal = reader.readDouble(offsets[6]);
  object.gender = reader.readStringOrNull(offsets[7]);
  object.hasGeminiApiKey = reader.readBool(offsets[8]);
  object.height = reader.readDoubleOrNull(offsets[9]);
  object.id = id;
  object.isDarkMode = reader.readBool(offsets[10]);
  object.isGoogleCalendarConnected = reader.readBool(offsets[11]);
  object.isHealthConnectConnected = reader.readBool(offsets[12]);
  object.locale = reader.readStringOrNull(offsets[13]);
  object.name = reader.readStringOrNull(offsets[14]);
  object.onboardingComplete = reader.readBool(offsets[15]);
  object.proteinGoal = reader.readDouble(offsets[16]);
  object.targetWeight = reader.readDoubleOrNull(offsets[17]);
  object.updatedAt = reader.readDateTime(offsets[18]);
  object.waterGoal = reader.readDouble(offsets[19]);
  object.weight = reader.readDoubleOrNull(offsets[20]);
  return object;
}

P _userProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readDoubleOrNull(offset)) as P;
    case 18:
      return (reader.readDateTime(offset)) as P;
    case 19:
      return (reader.readDouble(offset)) as P;
    case 20:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userProfileGetId(UserProfile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userProfileGetLinks(UserProfile object) {
  return [];
}

void _userProfileAttach(
    IsarCollection<dynamic> col, Id id, UserProfile object) {
  object.id = id;
}

extension UserProfileQueryWhereSort
    on QueryBuilder<UserProfile, UserProfile, QWhere> {
  QueryBuilder<UserProfile, UserProfile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserProfileQueryWhere
    on QueryBuilder<UserProfile, UserProfile, QWhereClause> {
  QueryBuilder<UserProfile, UserProfile, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<UserProfile, UserProfile, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterWhereClause> idBetween(
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

extension UserProfileQueryFilter
    on QueryBuilder<UserProfile, UserProfile, QFilterCondition> {
  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'activityLevel',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'activityLevel',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activityLevel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activityLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> ageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'age',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> ageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'age',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> ageEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> ageGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> ageLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> ageBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'age',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      avatarPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'avatarPath',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      avatarPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'avatarPath',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      avatarPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatarPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      avatarPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avatarPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      avatarPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avatarPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      avatarPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avatarPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      avatarPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'avatarPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      avatarPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'avatarPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      avatarPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'avatarPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      avatarPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'avatarPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      avatarPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatarPath',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      avatarPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'avatarPath',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      calorieGoalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calorieGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      calorieGoalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calorieGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      calorieGoalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calorieGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      calorieGoalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calorieGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> carbGoalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carbGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      carbGoalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carbGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      carbGoalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carbGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> carbGoalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carbGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> fatGoalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      fatGoalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> fatGoalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> fatGoalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> genderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gender',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      genderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gender',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> genderEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      genderGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> genderLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> genderBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gender',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      genderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> genderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> genderContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> genderMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gender',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      genderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      genderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      hasGeminiApiKeyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasGeminiApiKey',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> heightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'height',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      heightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'height',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> heightEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      heightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> heightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> heightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'height',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      isDarkModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDarkMode',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      isGoogleCalendarConnectedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isGoogleCalendarConnected',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      isHealthConnectConnectedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isHealthConnectConnected',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> localeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'locale',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      localeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'locale',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> localeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      localeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> localeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> localeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locale',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      localeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> localeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> localeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> localeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locale',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      localeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      localeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> nameEqualTo(
    String? value, {
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> nameGreaterThan(
    String? value, {
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> nameLessThan(
    String? value, {
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> nameContains(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      onboardingCompleteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'onboardingComplete',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      proteinGoalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proteinGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      proteinGoalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proteinGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      proteinGoalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proteinGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      proteinGoalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proteinGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      targetWeightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetWeight',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      targetWeightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetWeight',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      targetWeightEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetWeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      targetWeightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetWeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      targetWeightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetWeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      targetWeightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetWeight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      updatedAtLessThan(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      updatedAtBetween(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      waterGoalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waterGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      waterGoalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'waterGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      waterGoalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'waterGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      waterGoalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'waterGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> weightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weight',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weight',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> weightEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> weightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> weightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension UserProfileQueryObject
    on QueryBuilder<UserProfile, UserProfile, QFilterCondition> {}

extension UserProfileQueryLinks
    on QueryBuilder<UserProfile, UserProfile, QFilterCondition> {}

extension UserProfileQuerySortBy
    on QueryBuilder<UserProfile, UserProfile, QSortBy> {
  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByActivityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByActivityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByAvatarPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarPath', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByAvatarPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarPath', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByCalorieGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByCalorieGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByCarbGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByCarbGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByFatGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByFatGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByHasGeminiApiKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasGeminiApiKey', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByHasGeminiApiKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasGeminiApiKey', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByIsDarkModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByIsGoogleCalendarConnected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGoogleCalendarConnected', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByIsGoogleCalendarConnectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGoogleCalendarConnected', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByIsHealthConnectConnected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHealthConnectConnected', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByIsHealthConnectConnectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHealthConnectConnected', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByOnboardingComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByOnboardingCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByProteinGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByProteinGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByTargetWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetWeight', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByTargetWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetWeight', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByWaterGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByWaterGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension UserProfileQuerySortThenBy
    on QueryBuilder<UserProfile, UserProfile, QSortThenBy> {
  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByActivityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByActivityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByAvatarPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarPath', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByAvatarPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarPath', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByCalorieGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByCalorieGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByCarbGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByCarbGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByFatGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByFatGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByHasGeminiApiKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasGeminiApiKey', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByHasGeminiApiKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasGeminiApiKey', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByIsDarkModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByIsGoogleCalendarConnected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGoogleCalendarConnected', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByIsGoogleCalendarConnectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGoogleCalendarConnected', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByIsHealthConnectConnected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHealthConnectConnected', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByIsHealthConnectConnectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHealthConnectConnected', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByOnboardingComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByOnboardingCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByProteinGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByProteinGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByTargetWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetWeight', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByTargetWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetWeight', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByWaterGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByWaterGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension UserProfileQueryWhereDistinct
    on QueryBuilder<UserProfile, UserProfile, QDistinct> {
  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByActivityLevel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityLevel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'age');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByAvatarPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avatarPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByCalorieGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calorieGoal');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByCarbGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbGoal');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByFatGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatGoal');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByGender(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gender', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
      distinctByHasGeminiApiKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasGeminiApiKey');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'height');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDarkMode');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
      distinctByIsGoogleCalendarConnected() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isGoogleCalendarConnected');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
      distinctByIsHealthConnectConnected() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isHealthConnectConnected');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByLocale(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locale', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
      distinctByOnboardingComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onboardingComplete');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByProteinGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteinGoal');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByTargetWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetWeight');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByWaterGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'waterGoal');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weight');
    });
  }
}

extension UserProfileQueryProperty
    on QueryBuilder<UserProfile, UserProfile, QQueryProperty> {
  QueryBuilder<UserProfile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserProfile, String?, QQueryOperations> activityLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityLevel');
    });
  }

  QueryBuilder<UserProfile, int?, QQueryOperations> ageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'age');
    });
  }

  QueryBuilder<UserProfile, String?, QQueryOperations> avatarPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avatarPath');
    });
  }

  QueryBuilder<UserProfile, double, QQueryOperations> calorieGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calorieGoal');
    });
  }

  QueryBuilder<UserProfile, double, QQueryOperations> carbGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbGoal');
    });
  }

  QueryBuilder<UserProfile, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<UserProfile, double, QQueryOperations> fatGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatGoal');
    });
  }

  QueryBuilder<UserProfile, String?, QQueryOperations> genderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gender');
    });
  }

  QueryBuilder<UserProfile, bool, QQueryOperations> hasGeminiApiKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasGeminiApiKey');
    });
  }

  QueryBuilder<UserProfile, double?, QQueryOperations> heightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'height');
    });
  }

  QueryBuilder<UserProfile, bool, QQueryOperations> isDarkModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDarkMode');
    });
  }

  QueryBuilder<UserProfile, bool, QQueryOperations>
      isGoogleCalendarConnectedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isGoogleCalendarConnected');
    });
  }

  QueryBuilder<UserProfile, bool, QQueryOperations>
      isHealthConnectConnectedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isHealthConnectConnected');
    });
  }

  QueryBuilder<UserProfile, String?, QQueryOperations> localeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locale');
    });
  }

  QueryBuilder<UserProfile, String?, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<UserProfile, bool, QQueryOperations>
      onboardingCompleteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onboardingComplete');
    });
  }

  QueryBuilder<UserProfile, double, QQueryOperations> proteinGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteinGoal');
    });
  }

  QueryBuilder<UserProfile, double?, QQueryOperations> targetWeightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetWeight');
    });
  }

  QueryBuilder<UserProfile, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<UserProfile, double, QQueryOperations> waterGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'waterGoal');
    });
  }

  QueryBuilder<UserProfile, double?, QQueryOperations> weightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weight');
    });
  }
}
