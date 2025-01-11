part of '../../arculus_ffi.dart';

// Represents a size_t value in native memory
base class SizeT extends Struct {
  @IntPtr()
  external int value;
}

// Wrapper class to manage the pointer lifecycle
class SizeTPointer {
  late final Pointer<SizeT> _pointer;

  SizeTPointer() {
    _pointer = calloc<SizeT>();
    _pointer.ref.value = 0;
  }

  Pointer<SizeT> get pointer => _pointer;

  int getValue() => _pointer.ref.value;

  void setValue(int value) {
    _pointer.ref.value = value;
  }

  void free() {
    calloc.free(_pointer);
  }
}
