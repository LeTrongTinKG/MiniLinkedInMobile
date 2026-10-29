const express = require("express");
const c = require("../../controllers/social/comment.controller");

const router = express.Router();

router.get("/posts/:postId/comments", c.listComments);
router.post("/posts/:postId/comments", c.createComment);
router.get("/comments/:commentId/replies", c.listReplies);
router.patch("/comments/:commentId", c.updateComment);
router.delete("/comments/:commentId", c.deleteComment);

module.exports = router;
