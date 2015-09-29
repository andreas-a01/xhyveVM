#!/usr/bin/env ruby
#/ Usage: xhyvevms-inspect <vmname> [options]
#/ See information on VM


# Local Options
$localOptions = Proc.new { |opts|
    opts.banner = SubScript.grep_head_description(__FILE__)
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

    require 'pp'

    puts "name: #{vm.name}"
    puts "path: #{vm.path}"
    puts "size: #{vm.size}"
    puts "status: #{vm.status}"
    puts "pid: #{vm.pid}"
    puts ""
    puts "config:"
    pp(vm.config)

end

# Only run code if executed directly.
if $0 === __FILE__ then
    require_relative "./xhyvevms.rb"
    $command = ''
    $options = Optparse.parse(ARGV, $localOptions)
    run()
end
