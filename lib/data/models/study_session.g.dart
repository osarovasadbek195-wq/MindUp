// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStudySessionCollection on Isar {
  IsarCollection<StudySession> get studySessions => this.collection();
}

const StudySessionSchema = CollectionSchema(
  name: r'StudySession',
  id: 5950026954574551040,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'durationSeconds': PropertySchema(
      id: 1,
      name: r'durationSeconds',
      type: IsarType.long,
    ),
    r'subjectsCovered': PropertySchema(
      id: 2,
      name: r'subjectsCovered',
      type: IsarType.stringList,
    ),
    r'tasksCompleted': PropertySchema(
      id: 3,
      name: r'tasksCompleted',
      type: IsarType.long,
    )
  },
  estimateSize: _studySessionEstimateSize,
  serialize: _studySessionSerialize,
  deserialize: _studySessionDeserialize,
  deserializeProp: _studySessionDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _studySessionGetId,
  getLinks: _studySessionGetLinks,
  attach: _studySessionAttach,
  version: '3.1.0+1',
);

int _studySessionEstimateSize(
  StudySession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.subjectsCovered.length * 3;
  {
    for (var i = 0; i < object.subjectsCovered.length; i++) {
      final value = object.subjectsCovered[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _studySessionSerialize(
  StudySession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeLong(offsets[1], object.durationSeconds);
  writer.writeStringList(offsets[2], object.subjectsCovered);
  writer.writeLong(offsets[3], object.tasksCompleted);
}

StudySession _studySessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StudySession();
  object.date = reader.readDateTime(offsets[0]);
  object.durationSeconds = reader.readLong(offsets[1]);
  object.id = id;
  object.subjectsCovered = reader.readStringList(offsets[2]) ?? [];
  object.tasksCompleted = reader.readLong(offsets[3]);
  return object;
}

P _studySessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _studySessionGetId(StudySession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _studySessionGetLinks(StudySession object) {
  return [];
}

void _studySessionAttach(
    IsarCollection<dynamic> col, Id id, StudySession object) {
  object.id = id;
}

extension StudySessionQueryWhereSort
    on QueryBuilder<StudySession, StudySession, QWhere> {
  QueryBuilder<StudySession, StudySession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension StudySessionQueryWhere
    on QueryBuilder<StudySession, StudySession, QWhereClause> {
  QueryBuilder<StudySession, StudySession, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> idBetween(
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

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> dateNotEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StudySessionQueryFilter
    on QueryBuilder<StudySession, StudySession, QFilterCondition> {
  QueryBuilder<StudySession, StudySession, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      durationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      durationSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      durationSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      durationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectsCovered',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectsCovered',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectsCovered',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectsCovered',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectsCovered',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectsCovered',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectsCovered',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectsCovered',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectsCovered',
        value: '',
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectsCovered',
        value: '',
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subjectsCovered',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subjectsCovered',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subjectsCovered',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subjectsCovered',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subjectsCovered',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      subjectsCoveredLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subjectsCovered',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      tasksCompletedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tasksCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      tasksCompletedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tasksCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      tasksCompletedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tasksCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      tasksCompletedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tasksCompleted',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StudySessionQueryObject
    on QueryBuilder<StudySession, StudySession, QFilterCondition> {}

extension StudySessionQueryLinks
    on QueryBuilder<StudySession, StudySession, QFilterCondition> {}

extension StudySessionQuerySortBy
    on QueryBuilder<StudySession, StudySession, QSortBy> {
  QueryBuilder<StudySession, StudySession, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy>
      sortByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy>
      sortByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy>
      sortByTasksCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy>
      sortByTasksCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.desc);
    });
  }
}

extension StudySessionQuerySortThenBy
    on QueryBuilder<StudySession, StudySession, QSortThenBy> {
  QueryBuilder<StudySession, StudySession, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy>
      thenByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy>
      thenByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy>
      thenByTasksCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy>
      thenByTasksCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.desc);
    });
  }
}

extension StudySessionQueryWhereDistinct
    on QueryBuilder<StudySession, StudySession, QDistinct> {
  QueryBuilder<StudySession, StudySession, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<StudySession, StudySession, QDistinct>
      distinctByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationSeconds');
    });
  }

  QueryBuilder<StudySession, StudySession, QDistinct>
      distinctBySubjectsCovered() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectsCovered');
    });
  }

  QueryBuilder<StudySession, StudySession, QDistinct>
      distinctByTasksCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tasksCompleted');
    });
  }
}

extension StudySessionQueryProperty
    on QueryBuilder<StudySession, StudySession, QQueryProperty> {
  QueryBuilder<StudySession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StudySession, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<StudySession, int, QQueryOperations> durationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationSeconds');
    });
  }

  QueryBuilder<StudySession, List<String>, QQueryOperations>
      subjectsCoveredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectsCovered');
    });
  }

  QueryBuilder<StudySession, int, QQueryOperations> tasksCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tasksCompleted');
    });
  }
}
