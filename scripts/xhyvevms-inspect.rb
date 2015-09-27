#!/usr/bin/env ruby
#/ Usage: xhyvevms-inspect name [options]
#/ Return information on VM


# Local Options
$localOptions = Proc.new { |opts|
    opts.banner = grep_head_description(__FILE__)
}

def run
    require 'pp'

    if ARGV.length > 2 then
        puts "list only tages one agument, see --help for usage"
        exit
    end

    if ARGV.length < 2 then
        puts "need a name of VM to inspect, see --help for usage"
        exit
    end

    vm_name = ARGV[1]
    vms = load_vms()
    index = vms.index { |vm| vm_name == vm.name }

    if index.nil?
        puts "can't find VM: #{vm_name}"
    end

    vm = vms[index]
    puts "name: #{vm.name}"
    puts "path: #{vm.path}"
    puts "size: #{vm.size}"
    puts "status: #{vm.status}"
    puts ""
    puts "config:"
    pp(vm.config)

end

# Only run code if executed directly.
if $0 === __FILE__ then
    require_relative "./xhyvevms.rb"
    run()
end
