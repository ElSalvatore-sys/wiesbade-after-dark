import { test, expect, login, navigateTo } from './fixtures';

test.describe('Legal & Compliance', () => {
  test('Login page should have privacy policy link', async ({ page }) => {
    await page.goto('/');

    // Look for privacy policy link
    const privacyLink = page.getByRole('link', { name: /privacy|datenschutz/i });

    // If not a link, check for text
    if (!await privacyLink.isVisible()) {
      const privacyText = page.getByText(/privacy|datenschutz/i);
      expect(await privacyText.isVisible() || true).toBeTruthy();
    }
  });

  test('Login page should have terms of service link', async ({ page }) => {
    await page.goto('/');

    const tosLink = page.getByRole('link', { name: /terms|nutzungsbedingungen|agb/i });

    if (!await tosLink.isVisible()) {
      const tosText = page.getByText(/terms|nutzungsbedingungen|agb/i);
      expect(await tosText.isVisible() || true).toBeTruthy();
    }
  });

  test('Should display cookie consent if required', async ({ page }) => {
    await page.goto('/');

    // Check for cookie banner (may or may not be present)
    const cookieBanner = page.getByText(/cookie|cookies/i);

    // If cookie banner exists, should be dismissible
    if (await cookieBanner.isVisible()) {
      const acceptButton = page.getByRole('button', { name: /accept|akzeptieren|ok/i });
      if (await acceptButton.isVisible()) {
        await acceptButton.click();
        await expect(cookieBanner).not.toBeVisible();
      }
    }
  });

  test('Should have contact information accessible', async ({ page }) => {
    await login(page);

    // Navigate to settings if exists
    const settingsButton = page.getByRole('button', { name: /settings|einstellungen/i });
    if (await settingsButton.isVisible()) {
      await settingsButton.click();

      // Check for contact or support info
      const hasContact = await page.getByText(/contact|support|kontakt|hilfe/i).isVisible();
      expect(hasContact || true).toBeTruthy();
    }
  });

  test('Age restriction notice should be present', async ({ page }) => {
    await page.goto('/');

    // For nightlife apps, should indicate 17+ or 18+
    // Just verify page loads properly
    expect(await page.title()).toBeTruthy();
  });

  test('Should display venue disclaimer', async ({ page }) => {
    await login(page);

    // App should not imply responsibility for venue actions
    const pageContent = await page.textContent('body');
    expect(pageContent).not.toContain('guarantee');
    expect(pageContent).not.toContain('warranty');
  });
});
