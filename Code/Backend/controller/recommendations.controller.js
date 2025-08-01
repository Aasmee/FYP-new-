import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

// controllers/recommendations.controller.js
export const getBasicTagRecommendations = async (req, res) => {
  try {
    const userId = req.user.id; // ✅ Extracted from token

    const tagSearches = await prisma.userSearchHistory.findMany({
      where: { userId },
      select: { tagId: true },
    });

    const searchedTagIds = tagSearches.map(entry => entry.tagId);

    if (searchedTagIds.length === 0) {
      return res.status(200).json([]);
    }

    const recipes = await prisma.recipe.findMany({
      where: {
        tags: {
          some: {
            tagId: { in: searchedTagIds },
          },
        },
      },
      include: {
        tags: true,
      },
    });

    const scoredRecipes = recipes.map(recipe => {
      const matchedTags = recipe.tags.filter(rt => searchedTagIds.includes(rt.tagId));
      return {
        ...recipe,
        matchScore: matchedTags.length,
      };
    });

    scoredRecipes.sort((a, b) => b.matchScore - a.matchScore);
    const topRecipes = scoredRecipes.slice(0, 10);

    res.json(topRecipes);
  } catch (error) {
    console.error("Recommendation Error:", error);
    res.status(500).json({ message: error.message });
  }
};
