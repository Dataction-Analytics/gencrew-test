# Security, Compliance & Observability

Every control below is applied by the delivery itself — this document reports what the pipeline did, it does not describe intentions.

## Data classification & PII
- Classification selected: **pii**
- Compliance regimes: **gdpr**
- PII masking: not requested for this requirement (source values copied as-is).

## Access control
- This delivery provisions no infrastructure and holds no cloud credentials: it is SQL
  executed inside the client's own warehouse, under the connection selected at capture.
- Warehouse roles and grants stay with the client's administrator — nothing here changes them.
- The generated SQL is physically unable to DELETE, TRUNCATE or DROP: every statement
  passes `sql_guard.assert_safe` before execution, and `CREATE OR REPLACE` is the
  sanctioned refresh pattern. SCD Type 2 closes a superseded row, it never removes one.

## Exception handling
- Transient failures retry with exponential backoff and jitter (3 attempts).
- Per-table isolation: one failing table never aborts the run.
- A failed certificate holds the pipeline; nothing downstream runs on unverified data.

## Logging & observability
- The warehouse's own query history is the execution log — every statement this delivery
  runs is also written to the SQL folder, so any run can be replayed and diffed.
- Per-table progress, row counts and verification results are logged for every run.
- The delivery's CERTIFICATES.json records every gate, with agent review notes.
