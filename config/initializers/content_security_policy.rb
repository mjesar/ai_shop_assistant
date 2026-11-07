# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri :self
    policy.form_action :self
    policy.frame_ancestors :none
    policy.object_src :none
    policy.script_src :self
    policy.style_src :self
    policy.font_src :self
    # Chat messages can contain markdown images, and a remote image can tell an outside
    # server who viewed the chat. search_products returns no image URLs, so none are needed.
    # Add the image host here if product images are ever shown.
    policy.img_src :self, :data
    # Same-origin fetch requests and the Action Cable websocket behind Turbo Streams.
    policy.connect_src :self
  end

  # Generate a nonce per request for the inline importmap script and Turbo's progress bar style.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end
