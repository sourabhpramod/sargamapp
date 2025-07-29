import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GetParticipantInfoPage extends StatefulWidget {
  const GetParticipantInfoPage({super.key});

  @override
  State<GetParticipantInfoPage> createState() => _GetParticipantInfoPageState();
}

class _GetParticipantInfoPageState extends State<GetParticipantInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _regidController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  Map<String, dynamic>? _participantData;
  String? _errorMessage;
  
  static const String baseUrl = 'http://192.168.0.101:8000';

  @override
  void dispose() {
    _nameController.dispose();
    _regidController.dispose();
    super.dispose();
  }

  Future<void> _fetchParticipantInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if at least one field is provided
    if (_nameController.text.trim().isEmpty && _regidController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide either name or registration ID'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _participantData = null;
      _errorMessage = null;
    });

    try {
      // Build query parameters
      List<String> queryParams = [];
      if (_nameController.text.trim().isNotEmpty) {
        queryParams.add('name=${Uri.encodeComponent(_nameController.text.trim())}');
      }
      if (_regidController.text.trim().isNotEmpty) {
        queryParams.add('regid=${Uri.encodeComponent(_regidController.text.trim())}');
      }
      
      final queryString = queryParams.join('&');
      final url = '$baseUrl/participant-info/?$queryString';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _participantData = data;
          _errorMessage = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Participant info fetched successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _errorMessage = errorData['error'] ?? 'Failed to fetch participant info';
          _participantData = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: Unable to connect to server';
        _participantData = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error: Unable to connect to server'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _nameController.clear();
    _regidController.clear();
    setState(() {
      _participantData = null;
      _errorMessage = null;
    });
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Not available';
    }
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.deepOrange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantInfoDisplay() {
    if (_participantData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.deepOrange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Participant Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildInfoCard(
            'Registration ID',
            _participantData!['regid'] ?? 'Not available',
            Icons.badge,
          ),
          
          _buildInfoCard(
            'Name',
            _participantData!['name'] ?? 'Not available',
            Icons.person_outline,
          ),
          
          _buildInfoCard(
            'Email',
            _participantData!['email'] ?? 'Not available',
            Icons.email_outlined,
          ),
          
          _buildInfoCard(
            'Phone Number',
            _participantData!['phonenumber'] ?? 'Not available',
            Icons.phone_outlined,
          ),
          
          _buildInfoCard(
            'Transaction Time',
            _formatDateTime(_participantData!['transaction_timestamp']),
            Icons.access_time,
          ),
          
          _buildInfoCard(
            'Emails Sent',
            _formatDateTime(_participantData!['emails_sent']),
            Icons.mail_outline,
          ),
          
          _buildInfoCard(
            'QR Generated',
            _formatDateTime(_participantData!['qr_generated']),
            Icons.qr_code,
          ),
          
          if (_participantData!['qr_url'] != null && _participantData!['qr_url'].toString().isNotEmpty)
            _buildInfoCard(
              'QR Code URL',
              _participantData!['qr_url'],
              Icons.link,
            ),
          
          _buildInfoCard(
            'Created At',
            _formatDateTime(_participantData!['created_at']),
            Icons.calendar_today,
          ),
          
          _buildInfoCard(
            'Last Updated',
            _formatDateTime(_participantData!['updated_at']),
            Icons.update,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text(
          "Get Participant Info",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_participantData != null || _errorMessage != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearForm,
              tooltip: 'Clear',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.search,
                      size: 48,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search Participant',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter either name or registration ID to fetch participant information',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Form Fields
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Criteria',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name (Optional)',
                        hintText: 'Enter participant name',
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.deepOrange),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.orange[25],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Registration ID Field
                    TextFormField(
                      controller: _regidController,
                      decoration: InputDecoration(
                        labelText: 'Registration ID (Optional)',
                        hintText: 'Enter registration ID',
                        prefixIcon: const Icon(Icons.badge_outlined, color: Colors.deepOrange),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.orange[25],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Search Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _fetchParticipantInfo,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.search, color: Colors.white),
                        label: Text(
                          _isLoading ? 'Searching...' : 'Search Participant',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Results Section
              if (_participantData != null) _buildParticipantInfoDisplay(),
              
              // Error Display
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[600],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 30),
              
              // Go Back Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Go Back",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}