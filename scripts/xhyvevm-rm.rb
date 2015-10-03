#!/usr/bin/env ruby
#/ Usage: xhyvevm-rm <vmname> [options]
#/ Remove VM


# Local Options
$localOptions = Proc.new { |opts|
    opts.banner = SubScript.grep_head_description(__FILE__)
    opts.on("--force", "Use force") { options.force = true }
}

def run
    if ARGV.length < 1 then
        $logger.error("<vmname> argument missing, see --help for usage")
        exit
    end
    vmname = ARGV.shift

    if ARGV.length != 0 then
        $logger.error("#{$command} only takes one argument, see --help for usage")
        exit
    end

    vm =  VM.find(vmname)
    if vm.nil? then
        $logger.error("can't find vm: #{vmname}")
        exit
    end

    if (vm.status == :running) && (! $options.force) then
        $logger.error("can only delete VM that's stopped or dead")
        exit
    end

    vm.destroy
end

# Only run code if executed directly.
if $0 === __FILE__ then
    require_relative "./xhyvevms.rb"
    $command = ''
    $options = Optparse.parse(ARGV, $localOptions)
    run()
end
