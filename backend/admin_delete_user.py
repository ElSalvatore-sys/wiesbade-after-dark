"""
Admin script to delete a user from the database.
Uses the app's own database configuration.
"""
import sys
import os

# Add app directory to path
sys.path.insert(0, os.path.dirname(__file__))

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# Use synchronous engine for simplicity
DATABASE_URL = "postgresql://postgres.exjowhbyrdjnhmkmkvmf:LOLEalmasri998!@aws-0-eu-central-1.pooler.supabase.com:6543/postgres"

phone_number = "+4917663062016"

try:
    # Create engine
    engine = create_engine(DATABASE_URL)
    Session = sessionmaker(bind=engine)
    session = Session()
    
    # Find user
    result = session.execute(
        text("SELECT id, phone_number, first_name FROM users WHERE phone_number = :phone"),
        {"phone": phone_number}
    )
    user = result.first()
    
    if user:
        print(f"Found user: {user.first_name or 'Unknown'} ({user.phone_number})")
        print(f"User ID: {user.id}")
        
        # Delete user
        session.execute(
            text("DELETE FROM users WHERE phone_number = :phone"),
            {"phone": phone_number}
        )
        session.commit()
        
        print(f"✅ Deleted user: {phone_number}")
        print("You can now register again!")
    else:
        print(f"❌ No user found with phone: {phone_number}")
    
    session.close()
    
except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
