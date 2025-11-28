const { createCanvas } = require('canvas');
const fs = require('fs');

// Create 1024x1024 canvas
const size = 1024;
const canvas = createCanvas(size, size);
const ctx = canvas.getContext('2d');

// Purple to pink gradient background
const gradient = ctx.createLinearGradient(0, 0, size, size);
gradient.addColorStop(0, '#8B5CF6');
gradient.addColorStop(0.5, '#A855F7');
gradient.addColorStop(1, '#EC4899');
ctx.fillStyle = gradient;
ctx.fillRect(0, 0, size, size);

// Add subtle glow orb in top-left
ctx.globalAlpha = 0.25;
ctx.beginPath();
const orbGradient = ctx.createRadialGradient(size * 0.25, size * 0.3, 0, size * 0.25, size * 0.3, size * 0.45);
orbGradient.addColorStop(0, '#EC4899');
orbGradient.addColorStop(1, 'transparent');
ctx.fillStyle = orbGradient;
ctx.arc(size * 0.25, size * 0.3, size * 0.45, 0, Math.PI * 2);
ctx.fill();

ctx.globalAlpha = 1;

// Draw bold "W" manually using paths for guaranteed rendering
ctx.fillStyle = '#FFFFFF';
ctx.shadowColor = 'rgba(0, 0, 0, 0.2)';
ctx.shadowBlur = 30;
ctx.shadowOffsetX = 0;
ctx.shadowOffsetY = 10;

// W shape - custom path for consistent rendering
const w = size * 0.65;  // width of W
const h = size * 0.45;  // height of W
const strokeW = size * 0.11;  // stroke width
const startX = (size - w) / 2;
const startY = (size - h) / 2;

ctx.beginPath();
// Left leg
ctx.moveTo(startX, startY);
ctx.lineTo(startX + strokeW, startY);
ctx.lineTo(startX + w * 0.25, startY + h);
ctx.lineTo(startX + w * 0.25 - strokeW * 0.7, startY + h);
ctx.closePath();
ctx.fill();

// Left-center leg
ctx.beginPath();
ctx.moveTo(startX + w * 0.25 - strokeW * 0.3, startY + h);
ctx.lineTo(startX + w * 0.25 + strokeW * 0.4, startY + h);
ctx.lineTo(startX + w * 0.5, startY + h * 0.35);
ctx.lineTo(startX + w * 0.5 - strokeW * 0.5, startY + h * 0.35);
ctx.closePath();
ctx.fill();

// Right-center leg
ctx.beginPath();
ctx.moveTo(startX + w * 0.5 + strokeW * 0.5, startY + h * 0.35);
ctx.lineTo(startX + w * 0.5, startY + h * 0.35);
ctx.lineTo(startX + w * 0.75 - strokeW * 0.4, startY + h);
ctx.lineTo(startX + w * 0.75 + strokeW * 0.3, startY + h);
ctx.closePath();
ctx.fill();

// Right leg
ctx.beginPath();
ctx.moveTo(startX + w - strokeW, startY);
ctx.lineTo(startX + w, startY);
ctx.lineTo(startX + w * 0.75 + strokeW * 0.7, startY + h);
ctx.lineTo(startX + w * 0.75, startY + h);
ctx.closePath();
ctx.fill();

// Reset shadow
ctx.shadowColor = 'transparent';
ctx.shadowBlur = 0;
ctx.shadowOffsetX = 0;
ctx.shadowOffsetY = 0;

// Add moon accent in top-right
ctx.beginPath();
ctx.arc(size * 0.78, size * 0.22, size * 0.07, 0, Math.PI * 2);
ctx.fillStyle = '#FCD34D';
ctx.globalAlpha = 0.9;
ctx.fill();

// Add small star sparkles
ctx.globalAlpha = 0.7;
ctx.fillStyle = '#FFFFFF';

function drawStar(cx, cy, r) {
  ctx.beginPath();
  ctx.arc(cx, cy, r, 0, Math.PI * 2);
  ctx.fill();
}

drawStar(size * 0.85, size * 0.35, 4);
drawStar(size * 0.70, size * 0.15, 3);
drawStar(size * 0.88, size * 0.18, 2);

// Save
const buffer = canvas.toBuffer('image/png');
fs.writeFileSync('app-icon-1024.png', buffer);
console.log('Generated: app-icon-1024.png (1024x1024)');
