import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

// GET all list items for logged-in user
export const getListItems = async (req, res) => {
  try {
    const items = await prisma.listItem.findMany({
      where: { userId: req.user.id },
      orderBy: { createdAt: 'desc' }
    });
    res.json(items);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch list items' });
  }
};

// ADD a new list item
export const addListItem = async (req, res) => {
  const { name, quantity, unit } = req.body;
  if (!name || !quantity || !unit) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    const newItem = await prisma.listItem.create({
      data: {
        name,
        quantity: parseFloat(quantity),
        unit,
        userId: req.user.id
      }
    });
    res.status(201).json(newItem);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to add item' });
  }
};


// UPDATE an item (e.g., checkbox toggle)
export const updateListItem = async (req, res) => {
  const { id } = req.params;
  const { isChecked, name, quantity, unit } = req.body;

  try {
    const item = await prisma.listItem.findUnique({
      where: { id: parseInt(id) }
    });

    if (!item || item.userId !== req.user.id) {
      return res.status(404).json({ error: 'Item not found' });
    }

    const updatedItem = await prisma.listItem.update({
      where: { id: parseInt(id) },
      data: {
        isChecked: isChecked ?? item.isChecked,
        name: name ?? item.name,
        quantity: quantity ?? item.quantity,
        unit: unit ?? item.unit
      }
    });
    res.json(updatedItem);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to update item' });
  }
};

// DELETE an item
export const deleteListItem = async (req, res) => {
  const { id } = req.params;

  try {
    const item = await prisma.listItem.findUnique({
      where: { id: parseInt(id) }
    });

    if (!item || item.userId !== req.user.id) {
      return res.status(404).json({ error: 'Item not found' });
    }

    await prisma.listItem.delete({
      where: { id: parseInt(id) }
    });

    res.json({ message: 'Item deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to delete item' });
  }
};
