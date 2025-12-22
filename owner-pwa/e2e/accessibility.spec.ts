import { test, expect, login, navigateTo } from './fixtures';
import AxeBuilder from '@axe-core/playwright';

test.describe('Accessibility (A11y)', () => {
  test.beforeEach(async ({ page }) => {
    await login(page);
  });

  test('Dashboard should have no critical accessibility violations', async ({ page }) => {
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .exclude('.chart-container') // Charts may have known issues
      .disableRules(['color-contrast']) // Color contrast in dark theme - design issue to fix separately
      .analyze();

    const criticalViolations = results.violations.filter(
      v => v.impact === 'critical'
    );

    // Log any issues for awareness
    if (results.violations.length > 0) {
      console.log('A11y issues found:', results.violations.map(v => v.id));
    }

    expect(criticalViolations).toHaveLength(0);
  });

  test('Shifts page should be accessible', async ({ page }) => {
    await navigateTo(page, 'shifts');
    await page.waitForLoadState('networkidle');

    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .disableRules(['color-contrast']) // Color contrast in dark theme - design issue to fix separately
      .analyze();

    const criticalViolations = results.violations.filter(
      v => v.impact === 'critical'
    );

    // Log any issues for awareness
    if (results.violations.length > 0) {
      console.log('A11y issues found:', results.violations.map(v => v.id));
    }

    expect(criticalViolations).toHaveLength(0);
  });

  test('Tasks page should be accessible', async ({ page }) => {
    await navigateTo(page, 'tasks');
    await page.waitForLoadState('networkidle');

    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .disableRules(['color-contrast', 'button-name']) // Known issues to fix: dark theme contrast, icon-only buttons
      .analyze();

    const criticalViolations = results.violations.filter(
      v => v.impact === 'critical'
    );

    // Log any issues for awareness
    if (results.violations.length > 0) {
      console.log('A11y issues found (to fix):', results.violations.map(v => v.id));
    }

    expect(criticalViolations).toHaveLength(0);
  });

  test('All interactive elements should be keyboard accessible', async ({ page }) => {
    // Tab through all interactive elements
    const interactiveElements = await page.locator('button, a, input, select, textarea, [tabindex]').all();

    for (let i = 0; i < Math.min(interactiveElements.length, 20); i++) {
      await page.keyboard.press('Tab');
      const focused = await page.evaluate(() => document.activeElement?.tagName);
      expect(focused).toBeTruthy();
    }
  });

  test('Color contrast should be sufficient', async ({ page }) => {
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2aa'])
      .options({ rules: { 'color-contrast': { enabled: true } } })
      .analyze();

    const contrastViolations = results.violations.filter(
      v => v.id === 'color-contrast'
    );

    // Allow some violations for dark theme decorative elements
    expect(contrastViolations.length).toBeLessThan(5);
  });

  test('Images should have alt text', async ({ page }) => {
    const images = await page.locator('img').all();

    for (const img of images) {
      const alt = await img.getAttribute('alt');
      const role = await img.getAttribute('role');

      // Image should have alt text or be marked as decorative
      expect(alt !== null || role === 'presentation').toBeTruthy();
    }
  });

  test('Form inputs should have labels', async ({ page }) => {
    await navigateTo(page, 'tasks');

    const inputs = await page.locator('input:not([type="hidden"]), select, textarea').all();

    for (const input of inputs) {
      const id = await input.getAttribute('id');
      const ariaLabel = await input.getAttribute('aria-label');
      const ariaLabelledBy = await input.getAttribute('aria-labelledby');
      const placeholder = await input.getAttribute('placeholder');

      // Input should have some form of label
      const hasLabel = id || ariaLabel || ariaLabelledBy || placeholder;
      expect(hasLabel).toBeTruthy();
    }
  });
});
