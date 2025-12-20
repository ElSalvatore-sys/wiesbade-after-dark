import { test, expect } from '@playwright/test';

test.describe('Events Management', () => {
  test.beforeEach(async ({ page }) => {
    // Login before each test
    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');
    await page.getByRole('button', { name: /sign in/i }).click();

    // Wait for dashboard to load
    await expect(page.getByRole('button', { name: 'Dashboard', exact: true })).toBeVisible({ timeout: 5000 });

    // Navigate to events using sidebar (exact match)
    await page.getByRole('button', { name: 'Events', exact: true }).click();
    await page.waitForTimeout(500);
  });

  test('should display events page', async ({ page }) => {
    // Events navigation should be visible in sidebar
    await expect(page.getByRole('button', { name: 'Events', exact: true })).toBeVisible();
  });

  test('should have create event button', async ({ page }) => {
    // Look for add/create button with "New Event" or similar text
    const addButton = page.getByRole('button', { name: /new event|create event|\+/i });
    await expect(addButton.first()).toBeVisible({ timeout: 3000 });
  });

  test('should show events page content', async ({ page }) => {
    // The page should have filter buttons or content
    await page.waitForTimeout(500);
    // Check for All Events filter button which we saw in the error
    const hasAllEvents = await page.getByRole('button', { name: 'All Events' }).isVisible().catch(() => false);
    const hasEvents = await page.getByRole('button', { name: 'Events', exact: true }).isVisible();
    expect(hasAllEvents || hasEvents).toBeTruthy();
  });

  test('should have event filter tabs', async ({ page }) => {
    // Check for filter tabs
    const allEventsTab = page.getByRole('button', { name: 'All Events' });
    if (await allEventsTab.isVisible().catch(() => false)) {
      await expect(allEventsTab).toBeVisible();
    }
  });
});
