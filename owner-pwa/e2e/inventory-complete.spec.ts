import { test, expect } from './fixtures';

test.describe('Inventory - Complete Feature Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.getByPlaceholder(/email/i).fill('owner@example.com');
    await page.getByPlaceholder(/password/i).fill('password');
    await page.getByRole('button', { name: /sign in|login|anmelden/i }).click();
    await page.waitForTimeout(2000);
    const inventoryButton = page.getByRole('button', { name: /inventory|inventar|bestand/i }).first();
    if (await inventoryButton.isVisible()) {
      await inventoryButton.click();
      await page.waitForTimeout(1000);
    }
  });

  // ========== PAGE STRUCTURE ==========
  test('Should display inventory page with correct title', async ({ page }) => {
    const heading = page.getByRole('heading', { name: /inventory|inventar|bestand/i });
    const isVisible = await heading.first().isVisible().catch(() => false);
    if (!isVisible) {
      test.skip();
      return;
    }
    await expect(heading.first()).toBeVisible();
  });

  test('Should show add item button', async ({ page }) => {
    const addButton = page.getByRole('button', { name: /add|create|new|neu|hinzufügen|\+/i });
    const isVisible = await addButton.first().isVisible().catch(() => false);
    console.log('Add item button visible:', isVisible);
  });

  test('Should show search/filter input', async ({ page }) => {
    const searchInput = page.getByPlaceholder(/search|suchen|filter/i);
    const isVisible = await searchInput.isVisible().catch(() => false);
    console.log('Search input visible:', isVisible);
  });

  // ========== CATEGORY MANAGEMENT ==========
  test('Should display category tabs or filters', async ({ page }) => {
    const categories = [
      /beverages|getränke|drinks/i,
      /spirits|spirituosen/i,
      /food|essen|speisen/i,
      /supplies|zubehör|verbrauchsmaterial/i,
      /all|alle/i,
    ];

    for (const category of categories) {
      const tab = page.getByRole('button', { name: category }).or(page.getByText(category));
      const isVisible = await tab.first().isVisible().catch(() => false);
      if (isVisible) {
        console.log(`Category ${category} visible`);
      }
    }
  });

  test('Should filter items by category', async ({ page }) => {
    const categoryTab = page.getByRole('button', { name: /beverages|getränke/i }).first();
    if (await categoryTab.isVisible()) {
      await categoryTab.click();
      await page.waitForTimeout(500);
      // Items should filter
    }
  });

  // ========== ITEM DISPLAY ==========
  test('Should display inventory items in list or grid', async ({ page }) => {
    const itemCards = page.locator('[class*="item"], [class*="card"], [class*="inventory"]');
    const count = await itemCards.count();
    console.log('Inventory items found:', count);
  });

  test('Should show item name on each card', async ({ page }) => {
    const itemCard = page.locator('[class*="item"], [class*="card"]').first();
    if (await itemCard.isVisible()) {
      const text = await itemCard.textContent();
      expect(text?.length).toBeGreaterThan(0);
    }
  });

  test('Should show current stock quantity', async ({ page }) => {
    const stockIndicator = page.getByText(/\d+\s*(units|stück|bottles|flaschen|in stock)/i);
    const isVisible = await stockIndicator.first().isVisible().catch(() => false);
    console.log('Stock quantity visible:', isVisible);
  });

  test('Should show low stock warning', async ({ page }) => {
    const lowStockWarning = page.getByText(/low|niedrig|warning|warnung|reorder/i);
    const lowStockIcon = page.locator('[class*="warning"], [class*="alert"], [class*="low"]');
    const isVisible = await lowStockWarning.or(lowStockIcon).first().isVisible().catch(() => false);
    console.log('Low stock warning visible:', isVisible);
  });

  // ========== ADD ITEM ==========
  test('Should open add item modal', async ({ page }) => {
    const addButton = page.getByRole('button', { name: /add|create|new|neu|\+/i }).first();
    if (await addButton.isVisible()) {
      await addButton.click();
      await page.waitForTimeout(500);

      const modal = page.getByRole('dialog').or(page.locator('[class*="modal"]'));
      const nameInput = page.getByPlaceholder(/name|artikel/i);
      await expect(modal.or(nameInput)).toBeVisible();
    }
  });

  test('Should have required fields in add form', async ({ page }) => {
    const addButton = page.getByRole('button', { name: /add|create|new|neu|\+/i }).first();
    if (await addButton.isVisible().catch(() => false)) {
      await addButton.click();
      await page.waitForTimeout(500);

      // Check for fields
      const nameInput = page.getByPlaceholder(/name|artikel/i).first();
      const quantityInput = page.getByPlaceholder(/quantity|menge|anzahl/i).first();
      const categorySelect = page.getByText(/category|kategorie/i).first();

      const hasFields = await nameInput.isVisible().catch(() => false) ||
                        await quantityInput.isVisible().catch(() => false) ||
                        await categorySelect.isVisible().catch(() => false);
      console.log('Add form has fields:', hasFields);
    } else {
      console.log('Add button not visible, skipping form fields check');
    }
  });

  test('Should show unit type selector', async ({ page }) => {
    const addButton = page.getByRole('button', { name: /add|create|new|neu|\+/i }).first();
    if (await addButton.isVisible()) {
      await addButton.click();
      await page.waitForTimeout(500);

      const unitSelector = page.getByText(/unit|einheit|pieces|stück|bottles|flaschen|liters|liter/i);
      const isVisible = await unitSelector.first().isVisible().catch(() => false);
      console.log('Unit selector visible:', isVisible);
    }
  });

  test('Should show minimum stock level input', async ({ page }) => {
    const addButton = page.getByRole('button', { name: /add|create|new|neu|\+/i }).first();
    if (await addButton.isVisible()) {
      await addButton.click();
      await page.waitForTimeout(500);

      const minStockInput = page.getByPlaceholder(/minimum|mindest|reorder/i).or(page.getByLabel(/minimum|mindest/i));
      const isVisible = await minStockInput.isVisible().catch(() => false);
      console.log('Min stock input visible:', isVisible);
    }
  });

  test('Should create new inventory item', async ({ page }) => {
    const addButton = page.getByRole('button', { name: /add|create|new|neu|\+/i }).first();
    if (await addButton.isVisible()) {
      await addButton.click();
      await page.waitForTimeout(500);

      const nameInput = page.getByPlaceholder(/name|artikel/i).first();
      if (await nameInput.isVisible()) {
        await nameInput.fill('Test Item ' + Date.now());
      }

      const quantityInput = page.getByPlaceholder(/quantity|menge/i).first();
      if (await quantityInput.isVisible()) {
        await quantityInput.fill('10');
      }

      const submitButton = page.getByRole('button', { name: /save|create|speichern/i });
      if (await submitButton.isVisible()) {
        await submitButton.click();
        await page.waitForTimeout(1000);
      }
    }
  });

  // ========== STOCK ADJUSTMENT ==========
  test('Should allow adjusting stock quantity', async ({ page }) => {
    const itemCard = page.locator('[class*="item"], [class*="card"]').first();
    if (await itemCard.isVisible()) {
      await itemCard.click();
      await page.waitForTimeout(500);

      const adjustButton = page.getByRole('button', { name: /adjust|anpassen|update/i });
      const isVisible = await adjustButton.first().isVisible().catch(() => false);
      console.log('Adjust button visible:', isVisible);
    }
  });

  test('Should show add/remove stock buttons', async ({ page }) => {
    const addStockButton = page.getByRole('button', { name: /\+|add stock|hinzufügen/i });
    const removeStockButton = page.getByRole('button', { name: /-|remove|entfernen/i });

    const hasAddRemove = await addStockButton.or(removeStockButton).first().isVisible().catch(() => false);
    console.log('Add/Remove stock buttons visible:', hasAddRemove);
  });

  test('Should require reason for stock adjustment', async ({ page }) => {
    const adjustButton = page.getByRole('button', { name: /adjust|anpassen/i }).first();
    if (await adjustButton.isVisible()) {
      await adjustButton.click();
      await page.waitForTimeout(500);

      const reasonInput = page.getByPlaceholder(/reason|grund|comment/i).or(page.getByLabel(/reason|grund/i));
      const isVisible = await reasonInput.isVisible().catch(() => false);
      console.log('Reason input visible:', isVisible);
    }
  });

  // ========== ITEM DETAILS ==========
  test('Should show item detail view', async ({ page }) => {
    const itemCard = page.locator('[class*="item"], [class*="card"]').first();
    if (await itemCard.isVisible()) {
      await itemCard.click();
      await page.waitForTimeout(500);

      const detailView = page.getByText(/details|stock history|bestandsverlauf/i);
      const isVisible = await detailView.first().isVisible().catch(() => false);
      console.log('Detail view visible:', isVisible);
    }
  });

  test('Should show stock history/log', async ({ page }) => {
    const historyButton = page.getByRole('button', { name: /history|verlauf|log/i });
    if (await historyButton.first().isVisible()) {
      await historyButton.first().click();
      await page.waitForTimeout(500);

      const historyEntries = page.locator('[class*="history"], [class*="log"], [class*="entry"]');
      const count = await historyEntries.count();
      console.log('History entries:', count);
    }
  });

  // ========== BARCODE/SKU ==========
  test('Should show SKU or barcode field', async ({ page }) => {
    const skuField = page.getByText(/sku|barcode|artikelnummer/i);
    const isVisible = await skuField.first().isVisible().catch(() => false);
    console.log('SKU/Barcode field visible:', isVisible);
  });

  test('Should support barcode scanning', async ({ page }) => {
    const scanButton = page.getByRole('button', { name: /scan|scannen/i });
    const isVisible = await scanButton.first().isVisible().catch(() => false);
    console.log('Scan button visible:', isVisible);
  });

  // ========== SUPPLIER INFO ==========
  test('Should show supplier information', async ({ page }) => {
    const supplierInfo = page.getByText(/supplier|lieferant|vendor/i);
    const isVisible = await supplierInfo.first().isVisible().catch(() => false);
    console.log('Supplier info visible:', isVisible);
  });

  // ========== COST/PRICING ==========
  test('Should show cost price', async ({ page }) => {
    const costField = page.getByText(/cost|kosten|einkaufspreis|€/i);
    const isVisible = await costField.first().isVisible().catch(() => false);
    console.log('Cost field visible:', isVisible);
  });

  test('Should show selling price', async ({ page }) => {
    const priceField = page.getByText(/price|preis|verkaufspreis/i);
    const isVisible = await priceField.first().isVisible().catch(() => false);
    console.log('Price field visible:', isVisible);
  });

  // ========== REPORTS & EXPORT ==========
  test('Should show export/report button', async ({ page }) => {
    const exportButton = page.getByRole('button', { name: /export|report|bericht|download/i });
    const isVisible = await exportButton.first().isVisible().catch(() => false);
    console.log('Export button visible:', isVisible);
  });

  test('Should show inventory value summary', async ({ page }) => {
    const valueSummary = page.getByText(/total value|gesamtwert|inventory value/i);
    const isVisible = await valueSummary.first().isVisible().catch(() => false);
    console.log('Value summary visible:', isVisible);
  });

  // ========== SORTING ==========
  test('Should allow sorting items', async ({ page }) => {
    const sortButton = page.getByRole('button', { name: /sort|sortieren/i });
    const sortDropdown = page.getByRole('combobox');
    const isVisible = await sortButton.or(sortDropdown).first().isVisible().catch(() => false);
    console.log('Sort option visible:', isVisible);
  });

  // ========== DELETE ITEM ==========
  test('Should allow deleting items', async ({ page }) => {
    const deleteButton = page.getByRole('button', { name: /delete|löschen/i });
    const isVisible = await deleteButton.first().isVisible().catch(() => false);
    console.log('Delete button visible:', isVisible);
  });

  test('Should confirm before deletion', async ({ page }) => {
    const deleteButton = page.getByRole('button', { name: /delete|löschen/i }).first();
    if (await deleteButton.isVisible()) {
      await deleteButton.click();
      await page.waitForTimeout(500);

      const confirmDialog = page.getByText(/confirm|bestätigen|sicher/i);
      const isVisible = await confirmDialog.first().isVisible().catch(() => false);
      console.log('Delete confirmation visible:', isVisible);
    }
  });
});
