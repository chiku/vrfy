#!/usr/bin/env ruby

require 'open3'
require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'

module OS
  class << self
    def OS.windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def OS.mac?
     (/darwin/ =~ RUBY_PLATFORM) != nil
    end
  end
end

def verify_os
  if OS.windows?
    puts "Windows is not supported!"
    exit 0
  end

  if OS.mac?
    puts "OS X is not officially supported! Your mileage may vary. Continuing..."
  end
end

class Command
  def initialize(cmd)
  end

  def versioned?(version)
    @success && @stdout == version
  end

  def inspect
    @cmd
  end
end

module Minitest::Assertions
  def assert_version(cmd, version)
    _, stdout, stderr, wait_thr = Open3.popen3(cmd)
    code    = wait_thr.value
    success = code == 0
    output  = stdout.readlines.map(&:strip).join("\n")
    error   = stderr.readlines.map(&:strip).join("\n")
    assert success && (output.include?(version) || error.include?(version)), "Expected \"#{cmd}\" to contain \"#{version}\" with exit-code 0, but output was \"#{[output, error].select{|x| x != ''}.join("\n")}\" with exit code #{code}"
  end
end

String.infect_an_assertion :assert_version, :must_have_version, :only_one_argument

VERIFICATIONS = {
  "golang"        => ['go version',    '1.7.4'],
  "java compiler" => ['java -version', '1.7'],
}

verify_os

VERIFICATIONS.each do |name, (cmd, version)|
  describe name do
    it "has version #{version}" do
      cmd.must_have_version version
    end
  end
end
