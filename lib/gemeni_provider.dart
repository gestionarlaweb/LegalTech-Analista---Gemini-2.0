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

  // Controlador para el visor de PDF
  final PdfViewerController _pdfController = PdfViewerController();

  // Getters para la interfaz de usuario
  Uint8List? get pdfBytes => _pdfBytes;
  String get responseMessage => _responseMessage;
  bool get isLoading => _isLoading;
  PdfViewerController get pdfController => _pdfController;

  GeminiProvider() {
    _initModel();
  }

  // Inicializa el modelo usando la API Key del archivo .env
  void _initModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return;

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'Eres un Analista Legal experto. Analiza el PDF adjunto y responde estrictamente en formato JSON. '
        'Formato: {"respuesta": "tu análisis aquí", "cita": "texto exacto del PDF para resaltar"}',
      ),
    );
  }

  // Carga los bytes del PDF seleccionado
  void setPdf(Uint8List bytes) {
    _pdfBytes = bytes;
    _responseMessage =
        "Documento cargado correctamente. ¿En qué puedo ayudarte?";
    notifyListeners();
  }

  // Envía la consulta a Gemini 2.0
  Future<void> preguntar(String query, BuildContext context) async {
    if (_pdfBytes == null || _model == null) return;

    _isLoading = true;
    _responseMessage = "Gemini está procesando el contrato...";
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

      // Limpieza de formato Markdown si Gemini lo incluye
      final cleanJson = rawText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);

      _responseMessage =
          data['respuesta'] ?? "No se obtuvo una respuesta válida.";

      // LÓGICA DE BÚSQUEDA Y RESALTADO
      if (data['cita'] != null && data['cita'].toString().isNotEmpty) {
        _pdfController.clearSelection();

        // Usamos la firma más compatible para evitar errores de versión
        _pdfController.searchText(data['cita'].toString());
      }
    } catch (e) {
      _responseMessage = "Ocurrió un error al analizar el documento.";
      debugPrint("Error de Gemini: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Resetea la respuesta para volver a ver el PDF limpio
  void resetResponse() {
    _responseMessage = "Documento cargado correctamente.";
    _pdfController.clearSelection();
    notifyListeners();
  }

  // Borra el documento actual
  void clear() {
    _pdfBytes = null;
    _responseMessage = "Sube un contrato para analizarlo.";
    _pdfController.clearSelection();
    notifyListeners();
  }
}
