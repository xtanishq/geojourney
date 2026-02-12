
import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:snap_journey/service/sharedPreferencesService.dart';

Future cutCredit(int cutCredit) async {
  var credit = await SharedPreferencesService.getCreditValue('Credit');
  credit -= cutCredit;
  SharedPreferencesService.setCreditValue(credit, 'Credit');
  AdsVariable.credits.value = credit;
}

Future addCredit(int addCredit) async {
  var credit = await SharedPreferencesService.getCreditValue('Credit');
  credit += addCredit;
  SharedPreferencesService.setCreditValue(credit, 'Credit');
  AdsVariable.credits.value = credit;
}
