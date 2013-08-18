require 'uri'

module BootstrapNavbar::Helpers
  def nav_bar(options = {}, &block)
    nav_bar_div options do
      container_div options[:brand], options[:brand_link], options[:responsive], options[:fluid], &block
    end
  end

  def menu_group(options = {}, &block)
    css_classes = %w(nav navbar-nav).tap do |css_classes|
      css_classes << "pull-#{options.delete(:pull)}" if options.has_key?(:pull)
      css_classes << options.delete(:class) if options.has_key?(:class)
    end
    attributes = attribute_hash_to_string({ class: css_classes.join(' ') }.merge(options))
    prepare_html <<-HTML.chomp!
<ul#{with_preceding_space attributes}>
  #{capture(&block) if block_given?}
</ul>
HTML
  end

  def menu_item(name = nil, path = nil, list_item_options = nil, link_options = nil, &block)
    name, path, list_item_options, link_options = capture(&block), name, path, list_item_options if block_given?
    path              ||= '#'
    list_item_options ||= {}
    link_options      ||= {}

    list_item_css_classes = [].tap do |css_classes|
      css_classes << 'active' if current_url?(path)
      css_classes << list_item_options.delete(:class) if list_item_options.has_key?(:class)
    end
    list_item_attributes = attribute_hash_to_string(
      { class: list_item_css_classes.join(' ') }
        .delete_if { |k, v| v.empty? }
        .merge(list_item_options)
    )
    link_attributes = attribute_hash_to_string(link_options)
    prepare_html <<-HTML.chomp!
<li#{with_preceding_space list_item_attributes}>
  <a href="#{path}"#{with_preceding_space link_attributes}>
    #{name}
  </a>
</li>
HTML
  end

  def drop_down(name, &block)
    prepare_html <<-HTML.chomp!
<li class="dropdown">
  <a href="#" class="dropdown-toggle" data-toggle="dropdown">
    #{name} <b class="caret"></b>
  </a>
  #{drop_down_menu(&block)}
</li>
HTML
  end

  def sub_drop_down(name, list_item_options = {}, link_options = {}, &block)
    list_item_css_classes = %w(dropdown-submenu).tap do |css_classes|
      css_classes << list_item_options.delete(:class) if list_item_options.has_key?(:class)
    end
    list_item_attributes = attribute_hash_to_string({ class: list_item_css_classes.join(' ') }.merge(list_item_options))
    link_attributes = attribute_hash_to_string(link_options)
    prepare_html <<-HTML.chomp!
<li#{with_preceding_space list_item_attributes}>
  <a href="#"#{with_preceding_space link_attributes}>
    #{name}
  </a>
  #{drop_down_menu(&block)}
</li>
HTML
  end

  def drop_down_divider
    prepare_html %(<li class="divider"></li>)
  end

  def drop_down_header(text)
    prepare_html %(<li class="nav-header">#{text}</li>)
  end

  def menu_divider
    prepare_html %(<li class="divider-vertical"></li>)
  end

  def menu_text(text = nil, pull = nil, &block)
    css_classes = %w(navbar-text).tap do |css_classes|
      css_classes << "pull-#{pull}" if pull
    end
    prepare_html <<-HTML.chomp!
<p class="#{css_classes.join(' ')}">
  #{block_given? ? capture(&block) : text}
</p>
HTML
  end

  def brand_link(name, url = nil)
    prepare_html %(<a href="#{url || '/'}" class="navbar-brand">#{name}</a>)
  end

  private

  def nav_bar_header(brand, brand_link, responsive)
    content = [].tap do |content|
      content << responsive_button if responsive
      content << brand_link(brand, brand_link) if brand || brand_link
    end
    prepare_html <<-HTML.chomp!
<div class="navbar-header">
  #{content.join("\n")}
</div>
HTML
  end

  def nav_bar_div(options, &block)
    position = case
    when options.has_key?(:static)
      "static-#{options[:static]}"
    when options.has_key?(:fixed)
      "fixed-#{options[:fixed]}"
    end

    css_classes = %w(navbar).tap do |css_classes|
      css_classes << "navbar-#{position}" if position
      css_classes << 'navbar-inverse' if options[:inverse]
    end

    prepare_html <<-HTML.chomp!
<div class="#{css_classes.join(' ')}">
  #{capture(&block) if block_given?}
</div>
HTML
  end

  def navbar_inner_div(&block)
    prepare_html <<-HTML.chomp!
<div class="navbar-inner">
  #{capture(&block) if block_given?}
</div>
HTML
  end

  def container_div(brand, brand_link, responsive, fluid, &block)
    css_class = fluid ? 'container-fluid' : 'container'
    content = [].tap do |content|
      content << nav_bar_header(brand, brand_link, responsive)
      content << if responsive
        responsive_wrapper(&block)
      else
        capture(&block) if block_given?
      end
    end
    prepare_html <<-HTML.chomp!
<div class="#{css_class}">
  #{content.join("\n")}
</div>
HTML
  end

  def responsive_wrapper(&block)
    prepare_html <<-HTML.chomp!
<div class="navbar-collapse collapse">
  #{capture(&block) if block_given?}
</div>
HTML
  end

  def responsive_button
    prepare_html <<-HTML.chomp!
<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
  <span class="icon-bar"></span>
  <span class="icon-bar"></span>
  <span class="icon-bar"></span>
</button>
HTML
  end

  def drop_down_menu(&block)
    prepare_html <<-HTML.chomp!
<ul class="dropdown-menu">
  #{capture(&block) if block_given?}
</ul>
HTML
  end

  def with_preceding_space(attributes)
    ' ' << attributes unless [nil, ''].include?(attributes)
  end

  def attribute_hash_to_string(hash)
    hash.map { |k, v| %(#{k}="#{v}") }.join(' ')
  end

  def current_url?(url)
    normalized_path, normalized_current_path = [url, current_url].map do |url|
      URI.parse(url).path.sub(%r(/\z), '') rescue nil
    end
    normalized_path == normalized_current_path
  end

  def current_url
    raise StandardError, 'current_url_method is not defined.' if BootstrapNavbar.current_url_method.nil?
    eval BootstrapNavbar.current_url_method
  end

  def prepare_html(html)
    html
  end
end
