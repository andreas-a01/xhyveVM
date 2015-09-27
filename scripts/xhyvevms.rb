#!/usr/bin/env ruby
#/ Usage: xhyvevms [options] <command>


require 'yaml'
require 'optparse'
require 'ostruct'
require_relative "./lib.rb"

Version = [0,0,1]

class Optparse

    # Return a structure describing the options.
    def self.parse(args, subScripts, localOptions)

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

                #List all subScripts/commands if no command is given
                if $command.nil? then
                    puts "\nCommands:"
                    subScripts.each do |s|
                        puts "\t" + s.command + "\t\t\t     " + s.description
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
    subScripts = availableSubScripts()
    $command = ARGV.first

    if $command.nil? then
        Optparse.parse(%w[--help], subScripts, nil)
        exit
    end

    index = subScripts.index { |script| $command == script.command }

    if index.nil? then
        Optparse.parse(ARGV,subScripts, nil)
        puts "Unknowed command: " + $command
        puts "See --help for commands"
        exit
    end

    $subScript = subScripts[index]
    require $subScript.path
    $options = Optparse.parse(ARGV,subScripts, $localOptions)

    #execute run function from subScript
    run()
end

# Only run code if executed directly.
if $0 === __FILE__ then
    main()
end
