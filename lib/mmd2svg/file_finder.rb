# frozen_string_literal: true

module Mmd2svg
  class FileFinder
    MERMAID_EXTENSIONS = %w[.mmd .mermaid].freeze

    def self.find_files(input, recursive: false)
      if File.directory?(input)
        find_in_directory(input, recursive)
      elsif input.include?('*')
        Dir.glob(input).select { |f| File.file?(f) && mermaid_file?(f) }
      elsif File.file?(input)
        mermaid_file?(input) ? [input] : []
      else
        raise FileNotFoundError, "Input not found: #{input}"
      end
    end

    def self.find_in_directory(dir, recursive)
      pattern = recursive ? File.join(dir, '**', '*') : File.join(dir, '*')
      Dir.glob(pattern).select { |f| File.file?(f) && mermaid_file?(f) }
    end

    def self.mermaid_file?(path)
      MERMAID_EXTENSIONS.include?(File.extname(path).downcase)
    end

    def self.output_path(input_path, output_dir, base_dir = nil)
      relative_path =
        if base_dir
          input_path.sub(%r{^#{Regexp.escape(base_dir)}/}, '')
        else
          File.basename(input_path)
        end

      output_file = relative_path.sub(/\.(mmd|mermaid)$/i, '.svg')
      File.join(output_dir, output_file)
    end
  end
end
