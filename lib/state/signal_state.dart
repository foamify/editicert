part of 'state.dart';

/// Represents the state of a signal.
///
/// This is an abstract interface class that defines the behavior of a signal
/// state.
/// It provides access to the signal and the value it represents.
interface class SignalState<T> {
  /// Constructs a new instance of the [SignalState] class.
  const SignalState();

  /// The signal associated with this state.
  Signal<T> get _signal => throw UnimplementedError();
}

/// An extension on [SignalState]
extension SignalStateEx<T> on SignalState<T> {
  /// The value represented by the signal.
  T get value => _signal();
  set value(T value) => _signal.value = value;

  /// Calls the signal.
  T call() => _signal();

  Signal<T> get sig => _signal;
}

/// An extension on [SignalState]
extension SignalStateIterable<T> on SignalState<Iterable<T>> {
  void add(T element) => _signal.add(element);

  void remove(T element) => _signal.remove(element);

  void clear() => _signal.clear();
}

/// An extension on [Signal]
extension SignalIterable<T> on Signal<Iterable<T>> {
  void add(T element) => value is Set
      ? value = ({...value}..add(element))
      : value = [...value, element];

  void remove(T element) => value is Set
      ? value = (<T>{...value}..remove(element))
      : value = ([...value]..remove(element));

  void clear() => value is Set ? value = <T>{} : value = <T>[];
}
