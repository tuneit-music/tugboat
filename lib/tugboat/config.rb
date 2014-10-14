require 'singleton'

module Tugboat
  # This is the configuration object. It reads in configuration
  # from a .tugboat file located in the user's home directory

  class Configuration
    include Singleton
    attr_reader :data
    attr_reader :path

    FILE_NAME = '.tugboat'
    DEFAULT_SSH_KEY_PATH = '.ssh/id_rsa'
    DEFAULT_SSH_PORT = '22'
    DEFAULT_REGION = '1'
    DEFAULT_IMAGE = '3240036'
    DEFAULT_SIZE = '66'
    DEFAULT_SSH_KEY = ''
    DEFAULT_PRIVATE_NETWORKING = 'false'
    DEFAULT_BACKUPS_ENABLED = 'false'

    def initialize
      @path = ENV["TUGBOAT_CONFIG_PATH"] || File.join(File.expand_path("~"), FILE_NAME)
      @data = self.load_config_file
    end

    # If we can't load the config file, self.data is nil, which we can
    # check for in CheckConfiguration
    def load_config_file
      require 'yaml'
      YAML.load_file(@path)
    rescue Errno::ENOENT
      return
    end

    def client_key
      @data['authentication']['client_key']
    end

    def api_key
      @data['authentication']['api_key']
    end

    def ssh_key_path
      @data['ssh']['ssh_key_path']
    end

    def ssh_user
      @data['ssh']['ssh_user']
    end

    def ssh_port
      @data['ssh']['ssh_port']
    end

    def default_region
      @data['defaults'].nil? ? DEFAULT_REGION : @data['defaults']['region']
    end

    def default_image
      @data['defaults'].nil? ? DEFAULT_IMAGE : @data['defaults']['image']
    end

    def default_size
      @data['defaults'].nil? ? DEFAULT_SIZE : @data['defaults']['size']
    end

    def default_ssh_key
      @data['defaults'].nil? ? DEFAULT_SSH_KEY : @data['defaults']['ssh_key']
    end

    def default_private_networking
      @data['defaults'].nil? ? DEFAULT_PRIVATE_NETWORKING : @data['defaults']['private_networking']
    end

    def default_backups_enabled
      @data['defaults'].nil? ? DEFAULT_BACKUPS_ENABLED : @data['defaults']['backups_enabled']
    end

    # Re-runs initialize
    def reset!
      self.send(:initialize)
    end

    # Re-loads the config
    def reload!
      @data = self.load_config_file
    end

    # Writes a config file
    def create_config_file(client, api, ssh_key_path, ssh_user, ssh_port, region, image, size, ssh_key, private_networking, backups_enabled)
      # Default SSH Key path
      if ssh_key_path.empty?
        ssh_key_path = File.join(File.expand_path("~"), DEFAULT_SSH_KEY_PATH)
      end

      if ssh_user.empty?
        ssh_user = ENV['USER']
      end

      if ssh_port.empty?
        ssh_port = DEFAULT_SSH_PORT
      end

      if region.empty?
        region = DEFAULT_REGION
      end

      if image.empty?
        image = DEFAULT_IMAGE
      end

      if size.empty?
        size = DEFAULT_SIZE
      end

      if ssh_key.empty?
        default_ssh_key = DEFAULT_SSH_KEY
      end

      if private_networking.empty?
        private_networking = DEFAULT_PRIVATE_NETWORKING
      end

      if backups_enabled.empty?
        backups_enabled = DEFAULT_BACKUPS_ENABLED
      end

      require 'yaml'
      File.open(@path, File::RDWR|File::TRUNC|File::CREAT, 0600) do |file|
        data = {
                "authentication" => {
                  "client_key" => client,
                  "api_key" => api },
                "ssh" => {
                  "ssh_user" => ssh_user,
                  "ssh_key_path" => ssh_key_path ,
                  "ssh_port" => ssh_port },
                "defaults" => {
                  "region" => region,
                  "image" => image,
                  "size" => size,
                  "ssh_key" => ssh_key,
                  "private_networking" => private_networking,
                  "backups_enabled" => backups_enabled
                }
        }
        file.write data.to_yaml
      end
    end

  end
end
