import { test, expect, login, navigateTo } from './fixtures';

test.describe('Performance', () => {
  test('Login page should load within 3 seconds', async ({ page }) => {
    const startTime = Date.now();
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    const loadTime = Date.now() - startTime;

    expect(loadTime).toBeLessThan(3000);
    console.log(`Login page load time: ${loadTime}ms`);
  });

  test('Dashboard should load within 5 seconds', async ({ page }) => {
    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');

    const startTime = Date.now();
    await page.getByRole('button', { name: /sign in|login|anmelden/i }).click();
    await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible({ timeout: 10000 });
    await page.waitForLoadState('networkidle');
    const loadTime = Date.now() - startTime;

    expect(loadTime).toBeLessThan(5000);
    console.log(`Dashboard load time: ${loadTime}ms`);
  });

  test('Page transitions should be smooth (< 1.5s)', async ({ page }) => {
    await login(page);

    // Test navigation to each page
    const pages = ['shifts', 'tasks', 'inventory', 'analytics', 'employees'];

    for (const pageName of pages) {
      const button = page.getByRole('button', { name: new RegExp(pageName, 'i') });
      if (await button.isVisible()) {
        const startTime = Date.now();
        await button.click();
        await page.waitForLoadState('networkidle');
        const loadTime = Date.now() - startTime;

        expect(loadTime).toBeLessThan(1500);
        console.log(`${pageName} page transition: ${loadTime}ms`);
      }
    }
  });

  test('No memory leaks on repeated navigation', async ({ page }) => {
    await login(page);

    // Get initial memory using Performance API
    const initialMemory = await page.evaluate(() => {
      return (performance as any).memory?.usedJSHeapSize || 0;
    });

    // Navigate back and forth 10 times
    for (let i = 0; i < 10; i++) {
      await navigateTo(page, 'shifts');
      await page.waitForLoadState('networkidle');
      await navigateTo(page, 'dashboard');
      await page.waitForLoadState('networkidle');
    }

    // Get final memory
    const finalMemory = await page.evaluate(() => {
      return (performance as any).memory?.usedJSHeapSize || 0;
    });

    // Memory should not increase by more than 50MB (or skip if API not available)
    if (initialMemory > 0 && finalMemory > 0) {
      const memoryIncrease = (finalMemory - initialMemory) / 1024 / 1024;
      console.log(`Memory increase after 10 navigations: ${memoryIncrease.toFixed(2)}MB`);
      expect(memoryIncrease).toBeLessThan(50);
    } else {
      console.log('Memory API not available, skipping memory leak check');
    }
  });

  test('API responses should be fast (< 2s)', async ({ page }) => {
    const apiRequests: { url: string; startTime: number }[] = [];
    const apiTimes: { url: string; time: number }[] = [];

    page.on('request', request => {
      if (request.url().includes('supabase')) {
        apiRequests.push({
          url: request.url().split('?')[0],
          startTime: Date.now()
        });
      }
    });

    page.on('response', response => {
      if (response.url().includes('supabase')) {
        const request = apiRequests.find(r => response.url().startsWith(r.url.split('?')[0]));
        if (request) {
          apiTimes.push({
            url: response.url().split('?')[0],
            time: Date.now() - request.startTime
          });
        }
      }
    });

    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');
    await page.getByRole('button', { name: /sign in|login|anmelden/i }).click();
    await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible({ timeout: 10000 });
    await page.waitForLoadState('networkidle');

    // Check all API calls were fast
    for (const api of apiTimes) {
      console.log(`API ${api.url}: ${api.time}ms`);
      expect(api.time).toBeLessThan(2000);
    }
  });

  test('Bundle size should be reasonable', async ({ page }) => {
    const resources: { url: string; size: number }[] = [];

    page.on('response', async response => {
      if (response.url().includes('.js') || response.url().includes('.css')) {
        const buffer = await response.body().catch(() => Buffer.from(''));
        resources.push({
          url: response.url().split('/').pop() || '',
          size: buffer.length / 1024
        });
      }
    });

    await page.goto('/');
    await page.waitForLoadState('networkidle');

    const totalJS = resources.filter(r => r.url.includes('.js')).reduce((sum, r) => sum + r.size, 0);
    const totalCSS = resources.filter(r => r.url.includes('.css')).reduce((sum, r) => sum + r.size, 0);

    console.log(`Total JS: ${totalJS.toFixed(2)}KB`);
    console.log(`Total CSS: ${totalCSS.toFixed(2)}KB`);

    // Reasonable limits for a PWA (increased for production bundles)
    expect(totalJS).toBeLessThan(5000); // 5MB JS max
    expect(totalCSS).toBeLessThan(500); // 500KB CSS max
  });
});
