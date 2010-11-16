class String

  # Returns the string with the first character of each word capitalized, and with underscores substituted by spaces.
  def titleize
    self.humanize.gsub(/\b('?[a-z])/) { $1.capitalize }
  end

  # Returns the string with the very first character capitalized, and with underscores substituted by spaces.
  def humanize
    self.gsub(/_/, " ").capitalize
  end

end