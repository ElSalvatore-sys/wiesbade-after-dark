import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('Should show login page', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByPlaceholder(/email/i)).toBeVisible();
    await expect(page.getByPlaceholder(/password/i)).toBeVisible();
    await expect(page.getByRole('button', { name: /sign in|login|anmelden/i })).toBeVisible();
  });

  test('Should show error on invalid credentials', async ({ page }) => {
    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('invalid@example.com');
    await page.getByPlaceholder(/password/i).fill('wrongpassword');
    await page.getByRole('button', { name: /sign in|login|anmelden/i }).click();

    // Should show error message
    await expect(page.getByText(/invalid|error|wrong|falsch|ungültig/i)).toBeVisible({ timeout: 5000 });
  });

  test('Should login with valid credentials', async ({ page }) => {
    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');
    await page.getByRole('button', { name: /sign in|login|anmelden/i }).click();

    // Should show dashboard content (app uses client-side state navigation, not URL routing)
    await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible({ timeout: 10000 });
    // Verify welcome message or dashboard stats are visible
    await expect(page.locator('text=/welcome|staff on shift|today/i').first()).toBeVisible({ timeout: 5000 });
  });

  test('Should logout successfully', async ({ page, isMobile }) => {
    // Login first
    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');
    await page.getByRole('button', { name: /sign in|login|anmelden/i }).click();

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

    // Find and click logout - could be in sidebar or user dropdown
    const logoutButton = page.getByRole('button', { name: /logout|abmelden|sign out/i }).first();

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
    await expect(page.getByPlaceholder(/email/i)).toBeVisible({ timeout: 5000 });
  });

  test('Should prevent access to protected routes when not logged in', async ({ page }) => {
    await page.goto('/dashboard');
    // Should redirect to login
    await expect(page.getByPlaceholder(/email/i)).toBeVisible({ timeout: 5000 });
  });
});
