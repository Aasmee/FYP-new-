import multer from "multer";
import path from "path";
import fs from "fs";

const ensureDirectoryExistence = (directory) => {
  if(!fs.existsSync(directory)){
    fs.mkdirSync(directory, { recursive: true });
  }
}
// paths for the folders
const postImagePath = "uploads/postImages";
const postVideoPath = "uploads/postVideos";
ensureDirectoryExistence(postImagePath);
ensureDirectoryExistence(postVideoPath);


const postStorage=multer.diskStorage({
  destination: (req, file, cb) => {
    if (file.mimetype.startsWith("image/")) {
      cb(null, postImagePath);
    } else if (file.mimetype.startsWith("video/")) {
      cb(null, postVideoPath);
    } else {
      cb(new Error("Invalid file type. Only images and videos are allowed!"), false);
    }
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

// ✅ Filter only image and video files
const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith("image/") || file.mimetype.startsWith("video/")) {
    cb(null, true);
  } else {
    cb(new Error("Invalid file type. Only images and videos are allowed!"), false);
  }
};

// ✅ Allow multiple files (images & videos)
export const postImagesUpload = multer({
  storage: postStorage,
  fileFilter: fileFilter,
}).fields([{ name: "image", maxCount: 4 }, { name: "video", maxCount: 1 }])

const profileImagePath = "uploads/profileImages";
ensureDirectoryExistence(profileImagePath);

const profileStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, profileImagePath);
    /*
    if (file.mimetype.startsWith("image/")) {
      
    } else {
      cb(new Error("Only image files are allowed for profile pictures!"), false);
    }*/
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

export const profileImageUpload = multer({
  storage: profileStorage,
  fileFilter: (req, file, cb) => {
    cb(null, true);
   /* if (file.mimetype.startsWith("image/")) {
      
    } else {
      cb(new Error("Only image files are allowed!"), false);
    }*/
  }
}).single("profileImage");