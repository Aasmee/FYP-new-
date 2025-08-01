import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

// Bookmark/Unbookmark a post
export const bookmarkPost = async (req, res) => {
    try {
        const userId = req.user.id;
        const postId = parseInt(req.params.postId);

        // Validate post ID
        if (isNaN(postId)) {
            return res.status(400).json({ message: "Invalid post ID" });
        }

        // Check if post exists
        const post = await prisma.post.findUnique({ 
            where: { id: postId },
            select: { userId: true }
        });
        
        if (!post) {
            return res.status(404).json({ message: "Post not found" });
        }

        // Check existing bookmark
        const existingBookmark = await prisma.bookmark.findUnique({
            where: { unique_bookmark: { userId, postId } }
        });

        if (existingBookmark) {
            // Remove bookmark
            await prisma.bookmark.delete({
                where: { id: existingBookmark.id }
            });

            // Remove associated notification
            await prisma.notification.deleteMany({
                where: {
                    type: 'BOOKMARK',
                    senderId: userId,
                    postId: postId
                }
            });

            return res.status(200).json({ 
                bookmarked: false,
                message: "Bookmark removed"
            });
        }

        // Create new bookmark
        const newBookmark = await prisma.bookmark.create({
            data: { userId, postId }
        });

        // Create notification
        await prisma.notification.create({
            data: {
                type: 'BOOKMARK',
                recipientId: post.userId,
                senderId: userId,
                postId: postId
            }
        });

        return res.status(201).json({ 
            bookmarked: true,
            message: "Post bookmarked" 
        });

    } catch (error) {
        console.error("Bookmark error:", error);
        
        // Handle unique constraint error
        if (error.code === 'P2002') {
            return res.status(409).json({ 
                message: "Post already bookmarked" 
            });
        }
        
        return res.status(500).json({ 
            message: "Internal server error" 
        });
    }
};

// Get all bookmarked posts
export const getBookmarkedPosts = async (req, res) => {
  try {
    const userId = req.user.id;

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        username: true,
        profileImage: true,
        posts: {
          include: {
            user: { select: { id: true, username: true, profileImage: true } },
            _count: { select: { likes: true, comments: true } },
          }
        },
        bookmarks: {
          include: {
            post: {
              include: {
                user: { select: { id: true, username: true, profileImage: true } },
                _count: { select: { likes: true, comments: true } },
                likes: {
                  where: { userId },
                  select: { id: true }
                }
              }
            }
          }
        }
      }
    });

    // Format saved posts
    const savedPosts = user.bookmarks.map(b => ({
      ...b.post,
      hasLiked: b.post.likes.length > 0,
      isBookmarked: true,
    }));

    return res.json({
      username: user.username,
      profileImage: user.profileImage,
      posts: user.posts,
      savedPosts
    });

  } catch (error) {
    console.error("Error fetching bookmarks:", error);
    return res.status(500).json({ 
      error: "Failed to fetch bookmarked posts",
      details: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
};
