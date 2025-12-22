import { test, expect, login } from './fixtures';

test.describe('SEO & Meta Tags', () => {
  test('Should have proper page title', async ({ page }) => {
    await page.goto('/');

    const title = await page.title();
    expect(title).toBeTruthy();
    expect(title.length).toBeGreaterThan(10);
    expect(title.length).toBeLessThan(70); // Google truncates at ~60 chars

    console.log(`Page title: "${title}" (${title.length} chars)`);
  });

  test('Should have meta description', async ({ page }) => {
    await page.goto('/');

    const description = await page.getAttribute('meta[name="description"]', 'content');

    if (description) {
      expect(description.length).toBeGreaterThan(50);
      expect(description.length).toBeLessThan(160);
      console.log(`Meta description: "${description}" (${description.length} chars)`);
    } else {
      console.log('Warning: No meta description found');
    }
  });

  test('Should have viewport meta tag', async ({ page }) => {
    await page.goto('/');

    const viewport = await page.getAttribute('meta[name="viewport"]', 'content');
    expect(viewport).toBeTruthy();
    expect(viewport).toContain('width=device-width');

    console.log(`Viewport: ${viewport}`);
  });

  test('Should have charset meta tag', async ({ page }) => {
    await page.goto('/');

    const charset = await page.$('meta[charset]');
    const charsetContent = await page.getAttribute('meta[charset]', 'charset');

    expect(charset || charsetContent).toBeTruthy();
  });

  test('Should have Open Graph tags for social sharing', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');

    // Use $eval with fallback for optional meta tags
    const ogTitle = await page.$eval('meta[property="og:title"]', el => el.getAttribute('content')).catch(() => null);
    const ogDescription = await page.$eval('meta[property="og:description"]', el => el.getAttribute('content')).catch(() => null);
    const ogImage = await page.$eval('meta[property="og:image"]', el => el.getAttribute('content')).catch(() => null);
    const ogType = await page.$eval('meta[property="og:type"]', el => el.getAttribute('content')).catch(() => null);

    console.log('Open Graph tags:', { ogTitle, ogDescription, ogImage, ogType });

    // These are optional but recommended - just log their presence
    if (ogTitle) expect(ogTitle.length).toBeGreaterThan(0);
  });

  test('Should have Twitter Card tags', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');

    // Use $eval with fallback for optional meta tags
    const twitterCard = await page.$eval('meta[name="twitter:card"]', el => el.getAttribute('content')).catch(() => null);
    const twitterTitle = await page.$eval('meta[name="twitter:title"]', el => el.getAttribute('content')).catch(() => null);

    console.log('Twitter Card tags:', { twitterCard, twitterTitle });
  });

  test('Should have favicon', async ({ page }) => {
    await page.goto('/');

    const favicon = await page.$('link[rel="icon"], link[rel="shortcut icon"]');
    const appleTouchIcon = await page.$('link[rel="apple-touch-icon"]');

    expect(favicon || appleTouchIcon).toBeTruthy();
  });

  test('Should have canonical URL', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');

    // Use $eval with fallback for optional canonical link
    const canonical = await page.$eval('link[rel="canonical"]', el => el.getAttribute('href')).catch(() => null);

    if (canonical) {
      expect(canonical).toContain('http');
      console.log(`Canonical URL: ${canonical}`);
    } else {
      console.log('No canonical URL found (optional)');
    }
  });

  test('Should have proper heading hierarchy', async ({ page }) => {
    await login(page);

    // Check for h1
    const h1Count = await page.locator('h1').count();
    expect(h1Count).toBeGreaterThanOrEqual(1);
    expect(h1Count).toBeLessThanOrEqual(2); // Usually only 1 h1 per page

    // Check heading order
    const headings = await page.evaluate(() => {
      const heads = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
      return Array.from(heads).map(h => ({
        level: parseInt(h.tagName[1]),
        text: h.textContent?.trim().substring(0, 50),
      }));
    });

    console.log('Heading structure:', headings.slice(0, 10));

    // Check for heading jumps (e.g., h1 -> h3 without h2)
    let lastLevel = 0;
    for (const heading of headings) {
      if (heading.level > lastLevel + 1 && lastLevel > 0) {
        console.warn(`Heading jump: h${lastLevel} -> h${heading.level}`);
      }
      lastLevel = heading.level;
    }
  });

  test('Should have alt text on important images', async ({ page }) => {
    await login(page);

    const images = await page.locator('img').all();
    let missingAlt = 0;

    for (const img of images) {
      const alt = await img.getAttribute('alt');
      const role = await img.getAttribute('role');
      const ariaHidden = await img.getAttribute('aria-hidden');

      // Decorative images should have empty alt or role="presentation"
      if (!alt && role !== 'presentation' && ariaHidden !== 'true') {
        const src = await img.getAttribute('src');
        console.warn(`Missing alt text: ${src?.substring(0, 50)}`);
        missingAlt++;
      }
    }

    // Allow some decorative images without alt
    expect(missingAlt).toBeLessThan(5);
  });

  test('Should have proper link text', async ({ page }) => {
    await login(page);

    const links = await page.locator('a').all();
    let badLinks = 0;

    for (const link of links.slice(0, 20)) {
      const text = await link.textContent();
      const ariaLabel = await link.getAttribute('aria-label');
      const title = await link.getAttribute('title');

      const accessibleName = text?.trim() || ariaLabel || title;

      // Check for generic link text
      if (accessibleName && /^(click here|here|more|link)$/i.test(accessibleName)) {
        console.warn(`Generic link text: "${accessibleName}"`);
        badLinks++;
      }
    }

    expect(badLinks).toBeLessThan(3);
  });

  test('Should have lang attribute on html', async ({ page }) => {
    await page.goto('/');

    const lang = await page.getAttribute('html', 'lang');
    expect(lang).toBeTruthy();
    expect(lang).toMatch(/^[a-z]{2}(-[A-Z]{2})?$/); // e.g., "en", "de", "en-US"

    console.log(`Language: ${lang}`);
  });

  test('Should be mobile-friendly', async ({ page }) => {
    // Test at mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');

    // Check no horizontal scroll
    const hasHorizontalScroll = await page.evaluate(() => {
      return document.documentElement.scrollWidth > document.documentElement.clientWidth;
    });

    expect(hasHorizontalScroll).toBeFalsy();

    // Check text is readable (font size >= 12px)
    const smallText = await page.evaluate(() => {
      const elements = document.querySelectorAll('p, span, a, li');
      let tooSmall = 0;

      elements.forEach(el => {
        const fontSize = parseFloat(window.getComputedStyle(el).fontSize);
        if (fontSize < 12) tooSmall++;
      });

      return tooSmall;
    });

    console.log(`Elements with small text: ${smallText}`);
    expect(smallText).toBeLessThan(10);
  });

  test('Should have manifest for PWA', async ({ page }) => {
    await page.goto('/');

    const manifest = await page.$('link[rel="manifest"]');
    expect(manifest).toBeTruthy();

    // Check manifest is accessible
    const manifestHref = await page.getAttribute('link[rel="manifest"]', 'href');
    if (manifestHref) {
      const response = await page.request.get(manifestHref);
      expect(response.ok()).toBeTruthy();

      const manifestData = await response.json();
      console.log('Manifest:', {
        name: manifestData.name,
        short_name: manifestData.short_name,
        theme_color: manifestData.theme_color,
      });

      expect(manifestData.name).toBeTruthy();
    }
  });
});
