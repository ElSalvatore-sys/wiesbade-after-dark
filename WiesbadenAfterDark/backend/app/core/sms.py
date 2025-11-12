"""
SMS service using Twilio for sending verification codes.
"""

import logging
import secrets
from datetime import datetime, timedelta
from typing import Optional

from twilio.rest import Client
from twilio.base.exceptions import TwilioRestException

from app.core.config import settings

logger = logging.getLogger(__name__)


class SMSService:
    """Service for sending SMS messages via Twilio."""

    def __init__(self):
        """Initialize Twilio client."""
        self.client: Optional[Client] = None
        if settings.TWILIO_ACCOUNT_SID and settings.TWILIO_AUTH_TOKEN:
            try:
                self.client = Client(
                    settings.TWILIO_ACCOUNT_SID,
                    settings.TWILIO_AUTH_TOKEN
                )
                logger.info("Twilio SMS service initialized successfully")
            except Exception as e:
                logger.error(f"Failed to initialize Twilio client: {e}")
        else:
            logger.warning("Twilio credentials not configured - SMS will not be sent")

    def generate_verification_code(self) -> str:
        """
        Generate a 6-digit verification code.

        Returns:
            str: 6-digit verification code
        """
        # Generate cryptographically secure random 6-digit code
        return str(secrets.randbelow(1000000)).zfill(6)

    async def send_verification_code(
        self,
        phone_number: str,
        code: str
    ) -> bool:
        """
        Send verification code via SMS.

        Args:
            phone_number: Phone number in E.164 format (e.g., +4917012345678)
            code: 6-digit verification code

        Returns:
            bool: True if sent successfully, False otherwise
        """
        if not self.client:
            logger.warning(f"SMS not sent to {phone_number} - Twilio not configured")
            # In development, just log the code
            logger.info(f"🔐 VERIFICATION CODE for {phone_number}: {code}")
            return True

        try:
            message = self.client.messages.create(
                body=f"Wiesbaden After Dark\n\nYour verification code is: {code}\n\nValid for 5 minutes.",
                from_=settings.TWILIO_PHONE_NUMBER,
                to=phone_number
            )

            logger.info(f"SMS sent successfully to {phone_number} - SID: {message.sid}")
            return True

        except TwilioRestException as e:
            logger.error(f"Twilio error sending SMS to {phone_number}: {e}")
            return False
        except Exception as e:
            logger.error(f"Unexpected error sending SMS to {phone_number}: {e}")
            return False

    async def send_welcome_message(
        self,
        phone_number: str,
        referral_code: str,
        name: Optional[str] = None
    ) -> bool:
        """
        Send welcome message to new user.

        Args:
            phone_number: Phone number in E.164 format
            referral_code: User's unique referral code
            name: Optional user name

        Returns:
            bool: True if sent successfully, False otherwise
        """
        if not self.client:
            logger.warning(f"Welcome SMS not sent to {phone_number} - Twilio not configured")
            return True

        try:
            message = self.client.messages.create(
                body=f"Welcome to Wiesbaden After Dark! 🎉\n\nYour referral code: {referral_code}\n\nShare with friends to earn points!",
                from_=settings.TWILIO_PHONE_NUMBER,
                to=phone_number
            )

            logger.info(f"Welcome SMS sent to {phone_number} - SID: {message.sid}")
            return True

        except TwilioRestException as e:
            logger.error(f"Twilio error sending welcome SMS to {phone_number}: {e}")
            return False
        except Exception as e:
            logger.error(f"Unexpected error sending welcome SMS to {phone_number}: {e}")
            return False


# Global SMS service instance
sms_service = SMSService()
