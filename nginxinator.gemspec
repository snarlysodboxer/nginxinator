Gem::Specification.new do |s|
  s.name        = 'nginxinator'
  s.version     = '0.1.0'
  s.date        = '2014-11-10'
  s.summary     = "Deploy Nginx"
  s.description = "An Opinionated Nginx Deployment gem"
  s.authors     = ["david amick"]
  s.email       = "davidamick@ctisolutionsinc.com"
  s.files       = [
    "lib/nginxinator.rb",
    "lib/nginxinator/nginx.rb",
    "lib/nginxinator/config.rb",
    "lib/nginxinator/examples/Capfile",
    "lib/nginxinator/examples/config/deploy.rb",
    "lib/nginxinator/examples/config/deploy_nginxinator.rb",
    "lib/nginxinator/examples/config/deploy/staging.rb",
    "lib/nginxinator/examples/config/deploy/staging_nginxinator.rb",
    "lib/nginxinator/examples/nginx.conf.erb",
    "lib/nginxinator/examples/site-enabled.erb",
    "lib/nginxinator/examples/ssl.crt.erb",
    "lib/nginxinator/examples/ssl.key.erb",
    "lib/nginxinator/examples/mime.types.erb",
    "lib/nginxinator/examples/Dockerfile"
  ]
  s.required_ruby_version  =              '>= 1.9.3'
  s.requirements           <<             "Docker ~1.3.1"
  s.add_runtime_dependency 'capistrano',  '= 3.2.1'
  s.add_runtime_dependency 'rake',        '= 10.3.2'
  s.add_runtime_dependency 'sshkit',      '= 1.5.1'
  s.homepage    =
    'https://github.com/snarlysodboxer/nginxinator'
  s.license     = 'GNU'
end
