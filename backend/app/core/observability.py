"""
LangFuse Observability Integration for WiesbadenAfterDark API

This module provides comprehensive observability for the FastAPI backend using LangFuse.
It tracks all API requests, database operations, and business logic execution.
"""
import os
import functools
import asyncio
from datetime import datetime
from typing import Optional, Any, Dict, Callable
from contextlib import asynccontextmanager

from langfuse import Langfuse
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware


class LangfuseClient:
    """Singleton wrapper for LangFuse client"""

    _instance: Optional[Langfuse] = None
    _enabled: bool = False

    @classmethod
    def initialize(cls, public_key: str = None, secret_key: str = None, host: str = None) -> None:
        """Initialize LangFuse client from provided credentials or environment variables"""
        # Allow passing credentials directly (from Settings) or fall back to os.getenv
        public_key = public_key or os.getenv("LANGFUSE_PUBLIC_KEY")
        secret_key = secret_key or os.getenv("LANGFUSE_SECRET_KEY")
        host = host or os.getenv("LANGFUSE_HOST", "http://localhost:3100")

        if public_key and secret_key:
            try:
                cls._instance = Langfuse(
                    public_key=public_key,
                    secret_key=secret_key,
                    host=host,
                    debug=False,
                )
                cls._enabled = True
                print(f"✅ LangFuse initialized: {host}")
            except Exception as e:
                print(f"⚠️  LangFuse initialization failed: {e}")
                cls._enabled = False
        else:
            print("⚠️  LangFuse credentials not found - observability disabled")
            cls._enabled = False

    @classmethod
    def get_client(cls) -> Optional[Langfuse]:
        """Get the LangFuse client instance"""
        if cls._instance is None:
            cls.initialize()
        return cls._instance

    @classmethod
    def is_enabled(cls) -> bool:
        """Check if LangFuse is enabled"""
        return cls._enabled

    @classmethod
    def shutdown(cls) -> None:
        """Flush and shutdown LangFuse client"""
        if cls._instance:
            try:
                cls._instance.flush()
                print("✅ LangFuse flushed successfully")
            except Exception as e:
                print(f"⚠️  LangFuse flush failed: {e}")


class LangfuseMiddleware(BaseHTTPMiddleware):
    """
    FastAPI middleware to automatically trace all HTTP requests

    Creates a trace for each incoming request with:
    - Request metadata (method, path, headers, query params)
    - Response metadata (status code, headers)
    - Execution time
    - User context (if authenticated)
    """

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        """Process request and create LangFuse event"""

        if not LangfuseClient.is_enabled():
            return await call_next(request)

        # Extract request metadata
        event_name = f"{request.method} {request.url.path}"
        metadata = {
            "method": request.method,
            "path": request.url.path,
            "query_params": dict(request.query_params),
            "client_host": request.client.host if request.client else None,
            "user_agent": request.headers.get("user-agent"),
        }

        # Extract user context from auth header if present
        user_id = None
        auth_header = request.headers.get("authorization")
        if auth_header and auth_header.startswith("Bearer "):
            user_id = "authenticated_user"

        # Execute request and measure time
        start_time = datetime.utcnow()
        status_code = None
        error_message = None

        try:
            response = await call_next(request)
            status_code = response.status_code

            # Add response metadata
            metadata["duration_ms"] = (datetime.utcnow() - start_time).total_seconds() * 1000
            metadata["status_code"] = status_code
            if user_id:
                metadata["user_id"] = user_id

            # Create LangFuse event after successful response
            client = LangfuseClient.get_client()
            if client:
                try:
                    client.create_event(
                        name=event_name,
                        metadata=metadata,
                        level="DEFAULT" if status_code < 400 else "WARNING",
                    )
                except Exception as e:
                    print(f"⚠️  LangFuse event creation failed: {e}")

            return response

        except Exception as e:
            error_message = str(e)
            metadata["duration_ms"] = (datetime.utcnow() - start_time).total_seconds() * 1000
            metadata["error"] = error_message
            if user_id:
                metadata["user_id"] = user_id

            # Create LangFuse event for error
            client = LangfuseClient.get_client()
            if client:
                try:
                    client.create_event(
                        name=event_name,
                        metadata=metadata,
                        level="ERROR",
                    )
                except Exception as log_error:
                    print(f"⚠️  LangFuse error event creation failed: {log_error}")

            raise


def observe_operation(
    name: Optional[str] = None,
    capture_input: bool = True,
    capture_output: bool = True,
    metadata: Optional[Dict[str, Any]] = None,
):
    """
    Decorator to observe function/method execution with LangFuse

    Usage:
        @observe_operation(name="create_user", metadata={"service": "auth"})
        async def create_user(data: UserCreate):
            ...

    Args:
        name: Custom name for the observation (defaults to function name)
        capture_input: Whether to capture function arguments
        capture_output: Whether to capture function return value
        metadata: Additional metadata to attach to the observation
    """
    def decorator(func: Callable) -> Callable:
        operation_name = name or func.__name__

        @functools.wraps(func)
        async def async_wrapper(*args, **kwargs):
            if not LangfuseClient.is_enabled():
                return await func(*args, **kwargs)

            client = LangfuseClient.get_client()

            # Capture input if enabled
            input_data = None
            if capture_input:
                input_data = {
                    "args": str(args)[:500],  # Truncate to avoid huge payloads
                    "kwargs": {k: str(v)[:500] for k, v in kwargs.items()},
                }

            # Create observation metadata
            observation_metadata = metadata or {}
            observation_metadata["function"] = func.__name__
            observation_metadata["module"] = func.__module__

            # Track execution
            start_time = datetime.utcnow()

            try:
                result = await func(*args, **kwargs)
                duration_ms = (datetime.utcnow() - start_time).total_seconds() * 1000

                # Capture output if enabled
                output_data = None
                if capture_output:
                    output_data = str(result)[:500] if result else None

                # Log successful execution as event
                observation_metadata["duration_ms"] = duration_ms
                observation_metadata["status"] = "success"

                try:
                    client.create_event(
                        name=operation_name,
                        metadata={**observation_metadata, "output": output_data} if output_data else observation_metadata,
                        level="DEFAULT",
                    )
                except Exception:
                    pass  # Silently fail logging

                return result

            except Exception as e:
                duration_ms = (datetime.utcnow() - start_time).total_seconds() * 1000
                observation_metadata["duration_ms"] = duration_ms
                observation_metadata["error"] = str(e)
                observation_metadata["status"] = "error"

                try:
                    client.create_event(
                        name=operation_name,
                        metadata=observation_metadata,
                        level="ERROR",
                    )
                except Exception:
                    pass  # Silently fail logging

                raise

        @functools.wraps(func)
        def sync_wrapper(*args, **kwargs):
            if not LangfuseClient.is_enabled():
                return func(*args, **kwargs)

            client = LangfuseClient.get_client()

            # Capture input if enabled
            input_data = None
            if capture_input:
                input_data = {
                    "args": str(args)[:500],
                    "kwargs": {k: str(v)[:500] for k, v in kwargs.items()},
                }

            # Create observation metadata
            observation_metadata = metadata or {}
            observation_metadata["function"] = func.__name__
            observation_metadata["module"] = func.__module__

            # Track execution
            start_time = datetime.utcnow()

            try:
                result = func(*args, **kwargs)
                duration_ms = (datetime.utcnow() - start_time).total_seconds() * 1000

                # Capture output if enabled
                output_data = None
                if capture_output:
                    output_data = str(result)[:500] if result else None

                # Log successful execution as event
                observation_metadata["duration_ms"] = duration_ms
                observation_metadata["status"] = "success"

                try:
                    client.create_event(
                        name=operation_name,
                        metadata={**observation_metadata, "output": output_data} if output_data else observation_metadata,
                        level="DEFAULT",
                    )
                except Exception:
                    pass  # Silently fail logging

                return result

            except Exception as e:
                duration_ms = (datetime.utcnow() - start_time).total_seconds() * 1000
                observation_metadata["duration_ms"] = duration_ms
                observation_metadata["error"] = str(e)
                observation_metadata["status"] = "error"

                try:
                    client.create_event(
                        name=operation_name,
                        metadata=observation_metadata,
                        level="ERROR",
                    )
                except Exception:
                    pass  # Silently fail logging

                raise

        # Return appropriate wrapper based on function type
        if asyncio.iscoroutinefunction(func):
            return async_wrapper
        else:
            return sync_wrapper

    return decorator


# Convenience decorators for common operations
def observe_api(name: Optional[str] = None):
    """Observe API endpoint execution"""
    return observe_operation(name=name, metadata={"type": "api_endpoint"})


def observe_service(name: Optional[str] = None):
    """Observe service layer execution"""
    return observe_operation(name=name, metadata={"type": "service"})


def observe_db(name: Optional[str] = None):
    """Observe database operation execution"""
    return observe_operation(name=name, metadata={"type": "database"})


# Export commonly used items
__all__ = [
    "LangfuseClient",
    "LangfuseMiddleware",
    "observe_operation",
    "observe_api",
    "observe_service",
    "observe_db",
]
