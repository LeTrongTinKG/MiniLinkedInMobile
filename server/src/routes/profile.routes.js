const { Router } = require("express");
const controller = require("../controllers/profile.controller");
const { authenticate } = require("../middleware/auth");

const router = Router();

router.get("/", authenticate, controller.getProfile);
router.put("/", authenticate, controller.updateProfile);

module.exports = router;

