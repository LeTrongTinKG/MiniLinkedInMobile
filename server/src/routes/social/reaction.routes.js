const express = require("express");
const c = require("../../controllers/social/reaction.controller");

const router = express.Router();

router.put("/posts/:postId/reaction", c.setPostReaction);
router.delete("/posts/:postId/reaction", c.removePostReaction);
router.get("/posts/:postId/reactions", c.listPostReactions);
router.put("/comments/:commentId/reaction", c.setCommentReaction);
router.delete("/comments/:commentId/reaction", c.removeCommentReaction);

module.exports = router;
