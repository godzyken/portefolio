// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BasicThemeAdapter extends TypeAdapter<BasicTheme> {
  @override
  final int typeId = 2;

  @override
  BasicTheme read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BasicTheme(
      primaryColorValue: fields[0] as int,
      tertiaryColorValue: fields[1] as int,
      neutralColorValue: fields[2] as int,
      mode: fields[3] as AppThemeMode,
      name: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BasicTheme obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.primaryColorValue)
      ..writeByte(1)
      ..write(obj.tertiaryColorValue)
      ..writeByte(2)
      ..write(obj.neutralColorValue)
      ..writeByte(3)
      ..write(obj.mode)
      ..writeByte(4)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BasicThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppThemeModeAdapter extends TypeAdapter<AppThemeMode> {
  @override
  final int typeId = 1;

  @override
  AppThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppThemeMode.system;
      case 1:
        return AppThemeMode.light;
      case 2:
        return AppThemeMode.dark;
      case 3:
        return AppThemeMode.custom;
      default:
        return AppThemeMode.system;
    }
  }

  @override
  void write(BinaryWriter writer, AppThemeMode obj) {
    switch (obj) {
      case AppThemeMode.system:
        writer.writeByte(0);
        break;
      case AppThemeMode.light:
        writer.writeByte(1);
        break;
      case AppThemeMode.dark:
        writer.writeByte(2);
        break;
      case AppThemeMode.custom:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
