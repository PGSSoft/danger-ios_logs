require 'git_diff_parser'

module Danger
  # rubocop:disable Metrics/LineLength

  # This is a danger plugin to detect any `NSLog`/`print` entries left in the code.
  #
  # @example Ensure, by warning, there are no `NSLog`/`print` entries left in the modified code
  #
  #          ios_logs.check
  #
  # @example Ensure, by fail, there are no `NSLog`/`print` entries left in the modified code
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
    # rubocop:enable Metrics/LineLength
    NSLOG_REGEXP = /\s+NSLog\s*\(/
    PRINT_REGEXP = /\s+print\s*\(/

    NSLOG_MESSAGE = 'There remain `NSLog` in the modified code.'.freeze
    PRINT_MESSAGE = 'There remain `print` in the modified code.'.freeze

    #
    # Notify usage of `NSLog`. `true` by default
    #
    # @return [Bool]
    attr_writer :nslog

    #
    # Notify usage of `print`. `true` by default
    #
    # @return [Bool]
    attr_writer :print

    #
    # List of `print` in changeset
    #
    # @return [Array<FileLog>] List of `print`
    attr_accessor :prints

    #
    # List of `NSLog` in changeset
    #
    # @return [Array<FileLog>] List of `NSLog`
    attr_accessor :nslogs

    #
    # Combined list of both `NSLog` and `print`
    #
    # @return [Array<FileLog>] List of `NSLog` and `print`
    attr_accessor :logs

    #
    # Initialize plugin
    # @param keywords [type] [description]
    #
    # @return [type] [description]
    def initialize(keywords)
      super
      @print = true
      @nslog = true
      @nslogs = []
      @prints = []
    end

    #
    # Combined list of both NSLog and print
    #
    # @return [Array<FileLog>] List of `NSLog` and `print`
    def logs
      prints + nslogs
    end

    #
    # Checks if in the changed code `NSLog` or `print` are used.
    # @param method = :warn [Symbol] Used method to indicate log method usage.
    #   By default `:warn`. Possible values: `:message`, `:warn`, `:fail`
    #
    # @return [Void]
    def check(method = :warn)
      @nslogs = []
      @prints = []

      check_files files_of_interest

      print_logs method
    end

    private

    #
    # Checks if in the files `NSLog` or `print` are used.
    # @param files [Array<String>] List of interested / modified files to check.
    #
    # @return [Void]
    def check_files(files)
      files.select { |file| file.is_a? String }
           .each { |file| check_file file }
    end

    #
    # List of interested files.
    #
    # @return [Array<String>] List of interested / modified files to check.
    def files_of_interest
      git.modified_files + git.added_files
    end

    #
    # Checks if in the file `NSLog` or `print` are used.
    # @param file [String] Modified file to check.
    #
    # @return [Void]
    def check_file(file)
      changed_lines(file).each do |line|
        check_line(file, line)
      end
    end

    #
    # Returns changed lines in modified file.
    # @param file [String] Path to modified files.
    #
    # @return [Array<GitDiffParser::Line>] Modified lines
    def changed_lines(file)
      diff = git.diff_for_file(file)
      GitDiffParser::Patch.new(diff.patch).changed_lines
    end

    #
    # Check line if contains any `NSLog` or `print`
    # @param file [String] Path to file
    # @param line [GitDiffParser::Line] Line number
    #
    # @return [Void]
    def check_line(file, line)
      prints << Danger::FileLog.new(file, line.number) \
        if @print && line.content.match?(PRINT_REGEXP)
      nslogs << Danger::FileLog.new(file, line.number) \
        if @nslog && line.content.match?(NSLOG_REGEXP)
    end

    #
    # Print logs
    # @param method [Symbol] Method to indicate usage
    #
    # @return [Void]
    def print_logs(method)
      print_log_for(@prints, PRINT_MESSAGE, method)
      print_log_for(@nslogs, NSLOG_MESSAGE, method)
    end

    #
    # Print logs for given logs set and message
    # @param logs [Array<FileLog>] List of `NSLog` or `print`
    # @param message [String] Message to print
    # @param method [Symbol] Method to indicate usage
    #
    # @return [Void]
    def print_log_for(logs, message, method)
      logs.each do |log|
        public_send(
          method,
          message,
          sticky: false,
          file: log.file,
          line: log.line
        )
      end
    end
  end
end
