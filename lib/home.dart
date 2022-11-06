import 'dart:async';

import 'package:faller/models/measure.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'red_screen.dart';

const NUMBER_OF_MEASUREMENTS = 15;
const MAX_MEASURES = 600;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Timer setStateTimer;
  int _eventsCounter = 0;
  bool shouldCollectMeasures = true;
  bool didFall = false;
  List<AccelerometerMeasure> measures = [];
  List<double> greatestMeasures = [];
  List<double> secondGreatestMeasures = [];
  List<double> magnitudeTimeSeries = [];

  double greatestMeasureScale = 20;
  double secondGreatestMeasureScale = 20;
  double magnitudeScale = 40;

  @override
  void initState() {
    super.initState();
    setStateTimer = Timer.periodic(
      const Duration(milliseconds: 150),
      (Timer timer) {
        if (mounted && shouldCollectMeasures && !didFall) {
          setState(() {});
        }
      },
    );

    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      if (_eventsCounter == NUMBER_OF_MEASUREMENTS) {
        final sortedMeans = sortedMeasuresMeans(measures);

        if (greatestMeasures.length >= MAX_MEASURES) {
          greatestMeasures.removeAt(0);
        }

        if (secondGreatestMeasures.length >= MAX_MEASURES) {
          secondGreatestMeasures.removeAt(0);
        }

        if (magnitudeTimeSeries.length >= MAX_MEASURES) {
          magnitudeTimeSeries.removeAt(0);
        }
        greatestMeasures.add(sortedMeans.last);
        secondGreatestMeasures.add(sortedMeans[sortedMeans.length - 2]);
        magnitudeTimeSeries.add(magnitudeMean(measures));
        measures = [];
        _eventsCounter = 0;
        if (greatestMeasures.last >= 9) {
          setState(() {
            didFall = true;
            Future.delayed(
              const Duration(seconds: 10),
              () => {setState(() => didFall = false)},
            );
          });
        }
        // });
      } else if (shouldCollectMeasures && !didFall) {
        _eventsCounter++;
        measures.add(AccelerometerMeasure(event.x, event.y, event.z));
      }
    });
  }

  @override
  void dispose() {
    setStateTimer.cancel();
    super.dispose();
  }

  void _stopCollectingMeasures() {
    setState(() {
      shouldCollectMeasures = false;
    });
  }

  void _startCollectingMeasures() {
    setState(() {
      shouldCollectMeasures = true;
      measures = [];
      _eventsCounter = 0;
    });
  }

  void _cleanMeasures() {
    setState(() {
      greatestMeasures = [];
      secondGreatestMeasures = [];
      magnitudeTimeSeries = [];
      measures = [];
      _eventsCounter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return didFall
        ? const RedScreen()
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              actions: [
                IconButton(
                  onPressed: _stopCollectingMeasures,
                  icon: const Icon(Icons.stop),
                ),
                IconButton(
                  onPressed: _startCollectingMeasures,
                  icon: const Icon(Icons.play_arrow),
                ),
                IconButton(
                  onPressed: _cleanMeasures,
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SfCartesianChart(
                      primaryXAxis: NumericAxis(),
                      primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: greatestMeasureScale,
                      ),
                      zoomPanBehavior: ZoomPanBehavior(
                        enablePanning: true,
                        enablePinching: true,
                      ),
                      series: <ChartSeries>[
                        LineSeries<double, int>(
                          dataSource: greatestMeasures,
                          xValueMapper: (double measure, index) => index,
                          yValueMapper: (double measure, index) => measure,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Maior leitura"),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () =>
                                    setState(() => greatestMeasureScale += 5),
                                icon: const Icon(Icons.remove),
                              ),
                              IconButton(
                                onPressed: () =>
                                    setState(() => greatestMeasureScale -= 5),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                    SfCartesianChart(
                      primaryXAxis: NumericAxis(),
                      primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: secondGreatestMeasureScale,
                      ),
                      series: <ChartSeries>[
                        LineSeries<double, int>(
                          color: Colors.green,
                          dataSource: secondGreatestMeasures,
                          xValueMapper: (double measure, index) => index,
                          yValueMapper: (double measure, index) => measure,
                        ),
                      ],
                      zoomPanBehavior: ZoomPanBehavior(
                        enablePanning: true,
                        enablePinching: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("2ª Maior leitura"),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () => setState(
                                    () => secondGreatestMeasureScale += 5),
                                icon: const Icon(Icons.remove),
                              ),
                              IconButton(
                                onPressed: () => setState(
                                    () => secondGreatestMeasureScale -= 5),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                    SfCartesianChart(
                      primaryXAxis: NumericAxis(),
                      primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: magnitudeScale,
                      ),
                      series: <ChartSeries>[
                        LineSeries<double, int>(
                          color: Colors.red,
                          dataSource: magnitudeTimeSeries,
                          xValueMapper: (double measure, index) => index,
                          yValueMapper: (double measure, index) => measure,
                        ),
                      ],
                      zoomPanBehavior: ZoomPanBehavior(
                        enablePanning: true,
                        enablePinching: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Magnitude"),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () =>
                                    setState(() => magnitudeScale += 5),
                                icon: const Icon(Icons.remove),
                              ),
                              IconButton(
                                onPressed: () =>
                                    setState(() => magnitudeScale -= 5),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          );
  }
}
