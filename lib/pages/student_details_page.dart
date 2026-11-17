import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDetailsPage extends StatelessWidget {
  final String studentId;

  const StudentDetailsPage({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        title: const Text(
          'Student Details',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: const Color(0xFF2455C3),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load student details.'),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Student record not found.'),
            );
          }

          final data = snapshot.data!.data()!;
          final name =
              data['fullName']?.toString() ?? 'Unnamed Student';

          String formatLabel(String key) {
            return key
                .replaceAllMapped(
                  RegExp(r'([A-Z])'),
                  (match) => ' ${match.group(0)}',
                )
                .replaceAll('_', ' ')
                .split(' ')
                .map((word) => word.isEmpty
                    ? ''
                    : '${word[0].toUpperCase()}${word.substring(1)}')
                .join(' ');
          }

          String formatValue(dynamic value) {
            if (value == null) return 'N/A';

            if (value is Timestamp) {
              return value.toDate().toString().split('.').first;
            }

            return value.toString();
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2455C3),
                      Color(0xFF163B85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 43,
                      backgroundColor: Colors.white,
                      child: Text(
                        name.isNotEmpty
                            ? name[0].toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2455C3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Student ID: ${data['studentNumber'] ?? 'N/A'}',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Complete Student Information',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF163B85),
                ),
              ),

              const SizedBox(height: 15),

              ...data.entries.map((entry) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFE7ECF5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatLabel(entry.key),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        formatValue(entry.value),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF163B85),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
