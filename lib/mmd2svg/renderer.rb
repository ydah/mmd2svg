# frozen_string_literal: true

require 'puppeteer'
require 'tempfile'

module Mmd2svg
  class Renderer
    def initialize(config = Config.new)
      @config = config
    end

    def render(mermaid_code, output: nil)
      svg_content = render_to_string(mermaid_code)

      if output
        File.write(output, svg_content)
        output
      else
        svg_content
      end
    rescue StandardError => e
      raise RenderError, "Failed to render Mermaid diagram: #{e.message}"
    end

    def render_to_string(mermaid_code)
      Puppeteer.launch(
        headless: @config.puppeteer_headless,
        args: @config.puppeteer_args
      ) do |browser|
        page = browser.new_page

        html_content = build_html(mermaid_code)
        temp_file = create_temp_html(html_content)

        begin
          page.goto("file://#{temp_file.path}", wait_until: 'networkidle0')
          page.wait_for_function('() => window.mermaidReady === true', timeout: @config.puppeteer_timeout)
          escaped_code = escape_js(mermaid_code)
          svg_content = page.evaluate(<<~JS)
            async () => {
              const code = `#{escaped_code}`;
              return await window.renderMermaid(code);
            }
          JS

          apply_size(svg_content) if @config.width || @config.height

          svg_content
        ensure
          temp_file.close
          temp_file.unlink
        end
      end
    rescue Puppeteer::TimeoutError
      raise PuppeteerError, "Puppeteer timeout after #{@config.puppeteer_timeout}ms"
    rescue StandardError => e
      raise RenderError, "Failed to render: #{e.message}"
    end

    private

    def build_html(_mermaid_code)
      template = File.read(template_path)
      template.gsub('%<theme>s', @config.theme)
              .gsub('%<security_level>s', @config.mermaid_config['securityLevel'])
              .gsub('%<log_level>s', @config.mermaid_config['logLevel'])
              .gsub('%<background_color>s', @config.background_color)
    end

    def template_path
      File.expand_path('../../templates/render.html', __dir__)
    end

    def create_temp_html(content)
      temp = Tempfile.new(['mermaid', '.html'])
      temp.write(content)
      temp.flush
      temp
    end

    def escape_js(str)
      str.gsub('\\', '\\\\\\\\')
         .gsub('`', '\\`')
         .gsub('$', '\\$')
         .gsub("\n", '\\n')
         .gsub("\r", '\\r')
    end

    def apply_size(svg_content)
      svg_content.sub!(/width="[^"]*"/, %(width="#{@config.width}")) if @config.width
      svg_content.sub!(/height="[^"]*"/, %(height="#{@config.height}")) if @config.height
      svg_content
    end
  end
end
