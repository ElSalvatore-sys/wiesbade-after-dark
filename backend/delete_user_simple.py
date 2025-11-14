import psycopg2
from urllib.parse import quote_plus

# Supabase connection details
password = quote_plus("LOLEalmasri998!")
DATABASE_URL = f"postgresql://postgres.exjowhbyrdjnhmkmkvmf:{password}@aws-0-eu-central-1.pooler.supabase.com:6543/postgres"

phone_number = "+4917663062016"

try:
    # Connect to database
    conn = psycopg2.connect(DATABASE_URL)
    cursor = conn.cursor()
    
    # Find user
    cursor.execute("SELECT id, phone_number, first_name FROM users WHERE phone_number = %s", (phone_number,))
    user = cursor.fetchone()
    
    if user:
        user_id, phone, first_name = user
        print(f"Found user: {first_name or 'Unknown'} ({phone})")
        print(f"User ID: {user_id}")
        
        # Delete user
        cursor.execute("DELETE FROM users WHERE phone_number = %s", (phone_number,))
        conn.commit()
        
        print(f"✅ Deleted user: {phone_number}")
        print("You can now register again!")
    else:
        print(f"❌ No user found with phone: {phone_number}")
    
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"Error: {e}")
