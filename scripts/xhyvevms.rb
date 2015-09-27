#!/usr/bin/env ruby
#/ Usage: xhyvevms [options] <command>


require 'yaml'
require 'optparse'
require 'ostruct'
require_relative "./lib.rb"

Version = [0,0,1]

class Optparse

    # Return a structure describing the options.
    def self.parse(args, commands, localOptions)

        config_path =  File.expand_path("~/.xhyvevms/config.yaml")
        default_options = YAML.load_file(config_path)
        options = OpenStruct.new(default_options)


        options.inplace = false
        options.encoding = "utf8"
        options.transfer_type = :auto
        options.verbose = false

        opt_parser = OptionParser.new do |opts|

            if localOptions then
                opts.separator ""
                localOptions.call opts
            else
                opts.banner = grep_head_description(__FILE__)
            end

            opts.separator ""
            opts.separator "Global options:"

            # Force
            opts.on("--force", "force", String)   { options.force = true }

            # Boolean switch.
            opts.on("-v", "--verbose", "Run verbosely") do |v|
                options.verbose = v
            end


            opts.separator ""
            opts.separator "Common options:"

            # No argument, shows at tail.  This will print an options summary.
            opts.on_tail("-h", "--help", "Show this message") do
                puts opts

                #List all commands if no command is given
                if $command.nil? then
                    puts "\nCommands:"
                    commands.each do |command|
                        puts "\t" + command.to_s() + "\t\t\t     " + command.description()
                    end
                end

                exit
            end

            # Another typical switch to print the version.
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

        options
    end
end

def main
    commands = available_commands()
    command_string = ARGV.first

    if command_string.nil? then
        Optparse.parse(%w[--help], commands, nil)
        exit
    end

    index = commands.index { |command| command.to_s == command_string }

    if index.nil? then
        puts "Unknowed command: " + command_string
        puts "See --help for commands"
        exit
    else
        $command = commands[index]
    end

    require $command.path
    $options = Optparse.parse(ARGV,commands, $localOptions)

    command()
end

# Only run code if executed directly.
if $0 === __FILE__ then
    main()
end
