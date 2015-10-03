#!/usr/bin/env ruby
#/ Usage: xhyvevm [options] <command>

require 'yaml'
require 'optparse'
require 'ostruct'
require 'logger'

require_relative "libs/vm.rb"
require_relative "libs/subscript.rb"
require_relative "libs/helpers.rb"

Version = [0,1,0]

$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

$logger.formatter = proc do |severity, datetime, progname, msg|
    if severity == "INFO" then
        "#{msg}\n"
    else
        "#{severity}: #{msg}\n"
    end
end

class Optparse
    # Return a structure describing the options.
    def self.parse(args, localOptions)

        options = OpenStruct.new()

        # Set default options
        options.user_config = File.expand_path("~/.xhyvevms/config.yaml")
        options.default_config = File.expand_path(File.dirname(__FILE__) + "/../config.yaml")

        if File.file?(options.user_config) then
            config_path = options.user_config
        else
            config_path = options.default_config
        end


        options.config_path = config_path;
        options.config  = YAML.load_file(config_path)

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

                # List all subScripts/commands if no command is given
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

        begin
            opt_parser.parse!(args)
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

    # Execute run function from subScript
    run
end

# Only run code if executed directly.
if $0 === __FILE__ then
    main
end
