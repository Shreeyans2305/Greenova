"""
EcoTrack Backend - Cache Service
TTL-based in-memory cache to reduce redundant Ollama API calls.
"""

import hashlib
import json
import logging
import time
from typing import Any, Optional

from config import CACHE_TTL, CACHE_ENABLED

logger = logging.getLogger("greenNova.cache")


class CacheService:
    """Simple in-memory cache with TTL expiration."""

    def __init__(self, ttl: int = CACHE_TTL, enabled: bool = CACHE_ENABLED):
        self._store: dict[str, dict] = {}  # key -> {"value": Any, "expires": float}
        self._ttl = ttl
        self._enabled = enabled

    @staticmethod
    def make_key(*args) -> str:
        """Generate a deterministic cache key from arguments."""
        raw = json.dumps(args, sort_keys=True, default=str)
        return hashlib.sha256(raw.encode()).hexdigest()

    def get(self, key: str) -> Optional[Any]:
        """Return cached value if present and not expired, else None."""
        if not self._enabled:
            return None
        entry = self._store.get(key)
        if entry is None:
            return None
        if time.time() > entry["expires"]:
            del self._store[key]
            logger.debug("Cache EXPIRED for key=%s", key[:12])
            return None
        logger.debug("Cache HIT for key=%s", key[:12])
        return entry["value"]

    def set(self, key: str, value: Any) -> None:
        """Store a value with TTL expiration."""
        if not self._enabled:
            return
        self._store[key] = {
            "value": value,
            "expires": time.time() + self._ttl,
        }
        logger.debug("Cache SET for key=%s (TTL=%ds)", key[:12], self._ttl)

    def invalidate(self, key: str) -> bool:
        """Remove a specific key. Returns True if key existed."""
        removed = self._store.pop(key, None) is not None
        if removed:
            logger.info("Cache INVALIDATED key=%s", key[:12])
        return removed

    def clear(self) -> int:
        """Remove all cached entries. Returns count of cleared items."""
        count = len(self._store)
        self._store.clear()
        logger.info("Cache CLEARED (%d entries)", count)
        return count

    def stats(self) -> dict:
        """Return cache statistics."""
        now = time.time()
        total = len(self._store)
        active = sum(1 for e in self._store.values() if now <= e["expires"])
        return {
            "total_entries": total,
            "active_entries": active,
            "expired_entries": total - active,
            "ttl_seconds": self._ttl,
            "enabled": self._enabled,
        }


# Singleton instance used across the application
cache = CacheService()
