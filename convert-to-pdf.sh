#!/bin/bash

echo "=== CONVERTING LAUNCH GUIDES TO PDF ==="
echo ""

# Create PDFs directory
mkdir -p launch-pdfs

# Convert LAUNCH_DAY_CHECKLIST.md to PDF
echo "📋 Converting LAUNCH_DAY_CHECKLIST.md..."
pandoc LAUNCH_DAY_CHECKLIST.md \
  -o launch-pdfs/LAUNCH_DAY_CHECKLIST.pdf \
  --pdf-engine=xelatex \
  -V geometry:margin=2.5cm \
  -V papersize=a4 \
  -V fontsize=11pt \
  -V mainfont="Helvetica" \
  --toc \
  --toc-depth=2 \
  -V colorlinks=true \
  -V linkcolor=blue \
  -V urlcolor=blue \
  2>&1 | grep -v "Missing character"

if [ -f "launch-pdfs/LAUNCH_DAY_CHECKLIST.pdf" ]; then
  echo "✅ LAUNCH_DAY_CHECKLIST.pdf created"
else
  echo "❌ Failed to create LAUNCH_DAY_CHECKLIST.pdf"
fi

# Convert STAFF_QUICK_START_GUIDE.md to PDF
echo ""
echo "📱 Converting STAFF_QUICK_START_GUIDE.md..."
pandoc STAFF_QUICK_START_GUIDE.md \
  -o launch-pdfs/STAFF_QUICK_START_GUIDE.pdf \
  --pdf-engine=xelatex \
  -V geometry:margin=2cm \
  -V papersize=a4 \
  -V fontsize=12pt \
  -V mainfont="Helvetica" \
  -V colorlinks=true \
  -V linkcolor=blue \
  2>&1 | grep -v "Missing character"

if [ -f "launch-pdfs/STAFF_QUICK_START_GUIDE.pdf" ]; then
  echo "✅ STAFF_QUICK_START_GUIDE.pdf created"
else
  echo "❌ Failed to create STAFF_QUICK_START_GUIDE.pdf"
fi

# Convert MANAGER_LAUNCH_GUIDE.md to PDF
echo ""
echo "👔 Converting MANAGER_LAUNCH_GUIDE.md..."
pandoc MANAGER_LAUNCH_GUIDE.md \
  -o launch-pdfs/MANAGER_LAUNCH_GUIDE.pdf \
  --pdf-engine=xelatex \
  -V geometry:margin=2.5cm \
  -V papersize=a4 \
  -V fontsize=11pt \
  -V mainfont="Helvetica" \
  --toc \
  --toc-depth=2 \
  -V colorlinks=true \
  -V linkcolor=blue \
  2>&1 | grep -v "Missing character"

if [ -f "launch-pdfs/MANAGER_LAUNCH_GUIDE.pdf" ]; then
  echo "✅ MANAGER_LAUNCH_GUIDE.pdf created"
else
  echo "❌ Failed to create MANAGER_LAUNCH_GUIDE.pdf"
fi

echo ""
echo "=== PDF CONVERSION COMPLETE ==="
echo ""
echo "Output directory: launch-pdfs/"
ls -lh launch-pdfs/*.pdf 2>/dev/null

