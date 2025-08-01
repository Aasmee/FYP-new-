import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

// GET all recipes
export async function getAllRecipes(req, res) {
  try {
    const recipes = await prisma.recipe.findMany({
      include: {
        tags: { include: { tag: true } },
        ingredients: { include: { ingredient: true } },
        steps: { orderBy: { order: "asc" } },
      },
    });

    const formatted = recipes.map((r) => ({
      id: r.id,
      name: r.name,
      imageUrl: r.imageUrl,
      description: r.description,
      tags: r.tags.map((t) => t.tag.name),
      ingredients: r.ingredients.map((i) => i.ingredient.name),
      steps: r.steps.map((s) => ({ order: s.order, content: s.content })),
    }));

    res.json(formatted);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to fetch recipes" });
  }
}

// GET recipe by ID
export async function getRecipeById(req, res) {
  try {
    const recipe = await prisma.recipe.findUnique({
      where: { id: req.params.id },
      include: {
        tags: { include: { tag: true } },
        ingredients: { include: { ingredient: true } },
        steps: { orderBy: { order: "asc" } },
      },
    });

    if (!recipe) return res.status(404).json({ error: "Recipe not found" });

    res.json({
      id: recipe.id,
      name: recipe.name,
      imageUrl: recipe.imageUrl,
      description: recipe.description,
      tags: recipe.tags.map((t) => t.tag.name),
      ingredients: recipe.ingredients.map((i) => i.ingredient.name),
      steps: recipe.steps.map((s) => ({ order: s.order, content: s.content })),
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to fetch recipe" });
  }
}

// CREATE recipe (optional)
export async function createRecipe(req, res) {
  try {
    const { name, imageUrl, description, tags, ingredients, steps } = req.body;

    const recipe = await prisma.recipe.create({
      data: {
        name,
        imageUrl,
        description,
        tags: {
          create: tags.map((tagId) => ({
            tag: { connect: { id: tagId } },
          })),
        },
        ingredients: {
          create: ingredients.map((ingredientId) => ({
            ingredient: { connect: { id: ingredientId } },
          })),
        },
        steps: {
          create: steps.map((s, index) => ({
            order: index + 1,
            content: s,
          })),
        },
      },
    });

    res.status(201).json(recipe);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to create recipe" });
  }
}

// Save tags of searched recipes (one tag per history entry)
// export async function saveSearchedTags(req, res) {
//   try {
//     const { userId, tagId } = req.body;
//     const userIdInt = parseInt(userId, 10);
//     const tagIdInt = parseInt(tagId, 10);

//     if (!userIdInt || !tagIdInt) {
//       return res.status(400).json({ error: "Invalid input" });
//     }

//     await prisma.userSearchHistory.create({
//       data: {
//         userId: userIdInt,
//         tagId: tagIdInt
//       }
//     });

//     res.status(200).json({ success: true, message: "Tag saved successfully" });
//   } catch (error) {
//     console.error(error);
//     res.status(500).json({ error: "Failed to save tag" });
//   }
// }
