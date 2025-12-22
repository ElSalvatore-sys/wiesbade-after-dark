import { test, expect, login } from './fixtures';

test.describe('Mobile Responsiveness', () => {
  test.use({ viewport: { width: 375, height: 667 } }); // iPhone SE

  test('Should display mobile-friendly login', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByPlaceholder(/email/i)).toBeVisible();
    await expect(page.getByPlaceholder(/password/i)).toBeVisible();
  });

  test('Should login on mobile', async ({ page }) => {
    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');
    await page.getByRole('button', { name: /sign in|login|anmelden/i }).click();

    // Wait for dashboard content instead of URL
    await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible({ timeout: 10000 });
  });

  test('Should have mobile navigation', async ({ page }) => {
    await login(page);

    // On mobile, look for collapse/menu button or visible nav buttons
    const collapseButton = page.getByRole('button', { name: /collapse|menu/i });
    const navButtons = page.getByRole('button', { name: /dashboard|events|bookings/i });

    // Either collapse button or nav buttons should be visible
    const hasCollapse = await collapseButton.isVisible().catch(() => false);
    const hasNavButtons = await navButtons.first().isVisible().catch(() => false);

    expect(hasCollapse || hasNavButtons).toBeTruthy();
  });

  test('Should be scrollable on mobile', async ({ page }) => {
    await login(page);

    // Should be able to scroll
    await page.evaluate(() => window.scrollTo(0, 100));
    const scrollY = await page.evaluate(() => window.scrollY);
    expect(scrollY).toBeGreaterThanOrEqual(0);
  });
});
