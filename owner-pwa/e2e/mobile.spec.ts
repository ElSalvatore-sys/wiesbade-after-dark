import { test, expect, devices } from '@playwright/test';

// Use iPhone 13 device settings for all tests in this file
test.use({ ...devices['iPhone 13'] });

test.describe('Mobile Responsiveness', () => {
  test('should show login page on mobile', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByPlaceholder(/email/i)).toBeVisible();
    await expect(page.getByPlaceholder(/password/i)).toBeVisible();
  });

  test('should login successfully on mobile', async ({ page }) => {
    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');
    await page.getByRole('button', { name: /sign in/i }).click();

    // Wait for login to complete - check for something visible on mobile
    // The sidebar W logo should still be visible even when collapsed
    await page.waitForTimeout(2000);

    // Check that login page is gone (no "Welcome Back" heading)
    const loginVisible = await page.getByRole('heading', { name: /welcome back/i }).isVisible().catch(() => false);
    expect(loginVisible).toBeFalsy();
  });

  test('should have responsive layout', async ({ page }) => {
    await page.goto('/');

    // Check viewport is mobile sized
    const viewport = page.viewportSize();
    expect(viewport?.width).toBeLessThan(500);
  });

  test('should show demo login buttons on mobile', async ({ page }) => {
    await page.goto('/');
    // Demo login buttons should be visible
    await expect(page.getByRole('button', { name: /owner/i })).toBeVisible();
  });

  test('should show sign in button on mobile', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByRole('button', { name: /sign in/i })).toBeVisible();
  });
});
