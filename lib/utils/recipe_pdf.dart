import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../models/recipe.dart';

// Vygeneruje PDF dokument z objektu Recipe
Future<pw.Document> recipeToPdf(Recipe recipe) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4, // Formát strany A4
      build: (pw.Context context) {
        // Hlavný kontajner s paddingom
        return pw.Container(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Nadpis receptu
              pw.Text(recipe.title, style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              // Kategória receptu (ak je zadaná)
              if (recipe.category != null)
                pw.Text('Category: ${recipe.category}', style: pw.TextStyle(fontSize: 16, fontStyle: pw.FontStyle.italic)),
              pw.SizedBox(height: 16),
              // Zoznam ingrediencií
              pw.Text('Ingredients:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Bullet(text: recipe.ingredients.join('\n')),
              pw.SizedBox(height: 16),
              // Postup receptu
              pw.Text('Procedure:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(recipe.procedure, style: pw.TextStyle(fontSize: 14)),
            ],
          ),
        );
      },
    ),
  );
  return pdf;
}
