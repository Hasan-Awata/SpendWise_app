// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWalletModelCollection on Isar {
  IsarCollection<WalletModel> get walletModels => this.collection();
}

const WalletModelSchema = CollectionSchema(
  name: r'WalletModel',
  id: -4870835005747997710,
  properties: {
    r'balance': PropertySchema(
      id: 0,
      name: r'balance',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currencyId': PropertySchema(
      id: 2,
      name: r'currencyId',
      type: IsarType.long,
    ),
    r'isDeleted': PropertySchema(
      id: 3,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isSaved': PropertySchema(
      id: 4,
      name: r'isSaved',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 5,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'lastSyncError': PropertySchema(
      id: 6,
      name: r'lastSyncError',
      type: IsarType.dateTime,
    ),
    r'localId': PropertySchema(
      id: 7,
      name: r'localId',
      type: IsarType.string,
    ),
    r'serverId': PropertySchema(
      id: 8,
      name: r'serverId',
      type: IsarType.long,
    ),
    r'syncAttempts': PropertySchema(
      id: 9,
      name: r'syncAttempts',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 11,
      name: r'userId',
      type: IsarType.long,
    ),
    r'walletId': PropertySchema(
      id: 12,
      name: r'walletId',
      type: IsarType.long,
    )
  },
  estimateSize: _walletModelEstimateSize,
  serialize: _walletModelSerialize,
  deserialize: _walletModelDeserialize,
  deserializeProp: _walletModelDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'localId': IndexSchema(
      id: 1199848425898359622,
      name: r'localId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'localId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'walletId': IndexSchema(
      id: -1783113319798776304,
      name: r'walletId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'walletId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _walletModelGetId,
  getLinks: _walletModelGetLinks,
  attach: _walletModelAttach,
  version: '3.1.0+1',
);

int _walletModelEstimateSize(
  WalletModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.localId.length * 3;
  return bytesCount;
}

void _walletModelSerialize(
  WalletModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.balance);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.currencyId);
  writer.writeBool(offsets[3], object.isDeleted);
  writer.writeBool(offsets[4], object.isSaved);
  writer.writeBool(offsets[5], object.isSynced);
  writer.writeDateTime(offsets[6], object.lastSyncError);
  writer.writeString(offsets[7], object.localId);
  writer.writeLong(offsets[8], object.serverId);
  writer.writeLong(offsets[9], object.syncAttempts);
  writer.writeDateTime(offsets[10], object.updatedAt);
  writer.writeLong(offsets[11], object.userId);
  writer.writeLong(offsets[12], object.walletId);
}

WalletModel _walletModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WalletModel(
    balance: reader.readDouble(offsets[0]),
    createdAt: reader.readDateTimeOrNull(offsets[1]),
    currencyId: reader.readLong(offsets[2]),
    isDeleted: reader.readBoolOrNull(offsets[3]) ?? false,
    isSaved: reader.readBoolOrNull(offsets[4]) ?? false,
    isSynced: reader.readBoolOrNull(offsets[5]) ?? false,
    lastSyncError: reader.readDateTimeOrNull(offsets[6]),
    localId: reader.readString(offsets[7]),
    syncAttempts: reader.readLongOrNull(offsets[9]) ?? 0,
    updatedAt: reader.readDateTimeOrNull(offsets[10]),
    userId: reader.readLong(offsets[11]),
    walletId: reader.readLongOrNull(offsets[12]),
  );
  object.isarId = id;
  return object;
}

P _walletModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _walletModelGetId(WalletModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _walletModelGetLinks(WalletModel object) {
  return [];
}

void _walletModelAttach(
    IsarCollection<dynamic> col, Id id, WalletModel object) {
  object.isarId = id;
}

extension WalletModelByIndex on IsarCollection<WalletModel> {
  Future<WalletModel?> getByLocalId(String localId) {
    return getByIndex(r'localId', [localId]);
  }

  WalletModel? getByLocalIdSync(String localId) {
    return getByIndexSync(r'localId', [localId]);
  }

  Future<bool> deleteByLocalId(String localId) {
    return deleteByIndex(r'localId', [localId]);
  }

  bool deleteByLocalIdSync(String localId) {
    return deleteByIndexSync(r'localId', [localId]);
  }

  Future<List<WalletModel?>> getAllByLocalId(List<String> localIdValues) {
    final values = localIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'localId', values);
  }

  List<WalletModel?> getAllByLocalIdSync(List<String> localIdValues) {
    final values = localIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'localId', values);
  }

  Future<int> deleteAllByLocalId(List<String> localIdValues) {
    final values = localIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'localId', values);
  }

  int deleteAllByLocalIdSync(List<String> localIdValues) {
    final values = localIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'localId', values);
  }

  Future<Id> putByLocalId(WalletModel object) {
    return putByIndex(r'localId', object);
  }

  Id putByLocalIdSync(WalletModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'localId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLocalId(List<WalletModel> objects) {
    return putAllByIndex(r'localId', objects);
  }

  List<Id> putAllByLocalIdSync(List<WalletModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'localId', objects, saveLinks: saveLinks);
  }
}

extension WalletModelQueryWhereSort
    on QueryBuilder<WalletModel, WalletModel, QWhere> {
  QueryBuilder<WalletModel, WalletModel, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterWhere> anyWalletId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'walletId'),
      );
    });
  }
}

extension WalletModelQueryWhere
    on QueryBuilder<WalletModel, WalletModel, QWhereClause> {
  QueryBuilder<WalletModel, WalletModel, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
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

  QueryBuilder<WalletModel, WalletModel, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<WalletModel, WalletModel, QAfterWhereClause> localIdEqualTo(
      String localId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'localId',
        value: [localId],
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterWhereClause> localIdNotEqualTo(
      String localId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localId',
              lower: [],
              upper: [localId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localId',
              lower: [localId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localId',
              lower: [localId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localId',
              lower: [],
              upper: [localId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterWhereClause> walletIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'walletId',
        value: [null],
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterWhereClause>
      walletIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'walletId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterWhereClause> walletIdEqualTo(
      int? walletId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'walletId',
        value: [walletId],
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterWhereClause> walletIdNotEqualTo(
      int? walletId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'walletId',
              lower: [],
              upper: [walletId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'walletId',
              lower: [walletId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'walletId',
              lower: [walletId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'walletId',
              lower: [],
              upper: [walletId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterWhereClause> walletIdGreaterThan(
    int? walletId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'walletId',
        lower: [walletId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterWhereClause> walletIdLessThan(
    int? walletId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'walletId',
        lower: [],
        upper: [walletId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterWhereClause> walletIdBetween(
    int? lowerWalletId,
    int? upperWalletId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'walletId',
        lower: [lowerWalletId],
        includeLower: includeLower,
        upper: [upperWalletId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WalletModelQueryFilter
    on QueryBuilder<WalletModel, WalletModel, QFilterCondition> {
  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> balanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'balance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      balanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'balance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> balanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'balance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> balanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'balance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      createdAtLessThan(
    DateTime? value, {
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      currencyIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currencyId',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      currencyIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currencyId',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      currencyIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currencyId',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      currencyIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currencyId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> isSavedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSaved',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> isSyncedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      lastSyncErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncError',
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      lastSyncErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncError',
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      lastSyncErrorEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncError',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      lastSyncErrorGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncError',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      lastSyncErrorLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncError',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      lastSyncErrorBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> localIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      localIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> localIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> localIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      localIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> localIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> localIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> localIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      localIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localId',
        value: '',
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      localIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localId',
        value: '',
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      serverIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> serverIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> serverIdBetween(
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      syncAttemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime? value, {
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> userIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> userIdLessThan(
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> userIdBetween(
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      walletIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'walletId',
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      walletIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'walletId',
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> walletIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'walletId',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      walletIdGreaterThan(
    int? value, {
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition>
      walletIdLessThan(
    int? value, {
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

  QueryBuilder<WalletModel, WalletModel, QAfterFilterCondition> walletIdBetween(
    int? lower,
    int? upper, {
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

extension WalletModelQueryObject
    on QueryBuilder<WalletModel, WalletModel, QFilterCondition> {}

extension WalletModelQueryLinks
    on QueryBuilder<WalletModel, WalletModel, QFilterCondition> {}

extension WalletModelQuerySortBy
    on QueryBuilder<WalletModel, WalletModel, QSortBy> {
  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balance', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balance', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByCurrencyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyId', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByCurrencyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyId', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByIsSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSaved', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByIsSavedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSaved', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByLastSyncError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy>
      sortByLastSyncErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortBySyncAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncAttempts', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy>
      sortBySyncAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncAttempts', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByWalletId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletId', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> sortByWalletIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletId', Sort.desc);
    });
  }
}

extension WalletModelQuerySortThenBy
    on QueryBuilder<WalletModel, WalletModel, QSortThenBy> {
  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balance', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balance', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByCurrencyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyId', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByCurrencyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyId', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByIsSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSaved', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByIsSavedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSaved', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByLastSyncError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy>
      thenByLastSyncErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenBySyncAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncAttempts', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy>
      thenBySyncAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncAttempts', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByWalletId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletId', Sort.asc);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QAfterSortBy> thenByWalletIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletId', Sort.desc);
    });
  }
}

extension WalletModelQueryWhereDistinct
    on QueryBuilder<WalletModel, WalletModel, QDistinct> {
  QueryBuilder<WalletModel, WalletModel, QDistinct> distinctByBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'balance');
    });
  }

  QueryBuilder<WalletModel, WalletModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<WalletModel, WalletModel, QDistinct> distinctByCurrencyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currencyId');
    });
  }

  QueryBuilder<WalletModel, WalletModel, QDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<WalletModel, WalletModel, QDistinct> distinctByIsSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSaved');
    });
  }

  QueryBuilder<WalletModel, WalletModel, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<WalletModel, WalletModel, QDistinct> distinctByLastSyncError() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncError');
    });
  }

  QueryBuilder<WalletModel, WalletModel, QDistinct> distinctByLocalId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WalletModel, WalletModel, QDistinct> distinctByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId');
    });
  }

  QueryBuilder<WalletModel, WalletModel, QDistinct> distinctBySyncAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncAttempts');
    });
  }

  QueryBuilder<WalletModel, WalletModel, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<WalletModel, WalletModel, QDistinct> distinctByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId');
    });
  }

  QueryBuilder<WalletModel, WalletModel, QDistinct> distinctByWalletId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'walletId');
    });
  }
}

extension WalletModelQueryProperty
    on QueryBuilder<WalletModel, WalletModel, QQueryProperty> {
  QueryBuilder<WalletModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<WalletModel, double, QQueryOperations> balanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'balance');
    });
  }

  QueryBuilder<WalletModel, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<WalletModel, int, QQueryOperations> currencyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currencyId');
    });
  }

  QueryBuilder<WalletModel, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<WalletModel, bool, QQueryOperations> isSavedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSaved');
    });
  }

  QueryBuilder<WalletModel, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<WalletModel, DateTime?, QQueryOperations>
      lastSyncErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncError');
    });
  }

  QueryBuilder<WalletModel, String, QQueryOperations> localIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localId');
    });
  }

  QueryBuilder<WalletModel, int?, QQueryOperations> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<WalletModel, int, QQueryOperations> syncAttemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncAttempts');
    });
  }

  QueryBuilder<WalletModel, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<WalletModel, int, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<WalletModel, int?, QQueryOperations> walletIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'walletId');
    });
  }
}
