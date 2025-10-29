# frozen_string_literal: true

RSpec.describe Mmd2svg do
  it 'has a version number' do
    expect(Mmd2svg::VERSION).not_to be nil
  end

  describe '.render_to_string' do
    it 'renders a simple graph to SVG string' do
      mermaid_code = <<~MERMAID
        graph TD
          A[Start] --> B[End]
      MERMAID

      svg = Mmd2svg.render_to_string(mermaid_code)

      expect(svg).to be_a(String)
      expect(svg).to include('<svg')
      expect(svg).to include('</svg>')
    end
  end

  describe '.configure' do
    it 'allows configuration via block' do
      Mmd2svg.configure do |config|
        config.theme = 'dark'
        config.background_color = 'transparent'
      end

      expect(Mmd2svg.config.theme).to eq('dark')
      expect(Mmd2svg.config.background_color).to eq('transparent')
    end
  end
end
