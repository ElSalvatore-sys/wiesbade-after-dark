import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Simple hash function for PIN (in production, use bcrypt)
async function hashPin(pin: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(pin + "wad_salt_2024");
  const hashBuffer = await crypto.subtle.digest("SHA-256", data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, "0")).join("");
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { employee_id, pin } = await req.json();

    if (!employee_id || !pin) {
      return new Response(
        JSON.stringify({ error: "employee_id and pin required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Validate PIN format (4 digits)
    if (!/^\d{4}$/.test(pin)) {
      return new Response(
        JSON.stringify({ error: "PIN must be 4 digits", valid: false }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Get employee's stored PIN hash
    const { data: employee, error } = await supabase
      .from("employees")
      .select("id, name, pin_hash, role, is_active")
      .eq("id", employee_id)
      .single();

    if (error || !employee) {
      return new Response(
        JSON.stringify({ error: "Employee not found", valid: false }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (!employee.is_active) {
      return new Response(
        JSON.stringify({ error: "Employee is inactive", valid: false }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Hash the provided PIN and compare
    const providedHash = await hashPin(pin);
    const storedHash = employee.pin_hash;

    // Check if stored hash is already hashed (64 chars) or plain (4 chars)
    let isValid = false;
    if (storedHash.length === 64) {
      // Already hashed, compare hashes
      isValid = providedHash === storedHash;
    } else {
      // Plain text PIN (legacy), compare directly then update to hash
      isValid = pin === storedHash;
      
      if (isValid) {
        // Upgrade to hashed PIN
        await supabase
          .from("employees")
          .update({ pin_hash: providedHash })
          .eq("id", employee_id);
      }
    }

    if (!isValid) {
      // Log failed attempt (optional security feature)
      console.log(`Failed PIN attempt for employee ${employee_id}`);
      
      return new Response(
        JSON.stringify({ error: "Invalid PIN", valid: false }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Success - return employee info (without PIN hash)
    return new Response(
      JSON.stringify({
        valid: true,
        employee: {
          id: employee.id,
          name: employee.name,
          role: employee.role,
        }
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (err) {
    console.error("Error:", err);
    return new Response(
      JSON.stringify({ error: "Internal error", valid: false }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
