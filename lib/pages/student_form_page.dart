import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentFormPage extends StatefulWidget {
  final String? documentId;
  final Map<String, dynamic>? initialData;

  const StudentFormPage({
    super.key,
    this.documentId,
    this.initialData,
  });

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController studentNumber;
  late TextEditingController fullName;
  late TextEditingController email;
  late TextEditingController course;
  late TextEditingController yearLevel;

  bool saving = false;

  final CollectionReference<Map<String, dynamic>> students =
      FirebaseFirestore.instance.collection('students');

  @override
  void initState() {
    super.initState();

    final data = widget.initialData ?? {};

    studentNumber = TextEditingController(
      text: data['studentNumber'] ?? '',
    );
    fullName = TextEditingController(
      text: data['fullName'] ?? '',
    );
    email = TextEditingController(
      text: data['email'] ?? '',
    );
    course = TextEditingController(
      text: data['course'] ?? '',
    );
    yearLevel = TextEditingController(
      text: data['yearLevel'] ?? '',
    );
  }

  @override
  void dispose() {
    studentNumber.dispose();
    fullName.dispose();
    email.dispose();
    course.dispose();
    yearLevel.dispose();
    super.dispose();
  }

  Widget buildField(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF2455C3),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required.';
          }

          if (keyboard == TextInputType.emailAddress &&
              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                  .hasMatch(value.trim())) {
            return 'Enter a valid email address.';
          }

          return null;
        },
      ),
    );
  }

  Future<void> saveStudent() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => saving = true);

    final data = <String, dynamic>{
      'studentNumber': studentNumber.text.trim(),
      'fullName': fullName.text.trim(),
      'email': email.text.trim(),
      'course': course.text.trim(),
      'yearLevel': yearLevel.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.documentId == null) {
        await students.add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await students.doc(widget.documentId).update(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.documentId == null
                  ? 'Student added successfully!'
                  : 'Student updated successfully!',
            ),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.documentId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing ? 'Edit Student' : 'Add Student',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2455C3),
                      Color(0xFF163B85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Colors.white,
                      size: 45,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Student Information',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Please complete all required fields.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              buildField(
                'Student Number',
                Icons.badge_outlined,
                studentNumber,
              ),
              buildField(
                'Full Name',
                Icons.person_outline,
                fullName,
              ),
              buildField(
                'Email Address',
                Icons.email_outlined,
                email,
                keyboard: TextInputType.emailAddress,
              ),
              buildField(
                'Course',
                Icons.menu_book_outlined,
                course,
              ),
              buildField(
                'Year Level',
                Icons.school_outlined,
                yearLevel,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: saving ? null : saveStudent,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    saving
                        ? 'Saving...'
                        : editing
                            ? 'UPDATE STUDENT'
                            : 'SAVE STUDENT',
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
