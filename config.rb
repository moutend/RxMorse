require 'bootstrap-sass'
Time.zone = 'Tokyo'
# Slim::Engine.default_options[:pretty] = true
Tilt::CoffeeScriptTemplate.default_bare = true

set :css_dir,     'sass'
set :fonts_dir,   'fonts'
set :js_dir,      'js'
set :images_dir,  'img'
set :layouts_dir, '_layouts'

configure :build do
  before_build do
    prefix = "/huda"
    data.settings.global["url_prefix"] = prefix
    set :css_dir,    "#{prefix}/sass"
    set :fonts_dir,  "#{prefix}/fonts"
    set :js_dir,     "#{prefix}/js"
    set :images_dir, "#{prefix}/img"
  end
  activate :minify_css
  activate :minify_javascript
end
