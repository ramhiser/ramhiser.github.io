# Added to fix a YAML parsing issue when running 'rake generate'
# Discussed here: https://github.com/imathis/octopress/issues/57
# Found the fix here: http://stackoverflow.com/questions/4980877/rails-error-couldnt-parse-yaml
# require 'yaml'
# YAML::ENGINE.yamler = 'syck'

# Require any additional compass plugins here.
project_type = :stand_alone

# Publishing paths
http_path = "/"
http_images_path = "/images"
http_fonts_path = "/fonts"
css_dir = "public/stylesheets"

# Local development paths
sass_dir = "sass"
images_dir = "source/images"
fonts_dir = "source/fonts"

line_comments = false
output_style = :compressed
