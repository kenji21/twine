require 'pathname'

module Twine
  module Formatters
    class AppleSwiftTag < Abstract
      FORMAT_NAME = 'apple-swift-tag'
      EXTENSION = '.swift'
      DEFAULT_FILE_NAME = 'R2Tag+TxtFileName.swift'

      def self.can_handle_directory?(path)
        true
      end

      def default_file_name
        return DEFAULT_FILE_NAME
      end

      def determine_language_given_path(path)
        raise 'not going to implement'
      end

      def read_file(path, lang)
        raise 'not going to implement'
      end

      def write_file(path, lang)
        default_lang = @strings.language_codes[0]
        filePath = Pathname.new(path)
        stringFileName = filePath.basename.to_s[0..-7]
        
        impl = "R2Tag+" + stringFileName + ".swift"
        implPath = filePath.dirname + impl
        File.open(implPath, 'w:UTF-8') do |f|
          f.puts "/**\n * Swift File\n * Generated by Twine #{Twine::VERSION}\n */"
          f.write "\n"
          f.write (<<S).strip
import Foundation

fileprivate let kStringsFileName = "#{stringFileName}"

extension R2Tag {
S
          f.write "\n"
          f.write "\n"
          @strings.sections.each do |section|
            printed_section = false
            section.rows.each do |row|
              if row.matches_tags?(@options[:tags], @options[:untagged])
                if !printed_section
                  if section.name && section.name.length > 0
                    section_name = section.name
                    f.puts "    // MARK: - #{section_name}"
                    f.write "\n"
                  end
                  printed_section = true
                end

                key = row.key

                value = row.translated_string_for_lang(lang, default_lang)
                if !value && @options[:include_untranslated]
                  value = row.translated_string_for_lang(@strings.language_codes[0])
                end

                if value # if values is nil, there was no appropriate translation, so let Android handle the defaulting
                  value = String.new(value) # use a copy to prevent modifying the original

                  value.gsub!('"', '\\\\"')
                  f.write (<<S).rstrip
    var #{key}: String {
        return "#{value}"
    }
S
                  f.write "\n"
                  f.write "\n"
                end
              end
            end
          end
          f.write (<<S).rstrip
}
S
          f.write "\n"
        end
      end
    end
  end
end

Twine::Formatters.formatters << Twine::Formatters::AppleSwiftTag.new
