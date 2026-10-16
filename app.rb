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
