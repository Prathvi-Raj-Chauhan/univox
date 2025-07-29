import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:univox/PAGES/post_page.dart';

import '../MODELS/postModel.dart';

import 'edit_profile_page.dart';

final baseUrl = "https://univox-backend-r0u6.onrender.com";

class AccountPage extends StatefulWidget {
  final String? token;

  const AccountPage({required this.token});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late String userId;
  late Map<String, dynamic> userData;
  List<Post> userPosts = [];
  bool isLoading = true;
  String profilePictureURL = '';

  @override
  void initState() {
    super.initState();
    decodeToken();
    fetchUserPosts();
  }

  void decodeToken() {
    Map<String, dynamic> decoded = JwtDecoder.decode(widget.token ?? '');
    userId = decoded['_id'];
    userData = decoded;
    profilePictureURL = userData['profilePictureURL'] ?? '';
  }

  Future<void> fetchUserPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/post/$userId'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          userPosts = data.map((e) => Post.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load posts");
      }
    } catch (e) {
      print("Error fetching posts: $e");
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/post/$postId'));

      if (response.statusCode == 200) {
        setState(() {
          userPosts.removeWhere((post) => post.id == postId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Post deleted")));
      } else {
        throw Exception("Delete failed");
      }
    } catch (e) {
      print("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: RefreshIndicator(
                    onRefresh: fetchUserPosts,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Avatar & Edit Icon
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 30,
                                  sigmaY: 30,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 50,
                                            backgroundColor: Colors.grey[300],
                                            backgroundImage:
                                                profilePictureURL ==
                                                    ''
                                                ? AssetImage(
                                                    'assets/default.png',
                                                  )
                                                : NetworkImage(
                                                    profilePictureURL,
                                                  ),
                                          ),
                                          const SizedBox(width: 10),
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.deepPurple,
                                            ),
                                            onPressed: () async {
                                              final updated =
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          EditProfilePage(
                                                            userData: userData,
                                                            userId: userId,
                                                          ),
                                                    ),
                                                  );
                                              if (updated == true) {
                                                setState(() => decodeToken());
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        userData['username'] ?? "Unknown",
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        userData['email'] ?? "",
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      buildDetailField(
                                        Icons.school,
                                        userData['college'],
                                      ),
                                      buildDetailField(
                                        Icons.engineering,
                                        "${userData['branch']} • ${userData['year']} Year",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),
                            const Text(
                              "My Posts",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...userPosts.map((post) => buildPostCard(post)),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget buildDetailField(IconData icon, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPostCard(Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostPage(post: post, token: widget.token),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        color: Colors.white.withOpacity(0.7),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      post.title ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => confirmDelete(post),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                post.postContent ?? '',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        post.isPublic == true ? Icons.public : Icons.lock,
                        color: post.isPublic == true
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(post.isPublic == true ? "Public" : "Private"),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.arrow_upward,
                        size: 18,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(post.upvotes.toString()),
                    ],
                  ),
                  Switch(
                    value: post.isPublic ?? false,
                    onChanged: (value) {
                      updatePostVisibility(post.id!, value);
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void confirmDelete(Post post) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deletePost(post.id!);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> updatePostVisibility(String id, bool isPublic) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/post/visibility/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'public': isPublic}),
      );

      if (response.statusCode == 200) {
        setState(() {
          userPosts = userPosts.map((post) {
            if (post.id == id) {
              return Post(
                id: post.id,
                title: post.title,
                postContent: post.postContent,
                upvotes: post.upvotes,
                isPublic: isPublic,
                createdAt: post.createdAt,
                createdBy: post.createdBy,
                voters: post.voters,
              );
            }
            return post;
          }).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Post is now ${isPublic ? 'Public' : 'Private'}"),
          ),
        );
      } else {
        throw Exception("Visibility update failed");
      }
    } catch (e) {
      print("Visibility update error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating post visibility")));
    }
  }
}
