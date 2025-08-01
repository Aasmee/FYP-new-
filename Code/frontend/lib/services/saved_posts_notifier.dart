import 'package:flutter/material.dart';

class SavedPostsNotifier extends ValueNotifier<List<Map<String, dynamic>>> {
  SavedPostsNotifier() : super([]);

  void setPosts(List<Map<String, dynamic>> posts) {
    value = posts;
  }

  void addPost(Map<String, dynamic> post) {
    if (!value.any((p) => p['id'] == post['id'])) {
      value = [...value, post];
    }
  }

  void removePost(int postId) {
    value = value.where((p) => p['id'] != postId).toList();
  }
}

final savedPostsNotifier = SavedPostsNotifier();
