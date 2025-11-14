import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

# Database connection
DATABASE_URL = "postgresql+asyncpg://postgres.exjowhbyrdjnhmkmkvmf:LOLEalmasri998%21@aws-0-eu-central-1.pooler.supabase.com:6543/postgres"

async def delete_user(phone_number: str):
    engine = create_async_engine(DATABASE_URL)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    
    async with async_session() as session:
        # Find user
        result = await session.execute(
            text("SELECT id, phone_number, first_name FROM users WHERE phone_number = :phone"),
            {"phone": phone_number}
        )
        user = result.first()
        
        if user:
            print(f"Found user: {user.first_name} ({user.phone_number})")
            print(f"User ID: {user.id}")
            
            # Delete user
            await session.execute(
                text("DELETE FROM users WHERE phone_number = :phone"),
                {"phone": phone_number}
            )
            await session.commit()
            
            print(f"✅ Deleted user: {phone_number}")
            print("You can now register again!")
        else:
            print(f"❌ No user found with phone: {phone_number}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        phone = input("Enter phone number (e.g., +4915234567890): ")
    else:
        phone = sys.argv[1]
    
    asyncio.run(delete_user(phone))
