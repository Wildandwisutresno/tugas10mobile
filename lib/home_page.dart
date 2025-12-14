import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _todoController = TextEditingController();

  void _tambahList() {
    final user = _auth.currentUser;

    if (user != null && _todoController.text.trim().isNotEmpty) {
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('todos')
          .add({
        'task': _todoController.text.trim(),
        'isDone': false,
        'createdAt': Timestamp.now(),
      });

      _todoController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    // 🔒 Cegah error kalau user belum login
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'User belum login',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('todos')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada tugas'));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final bool isDone = data['isDone'] ?? false;

                    return ListTile(
                      leading: Checkbox(
                        value: isDone,
                        onChanged: (value) {
                          doc.reference.update({'isDone': value});
                        },
                      ),

                      title: Text(
                        data['task'] ?? '',
                        style: TextStyle(
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: isDone ? Colors.grey : Colors.black,
                        ),
                      ),

                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          doc.reference.delete();
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ➕ Input tambah tugas
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan Tugas Baru',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 30),
                  onPressed: _tambahList,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
