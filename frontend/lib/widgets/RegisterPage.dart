import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/colors.dart';
import 'package:frontend/widgets/SignInPage.dart';
import 'package:frontend/widgets/CustomTextField.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _accountType = 'User';
  String? _gender;
  String? _country;
  String? _language;

  TextEditingController _countrySearchController = TextEditingController();
  List<String> _searchedCountries = [];
  bool _isSearchingCountry = false;

  TextEditingController _languageSearchController = TextEditingController();
  List<String> _searchedLanguages = [];
  bool _isSearchingLanguage = false;

  Future<List<String>> fetchCountries() async {
    final response = await http.get(
      Uri.parse('https://restcountries.com/v3.1/all'),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final countryNames =
          data
              .map<String>((item) => item['name']['common'].toString())
              .toList();
      countryNames.sort();
      return countryNames;
    } else {
      throw Exception('Failed to load countries');
    }
  }

  Future<List<String>> fetchLanguages() async {
    final response = await http.get(
      Uri.parse('https://restcountries.com/v3.1/all'),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final Set<String> languages = {};
      for (var item in data) {
        final langs = item['languages'];
        if (langs != null) {
          languages.addAll(langs.values.map((e) => e.toString()));
        }
      }
      final list = languages.toList();
      list.sort();
      return list;
    } else {
      throw Exception('Failed to load languages');
    }
  }

  Future<void> searchCountries(String query) async {
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

  Future<void> searchLanguages(String query) async {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.islamicGreen50,
              const Color(0xFFF4F0E7),
              AppColors.islamicGold500.withAlpha((255 * 0.2).toInt()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((255 * 0.85).toInt()),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.islamicGreen200),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.islamicGreen500.withAlpha(
                          (255 * 0.3).toInt(),
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with icon and text
                      Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.islamicGreen500,
                                  AppColors.islamicGreen600,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.islamicGreen600.withAlpha(
                                    128,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.nights_stay_outlined,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Hidaya',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.islamicGreen800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'هداية - Guidance in Faith',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.islamicGreen600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Account type selector (DropdownButton)
                      const Text(
                        'Account Type',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.islamicGreen700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
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
                        ),
                        value: _accountType,
                        items: const [
                          DropdownMenuItem(
                            value: 'Volunteer',
                            child: Text('Volunteer'),
                          ),
                          DropdownMenuItem(value: 'User', child: Text('User')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _accountType = value;
                            });
                          }
                        },
                        style: TextStyle(
                          color: AppColors.islamicGreen800,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 24),

                      const CustomTextField(
                        label: 'Username',
                        hint: 'Enter your username',
                      ),
                      const SizedBox(height: 16),

                      // Gender input
                      const Text(
                        'Gender',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.islamicGreen700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
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
                        ),
                        value: _gender,
                        hint: const Text('Select your gender'),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
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

                      const SizedBox(height: 16),

                      // Country input (async, searchable)
                      const Text(
                        'Country',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.islamicGreen700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _countrySearchController,
                        decoration: InputDecoration(
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
                          searchCountries(value);
                        },
                      ),
                      const SizedBox(height: 8),

                      if (_searchedCountries.isNotEmpty)
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
                                color: AppColors.islamicGreen500.withAlpha(30),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
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
                                    _countrySearchController.text = country;
                                    _country = country;
                                    _searchedCountries = [];
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Language input (async, searchable)
                      const Text(
                        'Language',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.islamicGreen700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _languageSearchController,
                        decoration: InputDecoration(
                          hintText: 'Search for your language',
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
                              _isSearchingLanguage
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
                          searchLanguages(value);
                        },
                      ),
                      const SizedBox(height: 8),

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
                                color: AppColors.islamicGreen500.withAlpha(30),
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
                                    _languageSearchController.text = language;
                                    _language = language;
                                    _searchedLanguages = [];
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),

                      const CustomTextField(
                        label: 'Email Address',
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      const CustomTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      const CustomTextField(
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        obscureText: true,
                      ),

                      const SizedBox(height: 16),

                      // Extra fields for Volunteer
                      if (_accountType == 'Volunteer') ...[
                        const CustomTextField(
                          label: 'Phone Number',
                          hint: 'Enter your phone number',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        const CustomTextField(
                          label: 'City',
                          hint: 'Enter your city',
                        ),
                        const SizedBox(height: 16),
                        const CustomTextField(
                          label: 'Skills',
                          hint: 'List your skills',
                        ),
                        const SizedBox(height: 16),
                        const CustomTextField(
                          label: 'Why do you want to volunteer?',
                          hint: 'Tell us why you want to volunteer',
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Submit Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: AppColors.islamicGreen500,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          shadowColor: AppColors.islamicGreen600.withAlpha(
                            (255 * 0.7).toInt(),
                          ),
                          elevation: 8,
                        ),
                        onPressed: () {
                          // Handle submit
                        },
                        child: Text(
                          _accountType == 'Volunteer'
                              ? 'Create Volunteer Account'
                              : 'Create User Account',
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Already have an account? Sign In',
                          style: TextStyle(
                            color: AppColors.islamicGreen600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Footer Quran quote
                      Column(
                        children: [
                          Text(
                            '"And it is He who sends down rain from heaven, and We produce thereby the vegetation of every kind."',
                            style: TextStyle(
                              color: AppColors.islamicGreen600,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '- Quran 6:99',
                            style: TextStyle(
                              color: AppColors.islamicGreen500,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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
    );
  }
}
