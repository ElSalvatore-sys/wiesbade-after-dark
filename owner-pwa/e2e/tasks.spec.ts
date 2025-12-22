import { test, expect, login, navigateTo } from './fixtures';

test.describe('Tasks Management', () => {
  test.beforeEach(async ({ page }) => {
    await login(page);
    await navigateTo(page, 'tasks');
  });

  test('Should display tasks page', async ({ page }) => {
    await expect(page.getByRole('heading', { name: /tasks|aufgaben/i })).toBeVisible();
  });

  test('Should display task list', async ({ page }) => {
    const tasksList = page.locator('[class*="task"], [class*="list"], ul, table');
    await expect(tasksList.first()).toBeVisible({ timeout: 5000 });
  });

  test('Should have add task button', async ({ page }) => {
    const addButton = page.getByRole('button', { name: /add|create|new|neu|hinzufügen/i });
    await expect(addButton).toBeVisible();
  });
});
