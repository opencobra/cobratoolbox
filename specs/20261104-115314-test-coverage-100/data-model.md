# Data model

- **Coverage record** (JSON line): test, source, status, seconds, message, lines[], hits[].
- **Inventory row**: test, function, status (COMPLETE/GAP/SKIPPED/FAILING/ERROR), covered/total, missed, documented, undocumented.
