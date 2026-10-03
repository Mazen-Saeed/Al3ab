import 'package:uuid/uuid.dart';

// ignore: prefer_const_constructors
final _uuid = Uuid();

/// A new id for a row created on this device (a product, a stock item, a purchase...).
/// UUID v7, like the database ids (decision #1): safe to make offline, and ordered by time.
String newId() => _uuid.v7();
