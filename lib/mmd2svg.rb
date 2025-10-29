# frozen_string_literal: true

require_relative 'mmd2svg/version'
require_relative 'mmd2svg/errors'
require_relative 'mmd2svg/config'
require_relative 'mmd2svg/renderer'
require_relative 'mmd2svg/file_finder'
require_relative 'mmd2svg/batch_renderer'

module Mmd2svg
  class << self
    attr_writer :config

    def config
      @config ||= Config.new
    end

    def configure
      yield(config) if block_given?
    end

    # Render a single Mermaid diagram
    # @param code [String] Mermaid diagram code or file path
    # @param output [String, nil] Output file path (optional)
    # @param options [Hash] Rendering options
    # @return [String] SVG content or output file path
    def render(code, output: nil, **options)
      local_config = build_config(options)
      renderer = Renderer.new(local_config)

      mermaid_code = File.exist?(code) ? File.read(code) : code
      renderer.render(mermaid_code, output: output)
    end

    # Render Mermaid diagram to string
    # @param code [String] Mermaid diagram code
    # @param options [Hash] Rendering options
    # @return [String] SVG content
    def render_to_string(code, **options)
      local_config = build_config(options)
      renderer = Renderer.new(local_config)

      renderer.render_to_string(code)
    end

    # Batch render multiple Mermaid files
    # @param input [String] Input directory or glob pattern
    # @param output_dir [String] Output directory
    # @param options [Hash] Rendering options
    # @return [Hash] Results with :succeeded and :failed arrays
    def render_batch(input, output_dir:, **options)
      local_config = build_config(options)
      batch_renderer = BatchRenderer.new(local_config)

      batch_renderer.render_batch(input, output_dir: output_dir)
    end

    private

    def build_config(options)
      local_config = config.dup

      local_config.theme = options[:theme] if options[:theme]
      local_config.background_color = options[:background_color] if options[:background_color]
      local_config.width = options[:width] if options[:width]
      local_config.height = options[:height] if options[:height]
      local_config.puppeteer_timeout = options[:timeout] if options[:timeout]
      local_config.recursive = options[:recursive] if options.key?(:recursive)
      local_config.skip_errors = options[:skip_errors] if options.key?(:skip_errors)

      local_config
    end
  end
end
