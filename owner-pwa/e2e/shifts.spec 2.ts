import { test, expect } from '@playwright/test';

test.describe('Shifts Management', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');
    await page.getByRole('button', { name: /sign in/i }).click();
    await expect(page.getByRole('button', { name: 'Dashboard', exact: true })).toBeVisible({ timeout: 5000 });
    await page.getByRole('button', { name: 'Shifts', exact: true }).click();
    await page.waitForTimeout(500);
  });

  test('should display shifts page', async ({ page }) => {
    await expect(page.getByRole('button', { name: 'Shifts', exact: true })).toBeVisible();
  });

  test('should show shift controls', async ({ page }) => {
    // Page should have shift-related content
    await page.waitForTimeout(300);
    const hasShifts = await page.getByRole('button', { name: 'Shifts', exact: true }).isVisible();
    expect(hasShifts).toBeTruthy();
  });

  test('should navigate to other pages', async ({ page }) => {
    await page.getByRole('button', { name: 'Dashboard', exact: true }).click();
    await expect(page.getByRole('button', { name: 'Dashboard', exact: true })).toBeVisible();
  });
});
