import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

import 'package:univox/PAGES/post_page.dart';
import '../MODELS/postModel.dart';

import '../PROVIDERS/post_provider.dart';
import '../services/logout.dart';

final baseUrl = "https://univox-backend-r0u6.onrender.com";

class HomePage extends StatefulWidget {
  final String? token;
  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum SortOption { recent, upvotes }

SortOption _selectedSort = SortOption.recent;

class _HomePageState extends State<HomePage> {
  String? userId;

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
    super
        .initState(); //initState() should run before the widget is fully inserted into the widget tree. At this point, the context is not fully usable for Provider or other inherited widgets.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This defers(stops until) the execution of the code until after the first frame is rendered. At that point, the widget is mounted and the context is fully valid.
      Provider.of<PostProvider>(
        context,
        listen: false,
      ).fetchPosts(); // now safely call the fetchPosts() method after the widget is built, avoiding exceptions which we got
      Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token ?? '');
      setState(() {
        userId = decodedToken['_id'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Discussions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [
          Text('Log out'),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
          Text('Sort'),
          PopupMenuButton<SortOption>(
            initialValue: _selectedSort,
            onSelected: (SortOption selected) {
              setState(() {
                _selectedSort = selected;
              });
            },
            icon: Icon(Icons.sort_rounded, color: Colors.black),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortOption.recent,
                child: Text('Sort by Recent'),
              ),
              PopupMenuItem(
                value: SortOption.upvotes,
                child: Text('Sort by Upvotes'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.png', // use your image path
              fit: BoxFit.cover,
            ),
          ),
          Consumer<PostProvider>(
            builder: (context, postProvider, _) {
              if (postProvider.isLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (postProvider.posts.isEmpty) {
                return Center(child: Text("No posts available."));
              } else {
                List<Post> sortedPosts = List.from(postProvider.posts);
                if (_selectedSort == SortOption.recent) {
                  sortedPosts.sort(
                    (a, b) => DateTime.parse(
                      b.createdAt,
                    ).compareTo(DateTime.parse(a.createdAt)),
                  );
                } else if (_selectedSort == SortOption.upvotes) {
                  sortedPosts.sort(
                    (a, b) => (b.upvotes - b.downvotes).compareTo(
                      a.upvotes - a.downvotes,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: sortedPosts.length,
                  itemBuilder: (context, index) {
                    final post = sortedPosts[index];

                    final vote = post.voters[userId]; // can be 1, -1, or null
                    return Card(
                      key: ValueKey(
                        post.id,
                      ), // Important to help Flutter maintain scroll state
                      color: Colors.white.withValues(alpha: 0.9),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Username + Time
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      post.createdBy,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  timeAgoSinceDate(post.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 18),

                            // Title
                            Text(
                              post.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),

                            // Content
                            Text(
                              post.postContent,
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(height: 18),

                            if (post.coverImageURL != '')
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  post.coverImageURL,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Text('Image failed to load'),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                ),
                              ),

                            // Footer:
                            //TODO: change the color of the button of votes if clicked
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 45,
                                      padding: const EdgeInsets.all(2.4),

                                      decoration: BoxDecoration(
                                        color: vote == 1
                                            ? Colors.green.shade100
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Row(
                                        // upvote button
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Provider.of<PostProvider>(
                                                context,
                                                listen: false,
                                              ).upvotePost(
                                                post.id,
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
                                            '${post.upvotes}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(width: 4),
                                    Container(
                                      // downvote button
                                      padding: const EdgeInsets.all(2.4),
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: vote == -1
                                            ? Colors.red.shade100
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          Provider.of<PostProvider>(
                                            context,
                                            listen: false,
                                          ).downvotePost(
                                            post.id,
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
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => PostPage(
                                          post: post,
                                          token: widget.token,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.comment_outlined, size: 20),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
