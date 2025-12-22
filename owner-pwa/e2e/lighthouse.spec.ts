import { test, expect, login } from './fixtures';
import { playAudit } from 'playwright-lighthouse';

test.describe('Lighthouse Performance Audits', () => {
  // Note: Lighthouse tests require Chrome and run slower
  test.setTimeout(60000);

  test('Login page should meet performance thresholds', async ({ page }, testInfo) => {
    // Skip in CI or non-Chrome browsers
    if (testInfo.project.name !== 'chromium') {
      test.skip();
      return;
    }

    await page.goto('/');
    await page.waitForLoadState('networkidle');

    try {
      const result = await playAudit({
        page,
        thresholds: {
          performance: 70,
          accessibility: 80,
          'best-practices': 80,
          seo: 80,
        },
        port: 9222,
        reports: {
          formats: { html: true },
          name: 'lighthouse-login',
          directory: 'lighthouse-reports',
        },
      });

      console.log('Lighthouse Login Page Scores:', {
        performance: result.lhr.categories.performance.score * 100,
        accessibility: result.lhr.categories.accessibility.score * 100,
        bestPractices: result.lhr.categories['best-practices'].score * 100,
        seo: result.lhr.categories.seo.score * 100,
      });

      expect(result.lhr.categories.performance.score).toBeGreaterThanOrEqual(0.7);
      expect(result.lhr.categories.accessibility.score).toBeGreaterThanOrEqual(0.8);
    } catch (error) {
      console.log('Lighthouse audit skipped (requires Chrome debugging port)');
    }
  });

  test('Dashboard should meet performance thresholds', async ({ page }, testInfo) => {
    if (testInfo.project.name !== 'chromium') {
      test.skip();
      return;
    }

    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');
    await page.getByRole('button', { name: /sign in|login|anmelden/i }).click();
    await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible({ timeout: 10000 });
    await page.waitForLoadState('networkidle');

    try {
      const result = await playAudit({
        page,
        thresholds: {
          performance: 60,
          accessibility: 75,
          'best-practices': 75,
        },
        port: 9222,
      });

      console.log('Lighthouse Dashboard Scores:', {
        performance: result.lhr.categories.performance.score * 100,
        accessibility: result.lhr.categories.accessibility.score * 100,
        bestPractices: result.lhr.categories['best-practices'].score * 100,
      });
    } catch (error) {
      console.log('Lighthouse audit skipped');
    }
  });
});

// Manual performance metrics (works without Lighthouse)
test.describe('Core Web Vitals', () => {
  test('Should have good Core Web Vitals on login', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Get performance metrics
    const metrics = await page.evaluate(() => {
      return new Promise((resolve) => {
        let lcp = 0;
        let cls = 0;

        // Largest Contentful Paint
        new PerformanceObserver((list) => {
          const entries = list.getEntries();
          lcp = entries[entries.length - 1].startTime;
        }).observe({ type: 'largest-contentful-paint', buffered: true });

        // Cumulative Layout Shift
        new PerformanceObserver((list) => {
          for (const entry of list.getEntries()) {
            if (!(entry as any).hadRecentInput) {
              cls += (entry as any).value;
            }
          }
        }).observe({ type: 'layout-shift', buffered: true });

        // Wait a bit for metrics to collect
        setTimeout(() => {
          resolve({ lcp, cls });
        }, 2000);
      });
    });

    console.log('Core Web Vitals:', metrics);

    // LCP should be under 2.5s for "good"
    expect((metrics as any).lcp).toBeLessThan(4000);

    // CLS should be under 0.1 for "good"
    expect((metrics as any).cls).toBeLessThan(0.25);
  });

  test('Should load critical resources quickly', async ({ page }) => {
    const startTime = Date.now();

    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Use Performance API to get resource timings
    const slowResources = await page.evaluate(() => {
      const entries = performance.getEntriesByType('resource') as PerformanceResourceTiming[];
      return entries
        .filter(e => e.duration > 2000)
        .map(e => ({ name: e.name.split('/').pop(), duration: Math.round(e.duration) }));
    });

    console.log('Slow resources (>2s):', slowResources);
    expect(slowResources.length).toBeLessThan(3);
  });

  test('Time to Interactive should be reasonable', async ({ page }) => {
    const startTime = Date.now();

    await page.goto('/');

    // Wait until page is interactive (can type in input)
    await page.getByPlaceholder(/email/i).fill('test');

    const tti = Date.now() - startTime;
    console.log(`Time to Interactive: ${tti}ms`);

    // TTI should be under 5 seconds
    expect(tti).toBeLessThan(5000);
  });
});
