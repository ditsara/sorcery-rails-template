require 'erb'

files = [
  'template.rb.erb'
]

files.each do |filename|
  input = File.read filename
  new_filename = filename.split('.')[0..-2].join('.')
  File.open(new_filename, 'w') do |new_file|
    new_file.write ERB.new(input).result
  end
end
