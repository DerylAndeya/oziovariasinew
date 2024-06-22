import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oziovariasi/screens/sign_in_screen.dart';
import 'package:oziovariasi/screens/add_post_screen.dart';
import 'package:oziovariasi/screens/detail_screen.dart';
import 'package:oziovariasi/screens/favorite_screen.dart';
import 'package:oziovariasi/screens/akun_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;

  const HomeScreen({Key? key, this.onThemeChanged}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('HOME', style: TextStyle(color: Colors.white)),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
              icon: Icon(Icons.clear, color: Colors.white),
            ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.black,
                  title: const Text('Cari Postingan', style: TextStyle(color: Colors.white)),
                  content: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      hintText: 'Masukkan kata kunci',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Batal', style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cari', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.black,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title: const Text('Beranda', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.white),
                title: const Text('Favorit', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  FavoriteScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_circle, color: Colors.white),
                title: const Text('Profil', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AkunScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_6, color: Colors.white),
                title: const Text('Mode Terang', style: TextStyle(color: Colors.white)),
                onTap: () {
                  if (widget.onThemeChanged != null) {
                    widget.onThemeChanged!(ThemeMode.light);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_2, color: Colors.white),
                title: const Text('Mode Gelap', style: TextStyle(color: Colors.white)),
                onTap: () {
                  if (widget.onThemeChanged != null) {
                    widget.onThemeChanged!(ThemeMode.dark);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_auto, color: Colors.white),
                title: const Text('Mode Sistem', style: TextStyle(color: Colors.white)),
                onTap: () {
                  if (widget.onThemeChanged != null) {
                    widget.onThemeChanged!(ThemeMode.system);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.black,
                      title: const Text('Konfirmasi Logout', style: TextStyle(color: Colors.white)),
                      content: const Text('Apakah Anda yakin ingin logout?', style: TextStyle(color: Colors.white)),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Batal', style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: () {
                            signOut(context);
                          },
                          child: const Text('Logout', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada postingan tersedia', style: TextStyle(color: Colors.black)));
          }

          var posts = snapshot.data!.docs;
          var filteredPosts = posts.where((post) {
            var data = post.data() as Map<String, dynamic>;
            var username = data['username']?.toString().toLowerCase() ?? '';
            var text = data['text']?.toString().toLowerCase() ?? '';
            return username.contains(_searchController.text.toLowerCase()) ||
                text.contains(_searchController.text.toLowerCase());
          }).toList();

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
            ),
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              var post = filteredPosts[index];
              var data = post.data() as Map<String, dynamic>;
              var postTime = data['timestamp'] as Timestamp;
              var date = postTime.toDate();
              var formattedDate = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';

              var username = data.containsKey('username') ? data['username'] : 'Anonim';
              var imageUrl = data.containsKey('image_url') ? data['image_url'] : '';
              var text = data.containsKey('text') ? data['text'] : '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        postId: post.id,
                        username: username,
                        imageUrl: imageUrl,
                        text: text,
                        formattedDate: formattedDate,
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl.isNotEmpty)
                        Expanded(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Text('Gagal memuat gambar', style: TextStyle(color: Colors.black)));
                            },
                          ),
                        )
                      else
                        const Expanded(
                          child: Center(child: Text('Gambar tidak tersedia', style: TextStyle(color: Colors.black))),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPostScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
