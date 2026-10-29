const express = require("express");
const c = require("../../controllers/social/media.controller");
const { uploadImageMiddleware } = require("../../middleware/social/image-upload");

const router = express.Router();

router.post("/media", uploadImageMiddleware, c.uploadMedia);

module.exports = router;
