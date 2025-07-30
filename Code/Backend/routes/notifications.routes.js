// notifications.routes.js
import express from 'express';
import notificationsController from '../controller/notifications.controller.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

router.get('/', authenticate, notificationsController.getUserNotifications);
router.patch('/:id/read', authenticate, notificationsController.markAsRead);

export default router;