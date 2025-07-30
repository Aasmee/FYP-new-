// middleware/auth.js
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';
import dotenv from 'dotenv';

dotenv.config();
const prisma = new PrismaClient();

export const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Missing authorization header' });
    }

    const token = authHeader.split(' ')[1];

    const decoded = jwt.verify(token, process.env.JWT_SECRET, {
      ignoreExpiration: true
    });

    // ---- CHANGE HERE ----
    const userId = decoded.userId || decoded.id;  // Fallback for old tokens
    if (!userId) {
      return res.status(401).json({ error: 'Invalid token payload' });
    }
    // ---------------------

    if (decoded.exp * 1000 < Date.now()) {
      return res.status(401).json({
        success: false,
        error: 'Token expired',
        tokenExpired: true
      });
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        username: true,
        email: true,
        profileImage: true,
        isVerified: true
      }
    });

    if (!user) {
      return res.status(401).json({ error: 'User not found' });
    }

    req.user = user;
    next();
  } catch (error) {
    console.error('Authentication error:', error.message);
    return res.status(401).json({
      success: false,
      error: 'Not authorized, token failed',
      tokenExpired: error.name === 'TokenExpiredError'
    });
  }
};
