const { Router } = require("express");
const authController = require("../controllers/auth.controller");
const { authenticate } = require("../middleware/auth");

const router = Router();

router.post("/register", authController.register);
router.post("/login", authController.login);
router.post("/google", authController.googleLogin);
router.post("/refresh", authController.refresh);
router.post("/logout", authController.logout);
router.get("/me", authenticate, authController.getMe);

module.exports = router;
