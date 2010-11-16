module Moka
  module LipsumHelpers
    require File.expand_path('lipsum_constants.rb', File.dirname(__FILE__))
  
    class Lipsum

      # If called without a block, returns a number of paragraphs of dummy text equal to count (with each paragraph enclosed in <p>...</p>). If a block is given, iteratively calls the block passing each paragraph as argument.
      #
      def self.paragraphs(count, &block)
        if block_given?
          count.to_i.times do |i|
            yield LipsumConstants::PARAGRAPHS[i]
          end
        else
          return LipsumConstants::PARAGRAPHS[0, count].collect{|p| "<p>#{p}</p>\n"}.join
        end
      end

      # If called without a block, returns a string of dummy text with a number of sentences equal to count (without any markup). If a block is given, iteratively calls the block passing each sentence as argument.
      #
      def self.sentences(count, &block)
        sentences = LipsumConstants::PARAGRAPHS.join.split(/\.\s*/)
        if block_given?
          count.to_i.times do |i|
            yield sentences[i]
          end
        else
          return sentences[0, count].join(". ")
        end
      end

      # If called without a block, returns a string of dummy text with a number of words equal to count (space-separated and without any markup). If a block is given, iteratively calls the block passing each word as argument.
      #
      # ==== Gotcha:
      #
      # If a block is given, the block is iteratively called passing as arguments only words more than 3 characters long. This way, nice dummy lists and menus can be generated without having to remove very short words.
      #
      def self.words(count, &block)
        words = LipsumConstants::PARAGRAPHS.join.split(/[\W+]/)
        if block_given?
          shifter = 0
          count.to_i.times do |i|
            if words[i].size > 3
              yield words[i].downcase
            else
              shifter += 1
            end
          end
        else
          return words[0, count].join(" ")
        end
      end

    end
  end
end