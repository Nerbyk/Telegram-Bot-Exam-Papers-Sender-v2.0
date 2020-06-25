# frozen_string_literal: true

text = File.read('./test.rb')
replace = text.gsub(/Test/, 'replaced')
File.open('./test.rb', 'w') { |file| file.puts replace }
