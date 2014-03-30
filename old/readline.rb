require 'io/console' # Ruby 1.9

word = ""

@completions = {
    "fun" => "function"
}

while (char = $stdin.getch) != "\r"
  word += char
  word = "" if char == " "
  if char == "\t" && @completions.include?(word = word[0..-2])
    print @completions[word][word.length..-1]
  else
    print char
  end
end
