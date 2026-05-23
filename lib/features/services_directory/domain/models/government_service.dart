import 'package:flutter/material.dart';

enum ServiceCategory {
  identity,
  business,
  revenue,
  land,
  transport,
  health,
  education,
  travel,
  social,
}

extension ServiceCategoryX on ServiceCategory {
  String get label {
    switch (this) {
      case ServiceCategory.identity:
        return 'Identity & Civil';
      case ServiceCategory.business:
        return 'Business & Trade';
      case ServiceCategory.revenue:
        return 'Tax & Revenue';
      case ServiceCategory.land:
        return 'Land & Property';
      case ServiceCategory.transport:
        return 'Transport';
      case ServiceCategory.health:
        return 'Health';
      case ServiceCategory.education:
        return 'Education';
      case ServiceCategory.travel:
        return 'Travel & Immigration';
      case ServiceCategory.social:
        return 'Social Protection';
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceCategory.identity:
        return Icons.badge_outlined;
      case ServiceCategory.business:
        return Icons.storefront_outlined;
      case ServiceCategory.revenue:
        return Icons.receipt_long_outlined;
      case ServiceCategory.land:
        return Icons.terrain_outlined;
      case ServiceCategory.transport:
        return Icons.directions_car_outlined;
      case ServiceCategory.health:
        return Icons.medical_services_outlined;
      case ServiceCategory.education:
        return Icons.school_outlined;
      case ServiceCategory.travel:
        return Icons.flight_takeoff_outlined;
      case ServiceCategory.social:
        return Icons.volunteer_activism_outlined;
    }
  }
}

@immutable
class GovernmentService {
  const GovernmentService({
    required this.id,
    required this.name,
    required this.summary,
    required this.category,
    required this.responsibleAgency,
    required this.prerequisites,
    required this.steps,
    required this.requiredDocuments,
    required this.fee,
    required this.processingTime,
    required this.deliveryChannels,
    this.guvaVerificationAvailable = false,
  });

  final String id;
  final String name;
  final String summary;
  final ServiceCategory category;
  final String responsibleAgency;
  final List<String> prerequisites;
  final List<String> steps;
  final List<String> requiredDocuments;
  final String fee;
  final String processingTime;
  final List<String> deliveryChannels;
  final bool guvaVerificationAvailable;
}

abstract final class ServicesCatalogue {
  static const all = <GovernmentService>[
    GovernmentService(
      id: 'national-id',
      name: 'Apply for a National ID',
      summary:
          'Register for a National Identification Card with the National '
          'Identification and Registration Authority.',
      category: ServiceCategory.identity,
      responsibleAgency: 'NIRA',
      prerequisites: [
        'You are a Ugandan citizen',
        'You are 16 years or older (children under 16 receive a No-Photo card)',
      ],
      steps: [
        'Visit the nearest NIRA registration centre',
        'Complete the registration form (or apply online)',
        'Provide biometric data: photograph, fingerprints, signature',
        'Receive a registration slip with your tracking number',
        'Collect your card when notified',
      ],
      requiredDocuments: [
        'Birth certificate or sworn declaration',
        'Letter from local council (LC1)',
        'Parent or guardian National IDs (for minors)',
      ],
      fee: 'No fee for first issuance',
      processingTime: 'Typically 4–8 weeks',
      deliveryChannels: ['NIRA office', 'NIRA mobile registration'],
      guvaVerificationAvailable: true,
    ),
    GovernmentService(
      id: 'birth-certificate',
      name: 'Obtain a birth certificate',
      summary:
          'Register a birth and obtain the official birth certificate from '
          'NIRA.',
      category: ServiceCategory.identity,
      responsibleAgency: 'NIRA',
      prerequisites: [
        'A Notification of Birth from the place of birth',
      ],
      steps: [
        'Complete the registration of birth within 90 days where possible',
        'Submit Notification of Birth at NIRA office or via Hospital portal',
        'Pay the prescribed fee',
        'Collect or download the certificate',
      ],
      requiredDocuments: [
        'Notification of Birth',
        'Both parents’ National IDs',
        'Marriage certificate (if applicable)',
      ],
      fee: 'UGX 5,000 (long form)',
      processingTime: '1–14 days',
      deliveryChannels: ['NIRA office', 'Online (UBOS portal)'],
      guvaVerificationAvailable: true,
    ),
    GovernmentService(
      id: 'business-registration',
      name: 'Register a business',
      summary:
          'Reserve a business name and register with the Uganda Registration '
          'Services Bureau.',
      category: ServiceCategory.business,
      responsibleAgency: 'URSB',
      prerequisites: [
        'A unique business name',
        'Identified directors or proprietors with National IDs',
      ],
      steps: [
        'Reserve a business name online (URSB portal)',
        'Choose a structure (sole proprietorship, partnership, company)',
        'Complete registration forms and pay the fee',
        'Obtain a certificate of registration / incorporation',
      ],
      requiredDocuments: [
        'National IDs of directors',
        'Memorandum and Articles of Association (for companies)',
        'Proof of payment of registration fee',
      ],
      fee: 'From UGX 35,000 (varies by structure)',
      processingTime: '1–5 working days',
      deliveryChannels: ['URSB online portal', 'URSB regional offices'],
      guvaVerificationAvailable: true,
    ),
    GovernmentService(
      id: 'tin-registration',
      name: 'Register for a TIN',
      summary:
          'Get a Tax Identification Number from URA for individuals or '
          'businesses.',
      category: ServiceCategory.revenue,
      responsibleAgency: 'URA',
      prerequisites: [
        'A valid National ID (individuals)',
        'Business registration (entities)',
      ],
      steps: [
        'Open the URA web portal and select "Register for TIN"',
        'Complete the form with biographic and contact data',
        'Submit and receive your TIN within minutes',
      ],
      requiredDocuments: [
        'National ID number',
        'Business registration number (entities)',
        'Bank account details (entities)',
      ],
      fee: 'Free',
      processingTime: 'Instant in most cases',
      deliveryChannels: ['URA web portal', 'URA service centres'],
      guvaVerificationAvailable: true,
    ),
    GovernmentService(
      id: 'driving-permit',
      name: 'Renew driving permit',
      summary:
          'Renew an expired or about-to-expire driving permit through the '
          'Uganda Driver Licensing System.',
      category: ServiceCategory.transport,
      responsibleAgency: 'UDLS',
      prerequisites: [
        'A valid or recently expired permit',
        'No outstanding traffic obligations',
      ],
      steps: [
        'Log in to the UDLS portal',
        'Submit a renewal request and pay the fee',
        'Visit a service point for biometric capture if required',
        'Collect or receive the renewed permit',
      ],
      requiredDocuments: [
        'Existing driving permit',
        'National ID',
        'Proof of payment',
      ],
      fee: 'UGX 60,000 (1 year) — varies by validity',
      processingTime: 'Same day for renewals',
      deliveryChannels: ['UDLS portal', 'UDLS service points'],
      guvaVerificationAvailable: true,
    ),
    GovernmentService(
      id: 'passport-renewal',
      name: 'Renew a passport',
      summary:
          'Renew an ordinary Ugandan passport with the Directorate of '
          'Citizenship and Immigration Control.',
      category: ServiceCategory.travel,
      responsibleAgency: 'DCIC',
      prerequisites: [
        'A current Ugandan passport (even if expired)',
        'A valid National ID',
      ],
      steps: [
        'Apply online on the immigration portal',
        'Pay the renewal fee',
        'Book a biometric capture appointment',
        'Collect your renewed passport',
      ],
      requiredDocuments: [
        'Existing passport',
        'National ID',
        'Recent passport photograph (if required)',
      ],
      fee: 'UGX 250,000 (ordinary, 10-year)',
      processingTime: '10 working days',
      deliveryChannels: ['Immigration online portal', 'DCIC offices'],
      guvaVerificationAvailable: true,
    ),
    GovernmentService(
      id: 'land-title-search',
      name: 'Search a land title',
      summary:
          'Verify ownership and encumbrances of a parcel of land through the '
          'Ministry of Lands.',
      category: ServiceCategory.land,
      responsibleAgency: 'MoLHUD',
      prerequisites: [
        'Parcel identifier (plot, block, district)',
        'Legitimate interest (such as a mortgage check)',
      ],
      steps: [
        'Open the National Land Information System portal',
        'Submit a search request with parcel details',
        'Pay the search fee',
        'Receive the official search report',
      ],
      requiredDocuments: [
        'Identification of requester',
        'Proof of payment',
      ],
      fee: 'UGX 25,000',
      processingTime: '1–3 days',
      deliveryChannels: ['NLIS portal', 'Ministry zonal offices'],
      guvaVerificationAvailable: true,
    ),
    GovernmentService(
      id: 'unmeb-verify',
      name: 'Verify an academic qualification',
      summary:
          'Confirm a UNEB or equivalent qualification through the GUVA-backed '
          'education verification service.',
      category: ServiceCategory.education,
      responsibleAgency: 'UNEB',
      prerequisites: [
        'Consent from the qualification holder',
        'Original certificate or index number',
      ],
      steps: [
        'Submit the holder\'s consent',
        'Provide the index number and year',
        'Receive the verified qualification record',
      ],
      requiredDocuments: [
        'Index number',
        'Year of examination',
      ],
      fee: 'Free via Ask Uganda',
      processingTime: 'Instant',
      deliveryChannels: ['Ask Uganda', 'UNEB office'],
      guvaVerificationAvailable: true,
    ),
  ];
}
