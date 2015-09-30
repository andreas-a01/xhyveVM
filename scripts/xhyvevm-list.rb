#!/usr/bin/env ruby
#/ Usage: xhyvevm-list [options]
#/ List VMs


# Local Options
$localOptions = Proc.new { |opts|
    opts.banner = SubScript.grep_head_description(__FILE__)
}

def run
    if ARGV.length != 0 then
        $logger.error("#{$command} takes no arguments")
        exit
    end

    vms = VM.find_all

    vms.each do |vm|
        puts "* #{vm.name} [#{vm.status}]"
    end
end

# Only run code if executed directly.
if $0 === __FILE__ then
    require_relative "./xhyvevms.rb"
    $command = ''
    $options = Optparse.parse(ARGV, $localOptions)
    run()
end
