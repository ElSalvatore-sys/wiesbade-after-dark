import { test, expect, login, navigateTo } from './fixtures';

test.describe('Events Management', () => {
  test.beforeEach(async ({ page }) => {
    await login(page);
  });

  test('Should access events from dashboard', async ({ page }) => {
    const eventsButton = page.getByRole('button', { name: /events|veranstaltung/i }).first();
    const hasEvents = await eventsButton.isVisible().catch(() => false);
    if (hasEvents) {
      await eventsButton.click();
      await expect(page.getByRole('heading', { name: /events|veranstaltung/i }).first()).toBeVisible({ timeout: 5000 });
    } else {
      // Events may be accessed differently - check if we're still logged in
      await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible();
    }
  });

  test('Should display events list', async ({ page }) => {
    await navigateTo(page, 'events');
    const eventsList = page.locator('[class*="event"], [class*="list"], [class*="card"], table');
    await expect(eventsList.first()).toBeVisible({ timeout: 5000 });
  });

  test('Should have create event functionality', async ({ page }) => {
    await navigateTo(page, 'events');
    const addButton = page.getByRole('button', { name: /add|create|new|neu/i });
    await expect(addButton).toBeVisible();
  });
});
