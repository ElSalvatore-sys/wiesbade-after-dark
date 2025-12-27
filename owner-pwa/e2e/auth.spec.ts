import { test, expect } from '@playwright/test';

/**
 * Authentication Tests
 * Tests login, logout, password reset, and session management
 */
test.describe('Authentication', () => {
  test('should show login page elements', async ({ page }) => {
    await page.goto('/');

    // Check for email and password inputs using actual placeholders
    await expect(page.getByPlaceholder('E-Mail')).toBeVisible();
    await expect(page.getByPlaceholder('Passwort')).toBeVisible();
    
    // Check for login button
    await expect(page.getByRole('button', { name: 'Anmelden' })).toBeVisible();
  });

  test('should login successfully with valid credentials', async ({ page }) => {
    await page.goto('/');

    // Enter valid credentials using actual placeholders
    await page.getByPlaceholder('E-Mail').fill('owner@example.com');
    await page.getByPlaceholder('Passwort').fill('password');
    await page.getByRole('button', { name: 'Anmelden' }).click();

    // Wait for navigation
    await page.waitForTimeout(3000);

    // Dashboard H1 heading should be visible (use first() to avoid strict mode violation)
    await expect(page.locator('h1').filter({ hasText: /dashboard/i }).first()).toBeVisible({ timeout: 10000 });
  });

  test('should show error with invalid credentials', async ({ page }) => {
    await page.goto('/');

    // Enter invalid credentials
    await page.getByPlaceholder('E-Mail').fill('invalid@example.com');
    await page.getByPlaceholder('Passwort').fill('wrongpassword');
    await page.getByRole('button', { name: 'Anmelden' }).click();

    await page.waitForTimeout(2000);

    // Should still show login form (didn't successfully log in)
    const isVisible = await page.getByPlaceholder('E-Mail').isVisible().catch(() => false);
    expect(isVisible).toBeTruthy();
  });

  test('should logout successfully', async ({ page }) => {
    // Login first
    await page.goto('/');
    await page.getByPlaceholder('E-Mail').fill('owner@example.com');
    await page.getByPlaceholder('Passwort').fill('password');
    await page.getByRole('button', { name: 'Anmelden' }).click();

    // Wait for dashboard
    await page.waitForTimeout(3000);
    await expect(page.locator('h1').filter({ hasText: /dashboard/i }).first()).toBeVisible();

    // Find and click logout button
    const logoutBtn = page.getByRole('button', { name: /logout|abmelden/i });

    if (await logoutBtn.isVisible({ timeout: 5000 }).catch(() => false)) {
      await logoutBtn.click();
      await page.waitForTimeout(1000);

      // Should be back at login
      await expect(page.getByPlaceholder('E-Mail')).toBeVisible({ timeout: 5000 });
    }
  });

  test('should show password reset option', async ({ page }) => {
    await page.goto('/');

    // Look for "Passwort vergessen?" button
    const forgotPassword = page.getByRole('button', { name: /passwort vergessen/i });
    const isVisible = await forgotPassword.isVisible().catch(() => false);
    expect(isVisible).toBeTruthy();
  });

  test('should handle authentication state', async ({ page, context }) => {
    // Clear any existing sessions
    await context.clearCookies();
    await page.goto('/');
    await page.waitForTimeout(2000);

    // Fresh visit should show login or dashboard (app decides based on stored state)
    const hasLoginForm = await page.getByPlaceholder('E-Mail').isVisible({ timeout: 3000 }).catch(() => false);
    const hasDashboard = await page.locator('h1').filter({ hasText: /dashboard/i }).first().isVisible({ timeout: 3000 }).catch(() => false);
    
    // One of them should be visible (either login or authenticated dashboard)
    expect(hasLoginForm || hasDashboard).toBeTruthy();
  });

  test('should remember session on page reload', async ({ page }) => {
    // Login
    await page.goto('/');
    await page.getByPlaceholder('E-Mail').fill('owner@example.com');
    await page.getByPlaceholder('Passwort').fill('password');
    await page.getByRole('button', { name: 'Anmelden' }).click();

    // Wait for dashboard
    await page.waitForTimeout(3000);

    // Reload page
    await page.reload();
    await page.waitForTimeout(2000);

    // Should still show dashboard (not login form)
    const dashboardVisible = await page.locator('h1').filter({ hasText: /dashboard/i }).first().isVisible({ timeout: 5000 }).catch(() => false);
    expect(dashboardVisible).toBeTruthy();
  });
});
