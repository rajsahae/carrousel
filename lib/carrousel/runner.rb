#!/usr/env ruby
# enconding: UTF-8

require 'digest'
require 'yaml'
require 'yaml/store'
require 'proc/wait3'

##
# "Enter the Carrousel. This is the time of renewal."
#
# Carrousel is a system command execution and tracker utility.
module Carrousel

  class Runner

    CONTINUE_SIGNAL = 25

    def initialize(args, opts = {})
      @args      = args
      @opts      = opts

      incomplete = []
      complete   = []

      warn @opts.inspect if @opts[:debug]

      unless @opts[:listfile].nil?
        lines = File.readlines(@opts[:listfile]).map(&:strip)
        incomplete.concat(lines)
      end
      incomplete.concat(@args)

      warn "incomplete after cli parse: #{incomplete}" if @opts[:debug]
      warn "complete after cli parse: #{complete}"   if @opts[:debug]

      @opts[:statusfile] ||= generate_status_filename(incomplete.sort.join + Time.now.to_s)
      open_status_file(incomplete, complete)

      warn "incomplete after statusfile parse: #{incomplete}" if @opts[:debug]
      warn "complete after statusfile parse: #{complete}"     if @opts[:debug]

      raise ArgumentError.new("Command option is required") if @opts[:command].nil?
    end # def initialize

    def run
      # Loop over everything in the list. Run the command. If the command fails
      # then we move the item to the bottom of the list. If the command
      # succeeds, we move the item to the completed list. If we are interrupted
      # in the middle of processing, we ensure that the item is saved in the
      # normal list, and we ensure that we write out the completed list.

      begin

        until @store.transaction(true) { @store[:incomplete].empty? && @store[:processing].empty? }

          until @store.transaction(true) { @store[:incomplete].empty? }

            if @store.transaction(true) { @store[:pids].size < @opts[:maxjobs] }
              target = nil
              @store.transaction do
                target = @store[:incomplete].delete_at(0)
                @store[:processing].push(target)
              end

              warn "creating new job for target: #{target}" if @opts[:debug]
              pid = Process.fork { create_new_job(target) }
              warn "Forked job: #{pid}" if @opts[:debug]

              @store.transaction do
                @store[:pids].push(pid)
                warn "Num jobs: #{@store[:pids].size} Current jobs: #{@store[:pids]}" if @opts[:debug]
              end

              warn "Detaching #{pid}" if @opts[:debug]
              Process.detach(pid) # We don't plan to monitor these  

              warn "Sending continue signal to #{pid}" if @opts[:debug]
              Process.kill(CONTINUE_SIGNAL, pid)
            end

          end
        end

      ensure
        save_status_file
      end

    end

    private
    def create_new_job(target)
      warn "<#{target}> Job created. Pausing #{Process.pid}" if @opts[:debug]
      Process.pause(CONTINUE_SIGNAL)
      warn "<#{target}> Resuming job #{Process.pid}" if @opts[:debug]

      command = [@opts[:command], target].join(' ')
      warn "<#{target}> Executing command: #{command}" if @opts[:verbose]
      resp = system(command)
      warn "<#{target}> System response: #{resp}" if @opts[:verbose]

      @store.transaction do
        @store[:processing].delete(target)

        if resp
          @store[:complete] << target
        else
          @store[:incomplete] << target
        end

        @store[:pids].delete(Process.pid)

        warn "Removing pid from queue: #{Process.pid}" if @opts[:debug]
        warn "Num jobs: #{@store[:pids].size} Current jobs: #{@store[:pids]}" if @opts[:debug]
      end

    end # def run

    private
    def generate_status_filename(string)
      key = Digest::SHA256.hexdigest(string).slice(0...7)
      warn "status file key: #{key}" if @opts[:debug]
      name = self.class.name.gsub('::', '_').downcase
      File.expand_path(".#{name}_status_#{key}", Dir.pwd)
    end # def generate_status_filename

    private
    def open_status_file(incomplete, complete)
      resume = File.exists?(@opts[:statusfile])
      @store = YAML::Store.new @opts[:statusfile]
      warn "opened status file: #{@store.path}" if @opts[:debug]

      @store.transaction do
        @store[:processing] = []
        @store[:pids] = []
      end

      warn "resuming: #{resume}" if @opts[:debug]

      if resume
        @store.transaction(true) do # read-only transaction
          @opts[:command] ||= @store[:command]
          @store[:incomplete].concat(incomplete)
          @store[:complete].concat(complete)
        end
      else
        @store.transaction do
          @store[:command]    = @opts[:command]
          @store[:incomplete] = incomplete
          @store[:complete]   = complete
        end
      end

    end # def open_status_file

    private
    def save_status_file

      @store.transaction do
        @store[:pids].each do |process|
          warn "Killing #{process}" if @opts[:debug]
          Process.kill('KILL', process)
        end

        @store[:incomplete].concat(@store[:processing])
        @store.delete(:processing)
        @store.delete(:pids)
      end

      warn "Saved status file: #{@store.path}" if @opts[:debug]
    end # def save_status_file

  end # class Runner
end # module Carrousel
