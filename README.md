# Send with Sinatra

Send email from a Sinatra app with the uSend gem, and receive webhooks.

Part of [usend examples](https://github.com/usend/usend-examples). Step-by-step guide: https://usend.et/docs/quickstarts/sinatra

You need a [verified domain](https://usend.et/docs/domains/verify) and an [API key](https://usend.et/docs/api-keys).

```bash
gem install usend sinatra
export USEND_API_KEY="us_123456789"
```

## Send an email

`app.rb`

```ruby
require "sinatra"
require "usend"

USEND = Usend::Client.new(api_key: ENV.fetch("USEND_API_KEY"))

post "/signup" do
  USEND.emails.send_email(
    {
      from: "Acme <hello@acme.com>",
      to: [params[:email]],
      subject: "Welcome",
      html: "<p>Thanks for signing up!</p>"
    },
    idempotency_key: "signup-#{params[:email]}"
  )
  "ok"
rescue Usend::Error => e
  halt 502, "#{e.name}: #{e.message}"
end
```

Rate limits and server errors are retried for you, and the idempotency key makes a retry safe. See [Idempotency](https://usend.et/docs/sending/idempotency).

## Receive webhooks

```ruby
post "/usend/webhook" do
  event = Usend::Webhook.verify(
    payload: request.body.read, # the raw body
    headers: request.env,       # Rack's HTTP_WEBHOOK_* keys work
    secret: ENV.fetch("USEND_WEBHOOK_SECRET")
  )
  puts event["type"]
  status 204
rescue Usend::Error
  status 400
end
```

See [Verify signatures](https://usend.et/docs/webhooks/verify-signatures).

## Notes

- A `422` means the request is invalid (for example the `from` domain is not verified); fix it rather than retrying. See [Errors](https://usend.et/docs/api-reference/errors).
- While your organization is in the [sandbox](https://usend.et/docs/sending/sandbox-and-limits), send only to verified members.

## Without the gem

`Net::HTTP` works too: `POST https://api.usend.et/emails` with an `Authorization: Bearer` header and a JSON body. Or send over [SMTP](https://usend.et/docs/sending/smtp) with the `mail` gem: host `smtp.usend.et`, port `465` or `587`, username `usend`, your API key as the password.

More fields: [Send emails](https://usend.et/docs/sending/emails).

## Environment

Create an [API key](https://usend.et/docs/api-keys) and a [verified domain](https://usend.et/docs/domains/verify), then set `USEND_API_KEY` (starts with `us_`); copy any `.env*.example` file to its real name first. Never put the key in browser code.

## License

MIT
