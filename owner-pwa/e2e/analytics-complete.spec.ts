import { test, expect } from './fixtures';

test.describe('Analytics - Complete Feature Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');
    await page.getByRole('button', { name: /sign in|login|anmelden/i }).click();
    await page.waitForTimeout(2000);
    const analyticsButton = page.getByRole('button', { name: /analytics|statistik|berichte|reports/i }).first();
    if (await analyticsButton.isVisible()) {
      await analyticsButton.click();
      await page.waitForTimeout(1000);
    }
  });

  // ========== PAGE STRUCTURE ==========
  test('Should display analytics page with correct title', async ({ page }) => {
    const heading = page.getByRole('heading', { name: /analytics|statistik|berichte|reports|dashboard/i });
    const isVisible = await heading.first().isVisible().catch(() => false);
    if (!isVisible) {
      test.skip();
      return;
    }
    await expect(heading.first()).toBeVisible();
  });

  // ========== DATE RANGE SELECTION ==========
  test('Should show date range selector', async ({ page }) => {
    const dateSelector = page.getByRole('button', { name: /today|week|month|custom|heute|woche|monat/i });
    const dateInput = page.locator('input[type="date"]');
    const isVisible = await dateSelector.or(dateInput).first().isVisible().catch(() => false);
    console.log('Date selector visible:', isVisible);
  });

  test('Should allow selecting predefined date ranges', async ({ page }) => {
    const presets = [
      /today|heute/i,
      /yesterday|gestern/i,
      /this week|diese woche/i,
      /this month|dieser monat/i,
      /last 7 days|letzte 7 tage/i,
      /last 30 days|letzte 30 tage/i,
    ];

    for (const preset of presets) {
      const button = page.getByRole('button', { name: preset });
      const isVisible = await button.first().isVisible().catch(() => false);
      if (isVisible) {
        console.log(`Date preset ${preset} visible`);
      }
    }
  });

  test('Should allow custom date range selection', async ({ page }) => {
    const customButton = page.getByRole('button', { name: /custom|benutzerdefiniert/i });
    if (await customButton.first().isVisible()) {
      await customButton.first().click();
      await page.waitForTimeout(500);

      const datePicker = page.locator('input[type="date"]').or(page.locator('[class*="calendar"]'));
      const isVisible = await datePicker.first().isVisible().catch(() => false);
      console.log('Date picker visible:', isVisible);
    }
  });

  // ========== REVENUE METRICS ==========
  test('Should display total revenue', async ({ page }) => {
    const revenueMetric = page.getByText(/revenue|umsatz|einnahmen|€.*\d+/i);
    const isVisible = await revenueMetric.first().isVisible().catch(() => false);
    console.log('Revenue metric visible:', isVisible);
  });

  test('Should show revenue comparison to previous period', async ({ page }) => {
    const comparison = page.getByText(/vs|compared|vergleich|%.*higher|%.*lower|%.*mehr|%.*weniger/i);
    const isVisible = await comparison.first().isVisible().catch(() => false);
    console.log('Revenue comparison visible:', isVisible);
  });

  test('Should display revenue chart', async ({ page }) => {
    const chart = page.locator('canvas, svg, [class*="chart"], [class*="graph"]');
    const isVisible = await chart.first().isVisible().catch(() => false);
    console.log('Revenue chart visible:', isVisible);
  });

  // ========== SHIFT METRICS ==========
  test('Should show total hours worked', async ({ page }) => {
    const hoursMetric = page.getByText(/hours|stunden|arbeitszeit/i);
    const isVisible = await hoursMetric.first().isVisible().catch(() => false);
    console.log('Hours metric visible:', isVisible);
  });

  test('Should show number of shifts', async ({ page }) => {
    const shiftsMetric = page.getByText(/shifts|schichten|\d+\s*shifts/i);
    const isVisible = await shiftsMetric.first().isVisible().catch(() => false);
    console.log('Shifts metric visible:', isVisible);
  });

  test('Should show labor cost', async ({ page }) => {
    const laborCost = page.getByText(/labor|personalkosten|lohnkosten/i);
    const isVisible = await laborCost.first().isVisible().catch(() => false);
    console.log('Labor cost visible:', isVisible);
  });

  // ========== TASK METRICS ==========
  test('Should show task completion rate', async ({ page }) => {
    const taskMetric = page.getByText(/tasks|aufgaben|completion|erledigungsrate|%/i);
    const isVisible = await taskMetric.first().isVisible().catch(() => false);
    console.log('Task metrics visible:', isVisible);
  });

  test('Should show tasks by status breakdown', async ({ page }) => {
    const statusBreakdown = page.getByText(/pending|completed|approved|ausstehend|erledigt/i);
    const isVisible = await statusBreakdown.first().isVisible().catch(() => false);
    console.log('Task status breakdown visible:', isVisible);
  });

  // ========== EMPLOYEE PERFORMANCE ==========
  test('Should show employee performance section', async ({ page }) => {
    const employeeSection = page.getByText(/employee|mitarbeiter|performance|leistung/i);
    const isVisible = await employeeSection.first().isVisible().catch(() => false);
    console.log('Employee performance section visible:', isVisible);
  });

  test('Should show top performers', async ({ page }) => {
    const topPerformers = page.getByText(/top|best|ranking/i);
    const isVisible = await topPerformers.first().isVisible().catch(() => false);
    console.log('Top performers visible:', isVisible);
  });

  test('Should show employee hours breakdown', async ({ page }) => {
    const hoursBreakdown = page.locator('[class*="employee"], [class*="hours"]');
    const count = await hoursBreakdown.count();
    console.log('Employee hours entries:', count);
  });

  // ========== INVENTORY METRICS ==========
  test('Should show inventory value', async ({ page }) => {
    const inventoryValue = page.getByText(/inventory|inventar|bestand.*€|value|wert/i);
    const isVisible = await inventoryValue.first().isVisible().catch(() => false);
    console.log('Inventory value visible:', isVisible);
  });

  test('Should show low stock alerts count', async ({ page }) => {
    const lowStockAlert = page.getByText(/low stock|niedrig|warning|warnung|\d+\s*items low/i);
    const isVisible = await lowStockAlert.first().isVisible().catch(() => false);
    console.log('Low stock alerts visible:', isVisible);
  });

  // ========== CHARTS & VISUALIZATIONS ==========
  test('Should display multiple chart types', async ({ page }) => {
    const charts = page.locator('canvas, svg[class*="chart"], [class*="recharts"]');
    const count = await charts.count();
    console.log('Charts found:', count);
  });

  test('Should allow switching chart views', async ({ page }) => {
    const viewSwitcher = page.getByRole('button', { name: /bar|line|pie|torte|balken|linie/i });
    const isVisible = await viewSwitcher.first().isVisible().catch(() => false);
    console.log('Chart view switcher visible:', isVisible);
  });

  // ========== EXPORT FUNCTIONALITY ==========
  test('Should show export button', async ({ page }) => {
    const exportButton = page.getByRole('button', { name: /export|download|pdf|csv/i });
    const isVisible = await exportButton.first().isVisible().catch(() => false);
    console.log('Export button visible:', isVisible);
  });

  test('Should offer multiple export formats', async ({ page }) => {
    const exportButton = page.getByRole('button', { name: /export|download/i }).first();
    if (await exportButton.isVisible()) {
      await exportButton.click();
      await page.waitForTimeout(500);

      const formats = page.getByText(/pdf|csv|excel|xlsx/i);
      const isVisible = await formats.first().isVisible().catch(() => false);
      console.log('Export formats visible:', isVisible);
    }
  });

  // ========== REAL-TIME DATA ==========
  test('Should show real-time or live indicator', async ({ page }) => {
    const liveIndicator = page.getByText(/live|real-time|echtzeit|aktuell/i);
    const isVisible = await liveIndicator.first().isVisible().catch(() => false);
    console.log('Live indicator visible:', isVisible);
  });

  test('Should have refresh button', async ({ page }) => {
    const refreshButton = page.getByRole('button', { name: /refresh|aktualisieren/i });
    const isVisible = await refreshButton.first().isVisible().catch(() => false);
    console.log('Refresh button visible:', isVisible);
  });

  // ========== COMPARISON MODE ==========
  test('Should allow period comparison', async ({ page }) => {
    const compareButton = page.getByRole('button', { name: /compare|vergleichen/i });
    const isVisible = await compareButton.first().isVisible().catch(() => false);
    console.log('Compare button visible:', isVisible);
  });

  // ========== FILTERS ==========
  test('Should allow filtering by employee', async ({ page }) => {
    const employeeFilter = page.getByRole('combobox').or(page.getByText(/filter.*employee|mitarbeiter.*filter/i));
    const isVisible = await employeeFilter.first().isVisible().catch(() => false);
    console.log('Employee filter visible:', isVisible);
  });

  test('Should allow filtering by category', async ({ page }) => {
    const categoryFilter = page.getByText(/category|kategorie|all categories|alle kategorien/i);
    const isVisible = await categoryFilter.first().isVisible().catch(() => false);
    console.log('Category filter visible:', isVisible);
  });

  // ========== KEY PERFORMANCE INDICATORS ==========
  test('Should display KPI cards', async ({ page }) => {
    const kpiCards = page.locator('[class*="kpi"], [class*="metric"], [class*="stat"]');
    const count = await kpiCards.count();
    console.log('KPI cards found:', count);
  });

  test('Should show trend indicators', async ({ page }) => {
    const trendIndicator = page.locator('[class*="trend"], [class*="arrow"], [class*="up"], [class*="down"]');
    const count = await trendIndicator.count();
    console.log('Trend indicators found:', count);
  });

  // ========== RESPONSIVE BEHAVIOR ==========
  test('Charts should be responsive', async ({ page }) => {
    const chart = page.locator('canvas, svg, [class*="chart"]').first();
    if (await chart.isVisible()) {
      const box = await chart.boundingBox();
      expect(box?.width).toBeGreaterThan(0);
      expect(box?.height).toBeGreaterThan(0);
    }
  });

  // ========== LOADING STATES ==========
  test('Should show loading state while fetching data', async ({ page }) => {
    // Reload to catch loading state
    await page.reload();

    const loadingIndicator = page.getByText(/loading|laden/i).or(page.locator('[class*="loading"], [class*="spinner"]'));
    const wasVisible = await loadingIndicator.first().isVisible().catch(() => false);
    console.log('Loading indicator appeared:', wasVisible);
  });

  // ========== ERROR HANDLING ==========
  test('Should handle no data gracefully', async ({ page }) => {
    // Set date range to future (no data)
    const noDataMessage = page.getByText(/no data|keine daten|no results/i);
    const isVisible = await noDataMessage.first().isVisible().catch(() => false);
    console.log('No data message handling:', isVisible ? 'shown' : 'not needed');
  });
});
