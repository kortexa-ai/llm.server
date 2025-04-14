# kortexa.ai LLM server

A simple systemd and nginx configuration to run an LLM as a service using vllm.

### Enabling https

The easiest way is to install Nginx UI and enable Let's Encrypt automatic certificate through it.

Alternatively, you can just use your own certificate files and set the `ssl_certificate` and `ssl_certificate_key`variables in the nginx configuration.

-------------------
© 2025 kortexa.ai