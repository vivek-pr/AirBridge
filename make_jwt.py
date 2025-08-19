
import jwt, time, os
secret = "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
now = int(time.time())
payload = {
  "sub": "edge-worker",
  "iat": now,
  "nbf": now - 5,
  "exp": now + 3600,
  "aud": "urn:airflow.apache.org:task",   # keep in sync with server config
}
tok = jwt.encode(payload, secret, algorithm="HS256")
# PyJWT returns str; ensure no newlines
print(tok)
