#!/usr/env ruby
# enconding: UTF-8

require 'digest'
require 'yaml'
require 'yaml/store'

##
# "Enter the Carrousel. This is the time of renewal."
#
# Carrousel is a system command execution and tracker utility.
module Carrousel

  class Runner

    def initialize(args, opts = {})
      @args = args
      @opts = opts
      @incomplete = []
      @complete = []

      unless @opts[:listfile].nil?
        lines = File.readlines(@opts[:listfile]).map(&:strip)
        @incomplete.concat(lines)
      end
      @incomplete.concat(@args)

      @opts[:statusfile] ||= generate_status_filename
      open_status_file

      p self if @opts[:debug]

      raise ArgumentError.new("Command option is required") if @opts[:command].nil?
    end # def initialize

    def run
      # Loop over everything in the list. Run the command. If the command fails
      # then we move the item to the bottom of the list. If the command
      # succeeds, we move the item to the completed list. If we are interrupted
      # in the middle of processing, we ensure that the item is saved in the
      # normal list, and we ensure that we write out the completed list.
      until @incomplete.empty?
        begin
          command = [@opts[:command], @incomplete.first].join(' ')
          warn "Executing command: #{command}" if @opts[:verbose]
          resp = system(command)
          warn "System response: #{resp}" if @opts[:verbose]
          if resp
            @complete << @incomplete.delete(@incomplete.first)
          else
            @incomplete.rotate!
          end
        ensure
          save_status_file
        end

        if @opts[:delay] > 0
          warn "Sleeping for #{@opts[:delay]} seconds" if @opts[:verbose]
          sleep @opts[:delay]
        end
      end # until @incomplete.empty?
    end # def run

    private
    def generate_status_filename
      key = Digest::SHA256.hexdigest(@incomplete.sort.join).slice(0...7)
      warn "status file key: #{key}" if @opts[:debug]
      name = self.class.name.gsub('::', '_').downcase
      File.expand_path(".#{name}_status_#{key}", Dir.pwd)
    end # def generate_status_filename

    private
    def open_status_file
      resume = File.exists?(@opts[:statusfile])
      @store = YAML::Store.new @opts[:statusfile]
      warn "opened status file: #{@store.path}" if @opts[:debug]

      if resume
        @store.transaction(true) do # read-only transaction
          @opts[:command] ||= @store[:command]
          @complete.concat(@store[:complete])
          @incomplete.concat(@store[:incomplete])
        end
      end

    end # def open_status_file

    private
    def save_status_file
      warn "Saving status file: #{@store.path}" if @opts[:verbose]

      @store.transaction do
        @store[:command]    = @opts[:command]
        @store[:complete]   = @complete
        @store[:incomplete] = @incomplete
      end

      warn "Saved status file: #{@store.path}" if @opts[:debug]
    end # def save_status_file

  end # class Runner
end # module Carrousel
