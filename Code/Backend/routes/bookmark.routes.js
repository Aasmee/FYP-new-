import express from 'express';
import { bookmarkPost, getBookmarkedPosts } from '../controller/bookmark.controller.js';
import { authenticate } from '../middleware/auth.js'; // Adjust path if needed

const router = express.Router();

// Route to bookmark/unbookmark a post
router.post('/:postId', authenticate, bookmarkPost);

// Route to get all bookmarked posts for a user
router.get('/', authenticate, getBookmarkedPosts);

export default router;
