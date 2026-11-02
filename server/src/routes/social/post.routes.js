const express = require("express");
const c = require("../../controllers/social/post.controller");

const router = express.Router();

router.get("/posts", c.listFeed);
router.post("/posts", c.createPost);
router.get("/posts/:postId", c.getPost);
router.patch("/posts/:postId", c.updatePost);
router.delete("/posts/:postId", c.deletePost);
router.get("/posts/:postId/revisions", c.listRevisions);
router.post("/posts/:postId/shares", c.sharePost);
router.get("/users/:userId/posts", c.listUserPosts);

module.exports = router;
