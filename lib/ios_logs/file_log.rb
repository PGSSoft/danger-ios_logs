# rubocop:disable Style/StructInheritance

module Danger
  class FileLog < Struct.new(:file, :line); end
end

# rubocop:enable Style/StructInheritance
