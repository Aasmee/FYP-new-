import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

// GET pantry items for a user
export const getPantryItems = async (req, res) => {
  const userId = req.user.id;

  try {
    const items = await prisma.pantry.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
    });
    res.json(items);
  } catch (error) {
    console.error("Error fetching pantry items:", error);
    res.status(500).json({ message: "Failed to fetch pantry items" });
  }
};

// POST: Add new pantry item
export const addPantryItem = async (req, res) => {
  const userId = req.user.id;
  const { name, quantity, unit, category } = req.body;

  if (!name || !quantity || !unit) {
    return res.status(400).json({ message: "Missing required fields" });
  }

  try {
    const newItem = await prisma.pantry.create({
      data: {
        name,
        quantity: parseFloat(quantity),
        unit,
        category: category?.trim(), // Optional — Prisma will use default if undefined
        userId,
      },
    });
    res.status(201).json(newItem);
  } catch (error) {
    console.error("Error adding pantry item:", error);
    res.status(500).json({ message: "Failed to add pantry item", error: error.message });
  }
};

// DELETE a pantry item
export const deletePantryItem = async (req, res) => {
  const userId = req.user.id;
  const itemId = parseInt(req.params.id);

  try {
    const item = await prisma.pantry.findUnique({
      where: { id: itemId },
    });

    if (!item || item.userId !== userId) {
      return res.status(403).json({ message: "Unauthorized or item not found" });
    }

    await prisma.pantry.delete({ where: { id: itemId } });
    res.json({ message: "Item deleted successfully" });
  } catch (error) {
    console.error("Error deleting pantry item:", error);
    res.status(500).json({ message: "Failed to delete item" });
  }
};
