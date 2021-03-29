// Form State
class AnnotationFormState {
  final String startTime;
  final double duration;
  final String description;
  AnnotationFormState({
    String startTime,
    double duration,
    String description,
  })  : this.startTime = startTime ?? "",
        this.duration = duration ?? 0.0,
        this.description = description ?? "";
}
