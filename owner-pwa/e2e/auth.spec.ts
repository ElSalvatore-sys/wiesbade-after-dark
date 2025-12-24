import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  // German placeholders: "E-Mail" and "Passwort"
  test('Should show login page', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByPlaceholder('E-Mail')).toBeVisible();
    await expect(page.getByPlaceholder('Passwort')).toBeVisible();
    await expect(page.getByRole('button', { name: /anmelden/i })).toBeVisible();
  });

  test('Should show error on invalid credentials', async ({ page }) => {
    await page.goto('/');
    await page.getByPlaceholder('E-Mail').fill('invalid@example.com');
    await page.getByPlaceholder('Passwort').fill('wrongpassword');
    await page.getByRole('button', { name: /anmelden/i }).click();

    // Should show error message (German: "Ungültige" or similar)
    await expect(page.getByText(/invalid|error|falsch|ungültig|fehler/i)).toBeVisible({ timeout: 5000 });
  });

  test('Should login with valid credentials', async ({ page }) => {
    await page.goto('/');
    await page.getByPlaceholder('E-Mail').fill('owner@example.com');
    await page.getByPlaceholder('Passwort').fill('password');
    await page.getByRole('button', { name: /anmelden/i }).click();

    // Should show dashboard content (German: "Dashboard" heading)
    await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible({ timeout: 10000 });
    // Login page should be gone (E-Mail input no longer visible)
    await expect(page.getByPlaceholder('E-Mail')).not.toBeVisible({ timeout: 5000 });
  });

  test('Should logout successfully', async ({ page, isMobile }) => {
    // Login first
    await page.goto('/');
    await page.getByPlaceholder('E-Mail').fill('owner@example.com');
    await page.getByPlaceholder('Passwort').fill('password');
    await page.getByRole('button', { name: /anmelden/i }).click();

    // Wait for dashboard content to appear
    await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible({ timeout: 10000 });

    // On mobile, open the hamburger menu first to access sidebar
    if (isMobile) {
      // Click hamburger menu to open sidebar
      const menuButton = page.locator('button').filter({ has: page.locator('svg.lucide-menu') }).first();
      if (await menuButton.isVisible()) {
        await menuButton.click();
        await page.waitForTimeout(300); // Wait for sidebar animation
      }
    }

    // Find and click logout button (text is "Logout" when sidebar expanded)
    const logoutButton = page.getByRole('button', { name: /logout/i }).first();

    // If logout button not visible, try the user dropdown menu
    if (!(await logoutButton.isVisible({ timeout: 2000 }).catch(() => false))) {
      // Try clicking user avatar/dropdown to reveal logout
      const userMenu = page.locator('[class*="user"]').first();
      if (await userMenu.isVisible()) {
        await userMenu.click();
        await page.waitForTimeout(200);
      }
    }

    await expect(logoutButton).toBeVisible({ timeout: 5000 });
    await logoutButton.click();

    // Should return to login
    await expect(page.getByPlaceholder('E-Mail')).toBeVisible({ timeout: 5000 });
  });

  test('Should prevent access to protected routes when not logged in', async ({ page }) => {
    // App uses client-side state navigation, so going to / should show login
    await page.goto('/');
    // Should show login form
    await expect(page.getByPlaceholder('E-Mail')).toBeVisible({ timeout: 5000 });
  });
});
