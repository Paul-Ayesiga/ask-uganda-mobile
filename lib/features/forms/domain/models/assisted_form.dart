import 'package:flutter/foundation.dart';

enum FormFieldKind { text, number, date, choice, multiline, identityLinked }

@immutable
class AssistedFormField {
  const AssistedFormField({
    required this.id,
    required this.label,
    required this.explanation,
    required this.kind,
    this.example,
    this.canPrefillViaGuva = false,
    this.required = true,
    this.choices = const [],
  });

  final String id;
  final String label;
  final String explanation;
  final FormFieldKind kind;
  final String? example;
  final bool canPrefillViaGuva;
  final bool required;
  final List<String> choices;
}

@immutable
class AssistedForm {
  const AssistedForm({
    required this.id,
    required this.name,
    required this.responsibleAgency,
    required this.summary,
    required this.fields,
  });

  final String id;
  final String name;
  final String responsibleAgency;
  final String summary;
  final List<AssistedFormField> fields;
}

abstract final class AssistedFormsCatalogue {
  static const birthCertificate = AssistedForm(
    id: 'birth-certificate',
    name: 'Birth Certificate application',
    responsibleAgency: 'NIRA',
    summary:
        'A guided walkthrough of the long-form birth certificate application. '
        'Some fields can be confirmed against NIRA with your consent.',
    fields: [
      AssistedFormField(
        id: 'child-name',
        label: 'Child’s full name',
        explanation:
            'Enter the child’s legal name exactly as it appears on the '
            'Notification of Birth. Including all middle names avoids '
            'mismatches at collection.',
        kind: FormFieldKind.text,
        example: 'Akello Mariam Namatovu',
      ),
      AssistedFormField(
        id: 'date-of-birth',
        label: 'Date of birth',
        explanation:
            'Enter the date of birth as recorded on the Notification of Birth.',
        kind: FormFieldKind.date,
        example: '2026-02-14',
      ),
      AssistedFormField(
        id: 'place-of-birth',
        label: 'Place of birth',
        explanation:
            'The hospital, clinic, or community where the birth took place.',
        kind: FormFieldKind.text,
        example: 'Mulago Hospital, Kampala',
      ),
      AssistedFormField(
        id: 'mother-id',
        label: 'Mother’s National ID',
        explanation:
            'Your National ID number. With your consent, Ask Uganda can '
            'confirm this against the National Register through GUVA.',
        kind: FormFieldKind.identityLinked,
        canPrefillViaGuva: true,
      ),
      AssistedFormField(
        id: 'father-id',
        label: 'Father’s National ID',
        explanation:
            'The father’s National ID number, if available. May be optional '
            'depending on circumstances.',
        kind: FormFieldKind.identityLinked,
        canPrefillViaGuva: true,
        required: false,
      ),
      AssistedFormField(
        id: 'declarant-relationship',
        label: 'Declarant relationship',
        explanation:
            'Your relationship to the child if you are not the parent.',
        kind: FormFieldKind.choice,
        choices: ['Mother', 'Father', 'Guardian', 'Other'],
      ),
      AssistedFormField(
        id: 'additional-notes',
        label: 'Additional notes (optional)',
        explanation:
            'Anything the registrar should know that is not covered above.',
        kind: FormFieldKind.multiline,
        required: false,
      ),
    ],
  );
}
