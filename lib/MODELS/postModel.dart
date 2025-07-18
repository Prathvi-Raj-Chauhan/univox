// whenever we get response in json where their is a list of json objects then we have to make models


class Post {
  final String id;
  final String title;
  final String postContent;
  final bool isPublic;
  final String createdAt;
  final String createdBy;
  final String coverImageURL;
  final int upvotes;
  final int downvotes;
  final Map<String, int> voters;


  Post({
    required this.id,
    required this.title,
    required this.postContent,
    required this.isPublic,
    required this.createdAt,
    required this.createdBy,
    this.coverImageURL = '',
    this.upvotes = 0,
    this.downvotes = 0,
    required this.voters,
  });

  factory Post.fromJson(Map<String, dynamic> json) { //creates a Post object from a Map<String, dynamic>, i.e. a JSON object from your backend response.
    return Post(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      postContent: json['postContent'] ?? '',
      isPublic: json['isPublic'] ?? true,
      createdAt: json['createdAt'] ?? '',
      createdBy: json['createdBy'] != null && json['createdBy'] is Map
          ? json['createdBy']['username'] ?? ''
          : '',
      coverImageURL: json['coverImageURL'] as String? ?? '',
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      voters: Map<String, int>.from(json['voters'] ?? {}),
    );
  }

}

//This creates a Post object from a Map<String, dynamic>, i.e. a JSON object from your backend response.
//
// ✅ Example
// Assume you get this response from your backend:
// {
//   "_id": "abc123",
//   "title": "First Post",
//   "postContent": "This is a test post",
//   "isPublic": true,
//   "createdAt": "2025-07-08T12:34:56Z"
// }
// When you call:
// Post myPost = Post.fromJson(jsonResponse);
//
// It returns:
// Post(
//   id: "abc123",
//   title: "First Post",
//   postContent: "This is a test post",
//   isPublic: true,
//   createdAt: "2025-07-08T12:34:56Z"
// )