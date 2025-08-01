import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

// Add a comment
export const addComment = async (req, res) => {
    try {
        // Use userId from middleware if available, else from body (for backward compatibility)
        const userId = req.user?.id || req.body.userId;
        const { postId, text, parentId } = req.body;

        if (!userId || !postId) {
            return res.status(400).json({ message: "Missing required fields" });
        }

        // Verify post exists
        const postExists = await prisma.post.findUnique({
            where: { id: parseInt(postId) }
        });
        if (!postExists) {
            return res.status(404).json({ message: "Post not found" });
        }

        // Verify user exists
        const userExists = await prisma.user.findUnique({
            where: { id: parseInt(userId) }
        });
        if (!userExists) {
            return res.status(404).json({ message: "User not found" });
        }

        // Verify parent comment exists if replying
        if (parentId) {
            const parentComment = await prisma.comment.findUnique({
                where: { id: parseInt(parentId) }
            });
            if (!parentComment) {
                return res.status(404).json({ message: "Parent comment not found" });
            }
        }

        const comment = await prisma.comment.create({
            data: {
                userId: parseInt(userId),
                postId: parseInt(postId),
                text,
                parentId: parentId ? parseInt(parentId) : null
            },
            include: {
                user: { select: { username: true } },
                parent: true,
                replies: true
            }
        });

        // Create notification
        await prisma.notification.create({
            data: {
                type: 'COMMENT',
                recipientId: postExists.userId,
                senderId: parseInt(userId),
                postId: parseInt(postId)
            }
        });

        res.status(201).json({ message: "Comment added", comment });
    } catch (error) {
        console.error("Error adding comment:", error);

        if (error.code === 'P2003') {
            return res.status(400).json({
                message: "Invalid user or post ID"
            });
        }

        res.status(500).json({
            message: "Internal server error",
            error: error.message
        });
    }
};



// Get comments for a post
export const getComments = async (req, res) => {
    try {
        const { postId } = req.params;
        const comments = await prisma.comment.findMany({
            where: { 
                postId: parseInt(postId),
                parentId: null 
            },
            include: { 
                user: { select: { id: true, username: true } },
                replies: {
                    include: {
                        user: { select: { username: true } },
                        replies: { 
                            include: {
                                user: { select: { username: true } }
                            }
                        }
                    }
                }
            },
            orderBy: { createdAt: "desc" }
        });

        res.json({ postId, comments });
    } catch (error) {
        console.error("Error fetching comments:", error);
        res.status(500).json({ message: "Something went wrong" });
    }
};

// Delete a comment
export const deleteComment = async (req, res) => {
    try {
        const { commentId } = req.params;
        await prisma.comment.delete({ where: { id: parseInt(commentId) } });
        res.json({ message: "Comment deleted!" });
    } catch (error) {
        console.error("Error deleting comment:", error);
        res.status(500).json({ message: "Something went wrong" });
    }
};

// Edit a comment
export const editComment = async (req, res) => {
    try {
        const { commentId } = req.params;
        const { text } = req.body;

        if (!text.trim()) {
            return res.status(400).json({ message: "Comment cannot be empty" });
        }

        const updatedComment = await prisma.comment.update({
            where: { id: parseInt(commentId) },
            data: { text }
        });

        res.json({ message: "Comment updated successfully", updatedComment });
    } catch (error) {
        console.error("Error updating comment:", error);
        res.status(500).json({ message: "Something went wrong" });
    }
};


export const createComment = async (req, res) => {
    try {
      const { text, postId } = req.body;
      const userId = req.user.id;
  
      const comment = await prisma.comment.create({
        data: {
          text,
          userId,
          postId: parseInt(postId)
        }
      });
  
      // Create notification
      const post = await prisma.post.findUnique({
        where: { id: parseInt(postId) }
      });
  
      await prisma.notification.create({
        data: {
          type: 'COMMENT',
          recipientId: post.userId,
          senderId: userId,
          postId: parseInt(postId)
        }
      });
  
      res.status(201).json(comment);
    } catch (error) {
      console.error("Comment error:", error);
      res.status(500).json({ error: "Internal server error" });
    }
  };