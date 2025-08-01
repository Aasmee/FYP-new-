import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

export const toggleLike = async (req, res) => {
    try {
        const { postId } = req.params;
        const userId = req.user.id;

        const parsedPostId = parseInt(postId);
        if (isNaN(parsedPostId)) {
            return res.status(400).json({ error: "Invalid post ID" });
        }

        // Verify post exists
        const post = await prisma.post.findUnique({
            where: { id: parsedPostId },
            select: { id: true, userId: true }
        });
        if (!post) return res.status(404).json({ error: "Post not found" });

        // Check existing like using unique constraint
        const existingLike = await prisma.like.findUnique({
            where: { userId_postId: { userId, postId: parsedPostId } }
        });

        if (existingLike) {
            // Delete like
            await prisma.like.delete({
                where: { id: existingLike.id }
            });

            // Get updated like count
            const likeCount = await prisma.like.count({
                where: { postId: parsedPostId }
            });

            // Delete notification
            await prisma.notification.deleteMany({
                where: {
                    type: 'LIKE',
                    senderId: userId,
                    postId: parsedPostId
                }
            });

            return res.status(200).json({
                success: true,
                liked: false,
                likeCount
            });
        }

        // Create new like
        await prisma.like.create({
            data: { userId, postId: parsedPostId }
        });

        // Get updated like count
        const likeCount = await prisma.like.count({
            where: { postId: parsedPostId }
        });

        // Create notification
        await prisma.notification.create({
            data: {
                type: 'LIKE',
                recipientId: post.userId,
                senderId: userId,
                postId: parsedPostId
            }
        });

        res.status(200).json({
            success: true,
            liked: true,
            likeCount
        });

    } catch (error) {
        console.error("Like error:", error);
        
        // Handle unique constraint error
        if (error.code === 'P2002') {
            return res.status(409).json({ 
                message: "Post already liked" 
            });
        }
        
        res.status(500).json({ message: "Something went wrong" });
    }
};