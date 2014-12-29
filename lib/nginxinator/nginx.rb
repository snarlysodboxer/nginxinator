namespace :nginx do

  desc "Idempotently setup an Nginx instance."
  task :setup => ['deployinator:deployment_user', 'deployinator:webserver_user', 'deployinator:sshkit_umask'] do
    Rake::Task['nginx:open_firewall'].invoke
    # 'on', 'run_locally', 'as', 'execute', 'info', 'warn', and 'fatal' are from SSHKit
    on roles(:app) do
      as :root do
        set :config_file_changed, false
        Rake::Task['nginx:install_config_files'].invoke
        Rake::Task['deployinator:file_permissions'].invoke
        unless container_exists?(fetch(:webserver_container_name))
          create_container(fetch(:webserver_container_name), fetch(:webserver_docker_run_command))
        else
          unless container_is_running?(fetch(:webserver_container_name))
            start_container(fetch(:webserver_container_name))
          else
            if fetch(:config_file_changed)
              restart_container(fetch(:webserver_container_name))
            else
              info "No config file changes for #{fetch(:webserver_container_name)} and it is already running; we're setup!"
            end
          end
        end
      end
    end
  end

  desc "Check the status of the Nginx instance."
  task :status => ['deployinator:deployment_user'] do
    on roles(:app) do
      info ""
      if container_exists?(fetch(:webserver_container_name))
        info "#{fetch(:webserver_container_name)} exists on #{fetch(:domain)}"
        info ""
        if container_is_running?(fetch(:webserver_container_name))
          info "#{fetch(:webserver_container_name)} is running on #{fetch(:domain)}"
          info ""
        else
          info "#{fetch(:webserver_container_name)} is not running on #{fetch(:domain)}"
          info ""
        end
      else
        info "#{fetch(:webserver_container_name)} does not exist on #{fetch(:domain)}"
        info ""
      end
    end
  end

  task :install_config_files => ['deployinator:deployment_user', 'deployinator:webserver_user', 'deployinator:sshkit_umask'] do
    require 'erb'
    on roles(:app) do
      as 'root' do
        execute "mkdir", "-p", fetch(:webserver_socket_path),
          fetch(:webserver_logs_path), fetch(:webserver_config_path)
        fetch(:webserver_config_files).each do |config_file|
          template_path = File.expand_path("#{fetch(:local_templates_path)}/#{config_file}.erb")
          generated_config_file = ERB.new(File.new(template_path).read).result(binding)
          upload! StringIO.new(generated_config_file), "/tmp/#{config_file}.file"
          unless test "diff", "-q", "/tmp/#{config_file}.file", "#{fetch(:webserver_config_path)}/#{config_file}"
            warn "Config file #{config_file} on #{fetch(:domain)} is being updated."
            execute("mv", "/tmp/#{config_file}.file", "#{fetch(:webserver_config_path)}/#{config_file}")
            set :config_file_changed, true
          else
            execute "rm", "/tmp/#{config_file}.file"
          end
        end
        #execute("chown", "-R", "#{fetch(:deployment_user_id)}:#{fetch(:webserver_user_id)}", fetch(:webserver_config_path))
        execute("chown", "-R", "root:root", fetch(:webserver_config_path))
        execute "find", fetch(:webserver_config_path), "-type", "d", "-exec", "chmod", "2775", "{}", "+"
        execute "find", fetch(:webserver_config_path), "-type", "f", "-exec", "chmod", "0600", "{}", "+"
      end
    end
  end

  task :open_firewall do
    on roles(:app) do
      as "root" do
        if test "bash", "-c", "\"ufw", "status", "&>" "/dev/null\""
          fetch(:webserver_publish_ports).each do |port|
            raise "Error during opening UFW firewall" unless test("ufw", "allow", "#{port}/tcp")
          end
        end
      end
    end
  end

end
