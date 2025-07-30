import dotenv from 'dotenv';
dotenv.config();
import { PrismaClient } from "@prisma/client";
import bcrypt from 'bcryptjs';
import nodemailer from "nodemailer";
import express from 'express';
import jwt from 'jsonwebtoken';


import cors from 'cors';

const app = express();

app.use(cors({
  origin: 'http://192.168.1.6:3000',  
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
 allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());
const prisma = new PrismaClient();


//Register
export const register = async (req, res)=>{ 
    console.log("📩 Received registration request:", req.body);
    const{ username, email, password, confirmPassword }=req.body;

    if (!email || !username || !password || !confirmPassword) {
      return res.status(400).json({ error: "All fields are required." });
    }
      if (password !== confirmPassword) {
        return res.status(400).json({ error: "Passwords do not match." });
      }
      if (password.length < 6) {
        return res.status(400).json({ error: "Password must be at least 6 characters long." });
      }
      try {  
        const existingUser = await prisma.user.findUnique({
          where: { email: email.toLowerCase() },
        });
        if (existingUser) {
          return res.status(400).json({ error: "Email is already in use." });
        }
        const hashedPassword = await bcrypt.hash(password, 10);

        const newUser = await prisma.user.create({
          data: {
            username: username.toLowerCase(),
            email: email.toLowerCase(),
            password: hashedPassword, 
          },
        });
        console.log("User registered successfully:", newUser);

        const { password: _, ...userWithoutPassword } = newUser;
        return res.status(201).json({ message: "User registered successfully", user: userWithoutPassword });
    
      } catch (error) {
        console.error("Registration error:", JSON.stringify(error));
        return res.status(500).json({ error: "Internal Server Error" });
      }
    };





//Login
export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await prisma.user.findFirst({
      where: { email },
    });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    // 🔑 Create a token
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );

    res.status(200).json({
      message: "Login successful",
      token, // Your token is here
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
      }
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ message: "Login failed" });
  }
};







// Forgot Password
export const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ error: "Email is required." });
    }

    const user = await prisma.user.findUnique({ where: { email: email.toLowerCase() } });
    if (!user) {
      return res.status(404).json({ error: "User not found." });
    }
    console.log("Using Email Credentials:", process.env.USER, process.env.APP_PASSWORD);


      // Generate a reset token
      const verificationCode = Math.floor(1000 + Math.random() * 9000).toString();
      const codeExpiry = new Date(Date.now() + 15 * 60 * 1000); // Code expires in 15 minutes


      // Save token in database
      await prisma.user.update({
        where: { email: email.toLowerCase() },
        data: { verificationCode, codeExpiry },
      });


      // Configure nodemailer transporter
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      host: 'smtp.gmail.com',
      port: 587,
      secure: false,
      auth: {
        user: process.env.USER,
        pass: process.env.APP_PASSWORD,
      },
      
    });

    const mailOptions = {
      from: {
        name: 'Ingreedy',
        address: process.env.USER,
      },
      to: ["aasmee0408@gmail.com"],
      subject: 'Password Reset Verification code',
      html: `<p>Your verification code is: <strong>${verificationCode}</strong>. This code is valid for 15 minutes.</p>`,
    };
    

    const sendMail = async (transporter, mailOptions) => {
      try{
        await transporter.sendMail(mailOptions);
        console.log('Email sent successfully ');
        }catch (error){
          console.error(error);
        }
      }
    
    // Send reset email
    await transporter.sendMail(mailOptions);
    console.log("Password reset code sent to ${email}");

    return res.json({ message: "Verification code sent to email." });

  } catch (error) {
    console.error("Forgot Password error:", error);
    return res.status(500).json({ error: "Internal Server Error" });
  }
};


    
 

// Reset Password
export const resetPassword = async (req, res) => {
  try {
    const { email, code, newPassword } = req.body;

    if (!email || !code || !newPassword) {
      return res.status(400).json({ error: "Email, code, and new password are required." });
    }
    const user = await prisma.user.findUnique({ where: { email: email.toLowerCase() } });
    if (!user) {
      return res.status(404).json({ error: "User not found." });
    }
    // Check if the code matches and is still valid
    if (user.verificationCode !== code || new Date() > new Date(user.codeExpiry)) {
      return res.status(400).json({ error: "Invalid or expired code." });
    }

    // Hash the new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

     // Update user and clear verification data
    const updatedUser = await prisma.user.update({
      where: { email: email.toLowerCase() },
      data: {
        password: hashedPassword,
        verificationCode: null,
        codeExpiry: null,
      },
    });

    // Generate new JWT token for automatic login
    const token = jwt.sign(
      { 
        userId: updatedUser.id,
        iat: Math.floor(Date.now() / 1000) 
      },
      process.env.JWT_SECRET,
      { 
        expiresIn: process.env.JWT_EXPIRES_IN || '1d',
        algorithm: 'HS256' 
      }
    );

    console.log("Password reset successfully for ${user.email}");
    return res.json({ message: "Password reset successful. You can now log in." });
  } catch (error) {
      console.error("Reset Password error:", error);
      return res.status(500).json({ error: "Internal Server Error" });
  }
};






//getProfile
export const getProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    console.log("User ID:", userId);
    if (isNaN(userId)) {
      return res.status(400).json({ error: "Invalid user ID format" });
    }
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        username: true,
        email: true,
        bio: true,
        profileImage: true,
        createdAt: true,
        _count: {
          select: {
            posts: true,
          }
        }
      }
    });

    if (!user) return res.status(404).json({ error: "User not found" });
    
    res.json({
      ...user,
      postCount: user._count.posts,
    });
    
  } catch (error) {
    console.error("Get profile error:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};





// //updateProfile 
// export const updateProfile = async (req, res) => {
//   try {
//     const userId = parseInt(req.user.id);
//     console.log(" Profile Data:", req.body);
//     const { username, bio, email } = req.body;
//     console.log("Update Profile Data:", req.body);
//     const profileImage = req.file 
//     ? ${req.protocol}://${req.get("host")}/uploads/profileImages/${req.file.filename} : undefined;

//     if (userId !== req.user.id) {
//       return res.status(403).json({ error: "Unauthorized to update this profile" });
//     }

//     const updateData = {
//       username: username?.trim(),
//       bio: bio?.trim() || null,
//       email: email?.trim() || null,
//       ...(profileImage && { profileImage })
//     };

//     const updatedUser = await prisma.user.update({
//       where: { id: userId },
//       data: updateData,
//       select: {
//         id: true,
//         username: true,
//         email: true,
//         bio: true,
//         profileImage: true,
//         createdAt: true,
//         _count: {
//           select: {
//             posts: true,
//             // followers: true,
//             // following: true
//           }
//         }
//       }
//     });

//     res.json(updatedUser);
//   } catch (error) {
//     console.error("Update error:", error);
//     res.status(500).json({ error: error.message });
//   }
// };

//other user profile
export const getUserProfile = async (req, res) => {
  try {
    const targetUserId = parseInt(req.params.userId);
    const currentUserId = req.user.id;
    if (isNaN(targetUserId)) {
      return res.status(400).json({ error: "Invalid user ID format" });
    }

    const user = await prisma.user.findUnique({
      where: { id: targetUserId }, // Use the parsed userId
      select: {
        id: true,
        username: true,
        bio: true,
        profileImage: true,
        createdAt: true,
        _count: {
          select: {
            posts: true,
          }
        }
      }
    });
    
  } catch (error) {
    console.error("Get user profile error:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
  };

//changePassword
export const changePassword = async (req, res) => {
  try {
    const userId = req.user.id;
    const { oldPassword, newPassword } = req.body;

    const user = await prisma.user.findUnique({ 
      where: { id: userId },
      select: { password: true }
    });

    const isPasswordValid = await bcrypt.compare(oldPassword, user.password);
    if (!isPasswordValid) {
      return res.status(400).json({ error: "Invalid current password" });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    
    await prisma.user.update({
      where: { id: userId },
      data: { password: hashedPassword }
    });

    res.json({ message: "Password updated successfully" });
  } catch (error) {
    console.error("Change password error:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};
export const updateFcmToken = async (req, res) => {
  try {
    const userId = req.user.id;
    const { fcmToken } = req.body;
    await prisma.user.update({
      where: { id: userId },
      data: { fcmToken }
    });
    res.status(200).json({ success: true });
  } catch (error) {
    console.error("FCM token error:", error);
    res.status(500).json({ error: "Failed to update FCM token" });
  }
};


