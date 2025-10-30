
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


def one_line_enum(content, enum)
  content = content.gsub(/\.#{enum}\((.*)\)/) do |match|
    "['#{enum}', #{$1}]"
  end
end


def stat_lets(content)
  content.gsub(/static let (.*)/) do |m|
    "const #{$1}"
  end
end

template_str = <<-END
const editor = {
  name: "",
  trussMap: [
    ["global", "channel"],
    ['voice', Voice.patchTruss],
    ['bank/voice', Voice.bankTruss],
  ],
  fetchTransforms: [
  ],

  midiOuts: [
  ],
  
  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: [
  ],
}


END



# chug it.

file_content = synth_paths(file_content)
file_content = template_str + file_content
# file_content = stat_lets(file_content)



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