import express from 'express';
import {
  getListItems,
  addListItem,
  updateListItem,
  deleteListItem
} from '../controller/listItem.controller.js';
import { authenticate } from '../middleware/auth.js'; // JWT authentication

const router = express.Router();

// All routes require authentication
router.get('/', authenticate, getListItems);
router.post('/', authenticate, addListItem);
router.patch('/:id', authenticate, updateListItem);
router.delete('/:id', authenticate, deleteListItem);

export default router;
