# frozen_string_literal: true

require 'yaml'

module Mmd2svg
  class Config
    DEFAULT_CONFIG = {
      'theme' => 'default',
      'background_color' => 'white',
      'puppeteer' => {
        'headless' => true,
        'timeout' => 30_000,
        'args' => ['--no-sandbox', '--disable-setuid-sandbox']
      },
      'mermaid' => {
        'securityLevel' => 'loose',
        'startOnLoad' => true,
        'logLevel' => 'error'
      },
      'batch' => {
        'recursive' => false,
        'overwrite' => true,
        'skip_errors' => false
      }
    }.freeze

    attr_accessor :theme, :background_color, :width, :height,
                  :puppeteer_timeout, :puppeteer_headless, :puppeteer_args,
                  :mermaid_config, :recursive, :overwrite, :skip_errors

    def initialize(config_hash = {})
      merged_config = DEFAULT_CONFIG.merge(config_hash)

      @theme = merged_config['theme']
      @background_color = merged_config['background_color']
      @width = merged_config['width']
      @height = merged_config['height']

      @puppeteer_headless = merged_config['puppeteer']['headless']
      @puppeteer_timeout = merged_config['puppeteer']['timeout']
      @puppeteer_args = merged_config['puppeteer']['args']

      @mermaid_config = merged_config['mermaid']

      @recursive = merged_config['batch']['recursive']
      @overwrite = merged_config['batch']['overwrite']
      @skip_errors = merged_config['batch']['skip_errors']
    end

    def self.load_from_file(file_path)
      return new unless File.exist?(file_path)

      config_hash = YAML.load_file(file_path)
      new(config_hash)
    rescue StandardError => e
      raise ConfigError, "Failed to load config file: #{e.message}"
    end

    def self.find_config_file
      current_dir = Dir.pwd
      config_file = File.join(current_dir, '.mmd2svg.yml')

      return config_file if File.exist?(config_file)

      nil
    end

    def to_h
      {
        theme: @theme,
        background_color: @background_color,
        width: @width,
        height: @height,
        puppeteer_timeout: @puppeteer_timeout,
        puppeteer_headless: @puppeteer_headless,
        puppeteer_args: @puppeteer_args,
        mermaid_config: @mermaid_config,
        recursive: @recursive,
        overwrite: @overwrite,
        skip_errors: @skip_errors
      }
    end

    def dup
      Config.new(DEFAULT_CONFIG.merge(to_h.transform_keys(&:to_s)))
    end
  end
end
