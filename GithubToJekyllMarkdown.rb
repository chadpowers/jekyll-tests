# adds Front Matter and fixes links for converting GitHub markdown docs to Jekyll-ready markdown docs
# finds and applies to all files in current directory and its sub-directory

file_names  = Dir.glob("**/*.md")
file_names += Dir.glob("**/*.mkdn")
file_names += Dir.glob("**/*.mdown")
file_names += Dir.glob("**/*.markdown")



inline_link    = /(\]\(\s*)([^\#])(.)*\.[A-Za-z0-9]*\s*\)/
reference_link = /(\]\:\s*)([^\#])(.)*\.[A-Za-z0-9]*/
invalid_ending = /(index)*\.(md|markdown|mdown|mkdn)/

def isIndexFile(file_name)
  return (file_name.include?("index.md")    \
    or file_name.include?("index.mkdn")     \
    or file_name.include?("index.markdown") \
    or file_name.include?("index.mdown"))
end

def containsStandingURL(s)
  return (s.include?("https://") or s.include?("http://") or s.include?("www."))
end

file_names.each do |file_name| 
  text = File.read(file_name)

  # adds Front Matter used by Jekyll in conversion to HTML
  # assumes 'layout: documentation'
  new_contents = ""
  if !((text =~ /\s*---\s*\n/) == 0)
    new_contents << "---\n"
    new_contents << "layout: documentation\n"
    new_contents << "title: "
    new_contents << file_name
    new_contents << "\n---\n\n"
  end

  new_contents << text


  # Fix links before processing by Jekyll, 
  # 1) removes '.md', .'markdown', etc., 
  #       from same intra-directory links (solves Jekyll issue)
  # 2) adds '../' to intra-directory links (solves Jekyll issue)
  
  # resolves links in files ending in index.*
  if isIndexFile(file_name)

    # inline lines w/ format
    new_contents = new_contents.gsub(inline_link) {|s| if containsStandingURL(s)
      s # do nothing if it is free standing url link (includes http(s):// or www.)
    else 
      s.gsub(invalid_ending, "")
    end}

    # reference lines w/ format
    new_contents = new_contents.gsub(reference_link) {|s| if containsStandingURL(s)
      s # do nothing if it is free standing url link (includes http(s):// or www.)
    else 
      s.gsub(invalid_ending, "")
    end}

  # resolves links in files NOT ending in index.*
  else

    # inline lines w/ format
    new_contents = new_contents.gsub(inline_link) {|s| if containsStandingURL(s)
      s # do nothing if it is free standing url link (includes http(s):// or www.)
    else 
      s.gsub(invalid_ending, "").gsub(/\]\(\s*/, "\]\(\.\.\/")
    end}
    # reference lines w/ format
    new_contents = new_contents.gsub(reference_link) {|s| if containsStandingURL(s)
      s # do nothing if it is free standing url link (includes http(s):// or www.)
    else 
      s.gsub(invalid_ending, "").gsub(/\]\:\s*/, "\]\:\s\.\.\/")
    end}
  end
  
  File.open(file_name, "w") {|file| file.puts new_contents }
end