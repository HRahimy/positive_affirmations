part of 'affirmations_bloc.dart';

abstract class AffirmationsEvent extends Equatable {
  const AffirmationsEvent();
}

class AffirmationCreated extends AffirmationsEvent {
  const AffirmationCreated(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  List<Object> get props => [title, subtitle];
}

class AffirmationUpdated extends AffirmationsEvent {
  const AffirmationUpdated(this.id, this.title, this.subtitle);

  final int id;
  final String title;
  final String subtitle;

  @override
  List<Object> get props => [id, title, subtitle];
}

class AffirmationActivationToggled extends AffirmationsEvent {
  const AffirmationActivationToggled(this.id);

  final int id;

  @override
  List<Object> get props => [id];
}

class AffirmationLiked extends AffirmationsEvent {
  const AffirmationLiked(this.id);

  final int id;

  @override
  List<Object> get props => [id];
}

class ReaffirmationCreated extends AffirmationsEvent {
  const ReaffirmationCreated({
    required this.affirmationId,
    required this.value,
    required this.font,
    required this.stamp,
  });

  final int affirmationId;
  final ReaffirmationValue value;
  final ReaffirmationFont font;
  final ReaffirmationStamp stamp;

  @override
  List<Object> get props => [affirmationId, value, font, stamp];
}