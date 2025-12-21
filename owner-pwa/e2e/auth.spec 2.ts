import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('should display login page on initial load', async ({ page }) => {
    await page.goto('/');

    // Should show login form - heading says "Welcome Back"
    await expect(page.getByRole('heading', { name: /welcome back/i })).toBeVisible();
  });

  test('should show email and password fields', async ({ page }) => {
    await page.goto('/');

    // Uses placeholders instead of labels
    await expect(page.getByPlaceholder(/email/i)).toBeVisible();
    await expect(page.getByPlaceholder(/password/i)).toBeVisible();
    await expect(page.getByRole('button', { name: /sign in/i })).toBeVisible();
  });

  test('should show demo login buttons', async ({ page }) => {
    await page.goto('/');

    // Check for quick demo login buttons
    await expect(page.getByRole('button', { name: /owner/i })).toBeVisible();
    await expect(page.getByRole('button', { name: /manager/i })).toBeVisible();
    await expect(page.getByRole('button', { name: /bartender/i })).toBeVisible();
  });

  test('should show error for invalid credentials', async ({ page }) => {
    await page.goto('/');

    await page.getByPlaceholder(/email/i).fill('invalid@test.com');
    await page.getByPlaceholder(/password/i).fill('wrongpassword');
    await page.getByRole('button', { name: /sign in/i }).click();

    // Should show error message
    await expect(page.getByText(/invalid|error|credentials/i)).toBeVisible({ timeout: 5000 });
  });

  test('should login with valid credentials', async ({ page }) => {
    await page.goto('/');

    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');
    await page.getByRole('button', { name: /sign in/i }).click();

    // Should show dashboard content after login
    await expect(page.getByText(/dashboard/i)).toBeVisible({ timeout: 5000 });
  });

  test('should quick login with Owner demo button', async ({ page }) => {
    await page.goto('/');

    // Click Owner quick login
    await page.getByRole('button', { name: /owner/i }).click();

    // Email should be pre-filled
    await expect(page.getByPlaceholder(/email/i)).toHaveValue('owner@example.com');

    // Click sign in
    await page.getByRole('button', { name: /sign in/i }).click();

    // Should show dashboard
    await expect(page.getByText(/dashboard/i)).toBeVisible({ timeout: 5000 });
  });
});
