
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
  content = content.gsub(/\(PBKnob\((label: )?(.*?)\), "(.*?)"\)/) do |match|
    "[#{$2}, \"#{$3}\"]"
  end
  content = widget(content, 'checkbox')
  content = widget(content, 'select')
  content = widget(content, 'switch')
  content = widget(content, 'imageSelect', 'imgSelect')
  content
end

def widget(content, t, tt = nil)
  tt ||= t
  pbt = "PB#{t.dup.tap {|s| s[0] = s[0].upcase }}"
  content = content.gsub(/\(#{pbt}\((label: )?(.*?)\),\s*"(.*?)"\)/) do |match|
    "[{#{tt}: #{$2}}, \"#{$3}\"]"
  end

  content = content.gsub(/#{pbt}\((label: )?(.*?)\)/) do |match|
    "{#{tt}: #{$2}}"
  end
  
end

def panels(content)
  content = content.gsub(/(vc\.)?grid\(panel:\s*"(.*?)",\s*items:\s*(.*?)\[(\[?)/) do |match|
    "['panel', '#{$2}', { #{$3}}, [#{$4}"
  end

  content = content.gsub(/vc\.grid\(items:\s*\[\[/) do |match|
    "['grid', [["
  end

  content = content.gsub(/(vc\.)?grid\(view:\s*view,\s*items:\s*\[\[/) do |match|
    "['grid', [["
  end

  
  content = content.gsub(/\]\]\),/, "]]],")
  content = content.gsub(/\]\]\)/, "]]]")

  content = content.gsub(/(vc\.)?addChildren\(count: (\d+), panelPrefix: (.*?), setup: (.*?)\)/) do |match|
    "['children', #{$2}, #{$3}, #{$4}]"
  end

  content = content.gsub(/(vc\.)?addChildren\(count: (\d+), panelPrefix: (.*?), setup:/) do |match|
    "['children', #{$2}, #{$3},"
  end

  content = content.gsub(/(vc\.)?addChild\((.*), withPanel: (.*?)\)/) do |match|
    "['child', #{$2}, #{$3}]"
  end

  content
end

def one_line_enum(content, enum)
  content = content.gsub(/\.#{enum}\((.*)\)/) do |match|
    "['#{enum}', #{$1}]"
  end
end

def layouts(content)
  content = content.gsub(/layout\.addRowConstraints\((.*)/) do |match|
    sub = $1.gsub(/\((.*?),\s*(.*?)\)/) do |m2|
      "[#{$1}, #{$2}]"
    end
    sub = sub.gsub(/options:/) do |m2| "opts:" end    
    "['row', #{sub}"
  end
  content = content.gsub(/layout\.addColumnConstraints\((.*)/) do |match|
    sub = $1.gsub(/\((.*?),\s*(.*?)\)/) do |m2|
      "[#{$1}, #{$2}]"
    end
    sub = sub.gsub(/options:/) do |m2| "opts:" end    
    "['col', #{sub}"
  end
  content = content.gsub(/layout\.addEqualConstraints\(forItemKeys:/) do |match|
    "['eq',"
  end
  content = replace_attr(content, 'leading')
  content = replace_attr(content, 'trailing')
  content = replace_attr(content, 'bottom')
  content = replace_attr(content, 'top')
  
  content = content.gsub(/, spacing: "-s1-"/) do |match| "" end
  content = content.gsub(/, pinned: true/) do |match| "" end
  
end

def replace_attr(content, a)
  content = content.gsub(/attribute: \.#{a}\)/) do |match|
    "'#{a}']"
  end
end

def stat_funcs(content)
  content = content.gsub(/static func (.*)\((.*)\) -> .* {/) do |m|
    "const #{$1} = (#{$2}) => {"
  end
end

# chug it.
file_content = layouts(file_content)

def effects(content)
  
  content.gsub!(/(vc\.)?addPatchChangeBlock\(paths: (.*?)\) { values in/) do |m|
    "['patchChange', { paths: #{$2}, fn: values => {"
  end
  
  content.gsub!(/(vc\.)?addPatchChangeBlock\(\path: (.*?)\)/) do |m|
    "['patchChange', #{$2}, "
  end
  
  content.gsub!(/(vc\.)?registerForEditMenu\((.*?), bundle:/) do |m|
    "['editMenu', #{$2},"
  end
  
  content
end

enums = ['switcher', 'button', 'dimPanel', 'child', 'children', 'basicControlChange', 'basicPatchChange', 'setCtrlLabel', 'configCtrl', 'dimItem', 'simpleGrid', 'dimsOn', 'editMenu', 'setValue', 'controlChange']
enums.each do |en|
  file_content = one_line_enum(file_content, en)
end


file_content = synth_paths(file_content)
file_content = panel_items(file_content)
file_content = panels(file_content)
file_content = effects(file_content)
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