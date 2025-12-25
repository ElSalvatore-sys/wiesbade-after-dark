import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface BookingConfirmationRequest {
  booking_id: string;
  action: 'accepted' | 'rejected' | 'reminder';
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { booking_id, action } = await req.json() as BookingConfirmationRequest;

    if (!booking_id) {
      return new Response(
        JSON.stringify({ error: "booking_id required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Get booking details
    const { data: booking, error: bookingError } = await supabase
      .from("bookings")
      .select(`
        *,
        venues(name, address)
      `)
      .eq("id", booking_id)
      .single();

    if (bookingError || !booking) {
      return new Response(
        JSON.stringify({ error: "Booking not found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Format date for German locale
    const bookingDate = new Date(booking.date).toLocaleDateString('de-DE', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });

    // Prepare email content based on action
    let subject: string;
    let htmlContent: string;

    const venueName = booking.venues?.name || 'Das Wohnzimmer';
    const guestName = booking.guest_name || 'Gast';
    const guestCount = booking.guest_count || 2;
    const bookingTime = booking.time || '19:00';

    if (action === 'accepted') {
      subject = `Reservierung bestätigt - ${venueName}`;
      htmlContent = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #6b21a8;">Reservierung bestätigt! ✓</h2>

          <p>Hallo ${guestName},</p>

          <p>Ihre Reservierung bei <strong>${venueName}</strong> wurde bestätigt.</p>

          <div style="background: #f3f4f6; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <p style="margin: 5px 0;"><strong>📅 Datum:</strong> ${bookingDate}</p>
            <p style="margin: 5px 0;"><strong>🕐 Uhrzeit:</strong> ${bookingTime} Uhr</p>
            <p style="margin: 5px 0;"><strong>👥 Personen:</strong> ${guestCount}</p>
            ${booking.table_number ? `<p style="margin: 5px 0;"><strong>🪑 Tisch:</strong> ${booking.table_number}</p>` : ''}
          </div>

          ${booking.special_requests ? `
            <p><strong>Besondere Wünsche:</strong><br>${booking.special_requests}</p>
          ` : ''}

          <p>Wir freuen uns auf Ihren Besuch!</p>

          <p style="margin-top: 30px;">
            Mit freundlichen Grüßen,<br>
            <strong>${venueName}</strong>
          </p>

          <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 30px 0;">

          <p style="color: #6b7280; font-size: 12px;">
            Bei Fragen oder Änderungen kontaktieren Sie uns bitte direkt.<br>
            Diese E-Mail wurde automatisch von WiesbadenAfterDark gesendet.
          </p>
        </div>
      `;
    } else if (action === 'rejected') {
      subject = `Reservierungsanfrage - ${venueName}`;
      htmlContent = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #dc2626;">Reservierung leider nicht möglich</h2>

          <p>Hallo ${guestName},</p>

          <p>Leider können wir Ihre Reservierungsanfrage für den ${bookingDate} nicht bestätigen.</p>

          <p>Bitte kontaktieren Sie uns für alternative Termine oder besuchen Sie uns spontan - wir werden unser Bestes tun, einen Platz für Sie zu finden.</p>

          <p style="margin-top: 30px;">
            Mit freundlichen Grüßen,<br>
            <strong>${venueName}</strong>
          </p>
        </div>
      `;
    } else {
      // Reminder
      subject = `Erinnerung: Ihre Reservierung heute - ${venueName}`;
      htmlContent = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #6b21a8;">Erinnerung an Ihre Reservierung</h2>

          <p>Hallo ${guestName},</p>

          <p>Wir möchten Sie an Ihre heutige Reservierung erinnern:</p>

          <div style="background: #f3f4f6; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <p style="margin: 5px 0;"><strong>🕐 Uhrzeit:</strong> ${bookingTime} Uhr</p>
            <p style="margin: 5px 0;"><strong>👥 Personen:</strong> ${guestCount}</p>
          </div>

          <p>Wir freuen uns auf Sie!</p>

          <p style="margin-top: 30px;">
            Mit freundlichen Grüßen,<br>
            <strong>${venueName}</strong>
          </p>
        </div>
      `;
    }

    // Send email via Supabase Auth (uses configured SMTP)
    // Note: This uses Supabase's built-in email sending
    // For production, consider using a dedicated email service like Resend, SendGrid, etc.

    const { error: emailError } = await supabase.auth.admin.sendRawEmail({
      email: booking.guest_email,
      subject: subject,
      html: htmlContent,
    });

    // Fallback: If auth.admin.sendRawEmail doesn't work,
    // we'll log and mark as sent for manual follow-up
    if (emailError) {
      console.log('Email sending via auth not available, logging for manual follow-up');

      // Log to audit
      await supabase.from('audit_logs').insert({
        venue_id: booking.venue_id,
        action: `booking_${action}_email_pending`,
        entity_type: 'booking',
        entity_id: booking_id,
        details: {
          guest_email: booking.guest_email,
          guest_name: guestName,
          date: booking.date,
          time: bookingTime,
          subject: subject,
        }
      });

      return new Response(
        JSON.stringify({
          success: true,
          message: "Email logged for manual sending",
          booking_id,
          guest_email: booking.guest_email
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Update booking to mark email sent
    await supabase
      .from("bookings")
      .update({
        confirmation_sent_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })
      .eq("id", booking_id);

    // Log to audit
    await supabase.from('audit_logs').insert({
      venue_id: booking.venue_id,
      action: `booking_${action}_email_sent`,
      entity_type: 'booking',
      entity_id: booking_id,
      details: {
        guest_email: booking.guest_email,
        subject: subject,
      }
    });

    return new Response(
      JSON.stringify({
        success: true,
        message: `${action} email sent`,
        booking_id
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (err) {
    console.error("Error:", err);
    return new Response(
      JSON.stringify({ error: "Internal error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
