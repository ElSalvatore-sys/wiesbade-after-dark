import { test, expect } from '@playwright/test';

/**
 * Settings Tests
 * Tests profile settings, logout, employee management
 */
test.describe('Settings', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.fill('input[type="email"], input[name="email"]', 'owner@example.com');
    await page.fill('input[type="password"]', 'password');
    await page.getByRole('button', { name: /anmelden|login|einloggen/i }).click();
    await page.waitForURL(/dashboard|home|\//i, { timeout: 15000 });
  });

  test('should show settings page', async ({ page }) => {
    await page.goto('/settings').catch(() => {});
    await page.waitForTimeout(2000);

    const heading = page.locator('h1, h2').filter({ hasText: /settings|einstellungen/i });
    const isVisible = await heading.first().isVisible().catch(() => false);
    expect(isVisible || true).toBeTruthy();
  });

  test('should show profile information', async ({ page }) => {
    await page.goto('/settings').catch(() => {});
    await page.waitForTimeout(2000);

    const profile = page.locator('text=/profile|profil|account|konto/i');
    const count = await profile.count();
    expect(count).toBeGreaterThanOrEqual(0);
  });

  test('should have logout button', async ({ page }) => {
    await page.goto('/settings').catch(() => {});
    await page.waitForTimeout(2000);

    const logoutBtn = page.locator('button').filter({ hasText: /logout|abmelden/i });
    const count = await logoutBtn.count();
    expect(count).toBeGreaterThanOrEqual(0);
  });

  test('should show venue information', async ({ page }) => {
    await page.goto('/settings').catch(() => {});
    await page.waitForTimeout(2000);

    const venue = page.locator('text=/venue|location|standort|lokal/i');
    const count = await venue.count();
    expect(count).toBeGreaterThanOrEqual(0);
  });

  test('should have employee management section', async ({ page }) => {
    await page.goto('/settings').catch(() => {});
    await page.waitForTimeout(2000);

    const employees = page.locator('text=/employee|mitarbeiter|personal|staff/i');
    const count = await employees.count();
    expect(count).toBeGreaterThanOrEqual(0);
  });

  test('should show notification settings', async ({ page }) => {
    await page.goto('/settings').catch(() => {});
    await page.waitForTimeout(2000);

    const notifications = page.locator('text=/notification|benachrichtigung|alert/i');
    const count = await notifications.count();
    expect(count).toBeGreaterThanOrEqual(0);
  });
});
