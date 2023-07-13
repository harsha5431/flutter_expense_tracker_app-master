import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_app/constants/colors.dart';
import 'package:flutter_expense_tracker_app/controllers/home_controller.dart';
import 'package:flutter_expense_tracker_app/controllers/theme_controller.dart';
import 'package:flutter_expense_tracker_app/models/currency.dart';
import 'package:flutter_expense_tracker_app/models/transaction.dart';
import 'package:flutter_expense_tracker_app/views/screens/add_transaction_screen.dart';
import 'package:flutter_expense_tracker_app/views/screens/all_transactions_screen.dart';
import 'package:flutter_expense_tracker_app/views/screens/chart_screen.dart';
import 'package:flutter_expense_tracker_app/views/screens/pdf_viewer.dart';
import 'package:flutter_expense_tracker_app/views/widgets/income_expense.dart';
import 'package:flutter_expense_tracker_app/views/widgets/placeholder_info.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final HomeController _homeController = Get.put(HomeController());
  final _themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: _appBar(),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 12.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 8.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your Balance',
                    style: TextStyle(
                      fontSize: 23.sp,
                      fontWeight: FontWeight.w400,
                      color: _themeController.color,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_homeController.selectedCurrency.symbol}${_homeController.totalBalance.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IncomeExpence(
                    isIncome: true,
                    symbol: _homeController.selectedCurrency.symbol,
                    amount: _homeController.totalIncome.value,
                  ),
                  // SizedBox(
                  //   width: 30.w,
                  // ),
                  IncomeExpence(
                    isIncome: false,
                    symbol: _homeController.selectedCurrency.symbol,
                    amount: _homeController.totalExpense.value,
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .04.h,
              ),
              _homeController.myTransactions.isEmpty
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.h,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Center(
                              child: IconButton(
                                  onPressed: () => _showDatePicker(context),
                                  icon: Icon(
                                    Icons.calendar_month,
                                    color: _themeController.color,
                                  ))),
                        ),
                        title: Text(
                          _homeController.selectedDate.day == DateTime.now().day
                              ? 'Today'
                              : DateFormat.yMd()
                                  .format(_homeController.selectedDate),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 7.h,
                            ),
                            Text(
                              _homeController.totalForSelectedDate < 0
                                  ? 'You spent'
                                  : 'You earned',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Text(
                              '${_homeController.selectedCurrency.symbol}${_homeController.totalForSelectedDate.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              PlaceholderInfo(),
              _homeController.myTransactions.isNotEmpty
                  ? Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 10.h),
                      child: GestureDetector(
                        onTap: () => Get.to(() => AllTransactionsScreen()),
                        child: Text('Show all transactions,'),
                      ),
                    )
                  : SizedBox(),
              Divider(color: Colors.red,),
              ElevatedButton(onPressed: () async {
                print("Button pressed..");

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
                  PdfGridRow row = grid.rows.add();
                  row.cells[0].value = transactionModel.type;
                  row.cells[1].value = transactionModel.name;
                  row.cells[2].value = transactionModel.amount;
                  row.cells[3].value = transactionModel.date;
                  row.cells[4].value = transactionModel.time;
                  row.cells[5].value = transactionModel.category;
                  row.cells[6].value = transactionModel.mode;
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

              }, child: Text("Generate Report"))
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () async {
            await Get.to(() => AddTransactionScreen());
            _homeController.getTransactions();
          },
          child: Icon(
            Icons.add,
          ),
        ),
      );
    });
  }

  _showDatePicker(BuildContext context) async {
    DateTime? pickerDate = await showDatePicker(
        context: context,
        firstDate: DateTime(2012),
        initialDate: DateTime.now(),
        lastDate: DateTime(2122));
    if (pickerDate != null) {
      _homeController.updateSelectedDate(pickerDate);
    }
  }

  AppBar _appBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () async {
          _themeController.switchTheme();
        },
        icon: Icon(Get.isDarkMode ? Icons.nightlight : Icons.wb_sunny),
        color: _themeController.color,
      ),
      actions: [
        IconButton(
          onPressed: () => Get.to(() => ChartScreen()),
          icon: Icon(
            Icons.bar_chart,
            size: 27.sp,
            color: _themeController.color,
          ),
        ),
        Row(
          children: [
            Text(
              _homeController.selectedCurrency.currency,
              style: TextStyle(
                fontSize: 14.sp,
                color: _themeController.color,
              ),
            ),
            SizedBox(
              width: 40,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  customItemsHeight: 10,
                  customButton: Icon(
                    Icons.keyboard_arrow_down,
                    color: _themeController.color,
                  ),
                  items: Currency.currencies
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item.currency,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    _homeController.updateSelectedCurrency((val as Currency));
                  },
                  itemHeight: 30.h,
                  dropdownPadding: EdgeInsets.all(4),
                  dropdownWidth: 105.w,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
