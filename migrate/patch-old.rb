
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

def options_param(content)
  content = content.gsub(/OptionsParam\.makeOptions\((.*)\)/) do |match|
    "#{$1}"
  end
  content
end

def parms(content)
  content.gsub!(/p\[(.*?)\]\s+=\s+(RangeParam|OptionsParam)\((.*)\)/) do |match|
    path = $1
    obj = $3
    obj.gsub!(/parm:/) do |m| "p:" end
    obj.gsub!(/byte:/) do |m| "b:" end
    obj.gsub!(/range:/) do |m| "rng:" end
    obj.gsub!(/maxVal:/) do |m| "max:" end
    obj.gsub!(/options:/) do |m| "opts:" end
    obj.gsub!(/displayOffset:/) do |m| "dispOff:" end
    obj.gsub!(/extra:\s*\[(.*?)\]/) do |m| "ext: { #{$1} }" end
    "[#{path}, { #{obj} }],"
  end

  content.gsub!(/p\[(.*?)\] = MisoParam\.make\((.*)\)/) do |match|
    path = $1
    obj = $2
    obj.gsub!(/parm:/) do |m| "p:" end
    obj.gsub!(/byte:/) do |m| "b:" end
    obj.gsub!(/range:/) do |m| "rng:" end
    obj.gsub!(/maxVal:/) do |m| "max:" end
    obj.gsub!(/options:/) do |m| "opts:" end
    obj.gsub!(/displayOffset:/) do |m| "dispOff:" end
    obj.gsub!(/extra:\s*\[(.*?)\]/) do |m| "ext: { #{$1} }" end
    "[#{path}, { #{obj} }],"
  end

  content
end

def ranges(content)
  content.gsub!(/(-?\d+)\.\.\.(-?\d+)/) do |match|
    "[#{$1}, #{$2}]"
  end
  content
end

def maps(content)
  content.gsub!(/\(0\.\.\<(\d+)\)\.map\s*\{(.*?)\}/) do |match|
    "(#{$1}).map(i => #{$2})"
  end
  content
end

def string_interp(content)
  content.gsub!(/"([^"]*?)\\\((.*?)\)(.*?)"/) do |match|
    "`#{$1}${#{$2}}#{$3}`"
  end
  content
end




def stat_lets(content)
  content.gsub(/static let (.*)/) do |m|
    "const #{$1}"
  end
end

file_content = synth_paths(file_content)
file_content = options_param(file_content)
file_content = parms(file_content)
file_content = stat_lets(file_content)
file_content = ranges(file_content)
file_content = maps(file_content)
file_content = string_interp(file_content)


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