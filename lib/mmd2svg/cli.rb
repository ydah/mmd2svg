# frozen_string_literal: true

require 'thor'
require 'fileutils'

module Mmd2svg
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    class_option :config,
                 type: :string,
                 aliases: '-c',
                 desc: 'Config file path (default: .mermaid2svg.yml)'

    desc 'INPUT', 'Convert Mermaid diagram(s) to SVG'
    option :output,
           type: :string,
           aliases: '-o',
           desc: 'Output file or directory path (default: INPUT.svg)'
    option :theme,
           type: :string,
           aliases: '-t',
           desc: 'Theme: default, dark, forest, neutral'
    option :background,
           type: :string,
           aliases: '-b',
           desc: 'Background color (transparent, white, or hex)'
    option :width,
           type: :numeric,
           aliases: '-w',
           desc: 'Output width in pixels'
    option :height,
           type: :numeric,
           aliases: '-h',
           desc: 'Output height in pixels'
    option :recursive,
           type: :boolean,
           aliases: '-r',
           default: false,
           desc: 'Process directories recursively'
    option :timeout,
           type: :numeric,
           desc: 'Puppeteer timeout in milliseconds'
    option :skip_errors,
           type: :boolean,
           default: false,
           desc: 'Continue processing even if errors occur'

    def convert(input)
      config = load_config
      apply_options_to_config(config)
      output = determine_output(input)
      if batch_conversion?(input, output)
        perform_batch_conversion(input, output, config)
      else
        perform_single_conversion(input, output, config)
      end
    rescue Mermaid2svg::Error => e
      error_exit(e.message)
    rescue StandardError => e
      error_exit("Unexpected error: #{e.message}")
    end

    desc 'version', 'Show version'
    def version
      puts "mermaid2svg version #{Mermaid2svg::VERSION}"
    end

    desc 'help [COMMAND]', 'Describe available commands or one specific command'
    def help(command = nil)
      if command.nil?
        print_usage
      else
        super
      end
    end

    default_task :convert

    def self.start(given_args = ARGV, config = {})
      if given_args.any? && !%w[convert version help].include?(given_args.first) && !given_args.first.start_with?('-')
        given_args = ['convert'] + given_args
      end
      super(given_args, config)
    end

    private

    def print_usage
      puts "Usage: mermaid2svg INPUT [OPTIONS]"
      puts ""
      puts "Convert Mermaid diagram(s) to SVG"
      puts ""
      puts "Arguments:"
      puts "  INPUT                          Input file, directory, or glob pattern"
      puts ""
      puts "Options:"
      puts "  -o, --output=PATH              Output file or directory path (default: INPUT.svg)"
      puts "  -t, --theme=THEME              Theme: default, dark, forest, neutral"
      puts "  -b, --background=COLOR         Background color (transparent, white, or hex)"
      puts "  -w, --width=WIDTH              Output width in pixels"
      puts "  -h, --height=HEIGHT            Output height in pixels"
      puts "  -r, --recursive                Process directories recursively"
      puts "      --timeout=MILLISECONDS     Puppeteer timeout in milliseconds (default: 30000)"
      puts "      --skip-errors              Continue processing even if errors occur"
      puts "  -c, --config=FILE              Config file path (default: .mermaid2svg.yml)"
      puts ""
      puts "Commands:"
      puts "  mermaid2svg version            Show version"
      puts "  mermaid2svg help               Show this help message"
      puts ""
      puts "Examples:"
      puts "  mermaid2svg diagram.mmd                          # Convert to diagram.svg"
      puts "  mermaid2svg diagram.mmd -o output.svg            # Specify output file"
      puts "  mermaid2svg diagram.mmd --theme dark             # Use dark theme"
      puts "  mermaid2svg examples/ -o output/                 # Batch conversion"
      puts "  mermaid2svg examples/ -o output/ --recursive     # Recursive batch conversion"
    end

    def determine_output(input)
      return options[:output] if options[:output]

      if File.file?(input)
        input.sub(/\.(mmd|mermaid)$/i, '.svg')
      else
        'output'
      end
    end

    def load_config
      config_file = options[:config] || Config.find_config_file
      if config_file && File.exist?(config_file)
        puts "Loading config from: #{config_file}" if options[:verbose]
        Config.load_from_file(config_file)
      else
        Config.new
      end
    end

    def apply_options_to_config(config)
      config.theme = options[:theme] if options[:theme]
      config.background_color = options[:background] if options[:background]
      config.width = options[:width] if options[:width]
      config.height = options[:height] if options[:height]
      config.puppeteer_timeout = options[:timeout] if options[:timeout]
      config.recursive = options[:recursive]
      config.skip_errors = options[:skip_errors]
    end

    def batch_conversion?(input, output)
      File.directory?(input) || input.include?('*') || 
        (File.exist?(input) && File.exist?(output) && File.directory?(output))
    end

    def perform_batch_conversion(input, output, config)
      output_dir = output

      puts "Processing files from: #{input}"
      puts "Output directory: #{output_dir}"
      puts ''

      batch_renderer = BatchRenderer.new(config)
      results = batch_renderer.render_batch(input, output_dir: output_dir)

      display_batch_results(results)
    end

    def perform_single_conversion(input, output, config)
      raise FileNotFoundError, "Input file not found: #{input}" unless File.exist?(input)

      mermaid_code = File.read(input)
      renderer = Renderer.new(config)
      renderer.render(mermaid_code, output: output)
      puts "✓ #{input} → #{output}"
    end

    def display_batch_results(results)
      results[:succeeded].each do |result|
        puts "✓ #{result[:input]} → #{result[:output]}"
      end
      results[:failed].each do |result|
        puts "✗ #{result[:file]} → Error: #{result[:error]}"
      end
      puts ''
      puts "#{results[:succeeded].count} succeeded, #{results[:failed].count} failed"
      exit(1) if results[:failed].any? && !options[:skip_errors]
    end

    def error_exit(message)
      warn "Error: #{message}"
      exit(1)
    end
  end
end
