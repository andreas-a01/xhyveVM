#!/usr/bin/env ruby
#/ Usage: xhyvevms-list [options]
#/ List VMs


# Local Options
$localOptions = Proc.new { |opts|
    opts.banner = grep_head_description(__FILE__)
}

def run
    vms = load_vms($options['vms_path'])

    vms.each do |vm|
        puts "* #{vm.name} \t\t[#{vm.status}]"
    end
end

# Only run code if executed directly.
if $0 === __FILE__ then
    require_relative "./xhyvevms.rb"
    run()
end
