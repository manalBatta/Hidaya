import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/providers/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/utils/auth_utils.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State {
  late Map<String, dynamic> userObj = {
    'displayname': '',
    'gender': '',
    'email': '',
    'country': '',
    'language': '',
    'role': '',
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
  late TextEditingController _bioController;

  List<String> _searchedCountries = [];
  bool _isSearchingCountry = false;

  List<String> _searchedLanguages = [];
  bool _isSearchingLanguage = false;

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

  @override
  void initState() {
    super.initState();
    // Get user data from provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final role = userProvider.user?['role'] ?? '';
    userObj = userProvider.user ?? getInitialUserObj(role);

    _usernameController = TextEditingController(
      text: userObj['username'] as String? ?? '',
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
    _bioController = TextEditingController(
      text: userObj['bio'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _languageController.dispose();
    _bioController.dispose();
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
                height: 600, // keep this for dialog size
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
                        if (userObj['role'] != 'user')
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
                      setState(() {
                        userObj['username'] = _usernameController.text;
                        userObj['email'] = _emailController.text;
                        userObj['gender'] = _gender ?? '';
                        userObj['country'] = _countryController.text;
                        userObj['language'] = _languageController.text;
                        userObj['bio'] = _bioController.text;
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
                text: userObj['username'] as String? ?? '',
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
                (userObj['certificate'] as Map<String, dynamic>)['institution'],
              ),
              SizedBox(height: 16),
              _buildDetailRow(
                'Certificate Title',
                (userObj['certificate'] as Map<String, dynamic>)['title'],
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
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
            userObj['bio'] as String? ?? '',
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
            children:
                (userObj['languagesSpoken'] as List)
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
                    userObj['savedLessons'].toString(),
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
                    userObj['savedQuestions'].toString(),
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

  Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('http://your-backend-url/api/user/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedData),
    );
    if (response.statusCode == 200) {
      // Success: update userObj with returned user info
      final updatedUser = jsonDecode(response.body);
      setState(() {
        userObj = updatedUser;
      });
      // Optionally show a success message
    } else {
      // Handle error: Optionally show an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

Map<String, dynamic> getInitialUserObj(String role) {
  if (role == 'certified_volunteer' || role == 'volunteer_pending') {
    return {
      'role': role,
      'username': '',
      'email': '',
      'gender': '',
      'country': '',
      'language': '',
      'certificate': {'institution': '', 'title': '', 'hasDocument': false},
      'bio': '',
      'languagesSpoken': [],
      'savedLessons': 0,
      'savedQuestions': 0,
    };
  } else if (role == 'user') {
    return {
      'role': 'user',
      'username': '',
      'email': '',
      'gender': '',
      'country': '',
      'language': '',
      'savedLessons': 0,
      'savedQuestions': 0,
    };
  } else if (role == 'admin') {
    return {
      'role': 'admin',
      'username': '',
      'email': '',
      'gender': '',
      'country': '',
      'language': '',
      // Add admin-specific fields if needed
      'savedLessons': 0,
      'savedQuestions': 0,
    };
  } else {
    // Default fallback
    return {
      'role': '',
      'username': '',
      'email': '',
      'gender': '',
      'country': '',
      'language': '',
      'savedLessons': 0,
      'savedQuestions': 0,
    };
  }
}
