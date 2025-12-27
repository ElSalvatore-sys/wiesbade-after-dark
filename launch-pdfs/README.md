# 📄 Printable Launch Guides

This directory contains printable HTML versions of all launch documentation.

## Files

- **LAUNCH_DAY_CHECKLIST.html** - Complete launch day procedures (450+ lines)
- **STAFF_QUICK_START_GUIDE.html** - Staff training guide in German
- **MANAGER_LAUNCH_GUIDE.html** - Manager operational guide in German
- **print-style.css** - Print styling (A4 format)

## How to Create PDFs

### Method 1: Browser Print (Recommended)

1. **Open HTML file** in Safari or Chrome
2. **Press Cmd+P** (or File → Print)
3. **Select "Save as PDF"** from the destination dropdown
4. **Save** to this directory with same name (.pdf extension)

**Settings for best quality:**
- Paper size: A4
- Margins: Normal (or 2.5cm)
- Background graphics: ON
- Headers and footers: OFF

### Method 2: Command Line (Advanced)

If you have `wkhtmltopdf` installed:

```bash
# Install (if needed)
brew install wkhtmltopdf

# Convert all files
for file in *.html; do
  wkhtmltopdf \
    --page-size A4 \
    --margin-top 25mm \
    --margin-bottom 25mm \
    --margin-left 25mm \
    --margin-right 25mm \
    "${file}" "${file%.html}.pdf"
done
```

## Expected PDFs

After conversion, you should have:
- ✅ LAUNCH_DAY_CHECKLIST.pdf (~10-12 pages)
- ✅ STAFF_QUICK_START_GUIDE.pdf (~3-4 pages)
- ✅ MANAGER_LAUNCH_GUIDE.pdf (~8-10 pages)

## Print Multiple Copies

For Das Wohnzimmer launch, print:
- **1 copy** of LAUNCH_DAY_CHECKLIST.pdf (for owner/manager)
- **8 copies** of STAFF_QUICK_START_GUIDE.pdf (one per staff member)
- **2 copies** of MANAGER_LAUNCH_GUIDE.pdf (manager + backup)

## Tips

- Print in **color** for better readability of highlighted sections
- Use **double-sided** printing to save paper
- **Staple** multi-page documents in top-left corner
- Consider **laminating** the Staff Quick Start Guide for durability

---

*Created: December 28, 2025*
*For: Das Wohnzimmer Launch - January 1, 2025*

