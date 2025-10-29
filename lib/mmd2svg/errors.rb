# frozen_string_literal: true

module Mmd2svg
  class Error < StandardError; end
  class RenderError < Error; end
  class ConfigError < Error; end
  class FileNotFoundError < Error; end
  class PuppeteerError < Error; end
end
