#!/usr/env ruby
# enconding: UTF-8

require "carrousel/version"
require 'digest'
require 'yaml'

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

      raise ArgumentError.new("Missing command argument") if @opts[:command].nil?
    end # def initialize

    def run
      # Loop over everything in the list. Run the command. If the command fails
      # then we move the item to the bottom of the list. If the command
      # succeeds, we move the item to the completed list. If we are interrupted
      # in the middle of processing, we ensure that the item is saved in the
      # normal list, and we ensure that we write out the completed list.
      until @incomplete.empty?
        begin
          warn "Executing command:#{@opts[:command]} with arg:#{@incomplete.first}" if @opts[:verbose]
          resp = system([@opts[:command], @incomplete.first].join(' '))
          warn "System response:#{resp}" if @opts[:verbose]
          if resp
            @complete << @incomplete.delete(@incomplete.first)
          else
            @incomplete.rotate!
          end
        ensure
          save_status_file
        end
      end # until @incomplete.empty?
    end # def run

    private
    def generate_status_filename
      key = Digest::SHA256.hexdigest(@incomplete.sort.join).slice(0...7)
      warn "status filename key:#{key}" if @opts[:debug]
      name = self.class.name.gsub('::', '_').downcase
      File.expand_path(".#{name}_status_#{key}", Dir.pwd)
    end # def generate_status_filename

    private
    def open_status_file
      if File.exists?(@opts[:statusfile])
        dbs = YAML.load(File.read(@opts[:statusfile]))
        warn "YAML status file:#{dbs}" if @opts[:debug]
        if dbs
          @opts[:command] ||= dbs[:command]
          @complete.concat(dbs[:complete])
          @incomplete.concat(dbs[:incomplete])
        end
      end
    end # def open_status_file

    private
    def save_status_file
      warn "Saving status file:#{@opts[:statusfile]}" if @opts[:verbose]
      File.open(@opts[:statusfile], 'w') do |f|
        ydb = {
          :command => @opts[:command],
          :complete => @complete,
          :incomplete => @incomplete
        }.to_yaml
        warn "YAML status file:#{ydb}" if @opts[:debug]
        f.puts(ydb)
      end
      true
    end # def save_status_file

  end # class Runner
end # module Carrousel
