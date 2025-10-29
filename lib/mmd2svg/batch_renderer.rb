# frozen_string_literal: true

require 'fileutils'

module Mmd2svg
  class BatchRenderer
    def initialize(config = Config.new)
      @config = config
      @renderer = Renderer.new(config)
      @results = { succeeded: [], failed: [] }
    end

    def render_batch(input, output_dir:)
      files = FileFinder.find_files(input, recursive: @config.recursive)
      raise FileNotFoundError, "No Mermaid files found in: #{input}" if files.empty?

      base_dir = File.directory?(input) ? input : nil
      files.each do |file|
        process_file(file, output_dir, base_dir)
      end
      @results
    end

    private

    def process_file(input_file, output_dir, base_dir)
      output_file = FileFinder.output_path(input_file, output_dir, base_dir)
      FileUtils.mkdir_p(File.dirname(output_file))
      if !@config.overwrite && File.exist?(output_file)
        @results[:failed] << {
          file: input_file,
          error: "Output file already exists: #{output_file}"
        }
        return
      end

      mermaid_code = File.read(input_file)
      @renderer.render(mermaid_code, output: output_file)
      @results[:succeeded] << {
        input: input_file,
        output: output_file
      }
    rescue StandardError => e
      @results[:failed] << {
        file: input_file,
        error: e.message
      }
      raise unless @config.skip_errors
    end
  end
end
