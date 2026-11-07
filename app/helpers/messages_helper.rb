module MessagesHelper
  def render_markdown(text)
    # Message content comes from visitors and the LLM, so treat it as untrusted:
    # escape_html shows raw HTML as text, safe_links_only drops javascript: and data: links.
    html_renderer = Redcarpet::Render::HTML.new(
      escape_html: true,
      safe_links_only: true,
      link_attributes: { target: "_blank", rel: "noopener" }
    )
    Redcarpet::Markdown.new(html_renderer, autolink: true).render(text).html_safe
  end
end
