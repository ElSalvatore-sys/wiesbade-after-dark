import { chromium } from 'playwright';

const PRODUCTION_URL = 'https://owner-pwa.vercel.app';

async function testProduction() {
  console.log('🚀 Testing Production Deployment\n');
  console.log(`URL: ${PRODUCTION_URL}\n`);

  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  // Collect console messages
  const consoleMessages = [];
  page.on('console', msg => {
    consoleMessages.push(`[${msg.type()}] ${msg.text()}`);
  });

  try {
    // Test 1: Page loads
    console.log('📍 Test 1: Page Load');
    await page.goto(PRODUCTION_URL, { waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);

    const title = await page.title();
    console.log(`  ✓ Page loaded: "${title}"`);

    // Test 2: Check for errors
    console.log('\n🔍 Test 2: Console Errors');
    const errors = consoleMessages.filter(msg => msg.includes('[error]'));
    if (errors.length === 0) {
      console.log('  ✓ No console errors');
    } else {
      console.log(`  ⚠️  Found ${errors.length} errors:`);
      errors.slice(0, 3).forEach(err => console.log(`    - ${err}`));
    }

    // Test 3: Login form visible
    console.log('\n📍 Test 3: Login Form');
    const emailInput = await page.locator('input[type="email"]').count();
    const passwordInput = await page.locator('input[type="password"]').count();

    if (emailInput > 0 && passwordInput > 0) {
      console.log('  ✓ Login form present');

      // Try to login
      await page.fill('input[type="email"]', 'owner@example.com');
      await page.fill('input[type="password"]', 'password');

      const loginButton = page.locator('button:has-text("Sign In"), button:has-text("Login"), button:has-text("Anmelden")').first();
      await loginButton.click();

      console.log('  ✓ Login attempted');
      await page.waitForTimeout(3000);
    } else {
      console.log('  ⚠️  Login form not found');
    }

    // Test 4: Dashboard loads
    console.log('\n📍 Test 4: Dashboard');
    const isDashboard = await page.locator('text=/Dashboard|Übersicht/i').count();

    if (isDashboard > 0) {
      console.log('  ✓ Dashboard loaded');

      // Check for stat cards
      const statsCards = await page.locator('.glass-card, [class*="card"]').count();
      console.log(`  ✓ Found ${statsCards} cards/sections`);

      // Check for realtime data
      await page.waitForTimeout(2000);
      console.log('  ✓ Waiting for data to load...');
    } else {
      console.log('  ⚠️  Dashboard not visible (may need valid auth)');
    }

    // Test 5: Check network requests
    console.log('\n🌐 Test 5: Network Activity');
    const requests = [];
    page.on('request', req => {
      if (req.url().includes('/api/')) {
        requests.push(req.url());
      }
    });

    await page.waitForTimeout(2000);

    if (requests.length > 0) {
      console.log(`  ✓ API requests detected (${requests.length} calls)`);
    } else {
      console.log('  ℹ️  No API requests yet');
    }

    // Test 6: Screenshot
    console.log('\n📸 Test 6: Screenshot');
    await page.screenshot({ path: '/tmp/production-screenshot.png', fullPage: false });
    console.log('  ✓ Screenshot saved: /tmp/production-screenshot.png');

    // Final Summary
    console.log('\n' + '='.repeat(50));
    console.log('✅ Production Deployment Test Complete\n');
    console.log('Summary:');
    console.log(`  - URL: ${PRODUCTION_URL}`);
    console.log(`  - Page loads: ✓`);
    console.log(`  - Console errors: ${errors.length}`);
    console.log(`  - Login form: ${emailInput > 0 ? '✓' : '⚠️'}`);
    console.log(`  - Dashboard: ${isDashboard > 0 ? '✓' : '⚠️'}`);
    console.log('\nℹ️  Browser will stay open for manual testing...');
    console.log('   Press Ctrl+C to close when done.\n');

    // Keep browser open
    await new Promise(() => {});

  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
  }
}

testProduction().catch(console.error);
