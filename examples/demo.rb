#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/mmd2svg'

puts '=== Mmd2svg Demo ==='
puts ''

# Example 1: Simple render to string
puts '1. Rendering a simple diagram to string...'
simple_diagram = <<~MERMAID
  graph LR
    A[Hello] --> B[World]
MERMAID

begin
  svg = Mmd2svg.render_to_string(simple_diagram)
  puts "✓ Successfully generated SVG (#{svg.length} characters)"
rescue StandardError => e
  puts "✗ Error: #{e.message}"
end
puts ''

# Example 2: Render to file
puts '2. Rendering to file...'
begin
  Mmd2svg.render(simple_diagram, output: 'demo_output.svg')
  puts '✓ Saved to demo_output.svg'
rescue StandardError => e
  puts "✗ Error: #{e.message}"
end
puts ''

# Example 3: Using configuration
puts '3. Using custom configuration...'
Mmd2svg.configure do |config|
  config.theme = 'dark'
  config.background_color = 'transparent'
end

complex_diagram = <<~MERMAID
  sequenceDiagram
    participant A as Alice
    participant B as Bob
    A->>B: Hello Bob!
    B->>A: Hello Alice!
MERMAID

begin
  Mmd2svg.render(complex_diagram, output: 'demo_dark.svg')
  puts '✓ Saved dark theme diagram to demo_dark.svg'
rescue StandardError => e
  puts "✗ Error: #{e.message}"
end
puts ''

# Example 4: Batch conversion
puts '4. Batch conversion of examples...'
begin
  results = Mmd2svg.render_batch(
    '../examples/',
    output_dir: 'demo_batch_output/',
    theme: 'forest'
  )

  puts '✓ Batch conversion completed:'
  puts "  - Succeeded: #{results[:succeeded].count}"
  puts "  - Failed: #{results[:failed].count}"

  results[:succeeded].each do |result|
    puts "    ✓ #{result[:input]} → #{result[:output]}"
  end

  results[:failed].each do |result|
    puts "    ✗ #{result[:file]}: #{result[:error]}"
  end
rescue StandardError => e
  puts "✗ Error: #{e.message}"
end
puts ''

puts '=== Demo Complete ==='
puts ''
puts 'Check the generated files:'
puts '  - demo_output.svg'
puts '  - demo_dark.svg'
puts '  - demo_batch_output/'
