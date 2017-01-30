require "git_diff_parser"

module Danger
  # This is a danger plugin to detect any `NSLog`/`print` entries left in the code.
  #
  # @example Ensure, by warning, there are no `NSLog`/`print` left in the modified code
  #
  #          ios_logs.check
  # 
  # @example Ensure, by fail, there are no `NSLog`/`print` left in the modified code
  # 
  #          ios_logs.check :fail
  # 
  # @example Ensure, there are no `print` left in the modified code. Ignore `NSLog`
  # 
  #          ios_logs.nslog = false
  #          ios_logs.check
  #
  # @see  Bartosz Janda/danger-ios_logs
  # @tags ios, logs, print, nslog, swift
  #
  class DangerIosLogs < Plugin

    NSLOG_REGEXP = /\s+NSLog\s*\(/
    PRINT_REGEXP = /\s+print\s*\(/

    NSLOG_MESSAGE = "There remain `NSLog` in the modified code."
    PRINT_MESSAGE = "There remain `print` in the modified code."

    # Notify usage of `NSLog`. `true` by default
    # 
    # @return [Bool]
    attr_writer :nslog

    # Notify usage of `print`. `true` by default
    # 
    # @return [Bool]
    attr_writer :print

    # 
    # Initialize plugin
    # @param keywords [type] [description]
    # 
    # @return [type] [description]
    def initialize(keywords)
      super(keywords)
      @print = true
      @nslog = true
    end

    # 
    # Checks if in the changed code are used any `NSLog`s or `print`s
    # @param method = :warn [Symbol] Used method to indicate log method usage. By default `:warn`. Possible values: `:message`, `:warn`, `:fail`
    # 
    # @return [Void]
    def check(method = :warn)
      files = files_of_interest
      files.select { |f| f.is_a?(String) }
        .each do |file|
          GitDiffParser::Patch.new(git.diff_for_file(file).patch).changed_lines.each do |line|
            check_line(file, line, method)
          end
      end
    end

    private
    # 
    # List of interested files.
    # 
    # @return [Array<String>] List of interested / modified files to check.
    def files_of_interest
      git.modified_files + git.added_files
    end

    # 
    # Check line if contains any `NSLog` or `print`
    # @param file [String] Path to file
    # @param line [String] Line number
    # @param method [Symbol] Method to indicate usage
    # 
    # @return [type] [description]
    def check_line(file, line, method)
      public_send(method, NSLOG_MESSAGE, sticky: false, file: file, line: line.number) if @nslog && line.content.match?(NSLOG_REGEXP)
      public_send(method, PRINT_MESSAGE, sticky: false, file: file, line: line.number) if @print && line.content.match?(PRINT_REGEXP)
    end
  end
end
