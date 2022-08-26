import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ByteBuffer {
  final Uint8List _buffer;
  final int _offset;
  bool littleEndian;
  int position;
  List<String> stringTable;

  ByteBuffer(Uint8List buffer, int offset)
      : _buffer = buffer,
        position = 0,
        _offset = offset,
        littleEndian = false,
        stringTable = <String>[];

  int get bytesAvailable => _buffer.length - position;

  void skip(int count) => position += count;

  int readUByte() {
    int value = _buffer[_offset + position];
    ++position;
    return value;
  }

  int readByte() {
    int value = readUByte();
    if (value > 127) value -= 255;
    return value;
  }

  bool readBool() => readByte() == 1;

  int readUShort() {
    int startIndex = _offset + position;
    position += 2;
    if (littleEndian) {
      return _buffer[startIndex] | (_buffer[startIndex + 1] << 8);
    } else {
      return (_buffer[startIndex] << 8) | _buffer[startIndex + 1];
    }
  }

  int readShort() {
    int value = readUShort();
    if (value > 32767) value -= 65535;
    return value;
  }

  int readUInt() {
    int startIndex = _offset + position;
    position += 4;
    if (littleEndian) {
      return _buffer[startIndex] |
          (_buffer[startIndex + 1] << 8) |
          (_buffer[startIndex + 2] << 16) |
          (_buffer[startIndex + 3] << 24);
    } else {
      return (_buffer[startIndex] << 24) |
          (_buffer[startIndex + 1] << 16) |
          (_buffer[startIndex + 2] << 8) |
          _buffer[startIndex + 3];
    }
  }

  int readInt() {
    int value = readUInt();
    if (value > 2147483647) value -= 4294967295;
    return value;
  }

  double readFloat() => readInt().toDouble();

  String readString() => _readString(readUShort());

  String _readString(int len) {
    int startIndex = _offset + position;
    String value = _buffer.sublist(startIndex, startIndex + len).toString();
    position += len;
    return value;
  }

  String readS() {
    int index = readUShort();
    if (index == 65534 || index == 65533) {
      return '';
    } else {
      return stringTable[index];
    }
  }

  String? readSP() {
    int index = readUShort();
    if (index == 65534) {
      return null;
    } else if (index == 65533) {
      return '';
    } else {
      return stringTable[index];
    }
  }

  List<String> readSArray(int count) {
    List<String> arr = <String>[];
    for (int i = 0; i < count; ++i) {
      arr.add(readS());
    }
    return arr;
  }

  void writeS(final String value) {
    int index = readUShort();
    if (index != 65534 && index != 65533) stringTable[index] = value;
  }

  Color readColor() {
    int startIndex = _offset + position;
    position += 4;
    return Color.fromARGB(_buffer[startIndex + 3], _buffer[startIndex],
        _buffer[startIndex + 1], _buffer[startIndex + 2]);
  }

  ByteBuffer readBuffer() {
    int count = readInt();
    int startIndex = _offset + position;
    position += count;
    return ByteBuffer(_buffer.sublist(startIndex, startIndex + count), 0);
  }

  bool seek(int indexTablePos, int blockIndex) {
    int tmp = position;
    position = indexTablePos;
    int segCount = _buffer[_offset + position++];
    if (blockIndex < segCount) {
      bool useShort = _buffer[_offset + position++] == 1;
      int newPos;
      if (useShort) {
        position += 2 + blockIndex;
        newPos = readShort();
      } else {
        position += 4 + blockIndex;
        newPos = readInt();
      }

      if (newPos > 0) {
        position = indexTablePos + newPos;
        return true;
      } else {
        position = tmp;
        return false;
      }
    } else {
      position = tmp;
      return false;
    }
  }
}
