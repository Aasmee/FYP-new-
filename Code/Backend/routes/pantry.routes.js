import express from "express";
import {
  getPantryItems,
  addPantryItem,
  deletePantryItem,
} from "../controller/pantry.controller.js";
import { authenticate } from "../middleware/auth.js";

const router = express.Router();

router.get("/", authenticate, getPantryItems);
router.post("/", authenticate, addPantryItem);
router.delete("/:id", authenticate, deletePantryItem);

export default router;
