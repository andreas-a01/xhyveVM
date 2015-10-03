#!/usr/bin/env ruby
#/ Usage: xhyvevm-check [options]
#/ Check config, dependences and VMs


# Local Options
$localOptions = Proc.new { |opts|
    opts.banner = SubScript.grep_head_description(__FILE__)
}

def run
    if ARGV.length != 0 then
        $logger.error("#{$command} takes no arguments")
        exit
    end

    error = false

    # Config
    $logger.info("Config:")
    if $options.config_path == $options.user_config then
        $logger.info("\tUsing user config: #{$options.user_config}")
    else
        $logger.info("\tUsing default config: #{$options.default_config},")
        $logger.info("\tbefore changin it, copy it to: #{$options.user_config}")
    end
    #TODO: check premissions

    $logger.info("\nDependences:")
    # Check every (non-standard OS X) command is pressent
    commands_found = true
    required_commands = ['dtach']
    required_commands.each do |command|
        if ! check_command(command) then
            $logger.error("#{command} not found")
            commands_found = false
            error = true
        end
    if commands_found then
        $logger.info("\t All dependencies found.")
    end
    #TODO: instructions to install faild

    $logger.info("\nVMS path:")
    # Check vms_path exsit
    vmspath = File.expand_path($options['config']['vms_path'])
    if (! File.exist?(vmspath)) then
        $logger.error("can't open vmspath: #{vmspath}, please create it.")
        error = true
    else
        $logger.info("\tVMS path exist.")
    end
    #TODO: check premissions

    end
    if (! error) then
        $logger.info("\nEverything is ok!")
    end
end

# Only run code if executed directly.
if $0 === __FILE__ then
    require_relative "./xhyvevms.rb"
    $command = ''
    $options = Optparse.parse(ARGV, $localOptions)
    run()
end
