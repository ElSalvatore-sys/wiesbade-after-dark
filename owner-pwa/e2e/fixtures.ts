import { test as base, expect, Page } from '@playwright/test';

/**
 * Login helper - waits for dashboard content instead of URL change
 * The app uses client-side state navigation, not URL routing
 */
export async function login(page: Page) {
  await page.goto('/');
  // German placeholders: "E-Mail" and "Passwort"
  await page.getByPlaceholder('E-Mail').fill('owner@example.com');
  await page.getByPlaceholder('Passwort').fill('password');
  await page.getByRole('button', { name: /anmelden/i }).click();

  // Wait for dashboard content to appear (not URL change)
  await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible({ timeout: 10000 });
}

/**
 * Navigate to a page via sidebar button click
 */
export async function navigateTo(page: Page, pageName: string) {
  const button = page.getByRole('button', { name: new RegExp(pageName, 'i') });
  await button.click();
  await page.waitForTimeout(500); // Brief wait for navigation
}

/**
 * Test fixture with logged-in state
 */
export const test = base.extend<{ loggedInPage: Page }>({
  loggedInPage: async ({ page }, use) => {
    await login(page);
    await use(page);
  },
});

export { expect };
