# OBS Websocket Remote Control

https://github.com/Palakis/obs-websocket/blob/4.x-current/docs/generated/protocol.md#requests

Starting with obs-websocket 4.9, authentication is enabled by default and users are encouraged to configure a password on first run.

obs-websocket uses SHA256 to transmit credentials.

A request for GetAuthRequired returns two elements:

A challenge: a random string that will be used to generate the auth response.
A salt: applied to the password when generating the auth response.
To generate the answer to the auth challenge, follow this procedure:

Concatenate the user declared password with the salt sent by the server (in this order: password + server salt).
Generate a binary SHA256 hash of the result and encode the resulting SHA256 binary hash to base64, known as a base64 secret.
Concatenate the base64 secret with the challenge sent by the server (in this order: base64 secret + server challenge).
Generate a binary SHA256 hash of the result and encode it to base64.
Voilà, this last base64 string is the auth response. You may now use it to authenticate to the server with the Authenticate request.
Pseudo Code Example:

password = "supersecretpassword"
challenge = "ztTBnnuqrqaKDzRM3xcVdbYm"
salt = "PZVbYpvAnZut2SS6JNJytDm9"

secret_string = password + salt
secret_hash = binary_sha256(secret_string)
secret = base64_encode(secret_hash)

auth_response_string = secret + challenge
auth_response_hash = binary_sha256(auth_response_string)
auth_response = base64_encode(auth_response_hash)