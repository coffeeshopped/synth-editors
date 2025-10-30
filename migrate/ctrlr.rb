
# Check if a file name was provided as an argument
if ARGV.empty?
  puts "Please provide a file name as an argument."
  exit
end

# Get the file name from the command line argument
file_name = ARGV[0]

# Check if the file exists
unless File.exist?(file_name)
  puts "File not found: #{file_name}"
  exit
end

# Open and read the file
file_content = nil
begin
  file_content = File.read(file_name)
rescue => e
  puts "An error occurred while reading the file: #{e.message}"
  exit
end


# Transform file_content

# SynthPath
# regex
def synth_paths(content)
  content.gsub(/\[(\.[^\]]+)\]/) do |match|
    is_template = false
    x = $1.split(",").map { |s| s.strip }.map { |s|
      if s.start_with?(".i(")
        s[3..(s.length-2)]
      elsif s.start_with?(".")
        s[1..]
      else
        is_template = true
        "${#{s}}" # return unchanged if not start with .
      end
    }.join("/")
    is_template ? "`#{x}`" : "\"#{x}\""
  end
end

def panel_items(content)
  content = content.gsub(/\.knob\((.*?)\)/) do |match|
    "[#{$1}]"
  end
  content = widget(content, 'checkbox')
  content = widget(content, 'select')
  content = widget(content, 'switsch')
  content
end

def widget(content, t)
  content = content.gsub(/\.#{t}\((.*?)\)/) do |match|
    x = $1.split(",").map { |s| s.strip }
    if x.length == 2
      "[{#{t}: #{x[0]}}, #{x[1]}]"
    else
      $1
    end
  end
end

def panels(content)
  content = content.gsub(/\.panel\("(.*?)", (.*?)\[\[/) do |match|
    "['panel', '#{$1}', { #{$2}}, [["
  end

  content = content.gsub(/\.grid\(\[\[/) do |match|
    "['grid', [["
  end
  
  content = content.gsub(/\]\]\),/, "]]],")
  content = content.gsub(/\]\]\)/, "]]]")

  content
end

def one_line_enum(content, enum)
  content = content.gsub(/\.#{enum}\((.*)\)/) do |match|
    "['#{enum}', #{$1}]"
  end
end

def layouts(content)
  ['row', 'col', 'rowPart', 'colPart'].each do |rc|
    content = content.gsub(/\.#{rc}\((.*)\)/) do |m|
      arrMatch = m.match(/\[(.*?)\]/)
      arr = ""
      if arrMatch
        arr = arrMatch[1].gsub(/\((.*?)\)/) do |m2|
          "[#{$1}]"
        end
      end
    
      opts = ""
      optMatch = m.match(/opts: \[(.*?)\]/)
      if optMatch
        o = optMatch[1].split(',').map { |s| "'#{(s.strip)[1..]}'" }.join(', ')
        opts = ", { opts: [#{o}] }"
      end
      "['#{rc}', [#{arr}]#{opts}]"
    end
  end

  content = content.gsub(/\.eq\((.*)\)/) do |m|
    stuff = $1.gsub(/\.(.*)/) do |m2|
      "'#{$1}'"
    end
    "['eq', #{stuff}]"
  end

  content
end

def stat_funcs(content)
  content = content.gsub(/static func (.*)\((.*)\) -> .* {/) do |m|
    "const #{$1} = (#{$2}) => {"
  end
end

# chug it.
file_content = layouts(file_content)

enums = ['switcher', 'button', 'dimPanel', 'child', 'children', 'basicControlChange', 'basicPatchChange', 'setCtrlLabel', 'configCtrl', 'dimItem', 'simpleGrid', 'dimsOn', 'editMenu', 'setValue', 'controlChange']
enums.each do |en|
  file_content = one_line_enum(file_content, en)
end

file_content = synth_paths(file_content)
file_content = panel_items(file_content)
file_content = panels(file_content)
file_content = stat_funcs(file_content)



# MARK: Output

def transform_filename(filename)
  base_name = File.basename(filename, ".*")
  extension = File.extname(filename)
  
  File.join(File.dirname(filename), "#{base_name}-out#{extension}")
end

# Specify the file name
out_file = transform_filename(file_name)

# Write the string to the file
begin
  File.open(out_file, "w") do |file|
    file.write(file_content)
  end
  puts "Successfully wrote to #{out_file}"
rescue => e
  puts "An error occurred while writing to the file: #{e.message}"
end

puts "Complete."