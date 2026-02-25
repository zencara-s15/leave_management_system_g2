import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/db_connection_config.dart';
import '../services/mysql_service.dart';

class DbConnectionScreen extends StatefulWidget {
  const DbConnectionScreen({super.key});

  static const routeName = '/db-connection';

  @override
  State<DbConnectionScreen> createState() => _DbConnectionScreenState();
}

class _DbConnectionScreenState extends State<DbConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _databaseController = TextEditingController();

  bool _isLoading = false;
  String _message = 'Load connection settings and test the database.';

  @override
  void initState() {
    super.initState();
    _loadDefaultConfig();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _databaseController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultConfig() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/config/db_config.json',
      );
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final config = DbConnectionConfig.fromJson(map);

      _hostController.text = config.host;
      _portController.text = config.port.toString();
      _userController.text = config.user;
      _passwordController.text = config.password;
      _databaseController.text = config.database;

      if (!mounted) return;
      setState(() {
        _message = 'Default config loaded. Update values if needed.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _message = 'Could not load asset config: $error';
      });
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Connecting...';
    });

    final config = DbConnectionConfig(
      host: _hostController.text.trim(),
      port: int.parse(_portController.text.trim()),
      user: _userController.text.trim(),
      password: _passwordController.text,
      database: _databaseController.text.trim(),
    );

    final service = MySqlService(config);

    try {
      final result = await service.testConnection();
      if (!mounted) return;
      setState(() {
        _message = result;
      });
    } on DatabaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _message = error.message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _message = 'Unhandled error: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MySQL Connection')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Connection Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'If running on Android emulator, use host 10.0.2.2. '
                      'If running on Windows desktop, 127.0.0.1 works.',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Host',
                  controller: _hostController,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Port',
                  controller: _portController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'User',
                  controller: _userController,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Database',
                  controller: _databaseController,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testConnection,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Test MySQL Connection'),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_message),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }

        if (label == 'Port' && int.tryParse(value.trim()) == null) {
          return 'Port must be a number';
        }

        return null;
      },
    );
  }
}
