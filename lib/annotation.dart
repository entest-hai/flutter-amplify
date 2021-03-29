// Annotation Model
class Annotation {
  final DateTime timestamp;
  final String startTime;
  final double duration;
  final String description;
  Annotation({timestamp, this.startTime, this.duration, this.description})
      : this.timestamp = timestamp ?? null;
}
