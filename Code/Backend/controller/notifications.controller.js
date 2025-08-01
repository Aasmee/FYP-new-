import cors from 'cors';
import express from 'express';
import {PrismaClient } from '@prisma/client'
const prisma = new PrismaClient()


const app = express();
app.use(cors());

// Get all notifications for user
 const getUserNotifications = async (req, res) => {
    try {
      const oneMonthAgo = new Date();
      oneMonthAgo.setMonth(oneMonthAgo.getMonth() - 1);
  
      const notifications = await prisma.notification.findMany({
        where: { 
          recipientId: req.user.id,
          createdAt: { gte: oneMonthAgo } ,
          senderId: { not: req.user.id }
        },
        include: {
          sender: { select: { id: true, username: true, profileImage: true } },
          post: { select: { id: true,
            imagePaths: true,
            videoPaths: true } }
        },
        orderBy: { createdAt: 'desc' }
      });

      const formattedNotifications = notifications.map(notification => {
      let message = '';
      switch (notification.type) {
        case 'LIKE':
          message = `${notification.sender.username} liked your post`;
          break;
        case 'COMMENT':
          message = `${notification.sender.username} commented on your post`;
          break;
        case 'BOOKMARK':
          message = `${notification.sender.username} bookmarked your post`;
          break;
        default:
          message = 'New notification';
      }

      return {
        ...notification,
        message,
        sender: {
          ...notification.sender,
          profileImage: notification.sender.profileImage ? 
            `${process.env.BASE_URL}/uploads/${notification.sender.profileImage}` : 
            null
        }
      };
    });
  
      res.status(200).json(formattedNotifications);
  } catch (error) {
    console.error("Notification error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};
  
  // Mark notification as read
   const markAsRead = async (req, res) => {
    try {
      await prisma.notification.update({
        where: { id: parseInt(req.params.id) },
        data: { read: true }
      });
      
      res.status(200).json({ success: true });
    } catch (error) {
      res.status(500).json({ error: "Internal server error" });
    }
  };
  export default {
    getUserNotifications,
    markAsRead
  };