// import 'dart:typed_data';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
//
// class PdfService {
//   /// Generate PDF bytes
//   static Future<Uint8List> generatePdf({
//     required String userName,
//     required String userEmail,
//     required double totalIncome,
//     required double totalExpenses,
//     required double balance,
//     required List<Map<String, dynamic>> transactions,
//     required List<Map<String, dynamic>> categorySpending,
//   }) async {
//     final pdf = pw.Document();
//
//     // Add font to support Rupee symbol
//     final font = await PdfGoogleFonts.robotoRegular();
//     final fontBold = await PdfGoogleFonts.robotoBold();
//
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(24),
//         build: (context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               _buildHeader(font, fontBold),
//               pw.SizedBox(height: 12),
//               _buildUserInfo(userName, userEmail, font),
//               pw.SizedBox(height: 16),
//               _buildSummary(totalIncome, totalExpenses, balance, font, fontBold),
//               pw.SizedBox(height: 20),
//
//               if (transactions.isNotEmpty) ...[
//                 pw.Text(
//                   'Transaction Statement',
//                   style: pw.TextStyle(
//                     font: fontBold,
//                     fontSize: 18,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.blue800,
//                   ),
//                 ),
//                 pw.SizedBox(height: 10),
//                 _buildTransactionTable(transactions, font, fontBold),
//               ],
//
//               pw.Spacer(),
//               pw.Divider(),
//               _buildFooter(font),
//             ],
//           );
//         },
//       ),
//     );
//
//     return pdf.save();
//   }
//
//   // ---------------- HEADER ----------------
//   static pw.Widget _buildHeader(pw.Font font, pw.Font fontBold) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text(
//           'BUDGET BUDDY – FINANCIAL STATEMENT',
//           style: pw.TextStyle(
//             font: fontBold,
//             fontSize: 20,
//             fontWeight: pw.FontWeight.bold,
//             color: PdfColors.black,
//           ),
//         ),
//         pw.SizedBox(height: 4),
//         pw.Text(
//           'Period: ${DateFormat('MMM yyyy').format(DateTime.now())}',
//           style: pw.TextStyle(
//             font: font,
//             fontSize: 12,
//             color: PdfColors.grey700,
//           ),
//         ),
//         pw.SizedBox(height: 12),
//         pw.Divider(thickness: 1),
//       ],
//     );
//   }
//
//   // ---------------- USER INFO ----------------
//   static pw.Widget _buildUserInfo(String name, String email, pw.Font font) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(12),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: PdfColors.grey300),
//         borderRadius: pw.BorderRadius.circular(6),
//       ),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Text('Name: $name',
//               style: pw.TextStyle(font: font, fontSize: 12)),
//           pw.Text('Email: $email',
//               style: pw.TextStyle(font: font, fontSize: 12)),
//           pw.Text('Generated On: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
//               style: pw.TextStyle(font: font, fontSize: 12)),
//         ],
//       ),
//     );
//   }
//
//   // ---------------- SUMMARY ----------------
//   static pw.Widget _buildSummary(
//       double income,
//       double expenses,
//       double balance,
//       pw.Font font,
//       pw.Font fontBold,
//       ) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(16),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: PdfColors.grey300),
//         borderRadius: pw.BorderRadius.circular(6),
//       ),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Text(
//             'SUMMARY',
//             style: pw.TextStyle(
//               font: fontBold,
//               fontSize: 16,
//               fontWeight: pw.FontWeight.bold,
//               color: PdfColors.blue800,
//             ),
//           ),
//           pw.SizedBox(height: 12),
//           pw.Divider(),
//           pw.SizedBox(height: 8),
//           _summaryRow('Income', income, PdfColors.green, font, fontBold),
//           _summaryRow('Expenses', expenses, PdfColors.red, font, fontBold),
//           _summaryRow('Balance', balance,
//               balance >= 0 ? PdfColors.blue : PdfColors.red, font, fontBold, isBold: true),
//           pw.SizedBox(height: 8),
//           pw.Divider(),
//         ],
//       ),
//     );
//   }
//
//   static pw.Widget _summaryRow(
//       String label,
//       double amount,
//       PdfColor color,
//       pw.Font font,
//       pw.Font fontBold, {
//         bool isBold = false,
//       }) {
//     // Use Unicode Rupee symbol that works with most fonts: ₹
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 6),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(label,
//               style: pw.TextStyle(
//                 font: isBold ? fontBold : font,
//                 fontSize: 14,
//               )),
//           pw.Text(
//             '₹${amount.toStringAsFixed(2)}',
//             style: pw.TextStyle(
//               font: isBold ? fontBold : font,
//               fontSize: 14,
//               fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ---------------- TRANSACTION TABLE ----------------
//   static pw.Widget _buildTransactionTable(
//       List<Map<String, dynamic>> transactions,
//       pw.Font font,
//       pw.Font fontBold,
//       ) {
//     return pw.Table(
//       border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
//       columnWidths: {
//         0: const pw.FlexColumnWidth(1.5), // Date
//         1: const pw.FlexColumnWidth(3),   // Description
//         2: const pw.FlexColumnWidth(1.5), // Type
//         3: const pw.FlexColumnWidth(2),   // Amount
//       },
//       children: [
//         // Header
//         pw.TableRow(
//           decoration: const pw.BoxDecoration(color: PdfColors.grey200),
//           children: [
//             _tableHeader('Date', fontBold),
//             _tableHeader('Description', fontBold),
//             _tableHeader('Type', fontBold),
//             _tableHeader('Amount', fontBold),
//           ],
//         ),
//
//         // Rows
//         ...transactions.map((t) {
//           final isIncome = t['isIncome'] as bool;
//           final amount = t['amount'] as double;
//           final category = t['category']?.toString() ?? 'Other';
//           final date = t['date'] as DateTime;
//
//           return pw.TableRow(
//             decoration: const pw.BoxDecoration(
//               border: pw.Border(
//                 bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
//               ),
//             ),
//             children: [
//               _tableCell(
//                 DateFormat('dd MMM').format(date),
//                 font,
//               ),
//               _tableCell(category, font),
//               _tableCell(
//                 isIncome ? 'Credit' : 'Debit',
//                 font,
//                 color: isIncome ? PdfColors.green : PdfColors.red,
//                 bold: true,
//               ),
//               _tableCell(
//                 '₹${amount.toStringAsFixed(2)}',
//                 font,
//                 align: pw.TextAlign.right,
//                 color: isIncome ? PdfColors.green : PdfColors.red,
//                 bold: true,
//               ),
//             ],
//           );
//         }).toList(),
//       ],
//     );
//   }
//
//   static pw.Widget _tableHeader(String text, pw.Font fontBold) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(10),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           font: fontBold,
//           fontSize: 11,
//           fontWeight: pw.FontWeight.bold,
//         ),
//         textAlign: pw.TextAlign.center,
//       ),
//     );
//   }
//
//   static pw.Widget _tableCell(
//       String text,
//       pw.Font font, {
//         pw.TextAlign align = pw.TextAlign.left,
//         PdfColor? color,
//         bool bold = false,
//       }) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         textAlign: align,
//         style: pw.TextStyle(
//           font: bold ? font : font,
//           fontSize: 10,
//           fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//           color: color ?? PdfColors.black,
//         ),
//       ),
//     );
//   }
//
//   // ---------------- FOOTER ----------------
//   static pw.Widget _buildFooter(pw.Font font) {
//     return pw.Column(
//       children: [
//         pw.SizedBox(height: 8),
//         pw.Divider(),
//         pw.SizedBox(height: 10),
//         pw.Text(
//           'Generated by Budget Buddy App',
//           style: pw.TextStyle(
//             font: font,
//             fontSize: 10,
//             color: PdfColors.grey700,
//           ),
//           textAlign: pw.TextAlign.center,
//         ),
//       ],
//     );
//   }
//
//   // ---------------- PREVIEW ----------------
//   static Future<void> previewPdf(Uint8List pdfBytes) async {
//     await Printing.layoutPdf(
//       onLayout: (format) async => pdfBytes,
//     );
//   }
// }
// import 'dart:typed_data';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
//
// class PdfService {
//   /// Generate PDF bytes with selected month/year
//   static Future<Uint8List> generatePdf({
//     required String userName,
//     required String userEmail,
//     required double totalIncome,
//     required double totalExpenses,
//     required double balance,
//     required List<Map<String, dynamic>> transactions,
//     required DateTime selectedMonth, required List<Map<String, dynamic>> categorySpending,
//   }) async {
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(24),
//         build: (context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               _buildHeader(selectedMonth),
//               pw.SizedBox(height: 12),
//               _buildUserInfo(userName, userEmail, selectedMonth),
//               pw.SizedBox(height: 16),
//               _buildSummary(totalIncome, totalExpenses, balance),
//               pw.SizedBox(height: 20),
//
//               if (transactions.isNotEmpty) ...[
//                 pw.Text(
//                   'Transaction Statement - ${DateFormat('MMM yyyy').format(selectedMonth)}',
//                   style: pw.TextStyle(
//                     fontSize: 18,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.blue800,
//                   ),
//                 ),
//                 pw.SizedBox(height: 10),
//                 _buildTransactionTable(transactions),
//               ],
//
//               pw.Spacer(),
//               pw.Divider(),
//               _buildFooter(),
//             ],
//           );
//         },
//       ),
//     );
//
//     return pdf.save();
//   }
//
//   // ---------------- HEADER ----------------
//   static pw.Widget _buildHeader(DateTime selectedMonth) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text(
//           'BUDGET BUDDY',
//           style: pw.TextStyle(
//             fontSize: 24,
//             fontWeight: pw.FontWeight.bold,
//             color: PdfColors.blue900,
//           ),
//         ),
//         pw.Text(
//           'Financial Statement',
//           style: pw.TextStyle(
//             fontSize: 14,
//             color: PdfColors.grey700,
//           ),
//         ),
//         pw.SizedBox(height: 6),
//         pw.Text(
//           'For: ${DateFormat('MMMM yyyy').format(selectedMonth)}',
//           style:  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
//         ),
//         pw.Text(
//           'Generated on ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
//           style: const pw.TextStyle(fontSize: 10),
//         ),
//         pw.Divider(),
//       ],
//     );
//   }
//
//   // ---------------- USER INFO ----------------
//   static pw.Widget _buildUserInfo(String name, String email, DateTime selectedMonth) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(12),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: PdfColors.grey300),
//         borderRadius: pw.BorderRadius.circular(6),
//       ),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Text('Name: $name', style: const pw.TextStyle(fontSize: 12)),
//           pw.Text('Email: $email', style: const pw.TextStyle(fontSize: 12)),
//           pw.Text('Period: ${DateFormat('MMMM yyyy').format(selectedMonth)}',
//               style: const pw.TextStyle(fontSize: 12)),
//         ],
//       ),
//     );
//   }
//
//   // ---------------- SUMMARY ----------------
//   static pw.Widget _buildSummary(
//       double income,
//       double expenses,
//       double balance,
//       ) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(16),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: PdfColors.grey300),
//         borderRadius: pw.BorderRadius.circular(6),
//       ),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Text(
//             'Summary',
//             style: pw.TextStyle(
//               fontSize: 16,
//               fontWeight: pw.FontWeight.bold,
//               color: PdfColors.blue800,
//             ),
//           ),
//           pw.SizedBox(height: 10),
//           _summaryRow('Total Income', income, PdfColors.green),
//           _summaryRow('Total Expenses', expenses, PdfColors.red),
//           pw.Divider(),
//           _summaryRow(
//             'Balance',
//             balance,
//             balance >= 0 ? PdfColors.blue : PdfColors.red,
//             isBold: true,
//           ),
//         ],
//       ),
//     );
//   }
//
//   static pw.Widget _summaryRow(
//       String label,
//       double amount,
//       PdfColor color, {
//         bool isBold = false,
//       }) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 4),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
//           pw.Text(
//             '₹${amount.toStringAsFixed(2)}',
//             style: pw.TextStyle(
//               fontSize: 12,
//               fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ---------------- TRANSACTION TABLE ----------------
//   static pw.Widget _buildTransactionTable(
//       List<Map<String, dynamic>> transactions,
//       ) {
//     return pw.Table(
//       border: pw.TableBorder.all(color: PdfColors.grey300),
//       columnWidths: {
//         0: const pw.FlexColumnWidth(2),
//         1: const pw.FlexColumnWidth(3),
//         2: const pw.FlexColumnWidth(2),
//         3: const pw.FlexColumnWidth(2),
//       },
//       children: [
//         // Header
//         pw.TableRow(
//           decoration: const pw.BoxDecoration(color: PdfColors.grey200),
//           children: [
//             _tableHeader('Date'),
//             _tableHeader('Description'),
//             _tableHeader('Type'),
//             _tableHeader('Amount'),
//           ],
//         ),
//
//         // Rows
//         ...transactions.map((t) {
//           final isIncome = t['isIncome'] as bool;
//           return pw.TableRow(
//             children: [
//               _tableCell(
//                 DateFormat('dd MMM').format(t['date'] as DateTime),
//               ),
//               _tableCell(t['category'].toString()),
//               _tableCell(isIncome ? 'Credit' : 'Debit'),
//               _tableCell(
//                 '₹${(t['amount'] as double).toStringAsFixed(2)}',
//                 align: pw.TextAlign.right,
//                 color: isIncome ? PdfColors.green : PdfColors.red,
//                 bold: true,
//               ),
//             ],
//           );
//         }).toList(),
//       ],
//     );
//   }
//
//   static pw.Widget _tableHeader(String text) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontSize: 11,
//           fontWeight: pw.FontWeight.bold,
//         ),
//       ),
//     );
//   }
//
//   static pw.Widget _tableCell(
//       String text, {
//         pw.TextAlign align = pw.TextAlign.left,
//         PdfColor? color,
//         bool bold = false,
//       }) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         textAlign: align,
//         style: pw.TextStyle(
//           fontSize: 10,
//           fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//           color: color ?? PdfColors.black,
//         ),
//       ),
//     );
//   }
//
//   // ---------------- FOOTER ----------------
//   static pw.Widget _buildFooter() {
//     return pw.Column(
//       children: [
//         pw.SizedBox(height: 6),
//         pw.Text(
//           'Generated by Budget Buddy App',
//           style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
//         ),
//         pw.Text(
//           DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
//           style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
//         ),
//       ],
//     );
//   }
//
//   // ---------------- PREVIEW ----------------
//   static Future<void> previewPdf(Uint8List pdfBytes) async {
//     await Printing.layoutPdf(
//       onLayout: (format) async => pdfBytes,
//     );
//   }
// }


import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  /// Generate PDF bytes with selected month/year
  static Future<Uint8List> generatePdf({
    required String userName,
    required String userEmail,
    required double totalIncome,
    required double totalExpenses,
    required double balance,
    required List<Map<String, dynamic>> transactions,
    required DateTime selectedMonth,
    required List<Map<String, dynamic>> categorySpending,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(selectedMonth),
              pw.SizedBox(height: 12),
              _buildUserInfo(userName, userEmail, selectedMonth),
              pw.SizedBox(height: 16),
              _buildSummary(totalIncome, totalExpenses, balance),
              pw.SizedBox(height: 20),

              // Category Spending Section
              if (categorySpending.isNotEmpty) ...[
                pw.Text(
                  'Category Spending - ${DateFormat('MMM yyyy').format(selectedMonth)}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.purple800,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildCategorySpendingTable(categorySpending),
                pw.SizedBox(height: 20),
              ],

              // Transactions Section
              if (transactions.isNotEmpty) ...[
                pw.Text(
                  'Transaction Statement - ${DateFormat('MMM yyyy').format(selectedMonth)}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildTransactionTable(transactions),
              ],

              pw.Spacer(),
              pw.Divider(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ---------------- HEADER ----------------
  static pw.Widget _buildHeader(DateTime selectedMonth) {
    final monthName = DateFormat('MMMM yyyy').format(selectedMonth);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BUDGET BUDDY',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  'Financial Statement',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            // Month display
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue900),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                monthName,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'For Period: $monthName',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          'Generated on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
        ),
        pw.Divider(),
      ],
    );
  }

  // ---------------- USER INFO ----------------
  static pw.Widget _buildUserInfo(String name, String email, DateTime selectedMonth) {
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Name: $name', style: const pw.TextStyle(fontSize: 12)),
              pw.Text('Email: $email', style: const pw.TextStyle(fontSize: 12)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Period: ${DateFormat('MMMM yyyy').format(selectedMonth)}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                '${DateFormat('dd MMM').format(firstDay)} - ${DateFormat('dd MMM yyyy').format(lastDay)}',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- CATEGORY SPENDING TABLE ----------------
  static pw.Widget _buildCategorySpendingTable(
      List<Map<String, dynamic>> categorySpending) {
    // Calculate total for percentage calculation
    final totalExpenses = categorySpending.fold<double>(
      0.0,
          (sum, category) => sum + (category['amount'] as double),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableHeader('Category'),
            _tableHeader('Amount'),
            _tableHeader('Percentage'),
          ],
        ),

        // Rows
        ...categorySpending.map((category) {
          final amount = category['amount'] as double;
          final percentage = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0;

          return pw.TableRow(
            children: [
              _tableCell(category['name']?.toString() ?? 'Uncategorized'),
              _tableCell(
                '₹${amount.toStringAsFixed(2)}',
                align: pw.TextAlign.right,
                color: PdfColors.red,
              ),
              _tableCell(
                '${percentage.toStringAsFixed(1)}%',
                align: pw.TextAlign.right,
                color: PdfColors.blue,
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  // ---------------- SUMMARY ----------------
  static pw.Widget _buildSummary(
      double income,
      double expenses,
      double balance,
      ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 10),
          _summaryRow('Total Income', income, PdfColors.green),
          _summaryRow('Total Expenses', expenses, PdfColors.red),
          pw.Divider(),
          _summaryRow(
            'Balance',
            balance,
            balance >= 0 ? PdfColors.blue : PdfColors.red,
            isBold: true,
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryRow(
      String label,
      double amount,
      PdfColor color, {
        bool isBold = false,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
            '₹${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- TRANSACTION TABLE ----------------
  static pw.Widget _buildTransactionTable(
      List<Map<String, dynamic>> transactions,
      ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableHeader('Date'),
            _tableHeader('Category'),
            _tableHeader('Type'),
            _tableHeader('Amount'),
          ],
        ),

        // Rows
        ...transactions.map((t) {
          final isIncome = t['isIncome'] as bool;
          return pw.TableRow(
            children: [
              _tableCell(
                DateFormat('dd MMM').format(t['date'] as DateTime),
              ),
              _tableCell(t['category'].toString()),
              _tableCell(isIncome ? 'Credit' : 'Debit'),
              _tableCell(
                '₹${(t['amount'] as double).toStringAsFixed(2)}',
                align: pw.TextAlign.right,
                color: isIncome ? PdfColors.green : PdfColors.red,
                bold: true,
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(
      String text, {
        pw.TextAlign align = pw.TextAlign.left,
        PdfColor? color,
        bool bold = false,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  // ---------------- FOOTER ----------------
  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 6),
        pw.Text(
          'Generated by Budget Buddy App',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
        ),
        pw.Text(
          DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
        ),
      ],
    );
  }

  // ---------------- PREVIEW ----------------
  static Future<void> previewPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
    );
  }
}