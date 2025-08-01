import express from "express";
import { addComment, getComments, deleteComment, editComment } from "../controller/comment.controller.js";
import { authenticate } from "../middleware/auth.js";

const router = express.Router();

router.post("/",authenticate, addComment); // Add a comment
router.get("/:postId", getComments); // Get comments for a post
router.delete("/:commentId", authenticate, deleteComment); // Delete a comment
router.put('/:commentId', authenticate, editComment);
export default router;