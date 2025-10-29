# mermaid2svg

Convert Mermaid diagrams to SVG files using Puppeteer. Supports both CLI and programmatic usage with batch conversion capabilities.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mermaid2svg'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install mermaid2svg
```

## Usage

### Command Line Interface

#### Basic Usage

```bash
# Convert a single file
mermaid2svg diagram.mmd -o output.svg

# Convert with options
mermaid2svg diagram.mmd -o output.svg --theme dark --background transparent

# Batch conversion from directory
mermaid2svg diagrams/ -o output/

# Batch conversion with glob pattern
mermaid2svg diagrams/*.mmd -o output/

# Recursive directory conversion
mermaid2svg diagrams/ -o output/ --recursive
```

#### CLI Options

```
Options:
  -o, --output PATH          Output file or directory path (required)
  -t, --theme THEME          Theme: default, dark, forest, neutral (default: default)
  -b, --background COLOR     Background color: transparent, white, or #hexcode (default: white)
  -w, --width WIDTH          Output width in pixels
  -h, --height HEIGHT        Output height in pixels
  -c, --config FILE          Config file path (default: .mermaid2svg.yml)
  -r, --recursive            Process directories recursively
  --timeout MILLISECONDS     Puppeteer timeout in ms (default: 30000)
  --skip-errors              Continue processing even if errors occur
  --version                  Show version
  --help                     Show help message
```

### Ruby API

#### Single File Conversion

```ruby
require 'mermaid2svg'

# Render from code string
mermaid_code = <<~MERMAID
  graph TD
    A[Start] --> B[Process]
    B --> C[End]
MERMAID

Mermaid2svg.render(mermaid_code, output: 'diagram.svg')

# Render from file
Mermaid2svg.render('diagram.mmd', output: 'output.svg')

# Get SVG as string
svg_string = Mermaid2svg.render_to_string(mermaid_code)
```

#### Batch Conversion

```ruby
# Convert all .mmd files in a directory
results = Mermaid2svg.render_batch('diagrams/', output_dir: 'output/')

# With glob pattern
results = Mermaid2svg.render_batch('diagrams/*.mmd', output_dir: 'output/')

# Recursive conversion
results = Mermaid2svg.render_batch(
  'diagrams/',
  output_dir: 'output/',
  recursive: true
)

# Check results
puts "Succeeded: #{results[:succeeded].count}"
puts "Failed: #{results[:failed].count}"
```

#### With Options

```ruby
Mermaid2svg.render(
  mermaid_code,
  output: 'diagram.svg',
  theme: 'dark',
  background_color: 'transparent',
  width: 800,
  height: 600
)
```

#### Global Configuration

```ruby
Mermaid2svg.configure do |config|
  config.theme = 'dark'
  config.background_color = 'transparent'
  config.puppeteer_timeout = 60000
end

# Now all renders use these settings
Mermaid2svg.render(code, output: 'diagram.svg')
```

### Configuration File

Create a `.mermaid2svg.yml` file in your project root:

```yaml
# Theme setting
theme: default  # default, dark, forest, neutral

# Background color
background_color: white  # transparent, white, or #hexcode

# Output size (optional)
# width: 800
# height: 600

# Puppeteer settings
puppeteer:
  headless: true
  timeout: 30000
  args:
    - '--no-sandbox'
    - '--disable-setuid-sandbox'

# Mermaid.js settings
mermaid:
  securityLevel: 'loose'
  startOnLoad: true
  theme: default
  logLevel: 'error'

# Batch conversion settings
batch:
  recursive: false
  overwrite: true
  skip_errors: false
```

## Supported Mermaid Diagram Types

This gem supports all diagram types that Mermaid.js supports:

- Flowchart
- Sequence Diagram
- Class Diagram
- State Diagram
- Entity Relationship Diagram
- User Journey
- Gantt Chart
- Pie Chart
- Git Graph
- And more...

## Error Handling

The gem provides custom exceptions for different error scenarios:

```ruby
begin
  Mermaid2svg.render('invalid.mmd', output: 'out.svg')
rescue Mermaid2svg::RenderError => e
  puts "Render failed: #{e.message}"
rescue Mermaid2svg::FileNotFoundError => e
  puts "File not found: #{e.message}"
rescue Mermaid2svg::PuppeteerError => e
  puts "Puppeteer error: #{e.message}"
rescue Mermaid2svg::ConfigError => e
  puts "Configuration error: #{e.message}"
end
```

## Examples

### Example 1: Simple Flowchart

```ruby
code = <<~MERMAID
  graph LR
    A[Square Rect] --> B((Circle))
    A --> C(Round Rect)
    B --> D{Rhombus}
    C --> D
MERMAID

Mermaid2svg.render(code, output: 'flowchart.svg')
```

### Example 2: Sequence Diagram with Dark Theme

```ruby
code = <<~MERMAID
  sequenceDiagram
    Alice->>John: Hello John, how are you?
    John-->>Alice: Great!
    Alice-)John: See you later!
MERMAID

Mermaid2svg.render(
  code,
  output: 'sequence.svg',
  theme: 'dark',
  background_color: 'transparent'
)
```

### Example 3: Batch Convert Project Diagrams

```ruby
results = Mermaid2svg.render_batch(
  'docs/diagrams/',
  output_dir: 'public/images/',
  recursive: true,
  theme: 'forest'
)

results[:failed].each do |failure|
  puts "Failed: #{failure[:file]} - #{failure[:error]}"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
