import { Router } from "express";
import {addPost, getPost, deletePost, updatePost, getPostsByUser, getSinglePost} from "../controller/post.controller.js";
import { postImagesUpload } from "../utils/multer.js";
import { toggleLike, getLikedPosts } from "../controller/like.controller.js";
import { bookmarkPost, getBookmarkedPosts } from "../controller/bookmark.controller.js";
import { authenticate } from "../middleware/auth.js";
const router = Router();

router.post("/create", authenticate, postImagesUpload, addPost);

router.get("/get", getPost);

router.delete('/delete/:postId', authenticate, deletePost);
router.put('/update/:postId', authenticate, updatePost);

router.get("/following", authenticate, getPost);

router.get("/user/:userId", getPostsByUser);

router.post("/:postId/like", authenticate, toggleLike);
router.get('/liked-posts', authenticate, getLikedPosts);

router.post("/:postId/bookmark", authenticate, bookmarkPost);
router.get('/bookmarked-posts', authenticate, getBookmarkedPosts);


router.get('/:postId', authenticate, getSinglePost);
export default router;