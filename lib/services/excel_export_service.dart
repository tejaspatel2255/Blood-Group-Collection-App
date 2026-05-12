import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/family_model.dart';

class ExcelExportService {
  Future<void> exportFamiliesToExcel(List<FamilyModel> families) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Family Registry'];
      excel.setDefaultSheet('Family Registry');
      
      // Header row
      List<String> headers = [
        'Serial No',
        'Name',
        'Father/Husband',
        'DOB',
        'Age',
        'Blood Group',
        'Education',
        'Occupation',
        'Mobile',
        'City',
        'State',
        'Members Count'
      ];
      sheetObject.appendRow(headers.map((h) => TextCellValue(h)).toList());
      
      // Data rows
      for (var family in families) {
        List<String> row = [
          family.serialNumber,
          family.hofName,
          family.fatherHusbandName,
          family.dob != null ? DateFormat('dd/MM/yyyy').format(family.dob!) : '',
          family.age.toString(),
          family.bloodGroup,
          family.education,
          family.occupation,
          family.mobile,
          family.city,
          family.state,
          (family.members.length + 1).toString(), // HOF + Members
        ];
        sheetObject.appendRow(row.map((e) => TextCellValue(e)).toList());
      }
      
      // Save file
      var bytes = excel.encode()!;
      final dir = await getApplicationDocumentsDirectory();
      final String filePath = '${dir.path}/Family_Registry_Export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      
      File file = File(filePath);
      await file.writeAsBytes(bytes);
      
      // Share file
      await Share.shareXFiles([XFile(filePath)], text: 'Family Registry Data Export');
      
    } catch (e) {
      throw Exception('Failed to export to Excel: $e');
    }
  }
}
