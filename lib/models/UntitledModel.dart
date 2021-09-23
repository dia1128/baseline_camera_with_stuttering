/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// ignore_for_file: public_member_api_docs

import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
import 'package:flutter/foundation.dart';

/** This is an auto generated class representing the UntitledModel type in your schema. */
@immutable
class UntitledModel extends Model {
  static const classType = const _UntitledModelModelType();
  final String id;
  final String untitledfield;

  @override
  getInstanceType() => classType;

  @override
  String getId() {
    return id;
  }

  const UntitledModel._internal({@required this.id, this.untitledfield});

  factory UntitledModel({String id, String untitledfield}) {
    return UntitledModel._internal(
        id: id == null ? UUID.getUUID() : id, untitledfield: untitledfield);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UntitledModel &&
        id == other.id &&
        untitledfield == other.untitledfield;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("UntitledModel {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("untitledfield=" + "$untitledfield");
    buffer.write("}");

    return buffer.toString();
  }

  UntitledModel copyWith({String id, String untitledfield}) {
    return UntitledModel(
        id: id ?? this.id, untitledfield: untitledfield ?? this.untitledfield);
  }

  UntitledModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        untitledfield = json['untitledfield'];

  Map<String, dynamic> toJson() => {'id': id, 'untitledfield': untitledfield};

  static final QueryField ID = QueryField(fieldName: "untitledModel.id");
  static final QueryField UNTITLEDFIELD =
      QueryField(fieldName: "untitledfield");
  static var schema =
      Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "UntitledModel";
    modelSchemaDefinition.pluralName = "UntitledModels";

    modelSchemaDefinition.authRules = [
      AuthRule(authStrategy: AuthStrategy.PUBLIC, operations: [
        ModelOperation.CREATE,
        ModelOperation.UPDATE,
        ModelOperation.DELETE,
        ModelOperation.READ
      ])
    ];

    modelSchemaDefinition.addField(ModelFieldDefinition.id());

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UntitledModel.UNTITLEDFIELD,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));
  });
}

class _UntitledModelModelType extends ModelType<UntitledModel> {
  const _UntitledModelModelType();

  @override
  UntitledModel fromJson(Map<String, dynamic> jsonData) {
    return UntitledModel.fromJson(jsonData);
  }
}
