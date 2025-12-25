# Booking Confirmation Email System

**Created:** December 25, 2025
**Status:** Implemented (Edge Function + PWA Integration)

---

## Overview

Automated email system that sends confirmation/rejection emails to guests when their booking status changes in the Owner PWA.

## Architecture

### Components

1. **Edge Function** (`supabase/functions/send-booking-confirmation/index.ts`)
   - Deno runtime on Supabase Edge Functions
   - Fetches booking details from database
   - Formats German email templates
   - Sends via Supabase Auth SMTP
   - Logs to audit trail

2. **API Integration** (`owner-pwa/src/services/supabaseApi.ts`)
   - `sendBookingConfirmation(bookingId, action)` function
   - Calls Edge Function via HTTP POST
   - Handles errors gracefully

3. **UI Integration** (`owner-pwa/src/pages/Bookings.tsx`)
   - Triggers on Accept/Reject booking actions
   - Non-blocking (continues even if email fails)
   - Silent background operation

---

## Email Types

### 1. Accepted Booking
**Trigger:** Owner clicks "Accept" on booking request

**Template:**
- Subject: `Reservierung bestätigt - {Venue Name}`
- Content:
  - Confirmation header with checkmark
  - Date, time, guest count, table number
  - Special requests (if any)
  - Professional German footer

**Example:**
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

### 2. Rejected Booking
**Trigger:** Owner clicks "Reject" on booking request

**Template:**
- Subject: `Reservierungsanfrage - {Venue Name}`
- Content:
  - Polite rejection message
  - Invitation to contact for alternatives
  - Professional tone

### 3. Reminder (Future)
**Trigger:** Scheduled job (not yet implemented)

**Template:**
- Subject: `Erinnerung: Ihre Reservierung heute - {Venue Name}`
- Content:
  - Reminder for today's booking
  - Time and guest count
  - Simple, friendly tone

---

## Edge Function Details

### Endpoint
```
POST {SUPABASE_URL}/functions/v1/send-booking-confirmation
```

### Request Body
```typescript
{
  booking_id: string,
  action: 'accepted' | 'rejected' | 'reminder'
}
```

### Response
```typescript
{
  success: boolean,
  message?: string,
  booking_id?: string,
  guest_email?: string,  // If logged for manual follow-up
  error?: string
}
```

### Environment Variables Required
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_SERVICE_ROLE_KEY` - Service role key (admin access)

### Database Access
- **Read:** `bookings` table with `venues` join
- **Write:** `audit_logs` table
- **Update:** `bookings.confirmation_sent_at` timestamp

---

## Implementation Flow

### Accept Booking
1. User clicks "Accept" on booking in Owner PWA
2. `handleAccept()` updates booking status to 'confirmed'
3. Calls `sendBookingConfirmation(bookingId, 'accepted')`
4. Edge Function:
   - Fetches booking details
   - Formats German email template
   - Sends via Supabase Auth SMTP
   - Updates `confirmation_sent_at` timestamp
   - Logs to audit trail
5. PWA refreshes booking list
6. Guest receives confirmation email

### Reject Booking
1. User clicks "Reject" on booking in Owner PWA
2. `handleReject()` updates booking status to 'cancelled'
3. Calls `sendBookingConfirmation(bookingId, 'rejected')`
4. Edge Function sends rejection email
5. PWA refreshes booking list
6. Guest receives rejection email

---

## Error Handling

### Edge Function Fallback
If `supabase.auth.admin.sendRawEmail()` fails:
- Logs booking details to `audit_logs` table
- Marks action as `booking_{action}_email_pending`
- Returns success with manual follow-up flag
- Owner can manually send email using logged data

### PWA Error Handling
```typescript
const emailResult = await sendBookingConfirmation(booking.id, 'accepted');

if (!emailResult.success) {
  console.warn('Email sending failed:', emailResult.error);
  // Don't block booking confirmation - continue silently
}
```

**Philosophy:** Email sending should never block the core booking workflow. Bookings are confirmed/rejected regardless of email status.

---

## Database Schema Additions

### `bookings` Table
```sql
ALTER TABLE bookings
ADD COLUMN confirmation_sent_at TIMESTAMPTZ;
```

### `audit_logs` Table
Uses existing structure:
```typescript
{
  venue_id: string,
  action: 'booking_accepted_email_sent' | 'booking_rejected_email_sent' | 'booking_reminder_email_sent',
  entity_type: 'booking',
  entity_id: booking_id,
  details: {
    guest_email: string,
    subject: string,
    guest_name?: string,
    date?: string,
    time?: string
  }
}
```

---

## Deployment

### Deploy Edge Function
```bash
cd ~/Desktop/Projects-2025/WiesbadenAfterDark
supabase functions deploy send-booking-confirmation
```

### Environment Setup
Set in Supabase Dashboard → Edge Functions → Environment Variables:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

### PWA Deployment
```bash
cd owner-pwa
npm run build
vercel --prod
```

---

## Testing

### Manual Testing (Development)
1. Open Owner PWA locally
2. Create a test booking with your email
3. Click "Accept" or "Reject"
4. Check:
   - Console for API call
   - Email inbox (within 1-2 minutes)
   - Supabase audit_logs table
   - bookings.confirmation_sent_at timestamp

### Test Edge Function Directly
```bash
curl -X POST \
  https://{PROJECT_REF}.supabase.co/functions/v1/send-booking-confirmation \
  -H "Authorization: Bearer {ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"booking_id": "test-booking-id", "action": "accepted"}'
```

### Verify in Supabase
```sql
-- Check audit logs
SELECT * FROM audit_logs
WHERE action LIKE 'booking_%_email_%'
ORDER BY created_at DESC
LIMIT 10;

-- Check confirmation timestamps
SELECT id, guest_name, guest_email, status, confirmation_sent_at
FROM bookings
WHERE confirmation_sent_at IS NOT NULL
ORDER BY confirmation_sent_at DESC
LIMIT 10;
```

---

## Future Enhancements

### 1. Reminder Emails (Not Yet Implemented)
**Trigger:** Scheduled job (cron) runs daily at 10:00 AM

**Logic:**
```typescript
// Pseudo-code
const today = new Date();
const bookingsToday = await supabase
  .from('bookings')
  .select('*')
  .eq('date', today.toISOString().split('T')[0])
  .eq('status', 'confirmed')
  .is('reminder_sent_at', null);

for (const booking of bookingsToday) {
  await sendBookingConfirmation(booking.id, 'reminder');
}
```

**Implementation Options:**
- Supabase Cron Jobs (pg_cron extension)
- External scheduler (GitHub Actions, Railway Cron, Vercel Cron)
- Manual trigger from Owner PWA

### 2. Custom Email Service Integration
Replace `supabase.auth.admin.sendRawEmail()` with:
- **Resend** (recommended) - Modern API, generous free tier
- **SendGrid** - Reliable, widely used
- **Mailgun** - Good deliverability
- **Amazon SES** - Cost-effective for volume

**Benefits:**
- Better deliverability rates
- Email analytics (open rates, clicks)
- Transactional email templates
- No rate limits

### 3. Email Templates in Database
Store email templates in Supabase table:
```sql
CREATE TABLE email_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_type TEXT NOT NULL, -- 'booking_accepted', 'booking_rejected', etc.
  language TEXT DEFAULT 'de',
  subject TEXT NOT NULL,
  html_template TEXT NOT NULL,
  variables JSONB, -- List of available template variables
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Benefits:**
- Venue owners can customize email content
- A/B testing different templates
- Multi-language support
- No code deployment for template changes

### 4. Email Preferences
Allow guests to opt-in/out:
```sql
ALTER TABLE bookings
ADD COLUMN send_confirmation_email BOOLEAN DEFAULT TRUE;
```

### 5. SMS Integration
For higher open rates:
- Twilio for SMS
- Trigger on same events as email
- "Ihre Reservierung wurde bestätigt: {date} {time}"

---

## Known Limitations

1. **Email Delivery Time:** 1-5 minutes depending on Supabase SMTP queue
2. **Rate Limits:** Supabase free tier has email sending limits
3. **Spam Filters:** Emails may go to spam without proper SPF/DKIM setup
4. **No Retry Logic:** Failed emails are logged but not automatically retried
5. **No Delivery Confirmation:** Can't confirm if guest received/opened email

---

## Configuration Requirements

### Supabase Email Settings
**Dashboard:** Project Settings → Auth → Email Templates

1. **SMTP Configuration** (if using custom SMTP):
   - Host, port, username, password
   - TLS/SSL settings

2. **Email Templates:**
   - Customize default templates or use custom HTML
   - Set sender name and email

3. **Rate Limits:**
   - Free tier: Limited emails per hour
   - Paid tier: Higher limits or custom SMTP

### Environment Variables (.env)
```bash
VITE_SUPABASE_URL=https://yyplbhrqtaeyzmcxpfli.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

---

## Files Modified/Created

### Created:
- `supabase/functions/send-booking-confirmation/index.ts` - Edge Function

### Modified:
- `owner-pwa/src/services/supabaseApi.ts` - Added `sendBookingConfirmation()` function
- `owner-pwa/src/pages/Bookings.tsx` - Integrated email sending in Accept/Reject handlers

---

## Maintenance

### Monitor Email Delivery
```sql
-- Check email sending success rate
SELECT
  action,
  COUNT(*) as total,
  COUNT(CASE WHEN action LIKE '%_sent' THEN 1 END) as sent,
  COUNT(CASE WHEN action LIKE '%_pending' THEN 1 END) as pending
FROM audit_logs
WHERE action LIKE 'booking_%_email_%'
GROUP BY action;
```

### Failed Emails
```sql
-- Find bookings with pending emails
SELECT
  b.id,
  b.guest_name,
  b.guest_email,
  b.date,
  b.status,
  al.details
FROM bookings b
JOIN audit_logs al ON al.entity_id = b.id
WHERE al.action LIKE 'booking_%_email_pending'
ORDER BY b.date DESC;
```

### Resend Failed Emails
Manually trigger from Edge Function or create admin UI button:
```typescript
// Admin action to resend
await sendBookingConfirmation(booking_id, 'accepted');
```

---

## Support

For issues with email delivery:
1. Check Supabase Dashboard → Edge Functions → Logs
2. Check audit_logs table for email status
3. Verify SMTP configuration in Supabase Auth settings
4. Test with different email providers (Gmail, Outlook, etc.)

---

**Status:** ✅ Ready for testing
**Next Step:** Deploy Edge Function and test with real bookings
