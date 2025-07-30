import cors from 'cors';
import express from 'express';
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
const app = express();
app.use(cors());

export const addPost = async (req, res) => {
  try {
    const { title, description } = req.body;
    const files = req.files;
    const userId = req.user.id;

    if (!userId) {
      return res.status(401).json({ message: "User ID is not authenticated" });
    }

    console.log("Request Body:", req.body);

    const imagePaths = files?.['image']
      ? files['image'].map(file => `/uploads/postImages/${file.filename}`)
      : [];
    const videoPaths = files?.['video']
      ? files['video'].map(file => `/uploads/postVideos/${file.filename}`)
      : [];

    console.log("Uploaded Video Paths:", videoPaths);
    console.log("Uploaded Image Paths:", imagePaths);

    const newPost = await prisma.post.create({
      data: {
        title: title.trim(),
        description: description.trim(),
        imagePaths,
        videoPaths,
        userId: parseInt(userId),
      },
    });

    res.status(201).json({
      message: 'Post added successfully',
      post: newPost
    });
  } catch (error) {
    console.error("Add post error:", error);
    res.status(500).json({ message: 'Something went wrong' });
  }
};

export const getPost = async (req, res) => {
  try {
    const { userId, feedType } = req.query;
    console.log("user id", userId);

    const includeOptions = {
      user: { select: { id: true, username: true } },
      likes: { select: { userId: true } },
      _count: { select: { likes: true } },
      bookmarks: { select: { userId: true } },
    };
    let whereClause = {};

    // if (feedType === 'following' && userId) {
    //   const followedUsers = await prisma.follow.findMany({
    //     where: { followerId: parseInt(userId) },
    //     select: { followingId: true }
    //   });

    //   const followingIds = followedUsers.map(f => f.followingId);
    //   if (followingIds.length === 0) {
    //     return res.status(200).json([]);
    //   }
    //   whereClause.userId = { in: followingIds };
    // } else if (feedType === 'explore' && userId) {
    //   const followedUsers = await prisma.follow.findMany({
    //     where: { followerId: parseInt(userId) },
    //     select: { followingId: true }
    //   });

    //   const followingIds = followedUsers.map(f => f.followingId);
    //   whereClause.userId = { notIn: followingIds };
    // }

    const posts = await prisma.post.findMany({
      where: whereClause,
      include: includeOptions,
      orderBy: { id: 'desc' }
    });

    const formattedPosts = posts.map(post => ({
      id: post.id,
      title: post.title,
      description: post.description,
      imagePaths: post.imagePaths,
      videoPaths: post.videoPaths,
      createdAt: post.createdAt,
      likes: post._count.likes,
      hasLiked: userId ? post.likes.some(like => like.userId === parseInt(userId)) : false,
      isBookmarked: userId ? post.bookmarks?.some(bookmark => bookmark.userId === parseInt(userId)) ?? false : false,
      user: post.user,
      comments: []
    }));

    res.status(200).json(formattedPosts);
  } catch (error) {
    console.error("Error fetching posts:", error);
    res.status(500).json({ message: "Something went wrong" });
  }
};

export const deletePost = async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.id;

    if (!postId || isNaN(postId)) {
      return res.status(400).json({ message: 'Invalid post ID' });
    }

    const post = await prisma.post.findUnique({
      where: { id: parseInt(postId) },
    });

    if (!post) return res.status(404).json({ message: 'Post not found' });
    if (post.userId !== parseInt(userId)) {
      return res.status(403).json({ message: 'Unauthorized' });
    }

    await prisma.$transaction([
      prisma.comment.deleteMany({ where: { postId: parseInt(postId) } }),
      prisma.like.deleteMany({ where: { postId: parseInt(postId) } }),
      prisma.bookmark.deleteMany({ where: { postId: parseInt(postId) } }),
      prisma.post.delete({ where: { id: parseInt(postId) } }),
    ]);

    res.status(200).json({ message: 'Post deleted successfully' });
  } catch (error) {
    console.error('Delete error:', error);
    res.status(500).json({ message: 'Error deleting post', error: error.message });
  }
};

export const updatePost = async (req, res) => {
  try {
    const { postId } = req.params;
    const { description } = req.body;
    const userId = req.user.id;

    if (!description?.trim()) {
      return res.status(400).json({ message: 'Description cannot be empty' });
    }

    const post = await prisma.post.findUnique({
      where: { id: parseInt(postId) },
    });

    if (!post) return res.status(404).json({ message: 'Post not found' });
    if (post.userId !== parseInt(userId)) {
      return res.status(403).json({ message: 'Unauthorized' });
    }

    const updatedPost = await prisma.post.update({
      where: { id: parseInt(postId) },
      data: { description },
      include: {
        user: true,
        comments: true,
        bookmarks: true,
        likes: true
      }
    });

    res.status(200).json({ message: 'Post updated successfully', post: updatedPost });
  } catch (error) {
    console.error('Update error:', error);
    res.status(500).json({ message: 'Error updating post', error: error.message });
  }
};

export const getSinglePost = async (req, res) => {
  try {
    const postId = parseInt(req.params.postId);
    const userId = req.user?.id;

    if (isNaN(postId)) {
      return res.status(400).json({ message: "Invalid post ID" });
    }

    const post = await prisma.post.findUnique({
      where: { id: postId },
      include: {
        user: { select: { id: true, username: true, profileImage: true } },
        likes: { select: { userId: true } },
        bookmarks: { select: { userId: true } },
        comments: {
          select: {
            id: true,
            text: true,
            createdAt: true,
            user: {
              select: {
                id: true,
                username: true,
                profileImage: true,
              }
            }
          },
          orderBy: { createdAt: 'desc' }
        }
      }
    });

    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    const formattedPost = {
      id: post.id,
      title: post.title,
      description: post.description,
      imagePaths: post.imagePaths,
      videoPaths: post.videoPaths,
      createdAt: post.createdAt,
      user: post.user,
      likes: post._count?.likes || post.likes?.length || 0,
      hasLiked: userId ? post.likes.some(like => like.userId === parseInt(userId)) : false,
      isBookmarked: userId ? post.bookmarks.some(bookmark => bookmark.userId === parseInt(userId)) : false,
      comments: post.comments
    };

    res.status(200).json(formattedPost);
  } catch (error) {
    console.error('Error fetching single post:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

export const getPostsByUser = async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);

    const posts = await prisma.post.findMany({
      where: { userId },
      include: {
        user: { select: { id: true, username: true, profileImage: true } },
        likes: { select: { userId: true } },
        _count: { select: { likes: true } },
        bookmarks: { select: { userId: true } },
      },
      orderBy: { createdAt: 'desc' },
    });

    const currentUserId = req.user?.id;

    const formattedPosts = posts.map(post => ({
      id: post.id,
      title: post.title,
      description: post.description,
      imagePaths: post.imagePaths,
      videoPaths: post.videoPaths,
      createdAt: post.createdAt,
      likes: post._count.likes,
      hasLiked: currentUserId ? post.likes.some(like => like.userId === currentUserId) : false,
      isBookmarked: currentUserId ? post.bookmarks.some(b => b.userId === currentUserId) : false,
      user: post.user,
    }));

    res.status(200).json(formattedPosts);
  } catch (error) {
    console.error("Error fetching user posts:", error);
    res.status(500).json({ message: "Server error" });
  }
};
