import 'dart:async';

import 'package:app/models/machine_date_time.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:formz/formz.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:repository/repository.dart';
import 'package:uuid/uuid.dart';

part 'affirmations_event.dart';

part 'affirmations_state.dart';

class AffirmationsBloc extends Bloc<AffirmationsEvent, AffirmationsState> {
  AffirmationsBloc({
    required this.userRepository,
    required this.affirmationsRepository,
    this.time,
  }) : super(const AffirmationsState()) {
    on<AffirmationCreated>(_mapAffirmationCreatedToState);
    on<AffirmationLiked>(_mapAffirmationLikedToState);
    on<AffirmationActivationToggled>(_mapAffirmationActivationToggledToState);
    on<AffirmationUpdated>(_mapAffirmationUpdatedToState);
    on<ReaffirmationCreated>(_mapReaffirmationCreatedToState);
    on<AffirmationsLoaded>(_loadAffirmations);
    on<AffirmationsUpdated>(_updateAffirmations);
  }

  final MachineDateTime? time;
  final UserRepository userRepository;
  final AffirmationsRepository affirmationsRepository;

  // StreamSubscription? _affirmationsSubscription;

  @override
  Future<void> close() {
    // _affirmationsSubscription?.cancel();
    return super.close();
  }

  Future<void> _loadAffirmations(
      AffirmationsLoaded event, Emitter<AffirmationsState> emit) async {
    final affirmations = await affirmationsRepository.getAffirmations();
    debugPrint(affirmations.toString());
    emit(state.copyWith(affirmations: affirmations));
    // _affirmationsSubscription?.cancel();
    // _affirmationsSubscription =
    //     affirmationsRepository.getAffirmations().listen((affirmations) {
    //   add(AffirmationsUpdated(affirmations: affirmations));
    // });
  }

  void _updateAffirmations(
      AffirmationsUpdated event, Emitter<AffirmationsState> emit) {
    emit(state.copyWith(affirmations: event.affirmations));
  }

  Future<void> _mapAffirmationCreatedToState(
      AffirmationCreated event, Emitter<AffirmationsState> emit) async {
    final newAffirmation = Affirmation(
      id: const Uuid().v4(),
      title: event.title,
      subtitle: event.subtitle,
      createdById: userRepository.currentUser.id,
      createdOn: time?.now ?? DateTime.now(),
    );
    await affirmationsRepository.saveAffirmation(newAffirmation);

    // final newAffirmations = [
    //   ...state.affirmations,
    //   newAffirmation,
    // ];
    //
    // emit(state.copyWith(affirmations: newAffirmations));
  }

  void _mapAffirmationLikedToState(
      AffirmationLiked event, Emitter<AffirmationsState> emit) {
    final updatedAffirmations = state.affirmations.map((affirmation) {
      return affirmation.id == event.id
          ? affirmation.copyWith(liked: !affirmation.liked)
          : affirmation;
    }).toList();

    emit(state.copyWith(affirmations: [...updatedAffirmations]));
  }

  void _mapAffirmationActivationToggledToState(
      AffirmationActivationToggled event, Emitter<AffirmationsState> emit) {
    final updatedAffirmations = state.affirmations.map((affirmation) {
      return affirmation.id == event.id
          ? affirmation.copyWith(active: !affirmation.active)
          : affirmation;
    }).toList();

    emit(state.copyWith(affirmations: [...updatedAffirmations]));
  }

  void _mapAffirmationUpdatedToState(
      AffirmationUpdated event, Emitter<AffirmationsState> emit) {
    final updatedAffirmations = state.affirmations.map((affirmation) {
      return affirmation.id == event.id
          ? affirmation.copyWith(
              title: event.title,
              subtitle: event.subtitle,
            )
          : affirmation;
    }).toList();

    emit(state.copyWith(affirmations: [...updatedAffirmations]));
  }

  void _mapReaffirmationCreatedToState(
      ReaffirmationCreated event, Emitter<AffirmationsState> emit) {
    final updatedAffirmations = state.affirmations.map((affirmation) {
      return affirmation.id == event.affirmationId
          ? affirmation.copyWith(
              totalReaffirmations: affirmation.totalReaffirmations + 1)
          : affirmation;
    });
    final newReaffirmation = Reaffirmation(
      id: state.reaffirmations.length + 1,
      affirmationId: event.affirmationId,
      createdOn: time?.now ?? DateTime.now(),
      value: event.value,
      font: event.font,
      stamp: event.stamp,
    );

    emit(state.copyWith(
      affirmations: [...updatedAffirmations],
      reaffirmations: [...state.reaffirmations, newReaffirmation],
    ));
  }
}

class HydratedAffirmationsBloc extends AffirmationsBloc with HydratedMixin {
  HydratedAffirmationsBloc({
    required UserRepository userRepository,
    required AffirmationsRepository affirmationsRepository,
  }) : super(
          userRepository: userRepository,
          affirmationsRepository: affirmationsRepository,
        );

  @override
  AffirmationsState? fromJson(Map<String, dynamic> json) {
    List<Affirmation> affirmations = [
      ...(json[AffirmationsState.fieldAffirmations] as List<dynamic>)
          .map((affirmation) {
        final affirmationJson = affirmation as Map<String, dynamic>;
        return Affirmation.fromJson(affirmationJson);
      }),
    ];
    List<Reaffirmation> reaffirmations = [];
    if (json[AffirmationsState.fieldReaffirmations] != null) {
      reaffirmations = [
        ...(json[AffirmationsState.fieldReaffirmations] as List<dynamic>)
            .map((reaffirmation) {
          final reaffirmationJson = reaffirmation as Map<String, dynamic>;
          return Reaffirmation.fromJson(reaffirmationJson);
        })
      ];
    }

    return AffirmationsState(
      affirmations: affirmations,
      reaffirmations: reaffirmations,
    );
  }

  @override
  Map<String, dynamic>? toJson(AffirmationsState state) => {
        AffirmationsState.fieldAffirmations: [
          ...state.affirmations.map((e) => e.fieldValues),
        ],
        AffirmationsState.fieldReaffirmations: [
          ...state.reaffirmations.map((e) => e.fieldValues),
        ],
      };
}
