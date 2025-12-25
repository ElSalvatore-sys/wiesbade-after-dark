# Email System Quick Reference
### WiesbadenAfterDark

---

## Current Status

✅ **Active** - Booking confirmations working
⏳ **Rate Limited** - 4-5 emails/hour (free tier)
🔧 **Recommended** - Switch to Resend before production

---

## What's Working

- Booking accepted/rejected emails (German)
- Password reset emails (German)
- Email confirmation (German)
- Audit logging of all emails
- Error handling with fallback

---

## Quick Test

```bash
# 1. Start PWA
cd owner-pwa && npm run dev

# 2. Create booking with your email
# Go to http://localhost:5173

# 3. Click Accept
# Wait 1-2 minutes for email

# 4. Check inbox (and spam folder)
```

---

## Email Types

| Type | When | Template | Status |
|------|------|----------|--------|
| Booking Accept | Owner accepts booking | German ✅ | Working |
| Booking Reject | Owner rejects booking | German ✅ | Working |
| Password Reset | User clicks forgot pwd | German ✅ | Working |
| Email Confirm | User creates account | German ✅ | Working |
| Reminder | Daily 10am (not yet) | German ⏳ | Planned |

---

## Key Files

```
Edge Function:
  /supabase/functions/send-booking-confirmation/index.ts

PWA Integration:
  /owner-pwa/src/services/supabaseApi.ts
  /owner-pwa/src/pages/Bookings.tsx

Database:
  bookings.confirmation_sent_at
  audit_logs (email history)

Documentation:
  SMTP_SETUP_GUIDE.md (complete setup)
  EMAIL_SYSTEM_STATUS_REPORT.md (status)
  SUPABASE_EMAIL_TEMPLATES.md (templates)
```

---

## Resend Setup (30 Minutes)

1. Go to https://resend.com
2. Sign up
3. Copy API key
4. Set in Supabase: `RESEND_API_KEY`
5. Update Edge Function (4 lines of code)
6. Deploy: `supabase functions deploy send-booking-confirmation`
7. Test

See **SMTP_SETUP_GUIDE.md** for full instructions.

---

## Rate Limits

| Provider | Free Tier | Cost |
|----------|-----------|------|
| Supabase (Current) | 4-5/hour | Free |
| Resend (Recommended) | 100/day | Free |
| SendGrid | 100/day | $20/mo |
| AWS SES | 200/day | Pay-as-go |

---

## Troubleshooting

| Problem | Check |
|---------|-------|
| Email not arriving | Inbox spam folder, audit_logs table, Edge Function logs |
| Rate limit hit | Wait 1 hour or switch to Resend |
| Email in spam | SPF/DKIM setup (use Resend) |
| Function error | Supabase Dashboard → Edge Functions → Logs |
| Booking not found | Verify booking_id exists in database |

---

## Monitoring

```sql
-- Check sent emails
SELECT COUNT(*) FROM audit_logs
WHERE action LIKE 'booking_%_email_sent'
  AND created_at > NOW() - INTERVAL '24 hours';

-- Check failed emails
SELECT COUNT(*) FROM audit_logs
WHERE action LIKE 'booking_%_email_pending'
  AND created_at > NOW() - INTERVAL '24 hours';

-- Check booking tracking
SELECT confirmation_sent_at
FROM bookings
WHERE id = 'your-booking-id';
```

---

## Before Production

- [ ] Test with 10+ bookings
- [ ] Verify email delivery
- [ ] Check spam folder
- [ ] Upgrade to Resend
- [ ] Set up monitoring
- [ ] Document results

---

## Documentation Map

```
START HERE:
├─ EMAIL_QUICK_REFERENCE.md (this file)
│
DETAILED INFO:
├─ SMTP_SETUP_GUIDE.md (all providers + testing)
├─ EMAIL_SYSTEM_STATUS_REPORT.md (status + roadmap)
├─ SUPABASE_EMAIL_TEMPLATES.md (existing templates)
├─ BOOKING_CONFIRMATION_EMAILS.md (implementation)
│
TESTING:
└─ TEST_CURRENT_EMAIL_SETUP.sh (automated check)
```

---

## Support

1. **Can't receive emails?** → Check spam, then troubleshooting section
2. **Rate limit?** → Switch to Resend (free, 100/day)
3. **Want analytics?** → Use Resend (includes tracking)
4. **Need customization?** → See advanced section in SMTP_SETUP_GUIDE.md

---

## Next Action

Choose one:

**Development/Testing:**
- Read SMTP_SETUP_GUIDE.md
- Test current system
- Proceed to production setup

**Production Migration:**
- Set up Resend account
- Update Edge Function
- Deploy and test
- Monitor first 48 hours

---

**Last Updated:** December 25, 2025
**Status:** Ready for Use
