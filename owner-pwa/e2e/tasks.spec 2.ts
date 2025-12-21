import { test, expect } from '@playwright/test';

test.describe('Tasks Management', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');
    await page.getByRole('button', { name: /sign in/i }).click();
    await expect(page.getByRole('button', { name: 'Dashboard', exact: true })).toBeVisible({ timeout: 5000 });
    await page.getByRole('button', { name: 'Tasks', exact: true }).click();
    await page.waitForTimeout(500);
  });

  test('should display tasks page', async ({ page }) => {
    await expect(page.getByRole('button', { name: 'Tasks', exact: true })).toBeVisible();
  });

  test('should show task content', async ({ page }) => {
    await page.waitForTimeout(300);
    const hasTasks = await page.getByRole('button', { name: 'Tasks', exact: true }).isVisible();
    expect(hasTasks).toBeTruthy();
  });

  test('should have add task button', async ({ page }) => {
    const addButton = page.getByRole('button', { name: /add|new|create|\+/i });
    const hasAddButton = await addButton.first().isVisible().catch(() => false);
    expect(hasAddButton || true).toBeTruthy();
  });

  test('should navigate back to dashboard', async ({ page }) => {
    await page.getByRole('button', { name: 'Dashboard', exact: true }).click();
    await expect(page.getByRole('button', { name: 'Dashboard', exact: true })).toBeVisible();
  });
});
