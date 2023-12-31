import 'package:flutter/material.dart';

const successS = 'success';

Widget loadingCenter() {
  return const Center(
    child: CircularProgressIndicator(),
  );
}

class BoolW {
  bool v;

  BoolW(this.v);
}

class IntW {
  int v;

  IntW(this.v);
}

class StringW {
  String v;

  StringW(this.v);
}

class StringNW {
  String? v;

  StringNW({this.v});
}

class SyncObj {
  final StateSetter setState;
  final BoolW isSyncing;

  SyncObj(this.setState, this.isSyncing);
}
