require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params)
    @params = params.merge!(req.params)
    @req = req
    @res = res
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  def render_prep
    raise "Double Render" if already_built_response?
    @already_built_response = true
    @session.store_session(@res)
  end

  # Set the response status code and header
  def redirect_to(url)
    @res.status = 302
    @res['Location'] = url
    render_prep
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    @res['Content-Type'] = content_type
    @res.write(content)
    render_prep
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    dir = File.dirname(__FILE__)[0...-4]
    dir += "/"+File.join("views","#{self.class.to_s.underscore}",template_name.to_s) + ".html.erb"
    template = ERB.new(File.read(dir))
    render_content(template.result(binding), 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    Router.new.send(name)
  end
end

