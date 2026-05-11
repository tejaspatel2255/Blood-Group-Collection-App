import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/family_model.dart';
import 'package:intl/intl.dart';

class PdfService {
  Future<void> generateFamilyIDCard(FamilyModel family) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Family Registry ID Card', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Family ID: ${family.serialNumber}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Head of Family: ${family.headOfFamily.firstName} ${family.headOfFamily.lastName}', style: const pw.TextStyle(fontSize: 14)),
                        pw.Text('Mobile: +91 ${family.headOfFamily.mobileNumber}', style: const pw.TextStyle(fontSize: 14)),
                        pw.Text('Address: ${family.headOfFamily.village}, ${family.headOfFamily.district}', style: const pw.TextStyle(fontSize: 14)),
                        pw.Text('Registered: ${family.createdAt != null ? DateFormat('dd/MM/yyyy').format(family.createdAt!) : 'N/A'}', style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Text('Family Members', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                context: context,
                headers: ['Name', 'Relation', 'Age', 'Blood Group'],
                data: [
                  [
                    '${family.headOfFamily.firstName} ${family.headOfFamily.lastName}',
                    'Self (HOF)',
                    family.headOfFamily.age.toString(),
                    family.headOfFamily.bloodGroup,
                  ],
                  ...family.members.map((m) => [
                        '${m.firstName} ${m.lastName}',
                        m.relationWithHOF,
                        m.age.toString(),
                        m.bloodGroup,
                      ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Family_ID_${family.serialNumber}.pdf',
    );
  }
}
