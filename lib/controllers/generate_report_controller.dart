import 'package:get/get.dart';

class GenerateReportController extends GetxController {
  final Rx<DateTime> _fromDate = DateTime.now().obs;
  final Rx<DateTime> _toDate = DateTime.now().obs;

  Rx<DateTime> getFromDate() {
    return _fromDate;
  }

  Rx<DateTime> getToDate() {
    return _toDate;
  }

  set fromDate(DateTime fromDate) {
    _fromDate.value = fromDate;
  }

  set toDate(DateTime toDate) {
    _toDate.value = toDate;
  }



}