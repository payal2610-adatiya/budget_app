import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkAwareWidget extends StatefulWidget {
  final Widget child;
  final Widget offlineWidget;

  const NetworkAwareWidget({
    super.key,
    required this.child,
    required this.offlineWidget,
  });

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    } as void Function(List<ConnectivityResult> event)?);
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isConnected ? widget.child : widget.offlineWidget;
  }
}