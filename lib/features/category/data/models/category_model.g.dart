// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCategoryModelCollection on Isar {
  IsarCollection<CategoryModel> get categoryModels => this.collection();
}

const CategoryModelSchema = CollectionSchema(
  name: r'CategoryModel',
  id: 2062173352312629051,
  properties: {
    r'categoryId': PropertySchema(
      id: 0,
      name: r'categoryId',
      type: IsarType.long,
    ),
    r'localId': PropertySchema(id: 1, name: r'localId', type: IsarType.string),
    r'name': PropertySchema(id: 2, name: r'name', type: IsarType.string),
    r'priority': PropertySchema(id: 3, name: r'priority', type: IsarType.long),
  },
  estimateSize: _categoryModelEstimateSize,
  serialize: _categoryModelSerialize,
  deserialize: _categoryModelDeserialize,
  deserializeProp: _categoryModelDeserializeProp,
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
        ),
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
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _categoryModelGetId,
  getLinks: _categoryModelGetLinks,
  attach: _categoryModelAttach,
  version: '3.1.0+1',
);

int _categoryModelEstimateSize(
  CategoryModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.localId.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _categoryModelSerialize(
  CategoryModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.categoryId);
  writer.writeString(offsets[1], object.localId);
  writer.writeString(offsets[2], object.name);
  writer.writeLong(offsets[3], object.priority);
}

CategoryModel _categoryModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CategoryModel(
    categoryId: reader.readLongOrNull(offsets[0]),
    name: reader.readString(offsets[2]),
    priority: reader.readLong(offsets[3]),
  );
  object.isarId = id;
  object.localId = reader.readString(offsets[1]);
  return object;
}

P _categoryModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _categoryModelGetId(CategoryModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _categoryModelGetLinks(CategoryModel object) {
  return [];
}

void _categoryModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  CategoryModel object,
) {
  object.isarId = id;
}

extension CategoryModelByIndex on IsarCollection<CategoryModel> {
  Future<CategoryModel?> getByLocalId(String localId) {
    return getByIndex(r'localId', [localId]);
  }

  CategoryModel? getByLocalIdSync(String localId) {
    return getByIndexSync(r'localId', [localId]);
  }

  Future<bool> deleteByLocalId(String localId) {
    return deleteByIndex(r'localId', [localId]);
  }

  bool deleteByLocalIdSync(String localId) {
    return deleteByIndexSync(r'localId', [localId]);
  }

  Future<List<CategoryModel?>> getAllByLocalId(List<String> localIdValues) {
    final values = localIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'localId', values);
  }

  List<CategoryModel?> getAllByLocalIdSync(List<String> localIdValues) {
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

  Future<Id> putByLocalId(CategoryModel object) {
    return putByIndex(r'localId', object);
  }

  Id putByLocalIdSync(CategoryModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'localId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLocalId(List<CategoryModel> objects) {
    return putAllByIndex(r'localId', objects);
  }

  List<Id> putAllByLocalIdSync(
    List<CategoryModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'localId', objects, saveLinks: saveLinks);
  }
}

extension CategoryModelQueryWhereSort
    on QueryBuilder<CategoryModel, CategoryModel, QWhere> {
  QueryBuilder<CategoryModel, CategoryModel, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterWhere> anyCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'categoryId'),
      );
    });
  }
}

extension CategoryModelQueryWhere
    on QueryBuilder<CategoryModel, CategoryModel, QWhereClause> {
  QueryBuilder<CategoryModel, CategoryModel, QAfterWhereClause> isarIdEqualTo(
    Id isarId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: isarId, upper: isarId),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterWhereClause>
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

  QueryBuilder<CategoryModel, CategoryModel, QAfterWhereClause>
  isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterWhereClause> isarIdLessThan(
    Id isarId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerIsarId,
          includeLower: includeLower,
          upper: upperIsarId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterWhereClause> localIdEqualTo(
    String localId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'localId', value: [localId]),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterWhereClause>
  localIdNotEqualTo(String localId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localId',
                lower: [],
                upper: [localId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localId',
                lower: [localId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localId',
                lower: [localId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localId',
                lower: [],
                upper: [localId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterWhereClause>
  categoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'categoryId', value: [null]),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterWhereClause>
  categoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'categoryId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterWhereClause>
  categoryIdEqualTo(int? categoryId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'categoryId', value: [categoryId]),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterWhereClause>
  categoryIdNotEqualTo(int? categoryId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId',
                lower: [],
                upper: [categoryId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId',
                lower: [categoryId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId',
                lower: [categoryId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId',
                lower: [],
                upper: [categoryId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterWhereClause>
  categoryIdGreaterThan(int? categoryId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'categoryId',
          lower: [categoryId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterWhereClause>
  categoryIdLessThan(int? categoryId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'categoryId',
          lower: [],
          upper: [categoryId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterWhereClause>
  categoryIdBetween(
    int? lowerCategoryId,
    int? upperCategoryId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'categoryId',
          lower: [lowerCategoryId],
          includeLower: includeLower,
          upper: [upperCategoryId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension CategoryModelQueryFilter
    on QueryBuilder<CategoryModel, CategoryModel, QFilterCondition> {
  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  categoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'categoryId'),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  categoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'categoryId'),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  categoryIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryId', value: value),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  categoryIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'categoryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  categoryIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'categoryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  categoryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'categoryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isarId', value: value),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  isarIdGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  isarIdLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'isarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  localIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  localIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  localIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  localIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  localIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  localIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  localIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  localIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'localId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  localIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localId', value: ''),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  localIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'localId', value: ''),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  priorityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'priority', value: value),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  priorityGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'priority',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  priorityLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'priority',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  priorityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'priority',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension CategoryModelQueryObject
    on QueryBuilder<CategoryModel, CategoryModel, QFilterCondition> {}

extension CategoryModelQueryLinks
    on QueryBuilder<CategoryModel, CategoryModel, QFilterCondition> {}

extension CategoryModelQuerySortBy
    on QueryBuilder<CategoryModel, CategoryModel, QSortBy> {
  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy>
  sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> sortByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> sortByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy>
  sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }
}

extension CategoryModelQuerySortThenBy
    on QueryBuilder<CategoryModel, CategoryModel, QSortThenBy> {
  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy>
  thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> thenByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> thenByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy>
  thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }
}

extension CategoryModelQueryWhereDistinct
    on QueryBuilder<CategoryModel, CategoryModel, QDistinct> {
  QueryBuilder<CategoryModel, CategoryModel, QDistinct> distinctByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId');
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QDistinct> distinctByLocalId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QDistinct> distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }
}

extension CategoryModelQueryProperty
    on QueryBuilder<CategoryModel, CategoryModel, QQueryProperty> {
  QueryBuilder<CategoryModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<CategoryModel, int?, QQueryOperations> categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<CategoryModel, String, QQueryOperations> localIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localId');
    });
  }

  QueryBuilder<CategoryModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<CategoryModel, int, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }
}
