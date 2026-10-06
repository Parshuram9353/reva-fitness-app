class Exercise {
  final String type;
  final String title;
  final String desc;

  const Exercise({
    required this.type,
    required this.title,
    required this.desc,
  });
}

class Mistake {
  final String risk;
  final String title;
  final String desc;

  const Mistake({
    required this.risk,
    required this.title,
    required this.desc,
  });
}

class Stretch {
  final String type;
  final String title;
  final String desc;

  const Stretch({
    required this.type,
    required this.title,
    required this.desc,
  });
}

class Nutrition {
  final String type;
  final String title;
  final String desc;

  const Nutrition({
    required this.type,
    required this.title,
    required this.desc,
  });
}

class Muscle {
  final String id;
  final String name;
  final String details;
  final String function;
  final List<Exercise> exercises;
  final List<Mistake> mistakes;
  final List<Stretch> stretches;
  final List<Nutrition> nutrition;

  const Muscle({
    required this.id,
    required this.name,
    required this.details,
    required this.function,
    required this.exercises,
    required this.mistakes,
    required this.stretches,
    required this.nutrition,
  });
}
