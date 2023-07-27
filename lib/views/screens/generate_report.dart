import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_app/controllers/generate_report_controller.dart';
import 'package:flutter_expense_tracker_app/controllers/home_controller.dart';
import 'package:flutter_expense_tracker_app/models/transaction.dart';
import 'package:flutter_expense_tracker_app/views/screens/pdf_viewer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

class GenerateReport extends StatelessWidget {
  const GenerateReport({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final GenerateReportController _generateReportController = Get.put(GenerateReportController());
    final HomeController _homeController = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(title: Text("Generate Report")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ElevatedButton(
                        child: Text("Pick From Date"),
                        onPressed: () async {
                          DateTime? fromDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(Duration(days: 100)),
                            lastDate: DateTime.now().add(Duration(days: 100)),
                          );
                          if (fromDate != null) {
                            _generateReportController.fromDate = fromDate;
                          }
                        },
                      ),
                      Obx(() {
                        return Text(DateFormat.yMMMd().format(_generateReportController.getFromDate().value));
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    children: [
                      ElevatedButton(
                        child: Text("Pick To Date"),
                        onPressed: () async {
                          DateTime? toDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(Duration(days: 100)),
                            lastDate: DateTime.now().add(Duration(days: 100)),
                          );
                          if (toDate != null) {
                            _generateReportController.toDate = toDate;
                          }
                        },
                      ),
                      Obx(() {
                        return Text(DateFormat.yMMMd().format(_generateReportController.getToDate().value));
                      }),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 40,),
            Center(
              child: ElevatedButton(
                child: Text("Generate Report"),
                onPressed: () async {

                  // PermissionStatus permissionResult = await Permission.manageExternalStorage
                  //     .request();
                  // print("permissionResult: ${permissionResult}");
                  //
                  // if (!await Permission.manageExternalStorage.isGranted) {
                  //   print("NO PERMISSION");
                  //   return;
                  // } else {
                  //   print("PERMISSION");
                  // }


                  // Create a new PDF document.
                  final PdfDocument document = PdfDocument();
                  // Add a PDF page and draw text.
                  final PdfPage page = document.pages.add();
                  final PdfGrid grid = PdfGrid();
                  grid.columns.add(count: 7);

                  final PdfGridRow headerRow = grid.headers.add(1)[0];
                  headerRow.style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);

                  headerRow.cells[0].value = 'Type';
                  headerRow.cells[1].value = 'Name';
                  headerRow.cells[2].value = 'Amount';
                  headerRow.cells[3].value = 'Date';
                  headerRow.cells[4].value = 'Time';
                  headerRow.cells[5].value = 'Category';
                  headerRow.cells[6].value = 'Mode';

                  for (TransactionModel transactionModel in _homeController.myTransactions) {
                    // Add rows to the grid.

                    if (transactionModel.date != null) {
                      print("SEE HERE: DATE: ${transactionModel.date}");
                      List<String> dateStringSplit = transactionModel.date!.split("/");
                      int date =  int.parse(dateStringSplit[1]);
                      int month = int.parse(dateStringSplit[0]);
                      int year = int.parse(dateStringSplit[2]);

                      print("DATE IS $date, $month, $year");

                      DateTime transactionDate = DateTime(year, month, date);
                      print("IS BEFORE: ${transactionDate.isBefore(_generateReportController.getToDate().value)}");
                      print("IS AFTER: ${transactionDate.isAfter(_generateReportController.getFromDate().value)}");
                      if (
                        transactionDate.isBefore(_generateReportController.getToDate().value) &&
                        transactionDate.isAfter(_generateReportController.getFromDate().value)
                      ) {
                        print("ADDING VALUE");
                        PdfGridRow row = grid.rows.add();
                        row.cells[0].value = transactionModel.type;
                        row.cells[1].value = transactionModel.name;
                        row.cells[2].value = transactionModel.amount;
                        row.cells[3].value = transactionModel.date;
                        row.cells[4].value = transactionModel.time;
                        row.cells[5].value = transactionModel.category;
                        row.cells[6].value = transactionModel.mode;
                      }
                    }
                  }

                  grid.style.cellPadding = PdfPaddings(left: 5, top: 5);
                  grid.draw(
                      page: page,
                      bounds: Rect.fromLTWH(
                          0, 0, page.getClientSize().width, page.getClientSize().height
                      )
                  );

                  final List<int> bytes = await document.save();
                  // Dispose the document.
                  document.dispose();

                  // Save the document.
                  // File('HelloWorld.pdf').writeAsBytes(await document.save());

                  //Get external storage directory
                  // Directory directory = (await getApplicationDocumentsDirectory());
                  Directory? directory = (await getExternalStorageDirectories(type: StorageDirectory.downloads))?.first;

                  if (directory == null) {
                  return;
                  }
                  //Get directory path
                  // String path = directory.path;
                  String path = "/storage/emulated/0/Download";
                  print("PATH: ${path}");

                  //Create an empty file to write PDF data
                  File file = File('$path/Output.pdf');
                  //Write PDF data
                  await file.writeAsBytes(bytes, flush: true);
                  //Open the PDF document in mobile
                  // OpenFile.open('$path/Output.pdf');
                  Get.snackbar(
                  "File Downloaded",
                  "The file has been downloaded and stored in downloads folder",
                  snackPosition: SnackPosition.BOTTOM,
                  colorText: Colors.white,
                  borderRadius: 10,
                  backgroundColor: Colors.green.withOpacity(0.5),
                  );
                  Get.to(() => PDFViewer(path: "$path/Output.pdf"));
                },
              ),
            ),
            SizedBox(height: 40,),
            Center(
              child: ElevatedButton(
                child: Text("ALl Transaction"),
                onPressed: () async {

                  // PermissionStatus permissionResult = await Permission.manageExternalStorage
                  //     .request();
                  // print("permissionResult: ${permissionResult}");
                  //
                  // if (!await Permission.manageExternalStorage.isGranted) {
                  //   print("NO PERMISSION");
                  //   return;
                  // } else {
                  //   print("PERMISSION");
                  // }


                  // Create a new PDF document.
                  final PdfDocument document = PdfDocument();
                  // Add a PDF page and draw text.
                  final PdfPage page = document.pages.add();
                  final PdfGrid grid = PdfGrid();
                  grid.columns.add(count: 7);

                  final PdfGridRow headerRow = grid.headers.add(1)[0];
                  headerRow.style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);

                  headerRow.cells[0].value = 'Type';
                  headerRow.cells[1].value = 'Name';
                  headerRow.cells[2].value = 'Amount';
                  headerRow.cells[3].value = 'Date';
                  headerRow.cells[4].value = 'Time';
                  headerRow.cells[5].value = 'Category';
                  headerRow.cells[6].value = 'Mode';

                  for (TransactionModel transactionModel in _homeController.myTransactions) {
                    // Add rows to the grid.

                    if (transactionModel.date != null) {
                      print("SEE HERE: DATE: ${transactionModel.date}");
                      List<String> dateStringSplit = transactionModel.date!.split("/");
                      int date =  int.parse(dateStringSplit[1]);
                      int month = int.parse(dateStringSplit[0]);
                      int year = int.parse(dateStringSplit[2]);

                      print("DATE IS $date, $month, $year");

                      DateTime transactionDate = DateTime(year, month, date);
                      // if (
                      // transactionDate.isBefore(_generateReportController.getToDate().value) &&
                      //     transactionDate.isAfter(_generateReportController.getToDate().value)
                      // ) {
                        print("ADDING VALUE");
                        PdfGridRow row = grid.rows.add();
                        row.cells[0].value = transactionModel.type;
                        row.cells[1].value = transactionModel.name;
                        row.cells[2].value = transactionModel.amount;
                        row.cells[3].value = transactionModel.date;
                        row.cells[4].value = transactionModel.time;
                        row.cells[5].value = transactionModel.category;
                        row.cells[6].value = transactionModel.mode;
                      // }
                    }
                  }

                  grid.style.cellPadding = PdfPaddings(left: 5, top: 5);
                  grid.draw(
                      page: page,
                      bounds: Rect.fromLTWH(
                          0, 0, page.getClientSize().width, page.getClientSize().height
                      )
                  );

                  final List<int> bytes = await document.save();
                  // Dispose the document.
                  document.dispose();

                  // Save the document.
                  // File('HelloWorld.pdf').writeAsBytes(await document.save());

                  //Get external storage directory
                  // Directory directory = (await getApplicationDocumentsDirectory());
                  Directory? directory = (await getExternalStorageDirectories(type: StorageDirectory.downloads))?.first;

                  if (directory == null) {
                    return;
                  }
                  //Get directory path
                  // String path = directory.path;
                  String path = "/storage/emulated/0/Download";
                  print("PATH: ${path}");

                  //Create an empty file to write PDF data
                  File file = File('$path/Output.pdf');
                  //Write PDF data
                  await file.writeAsBytes(bytes, flush: true);
                  //Open the PDF document in mobile
                  // OpenFile.open('$path/Output.pdf');
                  Get.snackbar(
                    "File Downloaded",
                    "The file has been downloaded and stored in downloads folder",
                    snackPosition: SnackPosition.BOTTOM,
                    colorText: Colors.white,
                    borderRadius: 10,
                    backgroundColor: Colors.green.withOpacity(0.5),
                  );
                  Get.to(() => PDFViewer(path: "$path/Output.pdf"));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
