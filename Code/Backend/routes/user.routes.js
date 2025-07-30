import express from "express"
const router = express.Router();
import { register, login, forgotPassword, resetPassword, getProfile,
    getUserProfile} from "../controller/user.controller.js"; 
import { authenticate } from "../middleware/auth.js";

// import { profileImageUpload } from "../utils/multer.js";

// router.put("/updateProfile", profileImageUpload, authenticate, updateProfile);
// router.post("/register-admin", registerAdmin);

router.post("/register", register);
router.post("/login", login);



router.get("/profile", authenticate, getProfile);
router.put("/profile/:userId", authenticate);



router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);



router.get('/search-users', authenticate);
router.get('/:userId', authenticate, getUserProfile);



export default router;