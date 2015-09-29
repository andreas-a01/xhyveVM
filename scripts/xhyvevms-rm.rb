#!/usr/bin/env ruby
#/ Usage: xhyvevms-rm <vmname> [options]
#/ Remove VM


# Local Options
$localOptions = Proc.new { |opts|
    opts.banner = SubScript.grep_head_description(__FILE__)
    opts.on("--force", "Use force")   { options.force = true }
}

def run
    if ARGV.length < 0 then
        puts "vmname name missing"
        exit
    end
    vmname = ARGV.shift

    if ARGV.length != 0 then
        puts "only takes one argument"
        exit
    end

    vm =  VM.find(vmname)
    if vm.nil? then
        puts "can't find vm: #{vmname}"
        exit
    end

    $options.verbose ? (puts "DEBUG: deleting VM folder") : ()
    if (vm.status != "no running") && (! $options.force) then
        puts "can only delete VM that's not running"
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
