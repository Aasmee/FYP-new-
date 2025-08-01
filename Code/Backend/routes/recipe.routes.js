import express from "express";
import { getAllRecipes, getRecipeById, createRecipe } from "../controller/recipe.controller.js";

const router = express.Router();

router.get("/", getAllRecipes);
router.get("/:id", getRecipeById);
router.post("/", createRecipe);
// router.post("/save-tags", saveSearchedTags);


export default router;
