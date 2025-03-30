// routes/taskRoutes.js
const express = require('express');
const router = express.Router();
const {
  createTask,
  getTasks,
  updateTask,
  deleteTask,
} = require('../controllers/taskController');
const { protect } = require('../middleware/authMiddleware');

// Protected routes for tasks
router.route('/')
  .post(protect, createTask)    // Create new task
  .get(protect, getTasks);      // Get all tasks for user

router.route('/:id')
  .put(protect, updateTask)      // Update a specific task
  .delete(protect, deleteTask);  // Delete a specific task

module.exports = router;
