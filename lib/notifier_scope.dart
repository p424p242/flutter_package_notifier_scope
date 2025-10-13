library;

import 'package:flutter/widgets.dart';

abstract class StateNotifier extends ChangeNotifier {
  StateNotifier() {
    init();
  }

  bool _disposed = false;

  bool get isDisposed => _disposed;

  Future<void> init();

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Binding? _binding;

  @protected
  void _setBinding(Binding binding) {
    _binding = binding;
  }
}

class NotifierScope<T extends StateNotifier> {
  factory NotifierScope.global(T notifier) {
    return NotifierScope._(notifier, true);
  }

  factory NotifierScope.scoped(T Function() factory) {
    return NotifierScope._(null, false, factory: factory);
  }

  NotifierScope._(this._notifier, this.isGlobal, {this.factory});

  StateNotifier? _notifier;
  final StateNotifier Function()? factory;
  final bool isGlobal;

  static final Set<StateNotifier> _globalInstances = {};
  static final Set<StateNotifier> _scopedInstances = {};

  T get instance {
    if (_notifier != null && _notifier!.isDisposed) {
      _notifier = null;
    }

    if (_notifier == null) {
      _notifier = factory?.call();
      if (_notifier == null) {
        throw StateError('No notifier or factory provided.');
      }
    }

    if (_notifier!._binding == null) {
      _notifier!._setBinding(Binding(_notifier!, isGlobal));
    }

    final set = isGlobal ? _globalInstances : _scopedInstances;
    if (!set.contains(_notifier!)) {
      set.add(_notifier!);
    }

    if (NotifierBuilderState._currentBinder != null) {
      NotifierBuilderState._currentBinder!._registerNotifier(
        _notifier!._binding!,
        _notifier!,
      );
    }

    return _notifier! as T;
  }

  static void disposeGlobal() {
    for (final notifier in _globalInstances) {
      notifier.dispose();
    }
    _globalInstances.clear();
  }

  static void disposeAllScoped() {
    for (final notifier in _scopedInstances) {
      notifier.dispose();
    }
    _scopedInstances.clear();
  }
}

class Binding<T extends StateNotifier> {
  final T notifier;
  final bool isGlobal;
  int _refCount = 0;
  final List<_ListenerRegistration> _registrations = [];

  Binding(this.notifier, this.isGlobal) {
    notifier._setBinding(this);
  }

  int get refCount => _refCount;

  void _incrementRef() {
    if (isGlobal) return;
    _refCount++;
  }

  void _decrementRef() {
    if (isGlobal) return;
    _refCount--;
    if (_refCount <= 0) {
      for (final reg in _registrations) {
        reg.source.removeListener(reg.callback);
      }
      _registrations.clear();
      NotifierScope._scopedInstances.remove(notifier);
      notifier.dispose();
    }
  }

  void addRegistration(ChangeNotifier source, VoidCallback listener) {
    _registrations.add(_ListenerRegistration(source, listener));
    if (source is StateNotifier &&
        source._binding != null &&
        !source._binding!.isGlobal) {
      (source._binding as Binding)._incrementRef();
    }
  }
}

class _ListenerRegistration {
  final ChangeNotifier source;
  final VoidCallback callback;

  _ListenerRegistration(this.source, this.callback);
}

class NotifierBuilder extends StatefulWidget {
  const NotifierBuilder(this.builder, {super.key});

  final Widget Function(BuildContext) builder;

  @override
  State<NotifierBuilder> createState() => NotifierBuilderState();
}

class NotifierBuilderState extends State<NotifierBuilder> {
  static NotifierBuilderState? _currentBinder;
  final Set<StateNotifier> _notifiers = {};
  final Map<StateNotifier, Binding> _producer = {};

  void _registerNotifier(Binding producer, StateNotifier notifier) {
    _notifiers.add(notifier);
    _producer[notifier] = producer;
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final previous = Set<ChangeNotifier>.from(_notifiers);
    _notifiers.clear();
    final prev = _currentBinder;
    _currentBinder = this;
    final result = widget.builder(context);
    _currentBinder = prev;

    for (final notifier in previous.difference(_notifiers)) {
      try {
        notifier.removeListener(_onUpdate);
      } catch (_) {}
      final producer = _producer.remove(notifier);
      producer?._decrementRef();
    }

    for (final notifier in _notifiers.difference(previous)) {
      notifier.addListener(_onUpdate);
      final producer = _producer[notifier];
      producer?._incrementRef();
    }

    return result;
  }

  @override
  void dispose() {
    for (final notifier in _notifiers) {
      try {
        notifier.removeListener(_onUpdate);
      } catch (_) {}
      final producer = _producer.remove(notifier);
      producer?._decrementRef();
    }
    _notifiers.clear();
    super.dispose();
  }
}
