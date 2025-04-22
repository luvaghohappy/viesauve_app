import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../const.dart' as AppConstants show baseUrl;

class MultiStepForm extends StatefulWidget {
  @override
  _MultiStepFormState createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  // Controllers for user inputs
  TextEditingController dateNaissanceController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  List<Map<String, dynamic>> secteurs = [];

  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();
  File? _imageFile;
  bool _isPasswordValid = true;
  bool _isPasswordMatch = true;

  void _validatePassword() {
    setState(() {
      if (passwordController.text.length < 8) {
        _isPasswordValid = false;
      } else {
        _isPasswordValid = true;
      }

      if (passwordController.text != confirmPasswordController.text) {
        _isPasswordMatch = false;
      } else {
        _isPasswordMatch = true;
      }
    });
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('Aucune image sélectionnée.');
      }
    });
  }

  Future<void> saveUserData(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  // Champs de formulaire
  bool _obscurePassword = true;
  bool _obscureTextConf = true;
  String? nom, prenom, adresse, etatCivil;
  String? sexe;
  String? selectedSecteurId;
  String? groupeSanguin, allergies, maladies, medicaments;
  bool estMarie = false;
  List<Map<String, String>> enfants = [];
  String? contactUrgenceNom, contactUrgenceLien, contactUrgenceTel;

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Process form submission
      print("Formulaire soumis");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSecteurs();
  }

  Future<void> fetchSecteurs() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}getsecteur.php"),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          secteurs =
              data.map<Map<String, dynamic>>((item) {
                return {
                  'id_secteur': item['id_secteur'].toString(),
                  'nom_secteur': item['nom_secteur'],
                };
              }).toList();
        });
      }
    } catch (e) {
      print("Erreur chargement secteurs: $e");
    }
  }

  Future<void> showMessageDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> insertData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${AppConstants.baseUrl}insertuser.php"),
    );

    // Ajout des champs utilisateur
    request.fields.addAll({
      "noms": nom ?? '',
      "sexe": sexe ?? '',
      "date_naissance": dateNaissanceController.text.trim(),
      "secteur_id": selectedSecteurId ?? '',
      "adresse": adresse ?? '',
      "telephone": phoneController.text.trim(),
      "email": emailController.text.trim(),
      "etat_civil": etatCivil ?? '',
      "groupe_sanguin": groupeSanguin ?? '',
      "allergies": allergies ?? '',
      "maladies": maladies ?? '',
      "medicaments": medicaments ?? '',
      "contact_urgence_nom": contactUrgenceNom ?? '',
      "contact_urgence_lien": contactUrgenceLien ?? '',
      "contact_urgence_tel": contactUrgenceTel ?? '',
      "mot_de_passe": passwordController.text.trim(),
      "conf_passe": confirmPasswordController.text.trim(),
      "enfants": jsonEncode(enfants),
    });

    if (_imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );
    }

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("Réponse brute du serveur : $responseBody");
      print("Code de statut HTTP : ${response.statusCode}");

      if (response.statusCode == 200) {
        try {
          var jsonResponse = json.decode(responseBody);

          if (jsonResponse["success"] == true) {
            String idUser = jsonResponse["id_user"].toString();
            String secteurId = jsonResponse["secteur_id"].toString();

            await prefs.setString("id_user", idUser);
            await prefs.setString("secteur_id", secteurId);
            await prefs.setString("noms", nom ?? '');
            await prefs.setString("sexe", sexe ?? '');
            await prefs.setString(
              "date_naissance",
              dateNaissanceController.text.trim(),
            );
            await prefs.setString("groupe_sanguin", groupeSanguin ?? '');

            // 🔹 Afficher un dialogue de succès
            await showMessageDialog(
              "Succès",
              "Données enregistrées avec succès!",
            );

            // Nettoyage des champs
            nom = "";
            sexe = "";
            dateNaissanceController.clear();
            adresse = "";
            phoneController.clear();
            emailController.clear();
            etatCivil = "";
            groupeSanguin = "";
            allergies = "";
            maladies = "";
            medicaments = "";
            contactUrgenceNom = "";
            contactUrgenceLien = "";
            contactUrgenceTel = "";
            passwordController.clear();
            confirmPasswordController.clear();
            _imageFile = null;
            enfants.clear();

            setState(() {});
          } else {
            await showMessageDialog(
              "Erreur",
              "Erreur : ${jsonResponse["error"]}",
            );
          }
        } catch (e) {
          print("Erreur lors du décodage JSON : $e");
          await showMessageDialog(
            "Erreur",
            "Erreur serveur : réponse invalide.",
          );
        }
      } else {
        await showMessageDialog("Erreur", "Erreur lors de l'enregistrement.");
      }
    } catch (e) {
      print("Erreur lors de l'envoi de la requête : $e");
      await showMessageDialog("Exception", "Exception : $e");
    }
  }

  Step _buildStep1() {
    return Step(
      title: Text("Infos personnelles"),
      content: Column(
        children: [
          _buildTextField("Noms", (value) => nom = value, Icons.person),
          _buildDropdownField("État civil", [
            "Célibataire",
            "Marié(e)",
            "Divorcé(e)",
            "Veuf(ve)",
          ], (value) => setState(() => etatCivil = value)),
          Row(
            children: [
              Text("Sexe : "),
              Radio(
                value: "Masculin",
                groupValue: sexe,
                onChanged: (value) => setState(() => sexe = value),
              ),
              Text("Masculin"),
              Radio(
                value: "Féminin",
                groupValue: sexe,
                onChanged: (value) => setState(() => sexe = value),
              ),
              Text("Féminin"),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              controller: dateNaissanceController,
              decoration: InputDecoration(
                labelText: 'Date de naissance',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      String formattedDate = DateFormat(
                        'yyyy-MM-dd',
                      ).format(pickedDate);
                      setState(() {
                        dateNaissanceController.text = formattedDate;
                      });
                    }
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre date de naissance';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: DropdownButtonFormField<String>(
              value: selectedSecteurId,
              decoration: InputDecoration(
                labelText: "Votre Secteur",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items:
                  secteurs.map((secteur) {
                    return DropdownMenuItem<String>(
                      value: secteur['id_secteur'].toString(),
                      child: Text(secteur['nom_secteur']),
                    );
                  }).toList(),

              onChanged: (value) {
                setState(() => selectedSecteurId = value);
              },
            ),
          ),
          _buildTextField(
            "Adresse Complète",
            (value) => adresse = value,
            Icons.home,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                labelText: 'Numero Telephone',
                prefixIcon: Icon(Icons.phone, size: 15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                labelText: 'Email',
                prefixIcon: Icon(Icons.email, size: 15),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre email';
                } else if (!RegExp(
                  r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Veuillez entrer un email valide';
                }
                return null;
              },
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 0,
    );
  }

  Step _buildStep2() {
    return Step(
      title: const Text("Informations médicales"),
      content: Column(
        children: [
          _buildDropdownField("Groupe sanguin", [
            "A+",
            "A-",
            "B+",
            "B-",
            "AB+",
            "AB-",
            "O+",
            "O-",
          ], (value) => setState(() => groupeSanguin = value)),
          _buildTextField(
            "Allergies",
            (value) => allergies = value,
            Icons.medical_services,
          ),
          _buildTextField(
            "Maladies chroniques",
            (value) => maladies = value,
            Icons.healing,
          ),
          _buildTextField(
            "Médicaments en cours",
            (value) => medicaments = value,
            Icons.medication,
          ),
        ],
      ),
      isActive: _currentStep >= 1,
    );
  }

  Step _buildStep3() {
    return Step(
      title: const Text("Enfants"),
      content: Column(
        children: [
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    enfants.add({"noms": "", "date_naissance": "", "sexe": ""});
                  });
                },
                child: const Text("Ajouter un enfant"),
              ),
              Column(
                children:
                    enfants.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> enfant = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Enfant ${index + 1}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Noms de l'enfant",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    enfant["noms"] = value;
                                  });
                                },
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextFormField(
                                controller: TextEditingController(
                                  text: enfant["date_naissance"],
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Date de naissance',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.calendar_today),
                                    onPressed: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime.now(),
                                          );
                                      if (pickedDate != null) {
                                        String formattedDate = DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(pickedDate);
                                        setState(() {
                                          enfant["date_naissance"] =
                                              formattedDate;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer la date de naissance';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: "Sexe",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                value:
                                    enfant["sexe"].isNotEmpty
                                        ? enfant["sexe"]
                                        : null,
                                items: const [
                                  DropdownMenuItem(
                                    value: "M",
                                    child: Text("Masculin"),
                                  ),
                                  DropdownMenuItem(
                                    value: "F",
                                    child: Text("Féminin"),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    enfant["sexe"] = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ],
      ),
      isActive: _currentStep >= 2,
    );
  }

  Step _buildStep4() {
    return Step(
      title: Text("Contact d'urgence"),
      content: Column(
        children: [
          _buildTextField(
            "Nom du contact",
            (value) => contactUrgenceNom = value,
            Icons.person,
          ),
          _buildTextField(
            "Lien de parenté",
            (value) => contactUrgenceLien = value,
            Icons.family_restroom,
          ),
          _buildTextField(
            "Téléphone du contact",
            (value) => contactUrgenceTel = value,
            Icons.phone,
          ),
        ],
      ),
      isActive: _currentStep >= 3,
    );
  }

  Step _buildStep5() {
    return Step(
      title: Text("Sécurité"),
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                labelText: 'Mot de passe',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un mot de passe';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              controller: confirmPasswordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                labelText: 'Confirmer le mot de passe',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordMatch ? Icons.check : Icons.close,
                    color: _isPasswordMatch ? Colors.green : Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureTextConf = !_obscureTextConf;
                    });
                  },
                ),
              ),

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez confirmer votre mot de passe';
                } else if (value != passwordController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
              onChanged: (value) {
                _validatePassword();
              },
            ),
          ),
          SizedBox(height: 10),
          Text("Photo de profil"),
          _imageFile == null
              ? Text("Aucune image sélectionnée")
              : Image.file(
                _imageFile!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
          ElevatedButton(
            onPressed: getImage,
            child: Text("Sélectionner une photo"),
          ),
        ],
      ),
      isActive: _currentStep >= 4,
    );
  }

  Widget _buildTextField(
    String label,
    Function(String) onChanged,
    IconData icon, {
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          prefixIcon: Icon(icon, size: 15),
        ),
        obscureText: obscureText,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        items:
            options
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 10),
            Text(
              'CREATION COMPTE',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Stepper(
                currentStep: _currentStep,
                onStepContinue: _nextStep,
                onStepCancel: _previousStep,
                steps: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildStep5(),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  insertData();
                },
                child: Text('LOGIN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
