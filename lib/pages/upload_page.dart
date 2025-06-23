import 'dart:typed_data';
import 'dart:math';
import 'dart:convert';
import 'dart:ui';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as p;

class UploadSection extends StatefulWidget {
  const UploadSection({super.key});

  @override
  State<UploadSection> createState() => _UploadSectionState();
}

class _UploadSectionState extends State<UploadSection> {
  List<PlatformFile> _selectedFiles = [];
  late DropzoneViewController _dropzoneController;
  bool _isHovering = false;
  bool _isUploading = false;
  bool _isProcessing = false;
  bool _showAnalysisPrompt = false;
  bool _isAnalyzing = false;
  final double _baseHeight = 200.0;
  final double _maxHeight = 280.0;
  String _status = "Ready to upload";
  double _overallProgress = 0.0;
  Map<String, double> _uploadProgress = {};
  Map<String, String> _fileStatuses = {};
  String? _currentSessionId;
  
  List<String> _processingMessages = [
    'Uploading files...',
    'Analyzing document structure...',
    'Extracting medical data...',
    'Validating test results...',
    'Generating insights...',
    'Storing in database...',
    'Finalizing report...'
  ];
  int _currentMessageIndex = 0;

  // Backend configuration
  static const String _uploadEndpoint = 'http://localhost:8001/upload';
  static const String _analysisEndpoint = 'http://localhost:8000/run';
  static const String _appName = 'lab_report_orchestrator';
  static const String _analysisAppName = 'lab_data_visualizer';
  
  @override
  void initState() {
    super.initState();
  }

  void _startMessageRotation() {
    if (!_isUploading && !_isProcessing && !_isAnalyzing) return;
    
    Future.delayed(const Duration(seconds: 2), () {
      if ((_isUploading || _isProcessing || _isAnalyzing) && mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _processingMessages.length;
          _status = _processingMessages[_currentMessageIndex];
        });
        _startMessageRotation();
      }
    });
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        _addFiles(result.files);
      }
    } catch (e) {
      _showError('Error selecting files: ${e.toString()}');
    }
  }

  void _addFiles(List<PlatformFile> newFiles) {
    setState(() {
      final uniqueFiles = newFiles.where((newFile) =>
          !_selectedFiles.any((existing) => existing.name == newFile.name));
      _selectedFiles.addAll(uniqueFiles);

      for (var file in uniqueFiles) {
        _uploadProgress[file.name] = 0.0;
        _fileStatuses[file.name] = 'ready';
      }
    });
  }

  void _removeFile(int index) {
    setState(() {
      final fileName = _selectedFiles[index].name;
      _uploadProgress.remove(fileName);
      _fileStatuses.remove(fileName);
      _selectedFiles.removeAt(index);
    });
  }

  void _updateOverallProgress() {
    if (_uploadProgress.isEmpty) {
      _overallProgress = 0.0;
      return;
    }

    double totalProgress = 0.0;
    for (var progress in _uploadProgress.values) {
      totalProgress += progress.clamp(0.0, 1.0);
    }
    _overallProgress = totalProgress / _uploadProgress.length;
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
      _isProcessing = false;
      _showAnalysisPrompt = false;
      _currentMessageIndex = 0;
      _status = _processingMessages[0];
      _overallProgress = 0.0;
    });

    _startMessageRotation();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('Authentication required. Please sign in.');
      setState(() {
        _isUploading = false;
        _status = "Ready to upload";
      });
      return;
    }

    final userId = user.uid;
    debugPrint('🔍 DEBUG: Using Firebase UID: $userId');

    int successCount = 0;
    int failCount = 0;
    List<String> successfulFiles = [];
    String? lastSessionId;

    for (int i = 0; i < _selectedFiles.length; i++) {
      final file = _selectedFiles[i];
      final sessionId = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
      lastSessionId = sessionId; // Keep track of the last session ID

      setState(() {
        _fileStatuses[file.name] = 'uploading';
        _uploadProgress[file.name] = 0.1;
        _updateOverallProgress();
      });

      try {
        var request = http.MultipartRequest('POST', Uri.parse(_uploadEndpoint))
          ..fields['user_id'] = userId
          ..fields['session_id'] = sessionId
          ..fields['app_name'] = _appName;

        request.files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ));

        debugPrint('🔍 DEBUG: Uploading ${file.name} with session_id: $sessionId');

        setState(() {
          _uploadProgress[file.name] = 0.3;
          _updateOverallProgress();
        });

        final response = await request.send();
        final responseData = await response.stream.bytesToString();

        debugPrint('🔍 DEBUG: Response status: ${response.statusCode}');
        debugPrint('🔍 DEBUG: Response data: $responseData');

        setState(() {
          _fileStatuses[file.name] = 'processing';
          _uploadProgress[file.name] = 0.6;
          _updateOverallProgress();
        });

        if (response.statusCode == 200) {
          if (!_isProcessing) {
            setState(() {
              _isProcessing = true;
              _currentMessageIndex = 2;
            });
          }

          await Future.delayed(const Duration(seconds: 3));

          bool isSuccessful = false;
          try {
            final jsonResponse = json.decode(responseData);
            isSuccessful = jsonResponse.toString().contains('successfully') ||
                          jsonResponse.toString().contains('stored') ||
                          jsonResponse.toString().contains('normal') ||
                          jsonResponse.toString().contains('critical');
          } catch (e) {
            isSuccessful = responseData.contains('successfully') ||
                          responseData.contains('stored') ||
                          responseData.contains('Report stored') ||
                          responseData.contains('✅') ||
                          responseData.contains('"status":"normal"') ||
                          responseData.contains('"status":"critical"');
          }

          if (isSuccessful) {
            successCount++;
            successfulFiles.add(file.name);
            setState(() {
              _fileStatuses[file.name] = 'success';
              _uploadProgress[file.name] = 1.0;
              _updateOverallProgress();
            });
            _showMessage('✅ ${file.name} processed successfully');
          } else {
            failCount++;
            setState(() {
              _fileStatuses[file.name] = 'failed';
              _uploadProgress[file.name] = -1.0;
              _updateOverallProgress();
            });
            _showError('❌ ${file.name} processing failed');
          }
        } else {
          failCount++;
          setState(() {
            _fileStatuses[file.name] = 'failed';
            _uploadProgress[file.name] = -1.0;
            _updateOverallProgress();
          });
          _showError('❌ ${file.name} upload failed (${response.statusCode})');
        }
      } catch (e) {
        failCount++;
        setState(() {
          _fileStatuses[file.name] = 'failed';
          _uploadProgress[file.name] = -1.0;
          _updateOverallProgress();
        });
        _showError('❌ ${file.name} error: ${e.toString()}');
        debugPrint('Upload error: $e');
      }

      if (i < _selectedFiles.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // Final processing phase
    setState(() {
      _currentMessageIndex = _processingMessages.length - 1;
      _status = _processingMessages.last;
    });
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isUploading = false;
      _isProcessing = false;
      _status = successCount > 0 
          ? 'Completed: $successCount successful${failCount > 0 ? ", $failCount failed" : ""}'
          : 'Upload failed for all files';

      _selectedFiles.removeWhere((file) => successfulFiles.contains(file.name));
      
      for (String fileName in successfulFiles) {
        _uploadProgress.remove(fileName);
        _fileStatuses.remove(fileName);
      }
      
      _updateOverallProgress();
    });

    if (successCount > 0) {
      _showMessage('🎉 Successfully processed $successCount file${successCount > 1 ? "s" : ""}!');
      
      // Store the session ID and show analysis prompt
      _currentSessionId = lastSessionId;
      
      // Show analysis prompt after a brief delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _showAnalysisPrompt = true;
          });
        }
      });
    }

    if (failCount > 0) {
      _showUploadSummary(successCount, failCount);
    }
  }

  Future<void> _runAnalysis() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('Authentication required. Please sign in.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _status = 'Starting analysis...';
      _currentMessageIndex = 0;
    });

    _startMessageRotation();

    try {
      final userId = user.uid;
      final sessionId = _currentSessionId ?? 'session_${DateTime.now().millisecondsSinceEpoch}';
      
      debugPrint('🔍 DEBUG: Starting analysis for user: $userId, session: $sessionId');

      final response = await http.post(
        Uri.parse(_analysisEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'appName': _analysisAppName,
          'userId': userId,
          'sessionId': sessionId,
          'newMessage': {
            'role': 'user',
            'parts': [
              {'text': userId}
            ]
          }
        }),
      );

      debugPrint('🔍 DEBUG: Analysis response status: ${response.statusCode}');
      debugPrint('🔍 DEBUG: Analysis response: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _isAnalyzing = false;
          _showAnalysisPrompt = false;
          _status = 'Analysis completed successfully!';
        });

        _showMessage('✅ Analysis completed! Redirecting to dashboard...');
        
        // Redirect to dashboard after a brief delay
        Future.delayed(const Duration(seconds: 2), () {
          _navigateToDashboard();
        });
      } else {
        throw Exception('Analysis failed with status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _status = 'Analysis failed';
      });
      _showError('❌ Analysis failed: ${e.toString()}');
      debugPrint('Analysis error: $e');
    }
  }

  void _navigateToDashboard() {
    // TODO: Navigate to dashboard page
    // Navigator.pushReplacementNamed(context, '/dashboard');
    debugPrint('🔍 DEBUG: Navigating to dashboard...');
    _showMessage('Dashboard navigation would happen here');
  }

  void _dismissAnalysisPrompt() {
    setState(() {
      _showAnalysisPrompt = false;
    });
  }

  void _showUploadSummary(int success, int failed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (success > 0)
              Text('✅ Successfully processed: $success', 
                   style: const TextStyle(color: Colors.green)),
            if (failed > 0)
              Text('❌ Failed uploads: $failed', 
                   style: const TextStyle(color: Colors.red)),
            if (failed > 0)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Please try again with the failed files'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDrop(dynamic event) async {
    setState(() => _isHovering = false);
    try {
      final fileName = await _dropzoneController.getFilename(event);
      final fileSize = await _dropzoneController.getFileSize(event);
      final mimeType = await _dropzoneController.getFileMIME(event);

      if (!['application/pdf', 'image/jpeg', 'image/png']
          .any((type) => mimeType.contains(type))) {
        _showError('Unsupported file type: $mimeType');
        return;
      }

      Uint8List fileBytes;
      try {
        fileBytes = await _dropzoneController.getFileData(event);
      } catch (e) {
        _showError('Error reading file data: ${e.toString()}');
        return;
      }

      setState(() {
        _selectedFiles.add(PlatformFile(
          name: fileName,
          size: fileSize,
          bytes: fileBytes,
        ));
        _uploadProgress[fileName] = 0.0;
        _fileStatuses[fileName] = 'ready';
      });
    } catch (e) {
      _showError('Error processing dropped file: ${e.toString()}');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double get _dynamicHeight {
    if (_selectedFiles.isEmpty) return _baseHeight;
    final calculatedHeight = _baseHeight + (_selectedFiles.length * 36.0);
    return calculatedHeight > _maxHeight ? _maxHeight : calculatedHeight;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme.copyWith(
      headlineSmall: theme.textTheme.headlineSmall?.copyWith(fontSize: 24),
      bodyLarge: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
      bodyMedium: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
      bodySmall: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
    );

    return Stack(
      children: [
        // Main content
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    colors: [Color(0xFF15191E), Color(0xFF1B2B34)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Color(0xFFE7F0FD), Color(0xFFF5F7E2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700), 
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lottie Animation
                    SizedBox(
                      height: 150,
                      child: Lottie.asset(
                        'animations/health-kernel.json',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Upload your health documents',
                      style: textTheme.headlineSmall?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'For secure storage and analysis',
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Upload area
                    SizedBox(
                      width: 700,
                      child: DottedBorder(
                        dashPattern: const [6, 4],
                        strokeWidth: 1.8,
                        color: _isHovering ? primary : primary.withOpacity(0.5),
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            if (_isWeb)
                              SizedBox(
                                width: double.infinity,
                                height: _dynamicHeight,
                                child: DropzoneView(
                                  operation: DragOperation.copy,
                                  onCreated: (ctrl) => _dropzoneController = ctrl,
                                  onHover: () => setState(() => _isHovering = true),
                                  onLeave: () => setState(() => _isHovering = false),
                                  onDrop: _handleDrop,
                                ),
                              ),
                            InkWell(
                              onTap: _isUploading ? null : _pickFiles,
                              child: Container(
                                width: double.infinity,
                                height: _dynamicHeight,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(_isHovering ? 0.08 : 0.05)
                                      : Colors.white.withOpacity(_isHovering ? 0.2 : 0.12),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: _selectedFiles.isEmpty
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.cloud_upload, size: 52, color: primary),
                                          const SizedBox(height: 14),
                                          Text(
                                            'Click to upload or drag files here',
                                            style: textTheme.bodyLarge?.copyWith(fontSize: 17),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '(PDFs or Images, max 10MB)',
                                            style: textTheme.bodySmall?.copyWith(fontSize: 13),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: _selectedFiles.length,
                                              itemBuilder: (ctx, index) => _buildFileItem(index),
                                            ),
                                          ),
                                          if (_selectedFiles.isNotEmpty && !_isUploading)
                                            TextButton.icon(
                                              icon: Icon(Icons.add, color: primary),
                                              label: Text('Add more files',
                                                  style: TextStyle(color: primary)),
                                              onPressed: _pickFiles,
                                            ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),

                    
                    const SizedBox(height: 20),

                    // Upload button
                    ElevatedButton.icon(
                      icon: _isUploading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        _isUploading ? "Processing..." : "Upload Files",
                        style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isUploading || _selectedFiles.isEmpty ? null : _uploadFiles,
                    ),

                    // Placeholder image
                    const SizedBox(height: 20),
                    Container(
                      height: 250,
                      width: 400,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: const Center(
                        child: Icon(Icons.image, size: 56, color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Status panel with progress
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (_isUploading || _isProcessing || _isAnalyzing)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  _status,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: _status.startsWith('❌') ? Colors.red : null,
                                    fontWeight: (_isUploading || _isAnalyzing) ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if ((_isUploading || _isProcessing || _isAnalyzing) && _selectedFiles.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: _overallProgress,
                              backgroundColor: isDark ? Colors.white12 : Colors.black12,
                              valueColor: AlwaysStoppedAnimation<Color>(primary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(_overallProgress * 100).toInt()}% complete',
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
        ),

        // Analysis Prompt Overlay
        if (_showAnalysisPrompt)
          Container(
            width: double.infinity,
            height: double.infinity,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(32.0),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(32.0),
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Success animation or icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 50,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Text(
                            'Upload Complete!',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            'Your health documents have been successfully processed. Ready to analyze your data?',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _dismissAnalysisPrompt,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Later'),
                                ),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: _isAnalyzing ? null : _runAnalysis,
                                  icon: _isAnalyzing
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.analytics),
                                  label: Text(
                                    _isAnalyzing ? 'Analyzing...' : 'Analyze Now!',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFileItem(int index) {
    final file = _selectedFiles[index];
    final progress = _uploadProgress[file.name] ?? 0.0;
    final status = _fileStatuses[file.name] ?? 'ready';
    final isFailed = status == 'failed';
    final isComplete = status == 'success';
    final isProcessing = status == 'processing' || status == 'uploading';

    Color getStatusColor() {
      switch (status) {
        case 'failed':
          return Colors.red;
        case 'success':
          return Colors.green;
        case 'uploading':
        case 'processing':
          return Theme.of(context).colorScheme.primary;
        default:
          return Theme.of(context).colorScheme.primary;
      }
    }

    IconData getStatusIcon() {
      switch (status) {
        case 'failed':
          return Icons.error;
        case 'success':
          return Icons.check_circle;
        case 'uploading':
          return Icons.upload;
        case 'processing':
          return Icons.hourglass_empty;
        default:
          return Icons.description;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            getStatusIcon(),
            size: 20,
            color: getStatusColor(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatFileSize(file.size),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${_getFileExtension(file.name).toUpperCase()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: getStatusColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (isProcessing && progress > 0) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(getStatusColor()),
                  ),
                ],
              ],
            ),
          ),
          if (!_isUploading && !isProcessing)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => _removeFile(index),
              splashRadius: 16,
            ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _getFileExtension(String fileName) {
    return p.extension(fileName).replaceFirst('.', '');
  }

  bool get _isWeb {
    return identical(0, 0.0);
  }
}