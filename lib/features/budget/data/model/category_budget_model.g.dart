// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_budget_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCategoryBudgetModelCollection on Isar {
  IsarCollection<CategoryBudgetModel> get categoryBudgetModels =>
      this.collection();
}

const CategoryBudgetModelSchema = CollectionSchema(
  name: r'CategoryBudgetModel',
  id: 6463758381500692580,
  properties: {
    r'categoryBudgetId': PropertySchema(
      id: 0,
      name: r'categoryBudgetId',
      type: IsarType.long,
    ),
    r'categoryId': PropertySchema(
      id: 1,
      name: r'categoryId',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'endDate': PropertySchema(
      id: 3,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'isActive': PropertySchema(
      id: 4,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isDeleted': PropertySchema(
      id: 5,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 6,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'lastSyncError': PropertySchema(
      id: 7,
      name: r'lastSyncError',
      type: IsarType.dateTime,
    ),
    r'localId': PropertySchema(
      id: 8,
      name: r'localId',
      type: IsarType.string,
    ),
    r'moneyLimit': PropertySchema(
      id: 9,
      name: r'moneyLimit',
      type: IsarType.double,
    ),
    r'percentageLimit': PropertySchema(
      id: 10,
      name: r'percentageLimit',
      type: IsarType.double,
    ),
    r'percentageProgress': PropertySchema(
      id: 11,
      name: r'percentageProgress',
      type: IsarType.double,
    ),
    r'serverId': PropertySchema(
      id: 12,
      name: r'serverId',
      type: IsarType.long,
    ),
    r'spendingProgress': PropertySchema(
      id: 13,
      name: r'spendingProgress',
      type: IsarType.double,
    ),
    r'startDate': PropertySchema(
      id: 14,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'syncAttempts': PropertySchema(
      id: 15,
      name: r'syncAttempts',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 16,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 17,
      name: r'userId',
      type: IsarType.long,
    )
  },
  estimateSize: _categoryBudgetModelEstimateSize,
  serialize: _categoryBudgetModelSerialize,
  deserialize: _categoryBudgetModelDeserialize,
  deserializeProp: _categoryBudgetModelDeserializeProp,
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
    r'categoryBudgetId': IndexSchema(
      id: -380524984054758069,
      name: r'categoryBudgetId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'categoryBudgetId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'categoryId': IndexSchema(
      id: -8798048739239305339,
      name: r'categoryId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'categoryId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _categoryBudgetModelGetId,
  getLinks: _categoryBudgetModelGetLinks,
  attach: _categoryBudgetModelAttach,
  version: '3.1.0+1',
);

int _categoryBudgetModelEstimateSize(
  CategoryBudgetModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.localId.length * 3;
  return bytesCount;
}

void _categoryBudgetModelSerialize(
  CategoryBudgetModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.categoryBudgetId);
  writer.writeLong(offsets[1], object.categoryId);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeDateTime(offsets[3], object.endDate);
  writer.writeBool(offsets[4], object.isActive);
  writer.writeBool(offsets[5], object.isDeleted);
  writer.writeBool(offsets[6], object.isSynced);
  writer.writeDateTime(offsets[7], object.lastSyncError);
  writer.writeString(offsets[8], object.localId);
  writer.writeDouble(offsets[9], object.moneyLimit);
  writer.writeDouble(offsets[10], object.percentageLimit);
  writer.writeDouble(offsets[11], object.percentageProgress);
  writer.writeLong(offsets[12], object.serverId);
  writer.writeDouble(offsets[13], object.spendingProgress);
  writer.writeDateTime(offsets[14], object.startDate);
  writer.writeLong(offsets[15], object.syncAttempts);
  writer.writeDateTime(offsets[16], object.updatedAt);
  writer.writeLong(offsets[17], object.userId);
}

CategoryBudgetModel _categoryBudgetModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CategoryBudgetModel(
    categoryBudgetId: reader.readLongOrNull(offsets[0]),
    categoryId: reader.readLong(offsets[1]),
    createdAt: reader.readDateTimeOrNull(offsets[2]),
    endDate: reader.readDateTime(offsets[3]),
    isActive: reader.readBoolOrNull(offsets[4]) ?? true,
    isDeleted: reader.readBoolOrNull(offsets[5]) ?? false,
    isSynced: reader.readBoolOrNull(offsets[6]) ?? false,
    lastSyncError: reader.readDateTimeOrNull(offsets[7]),
    localId: reader.readString(offsets[8]),
    moneyLimit: reader.readDouble(offsets[9]),
    percentageLimit: reader.readDouble(offsets[10]),
    percentageProgress: reader.readDoubleOrNull(offsets[11]) ?? 0,
    spendingProgress: reader.readDouble(offsets[13]),
    startDate: reader.readDateTime(offsets[14]),
    syncAttempts: reader.readLongOrNull(offsets[15]) ?? 0,
    updatedAt: reader.readDateTimeOrNull(offsets[16]),
    userId: reader.readLong(offsets[17]),
  );
  object.isarId = id;
  return object;
}

P _categoryBudgetModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readDoubleOrNull(offset) ?? 0) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 16:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _categoryBudgetModelGetId(CategoryBudgetModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _categoryBudgetModelGetLinks(
    CategoryBudgetModel object) {
  return [];
}

void _categoryBudgetModelAttach(
    IsarCollection<dynamic> col, Id id, CategoryBudgetModel object) {
  object.isarId = id;
}

extension CategoryBudgetModelByIndex on IsarCollection<CategoryBudgetModel> {
  Future<CategoryBudgetModel?> getByLocalId(String localId) {
    return getByIndex(r'localId', [localId]);
  }

  CategoryBudgetModel? getByLocalIdSync(String localId) {
    return getByIndexSync(r'localId', [localId]);
  }

  Future<bool> deleteByLocalId(String localId) {
    return deleteByIndex(r'localId', [localId]);
  }

  bool deleteByLocalIdSync(String localId) {
    return deleteByIndexSync(r'localId', [localId]);
  }

  Future<List<CategoryBudgetModel?>> getAllByLocalId(
      List<String> localIdValues) {
    final values = localIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'localId', values);
  }

  List<CategoryBudgetModel?> getAllByLocalIdSync(List<String> localIdValues) {
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

  Future<Id> putByLocalId(CategoryBudgetModel object) {
    return putByIndex(r'localId', object);
  }

  Id putByLocalIdSync(CategoryBudgetModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'localId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLocalId(List<CategoryBudgetModel> objects) {
    return putAllByIndex(r'localId', objects);
  }

  List<Id> putAllByLocalIdSync(List<CategoryBudgetModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'localId', objects, saveLinks: saveLinks);
  }
}

extension CategoryBudgetModelQueryWhereSort
    on QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QWhere> {
  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhere>
      anyCategoryBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'categoryBudgetId'),
      );
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhere>
      anyCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'categoryId'),
      );
    });
  }
}

extension CategoryBudgetModelQueryWhere
    on QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QWhereClause> {
  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      localIdEqualTo(String localId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'localId',
        value: [localId],
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      localIdNotEqualTo(String localId) {
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      categoryBudgetIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'categoryBudgetId',
        value: [null],
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      categoryBudgetIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'categoryBudgetId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      categoryBudgetIdEqualTo(int? categoryBudgetId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'categoryBudgetId',
        value: [categoryBudgetId],
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      categoryBudgetIdNotEqualTo(int? categoryBudgetId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryBudgetId',
              lower: [],
              upper: [categoryBudgetId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryBudgetId',
              lower: [categoryBudgetId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryBudgetId',
              lower: [categoryBudgetId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryBudgetId',
              lower: [],
              upper: [categoryBudgetId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      categoryBudgetIdGreaterThan(
    int? categoryBudgetId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'categoryBudgetId',
        lower: [categoryBudgetId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      categoryBudgetIdLessThan(
    int? categoryBudgetId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'categoryBudgetId',
        lower: [],
        upper: [categoryBudgetId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      categoryBudgetIdBetween(
    int? lowerCategoryBudgetId,
    int? upperCategoryBudgetId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'categoryBudgetId',
        lower: [lowerCategoryBudgetId],
        includeLower: includeLower,
        upper: [upperCategoryBudgetId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      categoryIdEqualTo(int categoryId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'categoryId',
        value: [categoryId],
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      categoryIdNotEqualTo(int categoryId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryId',
              lower: [],
              upper: [categoryId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryId',
              lower: [categoryId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryId',
              lower: [categoryId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryId',
              lower: [],
              upper: [categoryId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      categoryIdGreaterThan(
    int categoryId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'categoryId',
        lower: [categoryId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      categoryIdLessThan(
    int categoryId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'categoryId',
        lower: [],
        upper: [categoryId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterWhereClause>
      categoryIdBetween(
    int lowerCategoryId,
    int upperCategoryId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'categoryId',
        lower: [lowerCategoryId],
        includeLower: includeLower,
        upper: [upperCategoryId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CategoryBudgetModelQueryFilter on QueryBuilder<CategoryBudgetModel,
    CategoryBudgetModel, QFilterCondition> {
  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      categoryBudgetIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'categoryBudgetId',
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      categoryBudgetIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'categoryBudgetId',
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      categoryBudgetIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryBudgetId',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      categoryBudgetIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryBudgetId',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      categoryBudgetIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryBudgetId',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      categoryBudgetIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryBudgetId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      categoryIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      categoryIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      categoryIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      categoryIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      endDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      endDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      endDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      endDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      lastSyncErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncError',
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      lastSyncErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncError',
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      lastSyncErrorEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncError',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      localIdEqualTo(
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      localIdLessThan(
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      localIdBetween(
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      localIdEndsWith(
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      localIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      localIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      localIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localId',
        value: '',
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      localIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localId',
        value: '',
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      moneyLimitEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moneyLimit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      moneyLimitGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'moneyLimit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      moneyLimitLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'moneyLimit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      moneyLimitBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'moneyLimit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      percentageLimitEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'percentageLimit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      percentageLimitGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'percentageLimit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      percentageLimitLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'percentageLimit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      percentageLimitBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'percentageLimit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      percentageProgressEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'percentageProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      percentageProgressGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'percentageProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      percentageProgressLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'percentageProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      percentageProgressBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'percentageProgress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      serverIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      serverIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      spendingProgressEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spendingProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      spendingProgressGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'spendingProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      spendingProgressLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'spendingProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      spendingProgressBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'spendingProgress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      startDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      startDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      startDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      startDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      syncAttemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
      userIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterFilterCondition>
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
}

extension CategoryBudgetModelQueryObject on QueryBuilder<CategoryBudgetModel,
    CategoryBudgetModel, QFilterCondition> {}

extension CategoryBudgetModelQueryLinks on QueryBuilder<CategoryBudgetModel,
    CategoryBudgetModel, QFilterCondition> {}

extension CategoryBudgetModelQuerySortBy
    on QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QSortBy> {
  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByCategoryBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryBudgetId', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByCategoryBudgetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryBudgetId', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByLastSyncError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByLastSyncErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByMoneyLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneyLimit', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByMoneyLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneyLimit', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByPercentageLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentageLimit', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByPercentageLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentageLimit', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByPercentageProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentageProgress', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByPercentageProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentageProgress', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortBySpendingProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spendingProgress', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortBySpendingProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spendingProgress', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortBySyncAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncAttempts', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortBySyncAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncAttempts', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension CategoryBudgetModelQuerySortThenBy
    on QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QSortThenBy> {
  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByCategoryBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryBudgetId', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByCategoryBudgetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryBudgetId', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByLastSyncError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByLastSyncErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByMoneyLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneyLimit', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByMoneyLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneyLimit', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByPercentageLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentageLimit', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByPercentageLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentageLimit', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByPercentageProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentageProgress', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByPercentageProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentageProgress', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenBySpendingProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spendingProgress', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenBySpendingProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spendingProgress', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenBySyncAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncAttempts', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenBySyncAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncAttempts', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension CategoryBudgetModelQueryWhereDistinct
    on QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct> {
  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByCategoryBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryBudgetId');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByLastSyncError() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncError');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByLocalId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByMoneyLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moneyLimit');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByPercentageLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'percentageLimit');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByPercentageProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'percentageProgress');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctBySpendingProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spendingProgress');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctBySyncAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncAttempts');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QDistinct>
      distinctByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId');
    });
  }
}

extension CategoryBudgetModelQueryProperty
    on QueryBuilder<CategoryBudgetModel, CategoryBudgetModel, QQueryProperty> {
  QueryBuilder<CategoryBudgetModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<CategoryBudgetModel, int?, QQueryOperations>
      categoryBudgetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryBudgetId');
    });
  }

  QueryBuilder<CategoryBudgetModel, int, QQueryOperations>
      categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<CategoryBudgetModel, DateTime?, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CategoryBudgetModel, DateTime, QQueryOperations>
      endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<CategoryBudgetModel, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<CategoryBudgetModel, bool, QQueryOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<CategoryBudgetModel, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<CategoryBudgetModel, DateTime?, QQueryOperations>
      lastSyncErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncError');
    });
  }

  QueryBuilder<CategoryBudgetModel, String, QQueryOperations>
      localIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localId');
    });
  }

  QueryBuilder<CategoryBudgetModel, double, QQueryOperations>
      moneyLimitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moneyLimit');
    });
  }

  QueryBuilder<CategoryBudgetModel, double, QQueryOperations>
      percentageLimitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'percentageLimit');
    });
  }

  QueryBuilder<CategoryBudgetModel, double, QQueryOperations>
      percentageProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'percentageProgress');
    });
  }

  QueryBuilder<CategoryBudgetModel, int?, QQueryOperations> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<CategoryBudgetModel, double, QQueryOperations>
      spendingProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spendingProgress');
    });
  }

  QueryBuilder<CategoryBudgetModel, DateTime, QQueryOperations>
      startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<CategoryBudgetModel, int, QQueryOperations>
      syncAttemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncAttempts');
    });
  }

  QueryBuilder<CategoryBudgetModel, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<CategoryBudgetModel, int, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
