import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import '../MODELS/commentModel.dart';
import '../MODELS/postModel.dart';

import '../PROVIDERS/post_comments_providers.dart';
import '../PROVIDERS/post_provider.dart';

final baseUrl = "https://univox-backend-r0u6.onrender.com";

class PostPage extends StatefulWidget {
  final Post post;
  final String? token;
  const PostPage({super.key, required this.post, required this.token});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  String? userId;
  String selectedSort = 'Recent'; // New: Dropdown value
  TextEditingController _comments = TextEditingController();

  String timeAgoSinceDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommentsProvider>(
        context,
        listen: false,
      ).fetchComments(widget.post.id);
      Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token ?? '');
      setState(() {
        userId = decodedToken['_id'];
      });
    });
  }

  void postComment(Post post, String? token) async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token ?? '');
    var comment = {"comment": _comments.text, "createdBy": decodedToken['_id']};

    try {
      var response = await http.post(
        Uri.parse('$baseUrl/comment/${post.id}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(comment),
      );

      if (response.statusCode == 200) {
        _comments.clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Comment posted')));
        await Provider.of<CommentsProvider>(
          context,
          listen: false,
        ).fetchComments(post.id);
        setState(() {});
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Error"),
            content: Text("Failed to post comment"),
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error in posting comment'),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final Post = postProvider.posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );
    final vote = Post.voters[userId];

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFEDEEF1),
          title: Text('POST', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/backgroundpost2.png',
                fit: BoxFit.cover,
              ),
            ),
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Post content UI
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(150),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 4,
                                blurRadius: 12,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  Post.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  Post.postContent,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              if (Post.coverImageURL != '')
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    Post.coverImageURL,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Text('Image failed to load'),
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  ),
                                ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Consumer<PostProvider>(
                                      builder: (context, postProvider, _) {
                                        return Row(
                                          children: [
                                            Container(
                                              width: 45,
                                              padding: const EdgeInsets.all(
                                                2.4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: vote == 1
                                                    ? Colors.green.shade100
                                                    : Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      postProvider.upvotePost(
                                                        Post.id,
                                                        widget.token!,
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.arrow_upward,
                                                      size: 20,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '${Post.upvotes}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Container(
                                              width: 40,
                                              padding: const EdgeInsets.all(
                                                2.4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: vote == -1
                                                    ? Colors.red.shade100
                                                    : Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  postProvider.downvotePost(
                                                    Post.id,
                                                    widget.token!,
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.arrow_downward,
                                                  size: 20,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.share),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Comment Input Field
                        TextField(
                          controller: _comments,
                          decoration: InputDecoration(
                            hintText: 'Your Thoughts ...',
                            hintStyle: TextStyle(
                              color: Colors.grey.withAlpha(200),
                            ),
                            filled: true,
                            fillColor: Colors.white.withAlpha(230),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => postComment(Post, widget.token),
                              icon: Icon(Icons.send),
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        // Sort Dropdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("Sort by: "),
                            DropdownButton<String>(
                              value: selectedSort,
                              items: ['Recent', 'Experienced']
                                  .map(
                                    (label) => DropdownMenuItem(
                                      value: label,
                                      child: Text(label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedSort = value!;
                                });
                              },
                            ),
                          ],
                        ),

                        // Comments List
                        Consumer<CommentsProvider>(
                          builder: (context, commentProvider, _) {
                            if (commentProvider.isLoading) {
                              return Center(child: CircularProgressIndicator());
                            }

                            List<Comment> sortedComments = List.from(
                              commentProvider.comments,
                            );
                            if (selectedSort == 'Recent') {
                              sortedComments.sort(
                                (a, b) => DateTime.parse(
                                  b.createdAt,
                                ).compareTo(DateTime.parse(a.createdAt)),
                              );
                            } else if (selectedSort == 'Experienced') {
                              sortedComments.sort((a, b) {
                                int yearA =
                                    a.year ?? 0; // fallback to 0 if null
                                int yearB = b.year ?? 0;
                                return yearB.compareTo(yearA);
                              });
                            }

                            if (sortedComments.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "No Comments yet... Become the Ice breaker",
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: sortedComments.length,
                              itemBuilder: (context, index) {
                                final comment = sortedComments[index];
                                return Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.person_outline,
                                                  size: 18,
                                                  color: Colors.grey[700],
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  comment.createdBy,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              timeAgoSinceDate(
                                                comment.createdAt,
                                              ),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          comment.comment,
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
