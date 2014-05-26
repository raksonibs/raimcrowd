module ApplicationHelper
  def method_missing(method, *args, &block)
    return main_app.send(method, *args) if (method.to_s.end_with?('_path') ||
                                            method.to_s.end_with?('_url')) &&
                                            main_app.respond_to?(method)
    super
  end
end
