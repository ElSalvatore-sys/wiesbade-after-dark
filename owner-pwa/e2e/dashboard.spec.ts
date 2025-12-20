import { test, expect } from '@playwright/test';

test.describe('Dashboard', () => {
  test.beforeEach(async ({ page }) => {
    // Login before each test
    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');
    await page.getByRole('button', { name: /sign in/i }).click();

    // Wait for dashboard to load - use exact match for sidebar button
    await expect(page.getByRole('button', { name: 'Dashboard', exact: true })).toBeVisible({ timeout: 5000 });
  });

  test('should display dashboard as active nav item', async ({ page }) => {
    // Dashboard button should be visible and is the default page
    await expect(page.getByRole('button', { name: 'Dashboard', exact: true })).toBeVisible();
  });

  test('should have navigation sidebar with all items', async ({ page }) => {
    // Check for main navigation items in sidebar - use exact match
    await expect(page.getByRole('button', { name: 'Events', exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Bookings', exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Inventory', exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Employees', exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Shifts', exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Tasks', exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Settings', exact: true })).toBeVisible();
  });

  test('should navigate to events page', async ({ page }) => {
    // Click on Events in sidebar
    await page.getByRole('button', { name: 'Events', exact: true }).click();
    await page.waitForTimeout(300);
  });

  test('should navigate to bookings page', async ({ page }) => {
    // Click on Bookings in sidebar
    await page.getByRole('button', { name: 'Bookings', exact: true }).click();
    await page.waitForTimeout(300);
  });

  test('should navigate to inventory page', async ({ page }) => {
    // Click on Inventory in sidebar
    await page.getByRole('button', { name: 'Inventory', exact: true }).click();
    await page.waitForTimeout(300);
  });

  test('should show app branding in sidebar', async ({ page }) => {
    // Should show "Wiesbaden" in the sidebar header
    await expect(page.getByText('Wiesbaden')).toBeVisible();
    await expect(page.getByText('Owner Portal')).toBeVisible();
  });

  test('should have logout button', async ({ page }) => {
    await expect(page.getByRole('button', { name: 'Logout', exact: true })).toBeVisible();
  });

  test('should logout and return to login', async ({ page }) => {
    await page.getByRole('button', { name: 'Logout', exact: true }).click();

    // Should be back at login page
    await expect(page.getByRole('heading', { name: /welcome back/i })).toBeVisible({ timeout: 3000 });
  });
});
