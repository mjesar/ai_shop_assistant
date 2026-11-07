require 'rails_helper'

RSpec.describe "Content Security Policy", type: :request do
  let(:policy) do
    get "/chats"
    response.headers["Content-Security-Policy"]
  end

  it "only allows scripts from the app and nonced inline scripts" do
    expect(policy).to match(/script-src 'self' 'nonce-[^']+'/)
    expect(policy).not_to include("unsafe-inline")
    expect(policy).not_to include("unsafe-eval")
  end

  it "blocks images from other sites" do
    expect(policy).to include("img-src 'self' data:")
  end

  it "blocks plugins and framing" do
    expect(policy).to include("object-src 'none'")
    expect(policy).to include("frame-ancestors 'none'")
  end

  it "puts the policy nonce on the inline importmap script" do
    nonce = policy[/script-src 'self' 'nonce-([^']+)'/, 1]
    expect(response.body).to include(%(<script type="importmap" data-turbo-track="reload" nonce="#{nonce}"))
  end

  it "uses a new nonce for each request" do
    get "/chats"
    first = response.headers["Content-Security-Policy"][/nonce-([^']+)/, 1]
    get "/chats"
    second = response.headers["Content-Security-Policy"][/nonce-([^']+)/, 1]
    expect(first).not_to eq(second)
  end
end
