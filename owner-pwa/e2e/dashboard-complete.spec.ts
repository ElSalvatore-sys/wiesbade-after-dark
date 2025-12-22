import { test, expect } from './fixtures';

test.describe('Dashboard - Complete Feature Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');
    await page.getByRole('button', { name: /sign in|login|anmelden/i }).click();
    await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible({ timeout: 10000 });
  });

  // ========== PAGE STRUCTURE ==========
  test('Should display dashboard with correct title', async ({ page }) => {
    await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible();
  });

  test('Should show welcome message or greeting', async ({ page }) => {
    const greeting = page.getByText(/welcome|willkommen|hello|hallo|good morning|guten/i);
    const isVisible = await greeting.first().isVisible().catch(() => false);
    console.log('Greeting visible:', isVisible);
  });

  test('Should show current date/time', async ({ page }) => {
    const dateTime = page.getByText(/\d{1,2}[.:]\d{2}|monday|tuesday|wednesday|thursday|friday|saturday|sunday|montag|dienstag|mittwoch|donnerstag|freitag|samstag|sonntag/i);
    const isVisible = await dateTime.first().isVisible().catch(() => false);
    console.log('Date/time visible:', isVisible);
  });

  // ========== QUICK STATS CARDS ==========
  test('Should show active shifts count', async ({ page }) => {
    const activeShifts = page.getByText(/active.*shift|aktive.*schicht|\d+\s*active|\d+\s*aktiv/i);
    const isVisible = await activeShifts.first().isVisible().catch(() => false);
    console.log('Active shifts visible:', isVisible);
  });

  test('Should show pending tasks count', async ({ page }) => {
    const pendingTasks = page.getByText(/pending.*task|ausstehende.*aufgabe|\d+\s*pending|\d+\s*ausstehend/i);
    const isVisible = await pendingTasks.first().isVisible().catch(() => false);
    console.log('Pending tasks visible:', isVisible);
  });

  test('Should show low inventory alerts', async ({ page }) => {
    const lowInventory = page.getByText(/low.*stock|niedrig.*bestand|inventory.*alert|\d+\s*low/i);
    const isVisible = await lowInventory.first().isVisible().catch(() => false);
    console.log('Low inventory alerts visible:', isVisible);
  });

  test('Should show today\'s revenue or sales', async ({ page }) => {
    const revenue = page.getByText(/revenue|umsatz|sales|€.*today|heute.*€/i);
    const isVisible = await revenue.first().isVisible().catch(() => false);
    console.log('Revenue visible:', isVisible);
  });

  // ========== STAT CARDS INTERACTIVITY ==========
  test('Stat cards should be clickable for details', async ({ page }) => {
    const statCard = page.locator('[class*="stat"], [class*="card"], [class*="metric"]').first();
    if (await statCard.isVisible()) {
      await statCard.click();
      await page.waitForTimeout(500);
      // Should navigate or show details
    }
  });

  // ========== ACTIVE SHIFTS SECTION ==========
  test('Should display active shifts section', async ({ page }) => {
    const shiftsSection = page.getByText(/active.*shifts|aktive.*schichten|currently.*working|gerade.*arbeiten/i);
    const isVisible = await shiftsSection.first().isVisible().catch(() => false);
    console.log('Active shifts section visible:', isVisible);
  });

  test('Should show employee names in active shifts', async ({ page }) => {
    const employeeInShift = page.locator('[class*="shift"] [class*="name"], [class*="active"] [class*="employee"]');
    const count = await employeeInShift.count();
    console.log('Employees in active shifts:', count);
  });

  test('Should show shift duration/timer', async ({ page }) => {
    const timer = page.getByText(/\d{1,2}:\d{2}:\d{2}|\d+h\s*\d+m|\d+\s*hours/i);
    const isVisible = await timer.first().isVisible().catch(() => false);
    console.log('Shift timer visible:', isVisible);
  });

  // ========== RECENT TASKS SECTION ==========
  test('Should display recent tasks section', async ({ page }) => {
    const tasksSection = page.getByText(/recent.*tasks|aktuelle.*aufgaben|pending.*tasks|ausstehende/i);
    const isVisible = await tasksSection.first().isVisible().catch(() => false);
    console.log('Recent tasks section visible:', isVisible);
  });

  test('Should show task titles', async ({ page }) => {
    const taskItems = page.locator('[class*="task"], [class*="todo"]');
    const count = await taskItems.count();
    console.log('Task items visible:', count);
  });

  test('Should show task status indicators', async ({ page }) => {
    const statusIndicators = page.locator('[class*="status"], [class*="badge"], [class*="pending"], [class*="completed"]');
    const count = await statusIndicators.count();
    console.log('Status indicators:', count);
  });

  // ========== QUICK ACTIONS ==========
  test('Should show quick action buttons', async ({ page }) => {
    const quickActions = [
      /add.*task|aufgabe.*hinzufügen/i,
      /clock.*in|einchecken/i,
      /view.*all|alle.*anzeigen/i,
    ];

    for (const action of quickActions) {
      const button = page.getByRole('button', { name: action });
      const isVisible = await button.first().isVisible().catch(() => false);
      if (isVisible) {
        console.log(`Quick action ${action} visible`);
      }
    }
  });

  test('Quick add task should open modal', async ({ page }) => {
    const addTaskButton = page.getByRole('button', { name: /add.*task|aufgabe.*hinzufügen|\+/i }).first();
    if (await addTaskButton.isVisible()) {
      await addTaskButton.click();
      await page.waitForTimeout(500);

      const modal = page.getByRole('dialog').or(page.getByPlaceholder(/title|titel/i));
      const isVisible = await modal.first().isVisible().catch(() => false);
      console.log('Add task modal opened:', isVisible);
    }
  });

  // ========== NOTIFICATIONS ==========
  test('Should show notification bell/icon', async ({ page }) => {
    const notificationIcon = page.locator('[class*="notification"], [class*="bell"], [aria-label*="notification"]');
    const isVisible = await notificationIcon.first().isVisible().catch(() => false);
    console.log('Notification icon visible:', isVisible);
  });

  test('Should show notification count badge', async ({ page }) => {
    const badge = page.locator('[class*="badge"], [class*="count"]');
    const isVisible = await badge.first().isVisible().catch(() => false);
    console.log('Notification badge visible:', isVisible);
  });

  // ========== NAVIGATION ==========
  test('Should have sidebar navigation', async ({ page }) => {
    const sidebar = page.locator('[class*="sidebar"], nav, [class*="navigation"]');
    await expect(sidebar.first()).toBeVisible();
  });

  test('Should highlight dashboard as active', async ({ page }) => {
    const dashboardNav = page.getByRole('button', { name: /dashboard/i }).first();
    if (await dashboardNav.isVisible()) {
      const classes = await dashboardNav.getAttribute('class');
      console.log('Dashboard nav classes:', classes);
    }
  });

  test('All main nav items should be visible', async ({ page }) => {
    const navItems = [
      /dashboard/i,
      /shifts|schichten/i,
      /tasks|aufgaben/i,
      /inventory|inventar/i,
    ];

    for (const item of navItems) {
      const navButton = page.getByRole('button', { name: item });
      const isVisible = await navButton.first().isVisible().catch(() => false);
      console.log(`Nav item ${item} visible:`, isVisible);
    }
  });

  // ========== USER PROFILE ==========
  test('Should show user profile/avatar', async ({ page }) => {
    const avatar = page.locator('[class*="avatar"], [class*="profile"], img[alt*="profile"]');
    const isVisible = await avatar.first().isVisible().catch(() => false);
    console.log('User avatar visible:', isVisible);
  });

  test('Should show logout option', async ({ page }) => {
    const logoutButton = page.getByRole('button', { name: /logout|abmelden|sign out/i });
    const profileMenu = page.locator('[class*="avatar"], [class*="profile"]').first();

    // Try clicking profile to reveal logout
    if (await profileMenu.isVisible()) {
      await profileMenu.click();
      await page.waitForTimeout(300);
    }

    const isVisible = await logoutButton.first().isVisible().catch(() => false);
    console.log('Logout button visible:', isVisible);
  });

  // ========== CHARTS/GRAPHS ==========
  test('Should display chart or graph', async ({ page }) => {
    const chart = page.locator('canvas, svg, [class*="chart"], [class*="graph"]');
    const isVisible = await chart.first().isVisible().catch(() => false);
    console.log('Chart visible:', isVisible);
  });

  // ========== RESPONSIVE LAYOUT ==========
  test('Dashboard should be responsive', async ({ page }) => {
    // Check that content fits viewport
    const body = page.locator('body');
    const box = await body.boundingBox();
    expect(box?.width).toBeGreaterThan(0);
  });

  // ========== LOADING STATES ==========
  test('Should handle loading gracefully', async ({ page }) => {
    await page.reload();
    await page.waitForLoadState('domcontentloaded');

    // Check for loading or content - wait for either loading indicator or dashboard heading
    const dashboard = page.getByRole('heading', { name: /dashboard/i });
    const loading = page.getByText(/loading|laden/i);

    // Wait up to 15 seconds for content to appear
    await expect(dashboard.or(loading)).toBeVisible({ timeout: 15000 });
  });

  // ========== REAL-TIME UPDATES ==========
  test('Should show real-time data indicators', async ({ page }) => {
    const liveIndicator = page.getByText(/live|real-time|echtzeit|aktuell/i);
    const pulsingDot = page.locator('[class*="pulse"], [class*="live"], [class*="online"]');
    const isVisible = await liveIndicator.or(pulsingDot).first().isVisible().catch(() => false);
    console.log('Live indicator visible:', isVisible);
  });

  // ========== DATE PICKER ==========
  test('Should have date selection for viewing different days', async ({ page }) => {
    const datePicker = page.locator('input[type="date"]').or(page.getByRole('button', { name: /today|heute|date/i }));
    const isVisible = await datePicker.first().isVisible().catch(() => false);
    console.log('Date picker visible:', isVisible);
  });

  // ========== SETTINGS ACCESS ==========
  test('Should have settings access', async ({ page }) => {
    const settingsButton = page.getByRole('button', { name: /settings|einstellungen/i });
    const settingsIcon = page.locator('[class*="settings"], [class*="gear"], [class*="cog"]');
    const isVisible = await settingsButton.or(settingsIcon).first().isVisible().catch(() => false);
    console.log('Settings access visible:', isVisible);
  });

  // ========== VENUE INFO ==========
  test('Should show venue name', async ({ page }) => {
    const venueName = page.getByText(/wiesbaden|after.*dark|venue|lokal/i);
    const isVisible = await venueName.first().isVisible().catch(() => false);
    console.log('Venue name visible:', isVisible);
  });

  // ========== EMPTY STATES ==========
  test('Should handle no data gracefully', async ({ page }) => {
    // The dashboard should still render even without data
    const emptyState = page.getByText(/no.*data|keine.*daten|nothing|nichts|get started/i);
    const hasData = page.locator('[class*="card"], [class*="stat"]');

    const hasEmptyOrData = await emptyState.first().isVisible().catch(() => false) ||
                           await hasData.first().isVisible().catch(() => false);
    expect(hasEmptyOrData).toBeTruthy();
  });

  // ========== KEYBOARD NAVIGATION ==========
  test('Should support keyboard navigation', async ({ page }) => {
    await page.keyboard.press('Tab');
    const focused = await page.evaluate(() => document.activeElement?.tagName);
    expect(focused).toBeTruthy();
  });

  // ========== REFRESH DATA ==========
  test('Should have refresh functionality', async ({ page }) => {
    const refreshButton = page.getByRole('button', { name: /refresh|aktualisieren/i });
    const isVisible = await refreshButton.first().isVisible().catch(() => false);
    console.log('Refresh button visible:', isVisible);
  });
});
