import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'students_page.dart';
import 'account_settings_page.dart';
import 'student_details_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeContent(),
      const StudentsPage(),
      const AccountSettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEAF1FF),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final studentCollection =
        FirebaseFirestore.instance.collection('students');

    final displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : (user?.email?.split('@').first ?? 'User');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2455C3),
                      Color(0xFF163B85),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'STUDENT PORTAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Text(
                            displayName.isEmpty
                                ? 'U'
                                : displayName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      displayName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Here is your student information overview.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF163B85),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // TOTAL
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: studentCollection.snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.hasData
                          ? snapshot.data!.docs.length
                          : 0;

                      return Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF1FF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.groups_rounded,
                                size: 35,
                                color: Color(0xFF2455C3),
                              ),
                            ),
                            const SizedBox(width: 18),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Students',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Registered Students',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF163B85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              snapshot.hasError
                                  ? '--'
                                  : snapshot.hasData
                                      ? '$count'
                                      : '...',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2455C3),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 27),

                  const Text(
                    'Quick Access',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF163B85),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: _QuickCard(
                          icon: Icons.people_alt_rounded,
                          title: 'Students',
                          subtitle: 'View records',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const StudentsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickCard(
                          icon: Icons.person_rounded,
                          title: 'Account',
                          subtitle: 'Manage profile',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AccountSettingsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 27),

                  // RECENTS
                  const Text(
                    'Recent Students',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF163B85),
                    ),
                  ),

                  const SizedBox(height: 12),

                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: studentCollection.limit(5).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Unable to load student records.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                snapshot.error.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.connectionState ==
                              ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return const Text(
                          'No student records available yet.',
                          style: TextStyle(color: Colors.grey),
                        );
                      }

                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data();

                          final name =
                              data['fullName']?.toString() ??
                                  'Unnamed Student';

                          final course =
                              data['course']?.toString() ?? '';

                          final initial = name.isNotEmpty
                              ? name[0].toUpperCase()
                              : 'S';

                          return Card(
                            color: Colors.white,
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                color: Color(0xFFE7ECF5),
                              ),
                            ),
                            child: ListTile(
                              // CLICK STUDENT TO VIEW FULL DETAILS
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        StudentDetailsPage(
                                      studentId: doc.id,
                                    ),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor:
                                    const Color(0xFFEAF1FF),
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Color(0xFF2455C3),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF163B85),
                                ),
                              ),
                              subtitle: Text(course),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Color(0xFF2455C3),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE7ECF5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xFF2455C3),
            ),
            const SizedBox(height: 13),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF163B85),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
