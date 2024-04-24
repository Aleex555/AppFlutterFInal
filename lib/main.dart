import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cronómetro y Temporizador',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: CronometroTemporizador(),
    );
  }
}

class CronometroTemporizador extends StatefulWidget {
  @override
  _CronometroTemporizadorState createState() => _CronometroTemporizadorState();
}

class _CronometroTemporizadorState extends State<CronometroTemporizador> {
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  List<Duration> _laps = [];
  Duration _lastLapTime = Duration.zero;
  bool _isTimer = false; // Indica si el modo actual es Temporizador
  bool _isRunning = false;
  bool _showPicker = false;
  int _hours = 0, _minutes = 0, _seconds = 0;
  Duration _duration = Duration();

  void _toggleMode() {
    setState(() {
      _isTimer = !_isTimer;
      _reset();
    });
  }

  void _startStop() {
    setState(() {
      if (_isRunning) {
        _stopwatch.stop();
        _timer?.cancel();
        _isRunning = false;
      } else {
        _showPicker = false;
        if (!_stopwatch.isRunning) {
          _stopwatch.start();
        }
        _isRunning = true;
        _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
          setState(() {
            if (_isTimer && _stopwatch.elapsed >= _duration) {
              _stopwatch.stop();
              _timer?.cancel();
              _isRunning = false;
              _showPicker = true;
            }
          });
        });
      }
    });
  }

  void _reset() {
    _stopwatch.reset();
    _timer?.cancel();
    _isRunning = false;
    _showPicker = _isTimer;
    _lastLapTime = Duration.zero;
    _laps.clear();
    _hours = 0;
    _minutes = 0;
    _seconds = 0;
    _duration = Duration();
    setState(() {});
  }

  void _addLap() {
    final currentDuration = _stopwatch.elapsed;
    final lapDuration = currentDuration - _lastLapTime;
    _lastLapTime = currentDuration;
    setState(() {
      _laps.insert(0, lapDuration);
    });
  }

  void _updateDuration() {
    setState(() {
      _duration = Duration(hours: _hours, minutes: _minutes, seconds: _seconds);
    });
  }

  Widget _buildPicker(
      String label, int value, int max, ValueChanged<int> onChanged) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label),
          SizedBox(
            height: 100,
            child: CupertinoPicker(
              itemExtent: 32.0,
              magnification: 1.2,
              useMagnifier: true,
              onSelectedItemChanged: onChanged,
              children: List<Widget>.generate(
                  max + 1, (index) => Text(index.toString())),
              scrollController: FixedExtentScrollController(initialItem: value),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayDuration =
        _isTimer ? _duration - _stopwatch.elapsed : _stopwatch.elapsed;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isTimer ? 'Temporizador' : 'Cronómetro'),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: _toggleMode,
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatDuration(displayDuration),
            style: Theme.of(context).textTheme.headline3,
          ),
          if (_isTimer && !_isRunning && _showPicker) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPicker("Horas", _hours, 23, (value) {
                  _hours = value;
                  _updateDuration();
                }),
                _buildPicker("Minutos", _minutes, 59, (value) {
                  _minutes = value;
                  _updateDuration();
                }),
                _buildPicker("Segundos", _seconds, 59, (value) {
                  _seconds = value;
                  _updateDuration();
                }),
              ],
            ),
          ],
          Expanded(
            child: ListView.builder(
              itemCount: _laps.length,
              itemBuilder: (context, index) => ListTile(
                title: Text('Lap ${index + 1}'),
                subtitle: Text(_formatDuration(_laps[index])),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _startStop,
            tooltip: 'Start/Stop',
            child: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
          ),
          SizedBox(width: 20),
          FloatingActionButton(
            onPressed: _reset,
            tooltip: 'Reset',
            child: Icon(Icons.refresh),
          ),
          SizedBox(width: 20),
          FloatingActionButton(
            onPressed: _addLap,
            tooltip: 'Lap',
            child: Icon(Icons.flag),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}
