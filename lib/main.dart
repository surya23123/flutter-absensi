import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: AbsensiForm()));
}

class AbsensiForm extends StatefulWidget {
  @override
  _AbsensiFormState createState() => _AbsensiFormState();
}

class _AbsensiFormState extends State<AbsensiForm> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nimController = TextEditingController();
  final TextEditingController kelasController = TextEditingController();
  final TextEditingController deviceController = TextEditingController();

  String? jenisKelamin;

  void showCustomPopup({
    required String title,
    required String message,
    required bool success,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: success ? Color(0xFF2ECC71) : Color(0xFFE74C3C),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                  size: 50,
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: success
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> submitAbsensi() async {
    final url = Uri.parse(
      "https://absensi-mobile.primakarauniversity.ac.id/api/absensi",
    );

    final body = {
      "nama": namaController.text,
      "nim": nimController.text,
      "kelas": kelasController.text,
      "jenis_kelamin": jenisKelamin ?? "",
      "device": deviceController.text,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (data["status"] == "success") {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "✨ Sukses",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(data["message"]),
        ),
      );
    } else {
      String errorMessage = "";

      if (data["message"] is Map) {
        data["message"].forEach((key, value) {
          errorMessage += "$key : ${value[0]}\n";
        });
      } else {
        errorMessage = data["message"].toString();
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("❌ Error", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(errorMessage),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE7EDF7), // soft blue background
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              SizedBox(height: 20),

              // TITLE
              Text(
                "Absensi Mahasiswa",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A3D62),
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Silakan isi data absensi dengan lengkap",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              SizedBox(height: 25),

              // CARD CONTAINER
              Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Nama
                    _inputField(
                      label: "Nama",
                      controller: namaController,
                      icon: Icons.person,
                    ),
                    SizedBox(height: 15),

                    // NIM
                    _inputField(
                      label: "NIM",
                      controller: nimController,
                      icon: Icons.credit_card,
                    ),
                    SizedBox(height: 15),

                    // Kelas
                    _inputField(
                      label: "Kelas",
                      controller: kelasController,
                      icon: Icons.class_,
                    ),
                    SizedBox(height: 15),

                    // Jenis Kelamin
                    DropdownButtonFormField<String>(
                      value: jenisKelamin,
                      items: [
                        DropdownMenuItem(
                          value: "Laki-Laki",
                          child: Text("Laki-Laki"),
                        ),
                        DropdownMenuItem(
                          value: "Perempuan",
                          child: Text("Perempuan"),
                        ),
                      ],
                      decoration: _dropdownDecoration("Jenis Kelamin"),
                      onChanged: (value) {
                        setState(() {
                          jenisKelamin = value;
                        });
                      },
                    ),
                    SizedBox(height: 15),

                    // Device
                    _inputField(
                      label: "Device",
                      controller: deviceController,
                      icon: Icons.phone_android,
                    ),
                    SizedBox(height: 25),

                    // BUTTON
                    GestureDetector(
                      onTap: submitAbsensi,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0A3D62), Color(0xFF3C6382)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Submit Absensi",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ⭐ Custom input form aesthetic
  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF0A3D62)),
        filled: true,
        fillColor: Color(0xFFF4F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ⭐ Custom dropdown decoration
  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Color(0xFFF4F7FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}
