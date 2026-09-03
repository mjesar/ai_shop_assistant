module MessagesHelper
  def render_markdown(text)
    renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(link_attributes: { target: '_blank', rel: 'noopener' }), autolink: true)
    renderer.render(text).html_safe
  end
end
