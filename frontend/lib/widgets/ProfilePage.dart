import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/widgets/CertificationViewer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/providers/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/utils/auth_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State {
  late Map<String, dynamic> userObj = {
    'id': '',
    'displayName': '',
    'email': '',
    'role': '',
    'gender': '',
    'country': '',
    'language': '',
    // Volunteer-specific fields (optional, only for volunteers)
    'volunteerProfile': {
      'certificate': {
        'institution': '',
        'title': '',
        'url': '',
        'uploadedAt': '',
        '_id': '',
      },
      'languages': [],
      'bio': '',
      '_id': '',
    },
    'savedQuestions': [],
    'savedLessons': [],
  };

  // Controllers for edit form
  final _editFormKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  String? _gender;
  late TextEditingController _countryController;
  late TextEditingController _languageController;
  TextEditingController? _bioController;

  // Volunteer-specific controllers
  late TextEditingController _certTitleController;
  late TextEditingController _certInstitutionController;
  late TextEditingController _spokenLanguagesController;

  // File handling
  PlatformFile? _selectedFile;
  String? _uploadedFileUrl;

  List<String> _searchedCountries = [];
  bool _isSearchingCountry = false;

  List<String> _searchedLanguages = [];
  bool _isSearchingLanguage = false;

  // Spoken languages for volunteers
  List<String> _selectedSpokenLanguages = [];
  List<String> _searchedSpokenLanguages = [];
  bool _isSearchingSpokenLanguages = false;

  Future<void> searchCountries(
    String query,
    void Function(void Function()) setState,
  ) async {
    if (query.isEmpty) {
      setState(() {
        _searchedCountries = [];
        _isSearchingCountry = false;
      });
      return;
    }
    setState(() {
      _isSearchingCountry = true;
    });
    final response = await http.get(
      Uri.parse('https://restcountries.com/v3.1/name/$query'),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final countryNames =
          data
              .map<String>((item) => item['name']['common'].toString())
              .toList();
      countryNames.sort();
      setState(() {
        _searchedCountries = countryNames;
        _isSearchingCountry = false;
      });
    } else {
      setState(() {
        _searchedCountries = [];
        _isSearchingCountry = false;
      });
    }
  }

  Future<void> searchLanguages(
    String query,
    void Function(void Function()) setState,
  ) async {
    if (query.isEmpty) {
      setState(() {
        _searchedLanguages = [];
        _isSearchingLanguage = false;
      });
      return;
    }
    setState(() {
      _isSearchingLanguage = true;
    });

    final response = await http.get(
      Uri.parse(
        'https://raw.githubusercontent.com/haliaeetus/iso-639/master/data/iso_639-1.json',
      ),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<String> languages = [];
      data.forEach((code, lang) {
        final name = lang['name']?.toString() ?? '';
        if (name.toLowerCase().contains(query.toLowerCase())) {
          languages.add(name);
        }
      });
      languages.sort();
      print(languages);
      setState(() {
        _searchedLanguages = languages;
        _isSearchingLanguage = false;
      });
    } else {
      setState(() {
        _searchedLanguages = [];
        _isSearchingLanguage = false;
      });
    }
  }

  Future<void> searchSpokenLanguages(
    String query,
    void Function(void Function()) setState,
  ) async {
    if (query.isEmpty) {
      setState(() {
        _searchedSpokenLanguages = [];
        _isSearchingSpokenLanguages = false;
      });
      return;
    }
    setState(() {
      _isSearchingSpokenLanguages = true;
    });

    final response = await http.get(
      Uri.parse(
        'https://raw.githubusercontent.com/haliaeetus/iso-639/master/data/iso_639-1.json',
      ),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<String> languages = [];
      data.forEach((code, lang) {
        final name = lang['name']?.toString() ?? '';
        if (name.toLowerCase().contains(query.toLowerCase())) {
          languages.add(name);
        }
      });
      languages.sort();
      setState(() {
        _searchedSpokenLanguages = languages;
        _isSearchingSpokenLanguages = false;
      });
    } else {
      setState(() {
        _searchedSpokenLanguages = [];
        _isSearchingSpokenLanguages = false;
      });
    }
  }

  Future<void> selectFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = result.files.single;

      setState(() {
        _selectedFile = file;
        _uploadedFileUrl = null; // Reset URL on new selection
      });
    }
  }

  Future<String> uploadFile(file) async {
    Uint8List? fileBytes;
    final fileName = file.name;
    // Platform-safe file bytes access
    if (file.bytes != null) {
      fileBytes = file.bytes;
    } else if (file.path != null) {
      fileBytes = await File(file.path!).readAsBytes();
    }

    if (fileBytes == null) {
      print('❌ Unable to read file bytes');
      return '';
    }
    try {
      final response = await Supabase.instance.client.storage
          .from('certifications') // ✅ use same bucket
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      if (response.isNotEmpty) {
        print('Upload successful');

        final publicUrl = Supabase.instance.client.storage
            .from('certifications') // ✅ use same bucket
            .getPublicUrl(fileName);

        print('🌍 Public URL: $publicUrl');
        return publicUrl;
      } else {
        print(' Error uploading: $response');
      }
    } catch (e) {
      print(' Exception during upload: $e');
    }

    return '';
  }

  @override
  void initState() {
    super.initState();
    // Get user data from provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final role = userProvider.user?['role'] ?? '';
    userObj = userProvider.user ?? getInitialUserObj(role);

    _usernameController = TextEditingController(
      text: userObj['displayName'] as String? ?? '',
    );
    _emailController = TextEditingController(
      text: userObj['email'] as String? ?? '',
    );
    _gender = userObj['gender'] as String?;
    _countryController = TextEditingController(
      text: userObj['country'] as String? ?? '',
    );
    _languageController = TextEditingController(
      text: userObj['language'] as String? ?? '',
    );

    // Initialize volunteer-specific controllers
    if (userObj['role'] != 'user') {
      _bioController = TextEditingController(text: _getBioValue());
      _certTitleController = TextEditingController(
        text: _getVolunteerField('certificate.title'),
      );
      _certInstitutionController = TextEditingController(
        text: _getVolunteerField('certificate.institution'),
      );
      _spokenLanguagesController = TextEditingController();

      // Initialize selected spoken languages
      _selectedSpokenLanguages = _getVolunteerLanguages();
    } else {
      // Initialize with empty controllers for non-volunteer users to avoid null issues
      _bioController = TextEditingController();
      _certTitleController = TextEditingController();
      _certInstitutionController = TextEditingController();
      _spokenLanguagesController = TextEditingController();
      _selectedSpokenLanguages = [];
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _languageController.dispose();
    _bioController?.dispose();
    _certTitleController.dispose();
    _certInstitutionController.dispose();
    _spokenLanguagesController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.islamicWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppColors.islamicGreen200),
              ),
              title: Text(
                'Edit Profile',
                style: TextStyle(
                  color: AppColors.islamicGreen800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 400,
                height: 800, // increased height for volunteer fields
                child: SingleChildScrollView(
                  child: Form(
                    key: _editFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Display Name',
                            labelStyle: TextStyle(
                              color: AppColors.islamicGreen700,
                              fontWeight: FontWeight.w500,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: AppColors.islamicGreen500,
                              fontWeight: FontWeight.w600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.islamicGreen200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.islamicGreen500,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.islamicWhite,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter your name'
                                      : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: AppColors.islamicGreen700,
                              fontWeight: FontWeight.w500,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: AppColors.islamicGreen500,
                              fontWeight: FontWeight.w600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.islamicGreen200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.islamicGreen500,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.islamicWhite,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter your email'
                                      : null,
                        ),
                        SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            labelStyle: TextStyle(
                              color: AppColors.islamicGreen700,
                              fontWeight: FontWeight.w500,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: AppColors.islamicGreen500,
                              fontWeight: FontWeight.w600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.islamicGreen200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.islamicGreen500,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.islamicWhite,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _gender = value;
                            });
                          },
                          style: TextStyle(
                            color: AppColors.islamicGreen800,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 12),
                        // Country input (async, searchable)
                        TextFormField(
                          controller: _countryController,
                          decoration: InputDecoration(
                            labelText: 'Country *',
                            labelStyle: TextStyle(
                              color: AppColors.islamicGreen700,
                              fontWeight: FontWeight.w500,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: AppColors.islamicGreen500,
                              fontWeight: FontWeight.w600,
                            ),
                            hintText: 'Search for your country',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.islamicGreen200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.islamicGreen500,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            suffixIcon:
                                _isSearchingCountry
                                    ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                    : null,
                          ),
                          onChanged: (value) {
                            searchCountries(value, setState);
                          },
                        ),
                        const SizedBox(height: 8),

                        if (_searchedCountries.isNotEmpty)
                          SizedBox(
                            height: 150, // or 200
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: AppColors.islamicGreen200,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.islamicGreen500.withAlpha(
                                      30,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListView.builder(
                                itemCount: _searchedCountries.length,
                                itemBuilder: (context, index) {
                                  final country = _searchedCountries[index];
                                  return ListTile(
                                    title: Text(
                                      country,
                                      style: TextStyle(
                                        color: AppColors.islamicGreen800,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _countryController.text = country;
                                        _searchedCountries = [];
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ),

                        SizedBox(height: 12),
                        TextFormField(
                          controller: _languageController,
                          decoration: InputDecoration(
                            labelText: 'Language',
                            labelStyle: TextStyle(
                              color: AppColors.islamicGreen700,
                              fontWeight: FontWeight.w500,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: AppColors.islamicGreen500,
                              fontWeight: FontWeight.w600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.islamicGreen200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.islamicGreen500,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.islamicWhite,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (value) {
                            searchLanguages(value, setState);
                          },
                        ),
                        if (_searchedLanguages.isNotEmpty)
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: AppColors.islamicGreen200,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.islamicGreen500.withAlpha(
                                    30,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchedLanguages.length,
                              itemBuilder: (context, index) {
                                final language = _searchedLanguages[index];
                                return ListTile(
                                  title: Text(
                                    language,
                                    style: TextStyle(
                                      color: AppColors.islamicGreen800,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _languageController.text = language;
                                      _searchedLanguages = [];
                                    });
                                  },
                                );
                              },
                            ),
                          ),

                        SizedBox(height: 12),
                        if (userObj['role'] != 'user') ...[
                          TextFormField(
                            controller: _bioController,
                            decoration: InputDecoration(
                              labelText: 'Bio',
                              labelStyle: TextStyle(
                                color: AppColors.islamicGreen700,
                                fontWeight: FontWeight.w500,
                              ),
                              floatingLabelStyle: TextStyle(
                                color: AppColors.islamicGreen500,
                                fontWeight: FontWeight.w600,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.islamicGreen200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.islamicGreen500,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.islamicWhite,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            maxLines: 2,
                          ),
                          SizedBox(height: 12),

                          // Spoken Languages
                          TextFormField(
                            controller: _spokenLanguagesController,
                            decoration: InputDecoration(
                              labelText: 'Spoken Languages *',
                              labelStyle: TextStyle(
                                color: AppColors.islamicGreen700,
                                fontWeight: FontWeight.w500,
                              ),
                              floatingLabelStyle: TextStyle(
                                color: AppColors.islamicGreen500,
                                fontWeight: FontWeight.w600,
                              ),
                              hintText: 'Type to search and select languages',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.islamicGreen200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.islamicGreen500,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              suffixIcon:
                                  _isSearchingSpokenLanguages
                                      ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                      : null,
                            ),
                            onChanged: (value) {
                              searchSpokenLanguages(value, setState);
                            },
                          ),
                          const SizedBox(height: 8),

                          if (_searchedSpokenLanguages.isNotEmpty)
                            Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: AppColors.islamicGreen200,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.islamicGreen500.withAlpha(
                                      30,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _searchedSpokenLanguages.length,
                                itemBuilder: (context, index) {
                                  final language =
                                      _searchedSpokenLanguages[index];
                                  final alreadySelected =
                                      _selectedSpokenLanguages.contains(
                                        language,
                                      );
                                  return ListTile(
                                    title: Text(
                                      language,
                                      style: TextStyle(
                                        color:
                                            alreadySelected
                                                ? AppColors.islamicGreen400
                                                : AppColors.islamicGreen800,
                                      ),
                                    ),
                                    trailing:
                                        alreadySelected
                                            ? const Icon(
                                              Icons.check,
                                              color: AppColors.islamicGreen400,
                                            )
                                            : null,
                                    onTap: () {
                                      setState(() {
                                        if (!alreadySelected) {
                                          _selectedSpokenLanguages.add(
                                            language,
                                          );
                                        }
                                        _spokenLanguagesController.clear();
                                        _searchedSpokenLanguages = [];
                                      });
                                    },
                                  );
                                },
                              ),
                            ),

                          if (_selectedSpokenLanguages.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Wrap(
                                spacing: 8,
                                children:
                                    _selectedSpokenLanguages
                                        .map(
                                          (lang) => Chip(
                                            label: Text(lang),
                                            onDeleted: () {
                                              setState(() {
                                                _selectedSpokenLanguages.remove(
                                                  lang,
                                                );
                                              });
                                            },
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),

                          SizedBox(height: 12),

                          // Certificate Title
                          TextFormField(
                            controller: _certTitleController,
                            decoration: InputDecoration(
                              labelText: 'Certification Title',
                              labelStyle: TextStyle(
                                color: AppColors.islamicGreen700,
                                fontWeight: FontWeight.w500,
                              ),
                              floatingLabelStyle: TextStyle(
                                color: AppColors.islamicGreen500,
                                fontWeight: FontWeight.w600,
                              ),
                              hintText: 'e.g., Quran Recitation Level 1',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.islamicGreen200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.islamicGreen500,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.islamicWhite,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),

                          // Certificate Institution
                          TextFormField(
                            controller: _certInstitutionController,
                            decoration: InputDecoration(
                              labelText: 'Certification Institution / Sheikh',
                              labelStyle: TextStyle(
                                color: AppColors.islamicGreen700,
                                fontWeight: FontWeight.w500,
                              ),
                              floatingLabelStyle: TextStyle(
                                color: AppColors.islamicGreen500,
                                fontWeight: FontWeight.w600,
                              ),
                              hintText: 'e.g., Sheikh Ahmad Al-Mansour',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.islamicGreen200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.islamicGreen500,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.islamicWhite,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),

                          // File Upload
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await selectFile();
                                  },
                                  icon: const Icon(Icons.upload_file),
                                  label: Text(
                                    _selectedFile != null
                                        ? (_uploadedFileUrl != null
                                            ? 'Uploaded: ${_selectedFile!.name}'
                                            : 'Selected: ${_selectedFile!.name}')
                                        : 'Upload New Certificate',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.islamicGreen400,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.islamicGreen600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.islamicGreen500,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    elevation: 4,
                    shadowColor: AppColors.islamicGreen600.withAlpha(128),
                  ),
                  onPressed: () async {
                    if (_editFormKey.currentState!.validate()) {
                      // Handle file upload if a new file is selected
                      String certUrl = '';
                      if (userObj['role'] != 'user' && _selectedFile != null) {
                        certUrl = await uploadFile(_selectedFile!);
                        if (certUrl.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to upload certificate'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      setState(() {
                        userObj['displayName'] = _usernameController.text;
                        userObj['email'] = _emailController.text;
                        userObj['gender'] = _gender ?? '';
                        userObj['country'] = _countryController.text;
                        userObj['language'] = _languageController.text;

                        // Set volunteer-specific fields
                        if (userObj['role'] != 'user') {
                          // For volunteers, save to volunteerProfile
                          if (userObj['volunteerProfile'] != null) {
                            final volunteerProfile =
                                userObj['volunteerProfile']
                                    as Map<String, dynamic>;
                            volunteerProfile['bio'] =
                                _bioController?.text ?? '';
                            volunteerProfile['languages'] =
                                _selectedSpokenLanguages;

                            // Update certificate information
                            if (volunteerProfile['certificate'] != null) {
                              final certificate =
                                  volunteerProfile['certificate']
                                      as Map<String, dynamic>;
                              certificate['title'] =
                                  _certTitleController?.text ?? '';
                              certificate['institution'] =
                                  _certInstitutionController?.text ?? '';
                              if (certUrl.isNotEmpty) {
                                certificate['url'] = certUrl;
                              }
                            } else {
                              volunteerProfile['certificate'] = {
                                'title': _certTitleController?.text ?? '',
                                'institution':
                                    _certInstitutionController?.text ?? '',
                                'url': certUrl.isNotEmpty ? certUrl : '',
                                'uploadedAt': DateTime.now().toIso8601String(),
                                '_id': '',
                              };
                            }
                          } else {
                            // Create volunteerProfile if it doesn't exist
                            userObj['volunteerProfile'] = {
                              'bio': _bioController?.text ?? '',
                              'languages': _selectedSpokenLanguages,
                              'certificate': {
                                'title': _certTitleController?.text ?? '',
                                'institution':
                                    _certInstitutionController?.text ?? '',
                                'url': certUrl.isNotEmpty ? certUrl : '',
                                'uploadedAt': DateTime.now().toIso8601String(),
                                '_id': '',
                              },
                              '_id': '',
                            };
                          }
                        } else if (userObj['role'] == 'user') {
                          // For regular users, save to top-level bio
                          userObj['bio'] = '';
                        }
                      });
                      await updateProfile(userObj);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUserInfoSection({
    bool showEdit = true,
    bool showButtons = true,
  }) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 96,
          height: 96,
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.islamicGreen500, AppColors.islamicGreen600],
            ),
            borderRadius: BorderRadius.circular(48),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.1 * 255).toInt()),
                blurRadius: 15,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(Icons.person, size: 48, color: Colors.white),
        ),
        // User Info
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text:
                    userObj['gender'] == 'Female'
                        ? 'Sister '
                        : userObj['gender'] == 'Male'
                        ? 'Brother '
                        : '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              TextSpan(
                text: userObj['displayName'] as String? ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.islamicGreen800,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        _buildInfoRow(Icons.email, userObj['email'] as String? ?? ''),
        SizedBox(height: 8),
        _buildInfoRow(Icons.location_on, userObj['country'] as String? ?? ''),
        SizedBox(height: 8),
        _buildInfoRow(Icons.language, userObj['language'] as String? ?? ''),
        if (showButtons) ...[
          SizedBox(height: 24),
          Divider(color: AppColors.islamicGreen200),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showEditProfileDialog,
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.islamicGreen600,
                    side: BorderSide(color: AppColors.islamicGreen300),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AuthUtils.logout(context);
                    // Optionally: Navigator.of(context).pushReplacementNamed('/login');
                  },
                  icon: Icon(Icons.logout, size: 16),
                  label: Text('Log Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    side: BorderSide(color: Colors.red[300]!),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.islamicGreen50,
              AppColors.islamicCream,
              AppColors.islamicGold50,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 768 &&
                        (userObj['role'] == 'volunteer_pending' ||
                            userObj['role'] == 'user')) {
                      // Center the profile card for pending volunteer or user
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 700),
                            child: _buildLeftColumn(),
                          ),
                        ],
                      );
                    } else if (constraints.maxWidth > 768 &&
                        userObj['role'] != 'volunteer_pending' &&
                        userObj['role'] != 'user') {
                      // Desktop layout for admin or certified_volunteer
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildLeftColumn()),
                          SizedBox(width: 24),
                          Expanded(child: _buildRightColumn()),
                        ],
                      );
                    } else {
                      // Mobile layout
                      return Column(
                        children: [
                          _buildLeftColumn(),
                          SizedBox(height: 24),
                          _buildRightColumn(),
                        ],
                      );
                    }
                  },
                ),

                // Footer Quote
                Container(
                  margin: EdgeInsets.only(top: 48),
                  padding: EdgeInsets.only(top: 32),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.islamicGreen200),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '"And those who believe and do righteous deeds - no fear shall they have, nor shall they grieve."',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.islamicGreen600,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '- Quran 2:62',
                        style: TextStyle(
                          color: AppColors.islamicGreen500,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    if (userObj['role'] == 'volunteer_pending') {
      return Column(children: [_buildPendingVolunteerSection()]);
    }
    return Column(
      children: [
        _buildCommonSection(),
        SizedBox(height: 24),
        if (userObj['role'] == 'admin') _buildAdminSection(),
        if (userObj['role'] == 'user' ||
            userObj['role'] == 'certified_volunteer')
          _buildSavedContentSection(),
      ],
    );
  }

  Widget _buildRightColumn() {
    if (userObj['role'] == 'volunteer_pending' || userObj['role'] == 'user') {
      return SizedBox.shrink();
    }
    return Column(
      children: [
        if (userObj['role'] == 'certified_volunteer')
          _buildCertifiedVolunteerSection(),
        if (userObj['role'] == 'admin') ...[
          _buildCertifiedVolunteerSection(),
          SizedBox(height: 24),
          _buildSavedContentSection(),
        ],
      ],
    );
  }

  Widget _buildPendingVolunteerSection() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.islamicGreen200),
      ),
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildUserInfoSection(showEdit: false, showButtons: false),
            SizedBox(height: 24),
            Divider(color: AppColors.islamicGreen200),
            SizedBox(height: 24),
            Icon(
              Icons.hourglass_top,
              color: AppColors.islamicGold400,
              size: 40,
            ),
            SizedBox(height: 16),
            Text(
              'Your application to become a Certified Muslim Volunteer is under review.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.islamicGreen700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'You will be recieved an email once your application is approved.\n\nThank you for your willingness to volunteer and contribute to our community!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.islamicGreen600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonSection() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.islamicGreen200),
      ),
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: _buildUserInfoSection(),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: AppColors.islamicGreen600),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 14, color: AppColors.islamicGreen600),
        ),
      ],
    );
  }

  Widget _buildCertifiedVolunteerSection() {
    return Column(
      children: [
        // Badge
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.islamicGreen50, AppColors.islamicGold50],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: AppColors.islamicGreen600),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.islamicGreen500,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Certified Muslim Volunteer',

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24),

        // Certificate Details
        _buildInfoCard(
          'Certification Details',
          Icons.military_tech,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'Institution',
                _getVolunteerField('certificate.institution'),
              ),
              SizedBox(height: 16),
              _buildDetailRow(
                'Certificate Title',
                _getVolunteerField('certificate.title'),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final certificateUrl = _getVolunteerField('certificate.url');
                  if (certificateUrl.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                CertificationViewer(fileUrl: certificateUrl),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No certificate available to view'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                icon: Icon(Icons.visibility),
                label: Text('View Certificate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.islamicGreen500,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),

        // Bio
        _buildInfoCard(
          'Islamic Background',
          Icons.description,
          Text(
            _getVolunteerField('bio'),
            style: TextStyle(color: AppColors.islamicGreen600, height: 1.5),
          ),
        ),
        SizedBox(height: 24),

        // Languages
        _buildInfoCard(
          'Languages Spoken',
          Icons.language,
          Wrap(
            spacing: 8,
            runSpacing: 8, // Adds vertical space between wrap elements
            children:
                _getVolunteerLanguages()
                    .map(
                      (lang) => Chip(
                        label: Text(lang),
                        backgroundColor: AppColors.islamicGreen200,
                        labelStyle: TextStyle(color: AppColors.islamicGreen600),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.islamicGold50, AppColors.islamicGreen50],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    color: AppColors.islamicGreen800,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.islamicGreen800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.settings),
                label: Text('Go to Admin Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.islamicGreen500,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              Text(
                'Quick Actions:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.islamicGreen800,
                ),
              ),
              SizedBox(height: 12),
              _buildActionTile(Icons.people, 'View Volunteers'),
              _buildActionTile(Icons.flag, 'Review Flags'),
              _buildActionTile(Icons.person_add, 'Promote Users'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedContentSection() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.islamicGreen200),
      ),
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved Content',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.islamicGreen800,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildContentCard(
                    Icons.book,
                    'Saved Lessons',
                    (userObj['savedLessons'] == null ||
                            userObj['savedLessons'].isEmpty)
                        ? 'start saving lessons'
                        : userObj['savedLessons'].length.toString(),
                    'lessons saved',
                    AppColors.islamicGreen50,
                    AppColors.islamicGreen600,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildContentCard(
                    Icons.help,
                    'My Questions',
                    (userObj['savedQuestions'] == null ||
                            userObj['savedQuestions'].isEmpty)
                        ? 'start saving questions'
                        : userObj['savedQuestions'].length.toString(),
                    'questions asked',
                    AppColors.islamicGold50,
                    AppColors.islamicGold400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, Widget content) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.islamicGreen200),
      ),
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.islamicGreen800, size: 20),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.islamicGreen800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.islamicGreen600,
          ),
        ),
        SizedBox(height: 4),
        Text(value, style: TextStyle(color: AppColors.islamicGreen600)),
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.islamicGreen600),
              SizedBox(width: 12),
              Text(title, style: TextStyle(color: AppColors.islamicGreen600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(
    IconData icon,
    String title,
    String count,
    String subtitle,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.islamicGreen800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          Text(subtitle, style: TextStyle(fontSize: 12, color: iconColor)),
        ],
      ),
    );
  }

  // Helper method to get volunteer profile fields safely
  String _getVolunteerField(String fieldPath) {
    if (userObj['volunteerProfile'] == null) {
      return '';
    }

    final volunteerProfile =
        userObj['volunteerProfile'] as Map<String, dynamic>;

    if (fieldPath.contains('.')) {
      final parts = fieldPath.split('.');
      final mainField = parts[0];
      final subField = parts[1];

      if (volunteerProfile[mainField] != null) {
        final subObject = volunteerProfile[mainField] as Map<String, dynamic>?;
        return subObject?[subField]?.toString() ?? '';
      }
    } else {
      return volunteerProfile[fieldPath]?.toString() ?? '';
    }

    return '';
  }

  // Helper method to get volunteer languages
  List<String> _getVolunteerLanguages() {
    if (userObj['volunteerProfile'] == null) {
      return [];
    }

    final volunteerProfile =
        userObj['volunteerProfile'] as Map<String, dynamic>;
    final languages = volunteerProfile['languages'] as List<dynamic>?;

    if (languages != null) {
      return languages.map((lang) => lang.toString()).toList();
    }

    return [];
  }

  // Helper method to get bio value for both user and volunteer roles
  String _getBioValue() {
    // For volunteers, bio is in volunteerProfile
    if (userObj['volunteerProfile'] != null) {
      final volunteerProfile =
          userObj['volunteerProfile'] as Map<String, dynamic>;
      return volunteerProfile['bio']?.toString() ?? '';
    }
    // For regular users, bio is directly in userObj
    return userObj['bio']?.toString() ?? '';
  }

  Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    final token = await AuthUtils.getValidToken(context);
    if (token == null) {
      // User was logged out due to expired token
      return;
    }

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request('PUT', Uri.parse(profile));

    // Build request body based on user role
    Map<String, dynamic> requestBody = {
      "displayName": updatedData['displayName'],
      "gender": updatedData['gender'],
      "email": updatedData['email'],
      "country": updatedData['country'],
      "language": updatedData['language'],
      "role": updatedData['role'],
    };

    // Add role-specific fields
    String role = updatedData['role'] as String? ?? '';
    if (role == 'certified_volunteer' ||
        role == 'volunteer_pending' ||
        role == 'volunteer') {
      // Volunteer-specific fields - handle both old and new structure
      if (updatedData['volunteerProfile'] != null) {
        // New structure with volunteerProfile
        final volunteerProfile =
            updatedData['volunteerProfile'] as Map<String, dynamic>;
        requestBody["bio"] = volunteerProfile['bio'] ?? '';
        requestBody["spoken_languages"] = volunteerProfile['languages'] ?? [];

        final certificate =
            volunteerProfile['certificate'] as Map<String, dynamic>?;
        requestBody["certification_title"] = certificate?['title'] ?? '';
        requestBody["certification_institution"] =
            certificate?['institution'] ?? '';
        requestBody["certification_url"] = certificate?['url'] ?? '';
      } else {
        // Fallback to old structure
        requestBody["bio"] = updatedData['bio'] ?? '';
        requestBody["spoken_languages"] = updatedData['languagesSpoken'] ?? [];

        final certificate = updatedData['certificate'] as Map<String, dynamic>?;
        requestBody["certification_title"] = certificate?['title'] ?? '';
        requestBody["certification_institution"] =
            certificate?['institution'] ?? '';
        requestBody["certification_url"] = certificate?['url'] ?? '';
      }
    }
    // For user and admin roles, only basic fields are sent (no bio, languages, or certificate)

    request.body = json.encode(requestBody);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      print(responseBody);

      // Success: update userObj with returned user info
      final responseData = jsonDecode(responseBody);
      final updatedUser = responseData['user']; // Extract user from response

      // Transform the API response to match frontend structure
      final transformedUser = {
        'id': updatedUser['userId'] ?? updatedUser['_id'],
        'displayName': updatedUser['displayName'],
        'email': updatedUser['email'],
        'role': updatedUser['role'],
        'gender': updatedUser['gender'],
        'country': updatedUser['country'],
        'language': updatedUser['language'],
        'volunteerProfile': updatedUser['volunteerProfile'],
        'savedQuestions': updatedUser['savedQuestions'] ?? [],
        'savedLessons': updatedUser['savedLessons'] ?? [],
      };

      // Only add bio field for non-volunteer users
      if (updatedUser['role'] == 'user' || updatedUser['role'] == 'admin') {
        transformedUser['bio'] = updatedUser['bio'] ?? '';
      }

      setState(() {
        userObj = transformedUser;
      });

      // Update the UserProvider with the transformed data
      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).setUser(transformedUser);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      print(response.reasonPhrase);
      // Handle error: show an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          ),
        );
      }
    }
  }
}

Map<String, dynamic> getInitialUserObj(String role) {
  if (role == 'certified_volunteer' ||
      role == 'volunteer_pending' ||
      role == 'volunteer') {
    return {
      'id': '',
      'displayName': '',
      'email': '',
      'role': role,
      'gender': '',
      'country': '',
      'language': '',
      'volunteerProfile': {
        'certificate': {
          'institution': '',
          'title': '',
          'url': '',
          'uploadedAt': '',
          '_id': '',
        },
        'languages': [],
        'bio': '',
        '_id': '',
      },
      'savedQuestions': [],
      'savedLessons': [],
    };
  } else if (role == 'user') {
    return {
      'id': '',
      'displayName': '',
      'email': '',
      'role': 'user',
      'gender': '',
      'country': '',
      'language': '',
      'savedQuestions': [],
      'savedLessons': [],
    };
  } else if (role == 'admin') {
    return {
      'id': '',
      'displayName': '',
      'email': '',
      'role': 'admin',
      'gender': '',
      'country': '',
      'language': '',
      'savedQuestions': [],
      'savedLessons': [],
    };
  } else {
    // Default fallback
    return {
      'id': '',
      'displayName': '',
      'email': '',
      'role': '',
      'gender': '',
      'country': '',
      'language': '',
      'savedQuestions': [],
      'savedLessons': [],
    };
  }
}
