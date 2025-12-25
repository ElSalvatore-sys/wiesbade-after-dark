# SMTP Configuration & Email Setup Guide
### WiesbadenAfterDark Platform

**Last Updated:** December 25, 2025
**Status:** Active (Booking confirmation emails implemented)
**Current Implementation:** Supabase Auth SMTP with Edge Functions

---

## Table of Contents

1. [Current Email Capability](#current-email-capability)
2. [Architecture Overview](#architecture-overview)
3. [Email Templates (German)](#email-templates-german)
4. [SMTP Setup Options](#smtp-setup-options)
5. [Testing Checklist](#testing-checklist)
6. [Troubleshooting](#troubleshooting)
7. [Production Recommendations](#production-recommendations)

---

## Current Email Capability

### Status
- **Active:** Booking confirmation emails (accepted/rejected)
- **Implementation:** Supabase Edge Function (`send-booking-confirmation`)
- **Email Service:** Supabase Auth SMTP (default)
- **Rate Limit:** Limited by Supabase free tier

### Current Architecture

```
Owner PWA Booking Action
    ↓
handleAccept() / handleReject()
    ↓
sendBookingConfirmation(bookingId, action)
    ↓
POST /functions/v1/send-booking-confirmation
    ↓
Supabase Edge Function (Deno)
    ├─ Fetch booking + venue details
    ├─ Format German email template
    └─ Send via Supabase Auth SMTP
         ↓
    Guest Email + Audit Log
```

### Files Involved

**Edge Function:**
- `/supabase/functions/send-booking-confirmation/index.ts` - Handles all email sending

**PWA Integration:**
- `/owner-pwa/src/services/supabaseApi.ts` - API wrapper function
- `/owner-pwa/src/pages/Bookings.tsx` - Trigger point (Accept/Reject buttons)

**Database:**
- `bookings.confirmation_sent_at` - Timestamp tracking
- `audit_logs` - Email send history

---

## Architecture Overview

### Supabase Email Settings

**Access:** https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli/auth/settings

Current Status:
- **Provider:** Supabase built-in SMTP (default)
- **Authentication:** Uses Supabase Auth system
- **Limitations:**
  - ~4-5 emails per hour on free tier
  - No custom sender name guarantee
  - Potential spam filter issues without proper SPF/DKIM

### Edge Function Flow

**Endpoint:** `POST {SUPABASE_URL}/functions/v1/send-booking-confirmation`

**Request:**
```json
{
  "booking_id": "uuid-string",
  "action": "accepted|rejected|reminder"
}
```

**Response:**
```json
{
  "success": true,
  "message": "accepted email sent",
  "booking_id": "uuid-string"
}
```

**Error Handling:**
- If SMTP fails, email details logged to audit_logs
- Booking confirmation proceeds regardless (non-blocking)
- No automatic retry (manual resend required)

---

## Email Templates (German)

### 1. Booking Accepted

**Trigger:** Owner clicks "Accept" on booking

**Subject:** `Reservierung bestätigt - {Venue Name}`

**Content:**
```
Reservierung bestätigt! ✓

Hallo {Guest Name},

Ihre Reservierung bei {Venue Name} wurde bestätigt.

📅 Datum: {Formatted Date}
🕐 Uhrzeit: {Time} Uhr
👥 Personen: {Guest Count}
🪑 Tisch: {Table Number}

[Optional: Special Requests if provided]

Wir freuen uns auf Ihren Besuch!

Mit freundlichen Grüßen,
{Venue Name}
```

**Example Sent:**
```
Subject: Reservierung bestätigt - Das Wohnzimmer

Hallo Max Mustermann,

Ihre Reservierung bei Das Wohnzimmer wurde bestätigt.

📅 Datum: Freitag, 27. Dezember 2025
🕐 Uhrzeit: 19:00 Uhr
👥 Personen: 4
🪑 Tisch: 12

Besondere Wünsche:
Fensterplatz, wenn möglich

Wir freuen uns auf Ihren Besuch!

Mit freundlichen Grüßen,
Das Wohnzimmer
```

### 2. Booking Rejected

**Trigger:** Owner clicks "Reject" on booking

**Subject:** `Reservierungsanfrage - {Venue Name}`

**Content:**
```
Reservierung leider nicht möglich

Hallo {Guest Name},

Leider können wir Ihre Reservierungsanfrage für den {Date}
nicht bestätigen.

Bitte kontaktieren Sie uns für alternative Termine oder
besuchen Sie uns spontan - wir werden unser Bestes tun,
einen Platz für Sie zu finden.

Mit freundlichen Grüßen,
{Venue Name}
```

### 3. Booking Reminder (Not Yet Implemented)

**Planned Trigger:** Daily cron job at 10:00 AM for today's bookings

**Subject:** `Erinnerung: Ihre Reservierung heute - {Venue Name}`

**Content:**
```
Erinnerung an Ihre Reservierung

Hallo {Guest Name},

Wir möchten Sie an Ihre heutige Reservierung erinnern:

🕐 Uhrzeit: {Time} Uhr
👥 Personen: {Guest Count}

Wir freuen uns auf Sie!

Mit freundlichen Grüßen,
{Venue Name}
```

---

## SMTP Setup Options

### Option 1: Resend (Recommended)

**Why Resend?**
- ✅ Free tier: 100 emails/day
- ✅ Modern API, excellent documentation
- ✅ Email analytics (opens, clicks)
- ✅ Transactional email optimized
- ✅ Great deliverability
- ✅ German company friendly
- ⚠️ No SPF/DKIM setup needed (they manage it)

**Cost:**
- Free tier: 100 emails/day
- Paid: €0.03 per email (or $10/month for 1,000)

**Setup Steps:**

1. **Create Account**
   - Go to https://resend.com
   - Sign up with email
   - Verify email

2. **Get API Key**
   - Dashboard → API Keys
   - Create new key (e.g., "WiesbadenAfterDark")
   - Copy key

3. **Update Edge Function**
   ```typescript
   import { Resend } from "npm:resend@latest";

   const resend = new Resend(Deno.env.get("RESEND_API_KEY"));

   const response = await resend.emails.send({
     from: "noreply@wiesbaden-after-dark.de",
     to: booking.guest_email,
     subject: subject,
     html: htmlContent,
   });
   ```

4. **Set Environment Variables**
   - Supabase Dashboard → Edge Functions → Environment Variables
   - Add: `RESEND_API_KEY=re_xxxxxxxxxxxxx`

5. **Deploy**
   ```bash
   supabase functions deploy send-booking-confirmation
   ```

6. **Test**
   - Send test booking confirmation
   - Check delivery within 1-2 minutes
   - Verify no spam folder

---

### Option 2: Gmail App Password

**Why Gmail?**
- ✅ Free tier unlimited
- ✅ Widely recognized sender
- ✅ Good deliverability
- ✅ Easy setup
- ⚠️ Personal account (not ideal for production)
- ⚠️ Requires app-specific password

**Cost:** Free

**Setup Steps:**

1. **Enable 2-Factor Authentication**
   - Go to https://myaccount.google.com
   - Left menu → Security
   - Enable 2-Step Verification

2. **Create App Password**
   - Security → App Passwords
   - Select: Mail, Windows Computer
   - Google generates 16-char password
   - Copy password

3. **Configure SMTP in Edge Function**
   ```typescript
   const transporter = await import("npm:nodemailer").default.createTransport({
     host: "smtp.gmail.com",
     port: 587,
     secure: false,
     auth: {
       user: "your-email@gmail.com",
       pass: "xxxx xxxx xxxx xxxx" // App password (16 chars)
     }
   });

   await transporter.sendMail({
     from: '"WiesbadenAfterDark" <your-email@gmail.com>',
     to: booking.guest_email,
     subject: subject,
     html: htmlContent,
   });
   ```

4. **Environment Variables**
   ```
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USER=your-email@gmail.com
   SMTP_PASS=xxxx xxxx xxxx xxxx
   ```

5. **Deploy & Test**

---

### Option 3: Supabase Default (Current)

**Limitations:**
- ✅ No setup required
- ✅ Works out of the box
- ⚠️ Rate limited (4-5/hour free tier)
- ⚠️ No analytics
- ⚠️ Potential deliverability issues

**When to Use:**
- Development only
- Testing phase
- Low-volume scenarios

**Current Status:**
- Working but limited by rate limits
- Email sends successfully when not rate-limited
- Good for initial MVP testing

---

### Option 4: SendGrid

**Why SendGrid?**
- ✅ Free tier: 100 emails/day
- ✅ Enterprise-grade reliability
- ✅ Excellent API documentation
- ✅ Email analytics
- ✅ Webhook support
- ⚠️ More complex setup
- ⚠️ Needs domain verification for production

**Cost:**
- Free tier: 100 emails/day
- Paid: $20/month for 50K emails

**Setup:**
- Sign up at https://sendgrid.com
- Create API key
- Verify domain (for production)
- Update Edge Function with SendGrid SDK
- Deploy and test

---

## Testing Checklist

### Phase 1: Development Testing

**Prerequisites:**
- [ ] Supabase project accessible
- [ ] Edge Function deployed locally or to Supabase
- [ ] Test email address (use personal Gmail/Outlook)
- [ ] Owner PWA running locally

**Tests:**

- [ ] **Create Test Booking**
  - Open Owner PWA at http://localhost:5173
  - Create new event with test date
  - Create booking with test guest email
  - Verify booking appears in list

- [ ] **Test Accept Booking**
  - Click "Accept" on test booking
  - Check browser console for API response
  - Confirm success status
  - Wait 1-2 minutes for email
  - Check inbox for confirmation email
  - Check spam folder
  - Verify content is correct German template
  - Note delivery time

- [ ] **Test Reject Booking**
  - Create another test booking
  - Click "Reject"
  - Check console response
  - Wait for email
  - Verify rejection email received
  - Check content

- [ ] **Test with Different Providers**
  - Repeat with Gmail address
  - Repeat with Outlook address
  - Repeat with corporate email (if available)
  - Note any deliverability differences

---

### Phase 2: Password Reset Email Testing

**Current Status:** Using Supabase Auth templates

**Test Steps:**

1. **Configure Auth Templates**
   - Go to Supabase Dashboard
   - Auth → Email Templates
   - Ensure German templates are set (see SUPABASE_EMAIL_TEMPLATES.md)

2. **Test Password Reset**
   - Open Owner PWA: https://owner-pwa.vercel.app/login
   - Click "Passwort vergessen?" (Password Forgot)
   - Enter test email
   - Check inbox for reset link (within 1-2 min)
   - Click link and reset password
   - Login with new password
   - Verify works

3. **Test Email Confirmation**
   - Create new account with test email
   - Check for confirmation email
   - Verify German template is used
   - Click confirmation link
   - Verify account activated

---

### Phase 3: Production Readiness Testing

- [ ] **Rate Limiting**
  - Send 10 booking confirmations rapidly
  - Monitor: Which sends succeed, which fail
  - Check Supabase rate limit headers
  - Verify failures logged to audit_logs

- [ ] **Audit Trail**
  - Send confirmation email
  - Query audit_logs table:
    ```sql
    SELECT * FROM audit_logs
    WHERE action LIKE 'booking_%_email_%'
    ORDER BY created_at DESC
    LIMIT 5;
    ```
  - Verify action, details, timestamps are correct

- [ ] **Booking State**
  - Send confirmation email
  - Query bookings table:
    ```sql
    SELECT id, status, confirmation_sent_at
    FROM bookings
    WHERE confirmation_sent_at IS NOT NULL
    ORDER BY confirmation_sent_at DESC
    LIMIT 5;
    ```
  - Verify confirmation_sent_at is populated

- [ ] **Error Handling**
  - Attempt to send to non-existent booking ID
  - Verify error response
  - Attempt with empty action
  - Verify validation error
  - Check no partial states created

- [ ] **Multi-Language Ready**
  - Verify German templates display correctly
  - Special characters (ä, ö, ü) render properly
  - No encoding issues
  - Date formatting is German (DD. Monat YYYY)

---

## Troubleshooting

### Email Not Arriving

**Symptom:** Edge function returns success but email not in inbox

**Diagnosis Steps:**

1. **Check Audit Log**
   ```sql
   SELECT * FROM audit_logs
   WHERE action LIKE 'booking_%_email_%'
   ORDER BY created_at DESC LIMIT 1;
   ```
   - If action ends with `_pending`: SMTP service failed, logged for manual retry
   - If action ends with `_sent`: Email sent, check spam/filters

2. **Check Spam Folder**
   - Gmail: Check "Spam" tab
   - Outlook: Check "Junk" folder
   - Yahoo: Check "Spam" folder
   - If found: Mark as "Not Spam"

3. **Check Edge Function Logs**
   - Supabase Dashboard → Edge Functions → send-booking-confirmation
   - Click latest invocation
   - Check for errors in logs
   - Look for SMTP error messages

4. **Test with Different Email**
   - Try Gmail address
   - Try corporate email
   - Try Outlook
   - Note which providers have issues

5. **Check Supabase Auth Settings**
   - Dashboard → Project Settings → Auth
   - Verify SMTP is configured
   - Check sender name/email
   - Verify redirect URLs

**Common Causes & Fixes:**

| Issue | Cause | Fix |
|-------|-------|-----|
| All emails fail | Rate limit exceeded | Wait 1 hour, upgrade tier, or switch to Resend |
| Emails go to spam | SPF/DKIM missing | Configure custom domain or use Resend |
| Inconsistent delivery | Supabase SMTP overload | Switch to dedicated service (Resend) |
| Field values missing (Guest Name = "Gast") | NULL values in database | Ensure booking creation populates all fields |
| Wrong venue name | NULL venue data | Check venue_id in booking, verify venue exists |
| Date formatting wrong | Locale issue | Verify Node/Deno locale, test with manual date string |

---

### Edge Function Not Responding

**Symptom:** 500 error or no response from Edge Function

**Debug:**

1. **Check Function is Deployed**
   ```bash
   supabase functions list
   # Should show: send-booking-confirmation
   ```

2. **Deploy Function**
   ```bash
   cd /Users/eldiaploo/Desktop/Projects-2025/WiesbadenAfterDark
   supabase functions deploy send-booking-confirmation
   ```

3. **Check Environment Variables**
   - Supabase Dashboard → Edge Functions
   - Verify SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are set
   - Keys should not be empty

4. **Test Function Directly**
   ```bash
   curl -X POST \
     https://yyplbhrqtaeyzmcxpfli.supabase.co/functions/v1/send-booking-confirmation \
     -H "Authorization: Bearer $(cat .env | grep SUPABASE_KEY | cut -d= -f2)" \
     -H "Content-Type: application/json" \
     -d '{"booking_id": "test-id", "action": "accepted"}'
   ```

5. **Check Logs**
   - Supabase Dashboard → Edge Functions → Logs
   - Filter by function name
   - Look for recent invocations
   - Check error messages

---

### Database Issues

**Symptom:** "Booking not found" error even with valid ID

**Debug:**

1. **Verify Booking Exists**
   ```sql
   SELECT id, guest_name, guest_email, date, status
   FROM bookings
   WHERE id = 'your-test-id' LIMIT 1;
   ```

2. **Verify Venue Relation**
   ```sql
   SELECT b.id, b.venue_id, v.id, v.name
   FROM bookings b
   LEFT JOIN venues v ON b.venue_id = v.id
   WHERE b.id = 'your-test-id';
   ```

3. **Check for RLS Policies**
   - Supabase Dashboard → Auth → Policies
   - Verify Edge Function has read access to bookings/venues
   - Service role should bypass RLS

---

### SMTP Authentication Fails (If Using Custom SMTP)

**Symptom:** "Authentication failed" in logs

**Debug:**

1. **Verify Credentials**
   - Check username/email format is correct
   - Verify password has no special character issues
   - Try without spaces/hyphens

2. **Test SMTP Directly**
   ```bash
   # Using openssl (macOS/Linux)
   openssl s_client -connect smtp.gmail.com:587 -starttls smtp
   # Type: EHLO test
   # Type: AUTH LOGIN
   ```

3. **Check Port**
   - Gmail: 587 (TLS) or 465 (SSL)
   - SendGrid/Resend: Usually 587 or API-only
   - Avoid port 25 (often blocked by ISPs)

4. **Verify App Password (Gmail)**
   - Re-generate app password
   - Use all 16 characters exactly
   - No spaces in code

---

### Email Content Issues

**Symptom:** Email received but content is malformed

| Issue | Cause | Fix |
|-------|-------|-----|
| HTML doesn't render (shows code) | Wrong MIME type | Ensure `Content-Type: text/html` |
| Special chars are ??? | Encoding issue | Use UTF-8, test with ä ö ü |
| Links are broken | Missing protocol in href | Use `https://` not relative paths |
| Images don't load | External CDN blocks | Inline images or use trusted CDN |
| Formatting is off | Email client CSS differences | Test in multiple clients (Gmail, Outlook, mobile) |

---

## Production Recommendations

### Recommendation Tier 1: Resend (Preferred)

**Implementation Cost:** 30 minutes
**Monthly Cost:** Free (100/day) → €0.03 per email or €10/month

**Advantages:**
- ✅ Modern, reliable API
- ✅ Great free tier for your volume
- ✅ German-friendly company
- ✅ Better deliverability than Supabase
- ✅ Email analytics built-in
- ✅ No SPF/DKIM hassle
- ✅ Easy to implement

**Timeline:**
1. Sign up at Resend (5 min)
2. Create API key (2 min)
3. Update Edge Function (15 min)
4. Deploy and test (10 min)

---

### Recommendation Tier 2: SendGrid + Domain

**Implementation Cost:** 2-3 hours (includes domain setup)
**Monthly Cost:** €20/month for 50K emails

**Advantages:**
- ✅ Enterprise-grade
- ✅ Excellent analytics
- ✅ Webhook support (bounce handling)
- ✅ Custom domain branding
- ✅ Lower per-email cost at scale

**Timeline:**
1. Sign up at SendGrid (5 min)
2. Verify domain (15 min, requires DNS change)
3. Create API key (2 min)
4. Implement integration (30 min)
5. Deploy and test (15 min)
6. Wait for domain verification (usually <1 hour)

---

### Recommendation Tier 3: AWS SES

**Implementation Cost:** 1-2 hours
**Monthly Cost:** €1-5 for your volume

**Advantages:**
- ✅ Cheapest at scale
- ✅ AWS reliability
- ✅ Good API
- ✅ Can handle very high volumes

**Disadvantages:**
- ⚠️ Sandbox mode (need to request production)
- ⚠️ More complex setup
- ⚠️ Need AWS account/knowledge

**Timeline:**
1. Create AWS account (10 min)
2. Set up SES (30 min)
3. Verify domain (15 min)
4. Request production access (5 min, automated)
5. Implement integration (20 min)
6. Deploy and test (10 min)

---

### Migration Plan (Resend Recommended)

**Step 1: Setup (Dev Environment)**
```bash
# 1. Create Resend account
# 2. Get API key
# 3. Update local Edge Function
cd /Users/eldiaploo/Desktop/Projects-2025/WiesbadenAfterDark

# 4. Edit supabase/functions/send-booking-confirmation/index.ts
# Replace Supabase auth email with Resend API call

# 5. Test locally
npm run dev  # Owner PWA
supabase functions serve  # Edge Functions
```

**Step 2: Deploy to Staging**
```bash
# Set environment variable in Supabase
supabase env set RESEND_API_KEY "re_xxxxx"

# Deploy function
supabase functions deploy send-booking-confirmation

# Test with Vercel preview
# Use test booking in staging
```

**Step 3: Monitor & Validate**
```sql
-- Check delivery success rate
SELECT
  COUNT(*) as total,
  COUNT(CASE WHEN confirmation_sent_at IS NOT NULL THEN 1 END) as sent
FROM bookings
WHERE created_at > NOW() - INTERVAL '7 days';

-- Check audit logs
SELECT action, COUNT(*)
FROM audit_logs
WHERE action LIKE 'booking_%_email_%'
  AND created_at > NOW() - INTERVAL '7 days'
GROUP BY action;
```

**Step 4: Production Deployment**
```bash
# After 48 hours of successful staging tests
# Deploy to production

supabase env set RESEND_API_KEY "re_xxxxx" --prod
supabase functions deploy send-booking-confirmation --prod

# Verify with real bookings
# Monitor for 24 hours
```

---

## Current Test Status

### Last Test: December 25, 2025

**Booking Confirmation:**
- ✅ Edge function deployed
- ✅ German templates implemented
- ✅ Accepts/rejects trigger email sending
- ✅ Audit logging functional
- ⚠️ Rate limit: 4-5 emails/hour (free tier)

**Password Reset (Auth):**
- ✅ Supabase Auth templates configured
- ✅ German templates in place
- ✅ Reset links functional
- ⚠️ Using Supabase default SMTP

**Action Items:**
1. Implement Resend for higher volume
2. Add booking reminder emails (scheduled)
3. Set up email analytics
4. Add bounce handling
5. Test with real user bookings

---

## Email Sending Flow (Current)

```
Owner PWA Booking Action
│
├─ Accept Booking
│  ├─ Update booking status → 'confirmed'
│  ├─ Call sendBookingConfirmation(id, 'accepted')
│  └─ API POST /functions/v1/send-booking-confirmation
│
├─ Reject Booking
│  ├─ Update booking status → 'cancelled'
│  ├─ Call sendBookingConfirmation(id, 'rejected')
│  └─ API POST /functions/v1/send-booking-confirmation
│
└─ Edge Function Processing
   ├─ Fetch booking + venue details
   ├─ Format German email template
   ├─ Send via Supabase Auth SMTP
   │  ├─ Success → Update confirmation_sent_at
   │  └─ Failure → Log as pending for manual retry
   └─ Create audit log entry
```

---

## Quick Reference

### Important URLs

| Service | URL |
|---------|-----|
| Supabase Auth Settings | https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli/auth/settings |
| Supabase Edge Functions | https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli/functions |
| Resend Dashboard | https://resend.com/dashboard |
| SendGrid Dashboard | https://app.sendgrid.com |
| Owner PWA (Prod) | https://owner-pwa.vercel.app |
| Owner PWA (Dev) | http://localhost:5173 |

### Test Booking SQL

```sql
-- Create test booking
INSERT INTO bookings (
  id, venue_id, guest_name, guest_email,
  guest_count, date, time, status
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM venues LIMIT 1),
  'Test Guest',
  'your-email@example.com',
  4,
  NOW() + INTERVAL '5 days',
  '19:00',
  'pending'
) RETURNING id, guest_email;

-- Check confirmation status
SELECT id, guest_name, guest_email, status, confirmation_sent_at
FROM bookings
WHERE guest_email = 'your-email@example.com'
ORDER BY created_at DESC LIMIT 1;
```

### Resend Quick Setup

```typescript
// 1. Install
import { Resend } from "npm:resend@latest";

// 2. Initialize
const resend = new Resend(Deno.env.get("RESEND_API_KEY"));

// 3. Send
const { data, error } = await resend.emails.send({
  from: "noreply@wiesbaden-after-dark.de",
  to: booking.guest_email,
  subject: subject,
  html: htmlContent,
});

// 4. Handle response
if (error) {
  console.error("Email error:", error);
  // Fallback: log for manual retry
}
```

---

## Support & Escalation

### Email Not Sending?
1. Check Supabase Edge Function logs
2. Verify booking exists in database
3. Check audit_logs for error details
4. Try different email provider
5. Contact Supabase support if SMTP issue

### Need Higher Volume?
1. Switch to Resend (100/day free → unlimited paid)
2. Or SendGrid (€20/month for 50K)
3. Or AWS SES (pay-as-you-go)

### Domain Branding?
- SendGrid or AWS SES recommended
- Requires SPF/DKIM/DMARC setup
- 30-60 minutes initial setup

---

## Version History

| Date | Changes |
|------|---------|
| 2025-12-25 | Initial guide created. Resend, Gmail, SendGrid options documented. Testing checklist added. |

---

**Next Steps:** Choose SMTP provider (Resend recommended) and implement per section above.
