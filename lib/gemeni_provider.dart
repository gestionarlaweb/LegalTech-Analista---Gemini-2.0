import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class GeminiProvider extends ChangeNotifier {
  GenerativeModel? _model;
  Uint8List? _pdfBytes;
  String _responseMessage = "Sube un contrato para analizarlo.";
  bool _isLoading = false;
  final PdfViewerController _pdfController = PdfViewerController();

  // Getters para la UI
  Uint8List? get pdfBytes => _pdfBytes;
  String get responseMessage => _responseMessage;
  bool get isLoading => _isLoading;
  PdfViewerController get pdfController => _pdfController;

  GeminiProvider() {
    _initModel();
  }

  void _initModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return;

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'Eres un Analista Legal Pro. Analiza el PDF y responde ÚNICAMENTE en JSON. '
        'Formato: {"respuesta": "tu análisis", "cita": "frase exacta para buscar"}',
      ),
    );
  }

  void setPdf(Uint8List bytes) {
    _pdfBytes = bytes;
    _responseMessage = "Documento cargado correctamente.";
    notifyListeners();
  }

  Future<void> preguntar(String query, BuildContext context) async {
    if (_pdfBytes == null || _model == null) return;

    _isLoading = true;
    _responseMessage = "Gemini está analizando...";
    notifyListeners();

    try {
      final content = [
        Content.multi([
          DataPart('application/pdf', _pdfBytes!),
          TextPart(query),
        ]),
      ];

      final response = await _model!.generateContent(content);
      final rawText = response.text ?? "{}";

      // Limpiar el JSON de bloques de código Markdown
      final cleanJson = rawText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);

      _responseMessage = data['respuesta'] ?? "No se obtuvo respuesta.";

      // Resaltado automático
      if (data['cita'] != null && data['cita'].toString().isNotEmpty) {
        _pdfController.clearSelection();
        _pdfController.searchText(data['cita'].toString());
      }
    } catch (e) {
      _responseMessage = "Hubo un error en la consulta.";
      debugPrint("Error Gemini: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para resetear solo el texto de la respuesta y limpiar resaltados
  void resetResponse() {
    _responseMessage = "Documento cargado correctamente.";
    _pdfController.clearSelection();
    notifyListeners();
  }

  // Limpiar todo para subir un nuevo documento
  void clear() {
    _pdfBytes = null;
    _responseMessage = "Sube un contrato para analizarlo.";
    _pdfController.clearSelection();
    notifyListeners();
  }
}
