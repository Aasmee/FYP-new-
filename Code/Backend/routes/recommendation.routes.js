// routes/recommendation.routes.js
import express from "express";
import { getBasicTagRecommendations } from "../controller/recommendations.controller.js";
import { authenticate } from "../middleware/auth.js";

const router = express.Router();

router.get("/recommendations", authenticate, getBasicTagRecommendations);

export default router;
