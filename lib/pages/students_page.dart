
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_form_page.dart';
import 'student_details_page.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final searchController = TextEditingController();
  String searchText = '';

  final CollectionReference<Map<String, dynamic>> students =
      FirebaseFirestore.instance.collection('students');

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // DELETE 
  Future<void> deleteStudent(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await students.doc(id).delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student deleted successfully!'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delete failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      appBar: AppBar(
        title: const Text(
          'Student Records',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),

      // ADD STUDENT 
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2455C3),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const StudentFormPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
      ),

      body: Column(
        children: [
          // HEADER 
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2455C3),
                  Color(0xFF163B85),
                ],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Students',
                  style: TextStyle(
                    fontSize: 23,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'View and manage student information.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),

                // SEARCH
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchText = value.toLowerCase().trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search student...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() => searchText = '');
                      },
                      icon: const Icon(Icons.close),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // STUDENT LIST
          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: students.orderBy('fullName').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Unable to load student records.',
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // FILTER 
                final filtered = snapshot.data!.docs.where((doc) {
                  final data = doc.data();

                  final name =
                      (data['fullName'] ?? '')
                          .toString()
                          .toLowerCase();

                  final number =
                      (data['studentNumber'] ?? '')
                          .toString()
                          .toLowerCase();

                  final course =
                      (data['course'] ?? '')
                          .toString()
                          .toLowerCase();

                  return name.contains(searchText) ||
                      number.contains(searchText) ||
                      course.contains(searchText);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 65,
                          color: Color(0xFF9BAAC5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          searchText.isEmpty
                              ? 'No students found.'
                              : 'No matching students.',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16, 18, 16, 100,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data();

                    final name =
                        data['fullName']?.toString() ??
                            'Unnamed Student';

                    final initial = name.isNotEmpty
                        ? name[0].toUpperCase()
                        : 'S';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(
                          color: const Color(0xFFE7ECF5),
                        ),
                      ),

                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentDetailsPage(
                                studentId: doc.id,
                              ),
                            ),
                          );
                        },

                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),

                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor:
                              const Color(0xFFEAF1FF),
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Color(0xFF2455C3),
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),

                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF163B85),
                          ),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'ID: ${data['studentNumber'] ?? 'N/A'}\n'
                            '${data['course'] ?? 'No course'} • '
                            '${data['yearLevel'] ?? 'No year level'}',
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.6,
                            ),
                          ),
                        ),

                        isThreeLine: true,

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                              color: Color(0xFF2455C3),
                            ),

                            // EDIT AND DELETE
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          StudentFormPage(
                                        documentId: doc.id,
                                        initialData: data,
                                      ),
                                    ),
                                  );
                                } else if (value == 'delete') {
                                  deleteStudent(doc.id, name);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit Student'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete Student'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
