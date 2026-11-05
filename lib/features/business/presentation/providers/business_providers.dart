import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/business_repository_impl.dart';
import '../../domain/entities/business.dart';

/// The provider's business; `null` until they register it.
final myBusinessProvider = FutureProvider<Business?>((ref) => ref.watch(businessRepositoryProvider).mine());

/// The provider's offers, newest first. Empty while there is no business yet.
final myOffersProvider = FutureProvider<List<ManagedOffer>>((ref) async {
  final business = await ref.watch(myBusinessProvider.future);
  if (business == null) return const [];
  return ref.watch(businessRepositoryProvider).offers();
});

/// Clock for offer statuses; overridden in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
