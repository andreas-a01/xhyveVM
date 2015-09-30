#!/usr/bin/env ruby
#/ Usage: xhyvevm [options] <command>

require 'yaml'
require 'optparse'
require 'ostruct'
require 'logger'

Version = [0,1,0]

require_relative "libs/vm.rb"
require_relative "libs/subscript.rb"
require_relative "libs/helpers.rb"


$logger = Logger.new(STDOUT)
$logger.level = Logger::WARN

$logger.formatter = proc do |severity, datetime, progname, msg|
  "#{severity}: #{msg}\n"
end

class Optparse
    # Return a structure describing the options.
    def self.parse(args, localOptions)
        #Set default options
        user_config = "~/.xhyvevms/config.yaml"
        default_config = File.dirname(__FILE__) + "/../config.yaml"

        if File.file?(File.expand_path(user_config)) then
            config_path = File.expand_path(user_config)
        else
            config_path = File.expand_path(default_config)
        end

        options = OpenStruct.new()

        options.config_path = config_path;
        options.config  = YAML.load_file(config_path)
        options.force = false

        opt_parser = OptionParser.new do |opts|
            if localOptions then
                opts.separator ""
                localOptions.call(opts, options)
            else
                opts.banner = SubScript.grep_head_description(__FILE__)
            end

            # No argument, shows at tail.  This will print an options summary.
            opts.on_tail("-h", "--help", "Show this message") do
                puts opts

                #List all subScripts/commands if no command is given
                if $command.nil? then
                    puts "\nCommands:"
                    SubScript.find_all.each do |s|
                        puts "\t" + s.command + "\t\t\t     " + s.short_description
                    end
                    puts ""
                    puts "\tsee <command> --help for usage"
                end

                exit
            end

            # Switch to print the version.
            opts.on_tail("--version", "Show version") do
                puts ::Version.join('.')
                exit
            end

        end

        begin opt_parser.parse!(args)
        rescue OptionParser::InvalidOption => e
            puts "Invalid option see --help from usage"
            exit
        end

        return options
    end
end

def main
    if (ARGV.length >= 1) && (ARGV[0].match(/^-{1,2}\w+/).nil?) then
        $command = ARGV.shift
    end

    if $command.nil? then
        Optparse.parse(%w[--help], nil)
        exit
    end

    $subScript = SubScript.find($command)

    if $subScript.nil? then
        Optparse.parse(ARGV, nil)
        puts "Unknowed command: " + $command
        puts "See --help for list of commands"
        exit
    end

    require $subScript.path
    # Optparse will exit if --help is set
    $options = Optparse.parse(ARGV, $localOptions)

    #execute run function from subScript
    run
end

# Only run code if executed directly.
if $0 === __FILE__ then
    main
end
