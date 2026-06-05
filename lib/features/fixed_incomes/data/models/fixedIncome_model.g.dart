// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixedIncome_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFixedIncomeModelCollection on Isar {
  IsarCollection<FixedIncomeModel> get fixedIncomeModels => this.collection();
}

const FixedIncomeModelSchema = CollectionSchema(
  name: r'FixedIncomeModel',
  id: -3402363863986033798,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'days': PropertySchema(
      id: 1,
      name: r'days',
      type: IsarType.long,
    ),
    r'fixedIncomeId': PropertySchema(
      id: 2,
      name: r'fixedIncomeId',
      type: IsarType.long,
    ),
    r'isActive': PropertySchema(
      id: 3,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isDeleted': PropertySchema(
      id: 4,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isMonthly': PropertySchema(
      id: 5,
      name: r'isMonthly',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 6,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'lastTime': PropertySchema(
      id: 7,
      name: r'lastTime',
      type: IsarType.dateTime,
    ),
    r'nextDueDate': PropertySchema(
      id: 8,
      name: r'nextDueDate',
      type: IsarType.dateTime,
    ),
    r'serverId': PropertySchema(
      id: 9,
      name: r'serverId',
      type: IsarType.long,
    ),
    r'syncAttempts': PropertySchema(
      id: 10,
      name: r'syncAttempts',
      type: IsarType.long,
    ),
    r'tagId': PropertySchema(
      id: 11,
      name: r'tagId',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 12,
      name: r'title',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 13,
      name: r'userId',
      type: IsarType.long,
    ),
    r'walletId': PropertySchema(
      id: 14,
      name: r'walletId',
      type: IsarType.long,
    )
  },
  estimateSize: _fixedIncomeModelEstimateSize,
  serialize: _fixedIncomeModelSerialize,
  deserialize: _fixedIncomeModelDeserialize,
  deserializeProp: _fixedIncomeModelDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'fixedIncomeId': IndexSchema(
      id: 8237504515503337173,
      name: r'fixedIncomeId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'fixedIncomeId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _fixedIncomeModelGetId,
  getLinks: _fixedIncomeModelGetLinks,
  attach: _fixedIncomeModelAttach,
  version: '3.1.0+1',
);

int _fixedIncomeModelEstimateSize(
  FixedIncomeModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _fixedIncomeModelSerialize(
  FixedIncomeModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeLong(offsets[1], object.days);
  writer.writeLong(offsets[2], object.fixedIncomeId);
  writer.writeBool(offsets[3], object.isActive);
  writer.writeBool(offsets[4], object.isDeleted);
  writer.writeBool(offsets[5], object.isMonthly);
  writer.writeBool(offsets[6], object.isSynced);
  writer.writeDateTime(offsets[7], object.lastTime);
  writer.writeDateTime(offsets[8], object.nextDueDate);
  writer.writeLong(offsets[9], object.serverId);
  writer.writeLong(offsets[10], object.syncAttempts);
  writer.writeLong(offsets[11], object.tagId);
  writer.writeString(offsets[12], object.title);
  writer.writeLong(offsets[13], object.userId);
  writer.writeLong(offsets[14], object.walletId);
}

FixedIncomeModel _fixedIncomeModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FixedIncomeModel(
    amount: reader.readDouble(offsets[0]),
    days: reader.readLong(offsets[1]),
    fixedIncomeId: reader.readLongOrNull(offsets[2]) ?? -1,
    isActive: reader.readBool(offsets[3]),
    isDeleted: reader.readBoolOrNull(offsets[4]) ?? false,
    isMonthly: reader.readBool(offsets[5]),
    isSynced: reader.readBoolOrNull(offsets[6]) ?? false,
    lastTime: reader.readDateTime(offsets[7]),
    syncAttempts: reader.readLongOrNull(offsets[10]) ?? 0,
    tagId: reader.readLong(offsets[11]),
    title: reader.readString(offsets[12]),
    userId: reader.readLong(offsets[13]),
    walletId: reader.readLong(offsets[14]),
  );
  object.isarId = id;
  return object;
}

P _fixedIncomeModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? -1) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _fixedIncomeModelGetId(FixedIncomeModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _fixedIncomeModelGetLinks(FixedIncomeModel object) {
  return [];
}

void _fixedIncomeModelAttach(
    IsarCollection<dynamic> col, Id id, FixedIncomeModel object) {
  object.isarId = id;
}

extension FixedIncomeModelQueryWhereSort
    on QueryBuilder<FixedIncomeModel, FixedIncomeModel, QWhere> {
  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterWhere>
      anyFixedIncomeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'fixedIncomeId'),
      );
    });
  }
}

extension FixedIncomeModelQueryWhere
    on QueryBuilder<FixedIncomeModel, FixedIncomeModel, QWhereClause> {
  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterWhereClause>
      fixedIncomeIdEqualTo(int fixedIncomeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'fixedIncomeId',
        value: [fixedIncomeId],
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterWhereClause>
      fixedIncomeIdNotEqualTo(int fixedIncomeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fixedIncomeId',
              lower: [],
              upper: [fixedIncomeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fixedIncomeId',
              lower: [fixedIncomeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fixedIncomeId',
              lower: [fixedIncomeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fixedIncomeId',
              lower: [],
              upper: [fixedIncomeId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterWhereClause>
      fixedIncomeIdGreaterThan(
    int fixedIncomeId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'fixedIncomeId',
        lower: [fixedIncomeId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterWhereClause>
      fixedIncomeIdLessThan(
    int fixedIncomeId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'fixedIncomeId',
        lower: [],
        upper: [fixedIncomeId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterWhereClause>
      fixedIncomeIdBetween(
    int lowerFixedIncomeId,
    int upperFixedIncomeId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'fixedIncomeId',
        lower: [lowerFixedIncomeId],
        includeLower: includeLower,
        upper: [upperFixedIncomeId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FixedIncomeModelQueryFilter
    on QueryBuilder<FixedIncomeModel, FixedIncomeModel, QFilterCondition> {
  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
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

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
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

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
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

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
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

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      daysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'days',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      daysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'days',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      daysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'days',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      daysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'days',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      fixedIncomeIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fixedIncomeId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      fixedIncomeIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fixedIncomeId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      fixedIncomeIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fixedIncomeId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      fixedIncomeIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fixedIncomeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      isMonthlyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMonthly',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      lastTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      lastTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      lastTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      lastTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      nextDueDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextDueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      nextDueDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextDueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      nextDueDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextDueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      nextDueDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextDueDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      serverIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      serverIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      serverIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      serverIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      serverIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serverId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      syncAttemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      syncAttemptsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      syncAttemptsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      syncAttemptsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncAttempts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      tagIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      tagIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tagId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      tagIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tagId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      tagIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tagId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      userIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      userIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      userIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      userIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      walletIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'walletId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      walletIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'walletId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      walletIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'walletId',
        value: value,
      ));
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterFilterCondition>
      walletIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'walletId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FixedIncomeModelQueryObject
    on QueryBuilder<FixedIncomeModel, FixedIncomeModel, QFilterCondition> {}

extension FixedIncomeModelQueryLinks
    on QueryBuilder<FixedIncomeModel, FixedIncomeModel, QFilterCondition> {}

extension FixedIncomeModelQuerySortBy
    on QueryBuilder<FixedIncomeModel, FixedIncomeModel, QSortBy> {
  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy> sortByDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'days', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'days', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByFixedIncomeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedIncomeId', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByFixedIncomeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedIncomeId', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByIsMonthly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMonthly', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByIsMonthlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMonthly', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByLastTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTime', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByLastTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTime', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByNextDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortBySyncAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncAttempts', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortBySyncAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncAttempts', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy> sortByTagId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagId', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByTagIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagId', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByWalletId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletId', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      sortByWalletIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletId', Sort.desc);
    });
  }
}

extension FixedIncomeModelQuerySortThenBy
    on QueryBuilder<FixedIncomeModel, FixedIncomeModel, QSortThenBy> {
  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy> thenByDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'days', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'days', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByFixedIncomeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedIncomeId', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByFixedIncomeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedIncomeId', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByIsMonthly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMonthly', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByIsMonthlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMonthly', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByLastTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTime', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByLastTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTime', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByNextDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenBySyncAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncAttempts', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenBySyncAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncAttempts', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy> thenByTagId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagId', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByTagIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagId', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByWalletId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletId', Sort.asc);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QAfterSortBy>
      thenByWalletIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletId', Sort.desc);
    });
  }
}

extension FixedIncomeModelQueryWhereDistinct
    on QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct> {
  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct> distinctByDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'days');
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct>
      distinctByFixedIncomeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fixedIncomeId');
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct>
      distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct>
      distinctByIsMonthly() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMonthly');
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct>
      distinctByLastTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastTime');
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct>
      distinctByNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextDueDate');
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct>
      distinctByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId');
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct>
      distinctBySyncAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncAttempts');
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct>
      distinctByTagId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tagId');
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct>
      distinctByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId');
    });
  }

  QueryBuilder<FixedIncomeModel, FixedIncomeModel, QDistinct>
      distinctByWalletId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'walletId');
    });
  }
}

extension FixedIncomeModelQueryProperty
    on QueryBuilder<FixedIncomeModel, FixedIncomeModel, QQueryProperty> {
  QueryBuilder<FixedIncomeModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<FixedIncomeModel, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<FixedIncomeModel, int, QQueryOperations> daysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'days');
    });
  }

  QueryBuilder<FixedIncomeModel, int, QQueryOperations>
      fixedIncomeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fixedIncomeId');
    });
  }

  QueryBuilder<FixedIncomeModel, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<FixedIncomeModel, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<FixedIncomeModel, bool, QQueryOperations> isMonthlyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMonthly');
    });
  }

  QueryBuilder<FixedIncomeModel, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<FixedIncomeModel, DateTime, QQueryOperations>
      lastTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastTime');
    });
  }

  QueryBuilder<FixedIncomeModel, DateTime, QQueryOperations>
      nextDueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextDueDate');
    });
  }

  QueryBuilder<FixedIncomeModel, int?, QQueryOperations> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<FixedIncomeModel, int, QQueryOperations> syncAttemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncAttempts');
    });
  }

  QueryBuilder<FixedIncomeModel, int, QQueryOperations> tagIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tagId');
    });
  }

  QueryBuilder<FixedIncomeModel, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<FixedIncomeModel, int, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<FixedIncomeModel, int, QQueryOperations> walletIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'walletId');
    });
  }
}
