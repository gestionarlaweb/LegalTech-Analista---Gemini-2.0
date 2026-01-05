import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:legal_analyzer/gemeni_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GeminiProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Analista de Contratos AI"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (provider.pdfBytes != null)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep,
                color: Color.fromARGB(255, 138, 18, 18),
              ),
              onPressed: () => provider.clear(),
            ),
        ],
      ),
      body: Column(
        children: [
          // ÁREA DEL PDF O BOTÓN CENTRAL
          Expanded(
            child: provider.pdfBytes != null
                ? SfPdfViewer.memory(
                    provider.pdfBytes!,
                    controller: provider.pdfController,
                  )
                : _buildEmptyState(provider),
          ),

          // PANEL INFERIOR (Solo si hay un PDF cargado)
          if (provider.pdfBytes != null) _buildChatPanel(provider, context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(GeminiProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_rounded, size: 100, color: Colors.indigo[100]),
          const SizedBox(height: 20),
          const Text(
            "Análisis Legal Inteligente",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _handlePickFile(provider),
            icon: const Icon(Icons.file_upload),
            label: const Text("SELECCIONAR PDF"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatPanel(GeminiProvider provider, BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cabecera con botón para cerrar respuesta
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  provider.isLoading ? "Procesando..." : "Análisis",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[300],
                  ),
                ),
                // BOTÓN PARA SALIR DE LA RESPUESTA
                if (!provider.isLoading &&
                    provider.responseMessage !=
                        "Documento cargado correctamente.")
                  GestureDetector(
                    onTap: () => provider.resetResponse(),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),

            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(),
              ),

            // Texto de respuesta con scroll
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      provider.responseMessage,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Campo de entrada tipo píldora
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (val) => _sendQuery(provider, context),
                    decoration: InputDecoration(
                      hintText: "Preguntar algo...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward, color: Colors.white),
                    onPressed: () => _sendQuery(provider, context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendQuery(GeminiProvider provider, BuildContext context) {
    if (_textController.text.isNotEmpty && !provider.isLoading) {
      provider.preguntar(_textController.text, context);
      _textController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _handlePickFile(GeminiProvider provider) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null) {
      provider.setPdf(result.files.first.bytes!);
    }
  }
}
