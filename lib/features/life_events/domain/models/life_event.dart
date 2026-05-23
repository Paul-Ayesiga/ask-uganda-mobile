import 'package:flutter/material.dart';

@immutable
class LifeEventStep {
  const LifeEventStep({
    required this.title,
    required this.summary,
    required this.responsibleAgency,
    this.serviceId,
  });

  final String title;
  final String summary;
  final String responsibleAgency;
  final String? serviceId;
}

@immutable
class LifeEvent {
  const LifeEvent({
    required this.id,
    required this.label,
    required this.summary,
    required this.icon,
    required this.steps,
  });

  final String id;
  final String label;
  final String summary;
  final IconData icon;
  final List<LifeEventStep> steps;
}

abstract final class LifeEventsCatalogue {
  static const all = <LifeEvent>[
    LifeEvent(
      id: 'start-business',
      label: 'Start a business',
      summary:
          'The full path from a business idea to formal trading: registration, '
          'taxation, licensing and local-authority permits.',
      icon: Icons.storefront_outlined,
      steps: [
        LifeEventStep(
          title: 'Reserve a business name',
          summary: 'Reserve a unique name on the URSB portal.',
          responsibleAgency: 'URSB',
          serviceId: 'business-registration',
        ),
        LifeEventStep(
          title: 'Register the business',
          summary:
              'Choose a legal structure and complete the registration with URSB.',
          responsibleAgency: 'URSB',
          serviceId: 'business-registration',
        ),
        LifeEventStep(
          title: 'Obtain a TIN',
          summary: 'Register for a Tax Identification Number with URA.',
          responsibleAgency: 'URA',
          serviceId: 'tin-registration',
        ),
        LifeEventStep(
          title: 'Get a trading licence',
          summary: 'Apply to your local authority for the trading licence.',
          responsibleAgency: 'Local Government',
        ),
        LifeEventStep(
          title: 'Sector-specific licences',
          summary:
              'Apply for any sector-specific licences your business needs.',
          responsibleAgency: 'Sector regulator',
        ),
      ],
    ),
    LifeEvent(
      id: 'new-child',
      label: 'Have a child',
      summary:
          'Birth registration, the certificate, and program eligibilities.',
      icon: Icons.child_care_outlined,
      steps: [
        LifeEventStep(
          title: 'Notification of birth',
          summary: 'Collect the Notification of Birth from the place of birth.',
          responsibleAgency: 'Place of birth',
        ),
        LifeEventStep(
          title: 'Birth registration',
          summary: 'Register the birth with NIRA within 90 days.',
          responsibleAgency: 'NIRA',
          serviceId: 'birth-certificate',
        ),
        LifeEventStep(
          title: 'Obtain the birth certificate',
          summary: 'Pay the fee and obtain the long-form birth certificate.',
          responsibleAgency: 'NIRA',
          serviceId: 'birth-certificate',
        ),
        LifeEventStep(
          title: 'Check eligible programs',
          summary:
              'Check eligibility for relevant Ministry of Health and social '
              'programs.',
          responsibleAgency: 'Ministry of Health',
        ),
      ],
    ),
    LifeEvent(
      id: 'buy-land',
      label: 'Buy a parcel of land',
      summary:
          'Search the title, conduct due diligence, transfer, and pay relevant '
          'taxes.',
      icon: Icons.terrain_outlined,
      steps: [
        LifeEventStep(
          title: 'Search the title',
          summary:
              'Verify ownership and encumbrances at the Ministry of Lands.',
          responsibleAgency: 'MoLHUD',
          serviceId: 'land-title-search',
        ),
        LifeEventStep(
          title: 'Engage a registered surveyor',
          summary: 'Confirm boundaries and measurements.',
          responsibleAgency: 'Licensed surveyor',
        ),
        LifeEventStep(
          title: 'Execute transfer',
          summary: 'Sign the transfer with both parties present.',
          responsibleAgency: 'MoLHUD',
        ),
        LifeEventStep(
          title: 'Pay stamp duty',
          summary: 'Pay any stamp duty due to URA on the transfer.',
          responsibleAgency: 'URA',
        ),
        LifeEventStep(
          title: 'Register the transfer',
          summary: 'Lodge for registration and obtain the new title.',
          responsibleAgency: 'MoLHUD',
        ),
      ],
    ),
    LifeEvent(
      id: 'travel-abroad',
      label: 'Travel abroad',
      summary:
          'Identity check, passport, visa where applicable, yellow-fever and '
          'any clearances.',
      icon: Icons.flight_takeoff_outlined,
      steps: [
        LifeEventStep(
          title: 'Confirm National ID is valid',
          summary: 'Confirm via Ask Uganda before applying.',
          responsibleAgency: 'NIRA',
        ),
        LifeEventStep(
          title: 'Obtain or renew passport',
          summary: 'Apply through the immigration portal.',
          responsibleAgency: 'DCIC',
          serviceId: 'passport-renewal',
        ),
        LifeEventStep(
          title: 'Visa for destination',
          summary:
              'Apply to the destination country if a visa is required.',
          responsibleAgency: 'Destination embassy',
        ),
        LifeEventStep(
          title: 'Yellow-fever and health',
          summary: 'Confirm health requirements at a designated centre.',
          responsibleAgency: 'Ministry of Health',
        ),
      ],
    ),
    LifeEvent(
      id: 'lost-id',
      label: 'Lost my National ID',
      summary: 'Police report, replacement application, and tracking.',
      icon: Icons.report_problem_outlined,
      steps: [
        LifeEventStep(
          title: 'Obtain a police report',
          summary: 'Report the loss at the nearest police station.',
          responsibleAgency: 'Uganda Police',
        ),
        LifeEventStep(
          title: 'Apply for replacement at NIRA',
          summary: 'Submit the report and pay the replacement fee.',
          responsibleAgency: 'NIRA',
          serviceId: 'national-id',
        ),
        LifeEventStep(
          title: 'Collect when notified',
          summary: 'Track the application and collect when ready.',
          responsibleAgency: 'NIRA',
        ),
      ],
    ),
    LifeEvent(
      id: 'retire',
      label: 'Retire',
      summary:
          'NSSF withdrawal eligibility, tax position and social entitlements.',
      icon: Icons.elderly_outlined,
      steps: [
        LifeEventStep(
          title: 'Confirm eligibility with NSSF',
          summary: 'Check your NSSF balance and withdrawal eligibility.',
          responsibleAgency: 'NSSF',
        ),
        LifeEventStep(
          title: 'Confirm tax position',
          summary: 'Confirm your final tax compliance status with URA.',
          responsibleAgency: 'URA',
          serviceId: 'tin-registration',
        ),
        LifeEventStep(
          title: 'Apply for SAGE if eligible',
          summary: 'Senior Citizens Grant for eligible elders.',
          responsibleAgency: 'MGLSD',
        ),
      ],
    ),
  ];
}
