const { createCanvas } = require('canvas');
const fs = require('fs');
const path = require('path');

const SIZES = {
  '6.7': { width: 1290, height: 2796 },
  '6.5': { width: 1284, height: 2778 },
  '5.5': { width: 1242, height: 2208 },
};

const SCREENS = [
  { id: 'home', title: 'Earn Points', subtitle: 'Get rewarded everywhere', gradient: ['#8B5CF6', '#EC4899'] },
  { id: 'discover', title: 'Discover Venues', subtitle: 'Find the best spots', gradient: ['#3B82F6', '#8B5CF6'] },
  { id: 'events', title: 'Exclusive Events', subtitle: 'Never miss a party', gradient: ['#EC4899', '#F59E0B'] },
  { id: 'community', title: 'Join Community', subtitle: 'Connect with others', gradient: ['#10B981', '#3B82F6'] },
  { id: 'profile', title: 'Track Progress', subtitle: 'Level up your nightlife', gradient: ['#F59E0B', '#EF4444'] },
];

if (!fs.existsSync('screenshots')) fs.mkdirSync('screenshots');

SCREENS.forEach(screen => {
  Object.entries(SIZES).forEach(([key, size]) => {
    const canvas = createCanvas(size.width, size.height);
    const ctx = canvas.getContext('2d');
    
    // Gradient background
    const grad = ctx.createLinearGradient(0, 0, size.width, size.height);
    grad.addColorStop(0, screen.gradient[0]);
    grad.addColorStop(1, screen.gradient[1]);
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, size.width, size.height);
    
    // Title
    ctx.fillStyle = '#FFFFFF';
    ctx.font = `bold ${size.width * 0.07}px sans-serif`;
    ctx.textAlign = 'center';
    ctx.fillText(screen.title, size.width/2, size.height * 0.12);
    
    // Subtitle
    ctx.fillStyle = 'rgba(255,255,255,0.8)';
    ctx.font = `${size.width * 0.035}px sans-serif`;
    ctx.fillText(screen.subtitle, size.width/2, size.height * 0.16);
    
    // Phone mockup placeholder
    ctx.fillStyle = '#000';
    ctx.beginPath();
    ctx.roundRect(size.width*0.12, size.height*0.2, size.width*0.76, size.height*0.72, 50);
    ctx.fill();
    
    ctx.fillStyle = '#09090B';
    ctx.beginPath();
    ctx.roundRect(size.width*0.14, size.height*0.22, size.width*0.72, size.height*0.68, 40);
    ctx.fill();
    
    ctx.fillStyle = '#333';
    ctx.font = `${size.width * 0.025}px sans-serif`;
    ctx.fillText('Add real screenshot here', size.width/2, size.height*0.55);
    
    const filename = `screenshots/${screen.id}_${key}inch.png`;
    fs.writeFileSync(filename, canvas.toBuffer('image/png'));
    console.log('Created:', filename);
  });
});

console.log('\n✅ Done! Screenshots in screenshots/ folder');
