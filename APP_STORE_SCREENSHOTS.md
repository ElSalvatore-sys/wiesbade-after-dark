# 📸 App Store Screenshots Guide
## WiesbadenAfterDark iOS App

---

## Required Screenshots

App Store requires **5 screenshots** in **3 device sizes**:
- 6.7" display (iPhone 17 Pro Max, 15 Pro Max, 14 Pro Max)
- 6.5" display (iPhone 15 Plus, 14 Plus, 13 Pro Max, 12 Pro Max)
- 5.5" display (iPhone 8 Plus, 7 Plus, 6s Plus)

---

## Recommended Screenshots

### 1. Discovery/Home Screen
**What to show:**
- Featured venues with beautiful images
- Category chips (Bars, Clubs, Restaurants, Cafés)
- Search bar at top
- Bottom tab bar visible

**Text Overlay:**
"Entdecke Wiesbadens Nachtleben"
"Discover nightlife venues near you"

**Capture in Xcode:**
```
Home tab → Wait for venues to load → Screenshot
```

---

### 2. Venue Detail
**What to show:**
- Large venue image at top
- Venue name and rating
- Check-in button (prominent purple)
- Opening hours
- Description
- Events list

**Text Overlay:**
"Exklusive Venue-Details"
"Get exclusive access and rewards"

**Capture in Xcode:**
```
Tap on any featured venue → Wait for detail to load → Screenshot
```

---

### 3. Events List
**What to show:**
- Upcoming events with images
- Date and time badges
- Event categories
- Book button visible

**Text Overlay:**
"Verpasse kein Event"
"Never miss your favorite events"

**Capture in Xcode:**
```
Events tab → Wait for events to load → Screenshot
```

---

### 4. Wallet/Points
**What to show:**
- Points balance card (large at top)
- Loyalty tier badge (Bronze/Silver/Gold)
- Check-ins history
- Rewards section

**Text Overlay:**
"Sammle Punkte & Belohnungen"
"Earn rewards with every visit"

**Capture in Xcode:**
```
Wallet tab → Wait for balance to load → Screenshot
```

---

### 5. Community Feed
**What to show:**
- User posts with images
- Likes and comments
- Create post button
- Social engagement

**Text Overlay:**
"Teile deine Erlebnisse"
"Share your nightlife moments"

**Capture in Xcode:**
```
Home tab → Scroll down to Community section → Screenshot
```

---

## Device Sizes and Resolutions

| Device Size | Resolution | Devices |
|-------------|------------|---------|
| 6.7" | 1290 x 2796 px | iPhone 17 Pro Max, 15 Pro Max, 14 Pro Max |
| 6.5" | 1284 x 2778 px | iPhone 15 Plus, 14 Plus, 13 Pro Max, 12 Pro Max |
| 5.5" | 1242 x 2208 px | iPhone 8 Plus, 7 Plus, 6s Plus |

---

## How to Capture Screenshots in Xcode

### Step 1: Launch Simulator
```bash
# Choose the device size
open -a Simulator
# Or in Xcode: Window → Devices and Simulators
```

### Step 2: Run App
```bash
Cmd + R in Xcode
# Or: Product → Run
```

### Step 3: Navigate to Screen
- Wait for data to load
- Ensure UI looks good (no loading spinners)
- Make sure tab bar is visible

### Step 4: Take Screenshot
```bash
Cmd + S in Simulator
# Or: File → New Screen Shot
```

**Screenshots save to:** `~/Desktop/`

### Step 5: Repeat for Each Device Size
1. iPhone 17 Pro Max (6.7")
2. iPhone 15 Plus (6.5")
3. iPhone 8 Plus (5.5")

**Total screenshots needed:** 5 screens × 3 sizes = **15 images**

---

## Text Overlays (Optional but Recommended)

Use **Keynote**, **Figma**, or **Photoshop** to add text overlays:

### Fonts:
- Title: **SF Pro Display Bold**, 48-60pt
- Subtitle: **SF Pro Text Regular**, 24-32pt

### Colors (Brand):
- Purple: `#7C3AED`
- Pink: `#EC4899`
- White: `#FFFFFF`
- Background overlay: `rgba(0,0,0,0.4)`

### Best Practices:
- Keep text short (5-7 words max)
- Use high contrast for readability
- Place text in top or bottom third
- Don't cover important UI elements

---

## App Store Preview Video (Optional)

If you want to add a **30-second preview video**:

### What to Show:
1. Launch app (0-3s)
2. Browse venues (3-10s)
3. Tap on venue detail (10-15s)
4. Show check-in flow (15-22s)
5. Show points earned (22-28s)
6. End with app icon (28-30s)

### Tools:
- **QuickTime Player**: Record simulator screen
- **iMovie**: Add transitions and music
- **Final Cut Pro**: Professional editing

---

## Testing Before Submission

### Screenshot Checklist:
- [ ] All 5 screenshots captured
- [ ] All 3 device sizes completed (15 total images)
- [ ] No loading spinners visible
- [ ] Text is readable
- [ ] UI looks polished (no placeholder data)
- [ ] Tab bar visible where appropriate
- [ ] Brand colors consistent

### Image Quality:
- [ ] PNG format (not JPEG)
- [ ] No compression artifacts
- [ ] Correct resolutions for each device
- [ ] File size < 10MB per image

---

## Uploading to App Store Connect

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Go to **My Apps** → **WiesbadenAfterDark**
3. Click **App Store** tab
4. Scroll to **App Previews and Screenshots**
5. Drag and drop screenshots for each device size
6. Arrange in order (1-5 as listed above)
7. Save changes

---

**Time estimate:** 1-2 hours for all screenshots + text overlays

**Next:** Run through manual checklist before submission

---

*Created: December 26, 2025*
