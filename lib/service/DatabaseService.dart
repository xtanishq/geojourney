import 'package:hive/hive.dart';
import 'package:snap_journey/model/moment.dart';
import 'package:snap_journey/service/StorageService.dart';

class DatabaseService {
  static Box<Moment>? _momentsBox;

  static Future<void> init() async {
    if (!Hive.isBoxOpen('moments')) {
      _momentsBox = await Hive.openBox<Moment>('moments');
    } else {
      _momentsBox = Hive.box<Moment>('moments');
    }
  }

  static Box<Moment> get momentsBox =>
      _momentsBox ?? Hive.box<Moment>('moments');

  static Future<List<Moment>> getMoments({bool withLocation = true}) async {
    try {
      var allMoments = momentsBox.values.toList();
      if (withLocation) {
        allMoments = allMoments.where((m) => m.hasLocation).toList();
      }
      allMoments.sort((a, b) => b.date.compareTo(a.date));
      return allMoments;
    } catch (e) {
      throw Exception('Failed to fetch moments: $e');
    }
  }

  static Future<void> addMoment(Moment moment) async {
    try {
      moment.hasLocation = moment.lat != 0 && moment.lng != 0;
      await momentsBox.add(moment);
      print(
        '💾 Moment added to Hive with paths: photos=${moment.photoPaths.length}, videos=${moment.videoPaths.length}',
      );
    } catch (e) {
      throw Exception('Failed to add moment: $e');
    }
  }

  static Future<void> updateMoment(Moment moment) async {
    try {
      await moment.save();
    } catch (e) {
      throw Exception('Failed to update moment: $e');
    }
  }

  static Future<void> deleteMoment(Moment moment) async {
    try {
      for (var p in moment.photoPaths) {
        await StorageService.deleteFile(p);
      }
      for (var p in moment.videoPaths) {
        await StorageService.deleteFile(p);
      }
      await moment.delete();
    } catch (e) {
      throw Exception('Failed to delete moment: $e');
    }
  }
}
