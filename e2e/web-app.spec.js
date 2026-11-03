const { test, expect } = require("@playwright/test");

test.describe("MiniLinkedIn E2E & Browser Automation Tests", () => {
  test("Frontend Web: Flutter Web app tải thành công tại port 3000", async ({ page }) => {
    const response = await page.goto("/", { waitUntil: "domcontentloaded" });
    expect(response?.status()).toBe(200);

    // Kiểm tra title trang
    await expect(page).toHaveTitle(/MiniLinkedIn|App|Flutter/i);

    // Chờ Flutter engine bootstrap (flutter-view hoặc flt-glass-pane)
    const flutterView = page.locator("flutter-view, flt-glass-pane, flt-scene");
    await expect(flutterView.first()).toBeAttached({ timeout: 15000 });
  });

  test("Backend API Health: Kiểm tra dịch vụ backend trên port 5001", async ({ request }) => {
    const res = await request.get("http://localhost:5001/health");
    expect(res.ok()).toBeTruthy();
    const body = await res.json();
    expect(body.database).toBe("connected");
  });

  test("Backend API Jobs: Lấy danh sách việc làm công khai với dữ liệu phong phú", async ({ request }) => {
    const res = await request.get("http://localhost:5001/api/v1/jobs");
    expect(res.ok()).toBeTruthy();
    const body = await res.json();
    expect(Array.isArray(body.data)).toBeTruthy();
    expect(body.data.length).toBeGreaterThan(0);
    expect(body.meta.total).toBeGreaterThanOrEqual(100);
  });
});

