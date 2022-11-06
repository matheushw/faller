import 'dart:math';

class AccelerometerMeasure {
  double x, y, z;

  AccelerometerMeasure(this.x, this.y, this.z);

  double get accelerationMagnitude => sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2));

  void printMeasures() {
    print('X -> $x');
    print('Y -> $y');
    print('Z -> $z');
  }
}

double measureMean(List<double> measures) {
  double sum = 0;
  for (var measure in measures) {
    sum += measure;
  }
  return sum / measures.length;
}

double magnitudeMean(List<AccelerometerMeasure> measures) {
  double sum = 0;
  for (AccelerometerMeasure measure in measures) {
    sum += measure.accelerationMagnitude;
  }
  return sum / measures.length;
}

dynamic sortedMeasuresMeans(List<AccelerometerMeasure> measures) {
  double xMean = measureMean(measures.map((e) => e.x).toList());
  double yMean = measureMean(measures.map((e) => e.y).toList());
  double zMean = measureMean(measures.map((e) => e.z).toList());

  List<double> means = [xMean.abs(), yMean.abs(), zMean.abs()];
  means.sort();

  return means;
}
