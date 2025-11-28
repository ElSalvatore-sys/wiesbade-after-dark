// Generate PWA icons for Owner Portal
const { createCanvas } = require('canvas');
const fs = require('fs');
const path = require('path');

const sizes = [16, 32, 72, 96, 128, 144, 152, 167, 180, 192, 384, 512];
const outputDir = path.join(__dirname, '../public');

function generateIcon(size) {
  const canvas = createCanvas(size, size);
  const ctx = canvas.getContext('2d');

  // Create gradient
  const gradient = ctx.createLinearGradient(0, 0, size, size);
  gradient.addColorStop(0, '#8B5CF6');
  gradient.addColorStop(1, '#EC4899');

  // Draw rounded rectangle
  const radius = size * 0.21;
  ctx.beginPath();
  ctx.moveTo(radius, 0);
  ctx.lineTo(size - radius, 0);
  ctx.quadraticCurveTo(size, 0, size, radius);
  ctx.lineTo(size, size - radius);
  ctx.quadraticCurveTo(size, size, size - radius, size);
  ctx.lineTo(radius, size);
  ctx.quadraticCurveTo(0, size, 0, size - radius);
  ctx.lineTo(0, radius);
  ctx.quadraticCurveTo(0, 0, radius, 0);
  ctx.closePath();
  ctx.fillStyle = gradient;
  ctx.fill();

  // Draw "W" letter
  ctx.fillStyle = 'white';
  ctx.font = `bold ${size * 0.45}px system-ui, -apple-system, BlinkMacSystemFont, sans-serif`;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText('W', size / 2, size / 2 + size * 0.03);

  // Save to file
  const buffer = canvas.toBuffer('image/png');
  const filename = `icon-${size}.png`;
  fs.writeFileSync(path.join(outputDir, filename), buffer);
  console.log(`Generated ${filename}`);
}

// Generate all sizes
console.log('Generating PWA icons...');
sizes.forEach(generateIcon);
console.log('Done! Icons saved to public/');
