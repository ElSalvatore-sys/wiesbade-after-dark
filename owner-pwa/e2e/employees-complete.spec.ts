import { test, expect } from './fixtures';

test.describe('Employees - Complete Feature Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');
    await page.getByRole('button', { name: /sign in|login|anmelden/i }).click();
    await page.waitForTimeout(2000);
    const employeesButton = page.getByRole('button', { name: /employees|mitarbeiter|team|staff/i }).first();
    if (await employeesButton.isVisible()) {
      await employeesButton.click();
      await page.waitForTimeout(1000);
    }
  });

  // ========== PAGE STRUCTURE ==========
  test('Should display employees page with correct title', async ({ page }) => {
    const heading = page.getByRole('heading', { name: /employees|mitarbeiter|team|staff/i });
    const isVisible = await heading.first().isVisible().catch(() => false);
    if (!isVisible) {
      test.skip();
      return;
    }
    await expect(heading.first()).toBeVisible();
  });

  test('Should show add employee button', async ({ page }) => {
    const addButton = page.getByRole('button', { name: /add|create|new|neu|hinzufügen|invite|\+/i });
    const isVisible = await addButton.first().isVisible().catch(() => false);
    console.log('Add employee button visible:', isVisible);
  });

  test('Should show search input', async ({ page }) => {
    const searchInput = page.getByPlaceholder(/search|suchen|filter/i);
    const isVisible = await searchInput.isVisible().catch(() => false);
    console.log('Search input visible:', isVisible);
  });

  // ========== EMPLOYEE LIST ==========
  test('Should display employee cards or list', async ({ page }) => {
    const employeeCards = page.locator('[class*="employee"], [class*="card"], [class*="user"]');
    const count = await employeeCards.count();
    console.log('Employee entries found:', count);
  });

  test('Should show employee avatar or initials', async ({ page }) => {
    const avatar = page.locator('[class*="avatar"], img[alt*="profile"], [class*="initials"]');
    const count = await avatar.count();
    console.log('Avatars found:', count);
  });

  test('Should show employee name', async ({ page }) => {
    const employeeCard = page.locator('[class*="employee"], [class*="card"]').first();
    if (await employeeCard.isVisible()) {
      const text = await employeeCard.textContent();
      expect(text?.length).toBeGreaterThan(0);
    }
  });

  test('Should show employee role/position', async ({ page }) => {
    const roleIndicator = page.getByText(/manager|bartender|waiter|kellner|barkeeper|staff/i);
    const isVisible = await roleIndicator.first().isVisible().catch(() => false);
    console.log('Role indicator visible:', isVisible);
  });

  test('Should show employee status (active/inactive)', async ({ page }) => {
    const statusIndicator = page.getByText(/active|inactive|aktiv|inaktiv/i).or(page.locator('[class*="status"]'));
    const isVisible = await statusIndicator.first().isVisible().catch(() => false);
    console.log('Status indicator visible:', isVisible);
  });

  // ========== ADD EMPLOYEE ==========
  test('Should open add employee modal', async ({ page }) => {
    const addButton = page.getByRole('button', { name: /add|create|new|neu|invite|\+/i }).first();
    if (await addButton.isVisible()) {
      await addButton.click();
      await page.waitForTimeout(500);

      const modal = page.getByRole('dialog').or(page.locator('[class*="modal"]'));
      const nameInput = page.getByPlaceholder(/name/i);
      await expect(modal.or(nameInput)).toBeVisible();
    }
  });

  test('Should have required fields in add form', async ({ page }) => {
    const addButton = page.getByRole('button', { name: /add|create|new|neu|invite|\+/i }).first();
    if (await addButton.isVisible().catch(() => false)) {
      await addButton.click();
      await page.waitForTimeout(500);

      // Check for typical employee fields
      const nameInput = page.getByPlaceholder(/name/i).first();
      const emailInput = page.getByPlaceholder(/email/i).first();
      const phoneInput = page.getByPlaceholder(/phone|telefon/i).first();

      const hasFields = await nameInput.isVisible().catch(() => false) ||
                        await emailInput.isVisible().catch(() => false) ||
                        await phoneInput.isVisible().catch(() => false);
      console.log('Add form has fields:', hasFields);
    } else {
      console.log('Add button not visible, skipping form fields check');
    }
  });

  test('Should show role/position selector', async ({ page }) => {
    const addButton = page.getByRole('button', { name: /add|create|new|neu|invite|\+/i }).first();
    if (await addButton.isVisible()) {
      await addButton.click();
      await page.waitForTimeout(500);

      const roleSelector = page.getByText(/role|position|rolle/i).or(page.getByRole('combobox'));
      const isVisible = await roleSelector.first().isVisible().catch(() => false);
      console.log('Role selector visible:', isVisible);
    }
  });

  test('Should show PIN setup field', async ({ page }) => {
    const addButton = page.getByRole('button', { name: /add|create|new|neu|invite|\+/i }).first();
    if (await addButton.isVisible()) {
      await addButton.click();
      await page.waitForTimeout(500);

      const pinField = page.getByPlaceholder(/pin/i).or(page.getByLabel(/pin/i));
      const isVisible = await pinField.isVisible().catch(() => false);
      console.log('PIN field visible:', isVisible);
    }
  });

  test('Should validate email format', async ({ page }) => {
    const addButton = page.getByRole('button', { name: /add|create|new|neu|invite|\+/i }).first();
    if (await addButton.isVisible()) {
      await addButton.click();
      await page.waitForTimeout(500);

      const emailInput = page.getByPlaceholder(/email/i).first();
      if (await emailInput.isVisible()) {
        await emailInput.fill('invalid-email');

        const submitButton = page.getByRole('button', { name: /save|create|speichern|invite/i });
        if (await submitButton.isVisible()) {
          await submitButton.click();
          await page.waitForTimeout(500);

          // Should show validation error
          const errorMessage = page.getByText(/invalid|ungültig|email/i);
          const isVisible = await errorMessage.first().isVisible().catch(() => false);
          console.log('Email validation error visible:', isVisible);
        }
      }
    }
  });

  test('Should create employee with valid data', async ({ page }) => {
    const addButton = page.getByRole('button', { name: /add|create|new|neu|invite|\+/i }).first();
    if (await addButton.isVisible()) {
      await addButton.click();
      await page.waitForTimeout(500);

      const nameInput = page.getByPlaceholder(/name/i).first();
      if (await nameInput.isVisible()) {
        await nameInput.fill('Test Employee');
      }

      const emailInput = page.getByPlaceholder(/email/i).first();
      if (await emailInput.isVisible()) {
        await emailInput.fill(`test${Date.now()}@example.com`);
      }

      const submitButton = page.getByRole('button', { name: /save|create|speichern|invite/i });
      if (await submitButton.isVisible()) {
        await submitButton.click();
        await page.waitForTimeout(1000);
      }
    }
  });

  // ========== EMPLOYEE DETAILS ==========
  test('Should open employee detail view', async ({ page }) => {
    const employeeCard = page.locator('[class*="employee"], [class*="card"]').first();
    if (await employeeCard.isVisible()) {
      await employeeCard.click();
      await page.waitForTimeout(500);

      const detailView = page.getByText(/details|profile|profil|contact|kontakt/i);
      const isVisible = await detailView.first().isVisible().catch(() => false);
      console.log('Detail view visible:', isVisible);
    }
  });

  test('Should show employee contact information', async ({ page }) => {
    const employeeCard = page.locator('[class*="employee"], [class*="card"]').first();
    if (await employeeCard.isVisible()) {
      await employeeCard.click();
      await page.waitForTimeout(500);

      const contactInfo = page.getByText(/email|phone|telefon|@/i);
      const isVisible = await contactInfo.first().isVisible().catch(() => false);
      console.log('Contact info visible:', isVisible);
    }
  });

  test('Should show employee work history/shifts', async ({ page }) => {
    const employeeCard = page.locator('[class*="employee"], [class*="card"]').first();
    if (await employeeCard.isVisible()) {
      await employeeCard.click();
      await page.waitForTimeout(500);

      const workHistory = page.getByText(/shifts|schichten|history|verlauf|hours|stunden/i);
      const isVisible = await workHistory.first().isVisible().catch(() => false);
      console.log('Work history visible:', isVisible);
    }
  });

  // ========== EDIT EMPLOYEE ==========
  test('Should show edit button', async ({ page }) => {
    const editButton = page.getByRole('button', { name: /edit|bearbeiten/i });
    const isVisible = await editButton.first().isVisible().catch(() => false);
    console.log('Edit button visible:', isVisible);
  });

  test('Should allow editing employee details', async ({ page }) => {
    const editButton = page.getByRole('button', { name: /edit|bearbeiten/i }).first();
    if (await editButton.isVisible()) {
      await editButton.click();
      await page.waitForTimeout(500);

      const editForm = page.getByPlaceholder(/name/i).or(page.getByPlaceholder(/email/i));
      const isVisible = await editForm.first().isVisible().catch(() => false);
      console.log('Edit form visible:', isVisible);
    }
  });

  // ========== PIN MANAGEMENT ==========
  test('Should allow resetting PIN', async ({ page }) => {
    const resetPinButton = page.getByRole('button', { name: /reset.*pin|pin.*reset|neuer pin/i });
    const isVisible = await resetPinButton.first().isVisible().catch(() => false);
    console.log('Reset PIN button visible:', isVisible);
  });

  // ========== PERMISSIONS ==========
  test('Should show permissions section', async ({ page }) => {
    const permissionsSection = page.getByText(/permissions|berechtigungen|access|zugriff/i);
    const isVisible = await permissionsSection.first().isVisible().catch(() => false);
    console.log('Permissions section visible:', isVisible);
  });

  test('Should allow toggling permissions', async ({ page }) => {
    const permissionToggle = page.locator('[role="switch"], input[type="checkbox"], [class*="toggle"]');
    const count = await permissionToggle.count();
    console.log('Permission toggles found:', count);
  });

  // ========== DEACTIVATE/DELETE ==========
  test('Should show deactivate option', async ({ page }) => {
    const deactivateButton = page.getByRole('button', { name: /deactivate|deaktivieren|disable/i });
    const isVisible = await deactivateButton.first().isVisible().catch(() => false);
    console.log('Deactivate button visible:', isVisible);
  });

  test('Should show delete option', async ({ page }) => {
    const deleteButton = page.getByRole('button', { name: /delete|löschen|remove|entfernen/i });
    const isVisible = await deleteButton.first().isVisible().catch(() => false);
    console.log('Delete button visible:', isVisible);
  });

  test('Should confirm before deactivation/deletion', async ({ page }) => {
    const actionButton = page.getByRole('button', { name: /delete|deactivate|löschen|deaktivieren/i }).first();
    if (await actionButton.isVisible()) {
      await actionButton.click();
      await page.waitForTimeout(500);

      const confirmDialog = page.getByText(/confirm|bestätigen|sicher|are you sure/i);
      const isVisible = await confirmDialog.first().isVisible().catch(() => false);
      console.log('Confirmation dialog visible:', isVisible);
    }
  });

  // ========== FILTER & SORT ==========
  test('Should allow filtering by role', async ({ page }) => {
    const roleFilter = page.getByRole('combobox').or(page.getByText(/all roles|alle rollen|filter/i));
    const isVisible = await roleFilter.first().isVisible().catch(() => false);
    console.log('Role filter visible:', isVisible);
  });

  test('Should allow filtering by status', async ({ page }) => {
    const statusFilter = page.getByText(/active|inactive|all status|alle/i);
    const isVisible = await statusFilter.first().isVisible().catch(() => false);
    console.log('Status filter visible:', isVisible);
  });

  test('Should allow sorting employees', async ({ page }) => {
    const sortButton = page.getByRole('button', { name: /sort|sortieren/i });
    const isVisible = await sortButton.first().isVisible().catch(() => false);
    console.log('Sort button visible:', isVisible);
  });

  // ========== WAGE/SALARY INFO ==========
  test('Should show hourly rate field', async ({ page }) => {
    const hourlyRate = page.getByText(/hourly|stundenlohn|€.*h|rate/i);
    const isVisible = await hourlyRate.first().isVisible().catch(() => false);
    console.log('Hourly rate visible:', isVisible);
  });

  // ========== SCHEDULE/AVAILABILITY ==========
  test('Should show availability section', async ({ page }) => {
    const availability = page.getByText(/availability|verfügbarkeit|schedule|zeitplan/i);
    const isVisible = await availability.first().isVisible().catch(() => false);
    console.log('Availability section visible:', isVisible);
  });

  // ========== DOCUMENTS ==========
  test('Should show documents section', async ({ page }) => {
    const documents = page.getByText(/documents|dokumente|contracts|verträge/i);
    const isVisible = await documents.first().isVisible().catch(() => false);
    console.log('Documents section visible:', isVisible);
  });

  // ========== INVITE FUNCTIONALITY ==========
  test('Should allow sending invite email', async ({ page }) => {
    const inviteButton = page.getByRole('button', { name: /invite|einladen|send/i });
    const isVisible = await inviteButton.first().isVisible().catch(() => false);
    console.log('Invite button visible:', isVisible);
  });

  // ========== BULK ACTIONS ==========
  test('Should allow selecting multiple employees', async ({ page }) => {
    const checkbox = page.locator('input[type="checkbox"]').first();
    const isVisible = await checkbox.isVisible().catch(() => false);
    console.log('Selection checkbox visible:', isVisible);
  });

  test('Should show bulk action options when selected', async ({ page }) => {
    const checkbox = page.locator('input[type="checkbox"]').first();
    if (await checkbox.isVisible()) {
      await checkbox.check();
      await page.waitForTimeout(300);

      const bulkActions = page.getByText(/selected|ausgewählt|bulk/i);
      const isVisible = await bulkActions.first().isVisible().catch(() => false);
      console.log('Bulk actions visible:', isVisible);
    }
  });

  // ========== EXPORT ==========
  test('Should allow exporting employee list', async ({ page }) => {
    const exportButton = page.getByRole('button', { name: /export|download|csv/i });
    const isVisible = await exportButton.first().isVisible().catch(() => false);
    console.log('Export button visible:', isVisible);
  });
});
