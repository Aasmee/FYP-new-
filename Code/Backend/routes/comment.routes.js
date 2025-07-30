import express from "express";
import { addComment, getComments, deleteComment, editComment } from "../controller/comment.controller.js";

const router = express.Router();

router.post("/", addComment); // Add a comment
router.get("/:postId", getComments); // Get comments for a post
router.delete("/:commentId", deleteComment); // Delete a comment
router.put('/:commentId', editComment);
export default router;