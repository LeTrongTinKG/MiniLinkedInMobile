const express = require("express");
const interactionController = require("../controllers/interaction.controller");
const { authenticate } = require("../middleware/auth");

const router = express.Router();

/**
 * Cảm xúc + bình luận (mount ở /api/v1)
 * Gắn authenticate TỪNG ROUTE, không dùng router.use: router này mount ở /api/v1
 * nên router.use sẽ bắt đăng nhập cả các route mount sau nó.
 */
router.put("/reactions", authenticate, interactionController.setReaction);
router.delete("/reactions", authenticate, interactionController.removeReaction);
router.get("/reactions/summary", authenticate, interactionController.getSummary);

router.get("/comments", authenticate, interactionController.listComments);
router.post("/comments", authenticate, interactionController.createComment);
router.delete("/comments/:id", authenticate, interactionController.deleteComment);

module.exports = router;
