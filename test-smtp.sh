#!/bin/bash

# SMTP Configuration Test Script
# WiesbadenAfterDark - Booking Emails

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📧 SMTP Configuration Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if SMTP is configured
echo "🔍 Step 1: Checking Supabase SMTP Configuration..."
echo ""
echo "Please verify manually in Supabase Dashboard:"
echo "👉 https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli/settings/auth"
echo ""
echo "✓ Custom SMTP should be ENABLED"
echo "✓ Host: smtp.resend.com"
echo "✓ Port: 465"
echo "✓ Username: resend"
echo "✓ API Key: [Your Resend API Key in password field]"
echo ""

read -p "Is SMTP configured in Supabase? (y/n): " smtp_configured

if [ "$smtp_configured" != "y" ]; then
    echo ""
    echo "⚠️  Please configure SMTP first!"
    echo "📖 Follow: SMTP_CONFIGURATION_CHECKLIST.md"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SMTP Configuration Confirmed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 1: Password Reset Email
echo "📨 Test 1: Password Reset Email"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This test will send a password reset email."
echo ""

read -p "Enter email address to test: " test_email

if [ -z "$test_email" ]; then
    echo "❌ Email address required"
    exit 1
fi

echo ""
echo "Opening Owner PWA login page..."
echo "URL: https://owner-pwa.vercel.app"
echo ""
echo "📋 Manual Steps:"
echo "1. Click 'Passwort vergessen?'"
echo "2. Enter: $test_email"
echo "3. Click 'Zurücksetzen'"
echo "4. Check your inbox (and spam folder)"
echo ""

# Open the PWA
open "https://owner-pwa.vercel.app" 2>/dev/null || echo "Open manually: https://owner-pwa.vercel.app"

echo ""
read -p "Did you receive the password reset email? (y/n): " reset_received

if [ "$reset_received" == "y" ]; then
    echo "✅ Password reset email WORKING!"
else
    echo "❌ Password reset email FAILED"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check spam folder"
    echo "2. Wait 2-3 minutes"
    echo "3. Verify SMTP settings in Supabase"
    echo "4. Check Resend dashboard: https://resend.com/emails"
    echo ""
    open "https://resend.com/emails" 2>/dev/null
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📨 Test 2: Booking Confirmation Email"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This test will send a booking confirmation email."
echo ""
echo "📋 Manual Steps:"
echo "1. Log into Owner PWA: https://owner-pwa.vercel.app"
echo "2. Navigate to Bookings page"
echo "3. Find a pending booking (or create one)"
echo "4. Click 'Bestätigen' (Confirm)"
echo "5. Check guest email"
echo ""

read -p "Ready to test booking email? (y/n): " ready_booking

if [ "$ready_booking" == "y" ]; then
    echo ""
    echo "Opening Owner PWA Bookings page..."
    open "https://owner-pwa.vercel.app" 2>/dev/null
    echo ""
    read -p "Enter guest email address: " guest_email
    echo ""
    echo "After confirming the booking, wait 30 seconds..."
    echo ""
    read -p "Did $guest_email receive the booking confirmation? (y/n): " booking_received

    if [ "$booking_received" == "y" ]; then
        echo "✅ Booking confirmation email WORKING!"
    else
        echo "❌ Booking confirmation email FAILED"
        echo ""
        echo "Troubleshooting:"
        echo "1. Check Edge Function logs in Supabase"
        echo "2. Verify send-booking-confirmation is deployed"
        echo "3. Check Resend dashboard for errors"
        echo ""
        open "https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli/functions" 2>/dev/null
    fi
else
    echo "⏭️  Skipping booking email test"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$reset_received" == "y" ]; then
    echo "✅ Password Reset: WORKING"
else
    echo "❌ Password Reset: FAILED"
fi

if [ "$booking_received" == "y" ]; then
    echo "✅ Booking Confirmation: WORKING"
elif [ "$ready_booking" != "y" ]; then
    echo "⏭️  Booking Confirmation: SKIPPED"
else
    echo "❌ Booking Confirmation: FAILED"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 Resources"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Resend Dashboard: https://resend.com/emails"
echo "Supabase SMTP: https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli/settings/auth"
echo "Edge Functions: https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli/functions"
echo "Setup Guide: SMTP_CONFIGURATION_CHECKLIST.md"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ SMTP Test Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
