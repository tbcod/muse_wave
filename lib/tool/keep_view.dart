import 'package:flutter/material.dart';

class KeepStateView extends StatefulWidget {
  final Widget child;
  final bool wantKeepAlive;
  const KeepStateView({
    super.key,
    required this.child,
    this.wantKeepAlive = true,
  });

  @override
  State<KeepStateView> createState() => _KeepStatePageState();
}

class _KeepStatePageState extends State<KeepStateView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => widget.wantKeepAlive;
}
