require_relative "lib/MLserver.rb"

exe=['mlserver']

Gem::Specification.new do |s|
  s.name        = 'mlserver'
  s.version     = MLserver.version
  s.summary     = "A simple web server"
  s.description = "A simple web server"
  s.authors     = ["Matthias Lee"]
  s.email       = 'matthias@matthiasclee.com'
  s.files       = [
    "lib/MLserver/html/error_page.template.html",
    "lib/MLserver/html/default_response_footer.template.html",
    "lib/MLserver.rb",
    "lib/MLserver/request_parser.rb",
    "lib/MLserver/request.rb",
    "lib/MLserver/response.rb",
    "lib/MLserver/server.rb",
    "lib/MLserver/client_handler.rb",
    "lib/MLserver/logger.rb",
    "lib/MLserver/error_response.rb",
    "lib/MLserver/redirect_response.rb",
    "lib/MLserver/settings.rb",
  ] + exe.map{|i|"bin/#{i}"}
  s.executables = exe
  s.add_runtime_dependency "argparse", '~> 0.0.3'
  s.add_runtime_dependency "rbtext", '~> 0.3.4'
  s.require_paths = ["lib"]
  s.homepage = 'https://github.com/Matthiasclee/MLServer'
end

