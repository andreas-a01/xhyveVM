#!/usr/bin/env ruby
#/ Usage: xhyvevms-kill [options]
#/ Kill running VM


# Local Options
$localOptions = Proc.new { |opts|
    opts.banner = SubScript.grep_head_description(__FILE__)
    opts.on("--force", "Use force")   { options.force = true }
}

def run
    if ARGV.length < 1 then
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

    if (vm.status == "dead") && (! $options.force) then
        puts "this VM is allready dead"
        exit
    end

    if (vm.status == "no running") && (! $options.force) then
        puts "this VM is not running"
        exit
    end

    $options.verbose ? (puts "DEBUG: sending kill signal to VM") : ()
    vm.kill

    $options.verbose ? (puts "DEBUG: cleaning up after vm") : ()
    vm.clean
end

# Only run code if executed directly.
if $0 === __FILE__ then
    require_relative "./xhyvevms.rb"
    $command = ''
    $options = Optparse.parse(ARGV, $localOptions)
    run()
end
