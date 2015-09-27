#!/usr/bin/env ruby
#/ Usage: xhyvevms-export [options]
#/ Expoet a VM to tarball


# Local Options
$localOptions = Proc.new { |opts|
    opts.banner = grep_head_description(__FILE__)
}

def command
    puts "not implemented"
end

# Only run code if executed directly.
if $0 === __FILE__ then
    require_relative "./xhyvevms.rb"
    command()
end
