#!/usr/bin/env ruby
#/ Usage: xhyvevm-import archive <tarball> [<vmname>] [options]
#/ Import VM from a tarball


# Local Options
$localOptions = Proc.new { |opts|
    opts.banner = SubScript.grep_head_description(__FILE__)
    opts.on("--force", "Use force")   { options.force = true }
}

def run
    if ARGV.length < 0 then
        puts "tarball is missing"
        exit
    end
    filename = ARGV.shift

    if ARGV.length > 0 then
        vmname = ARGV.shift
    else
        vmname = filename.gsub(/\..+$/,"")
    end

    if ARGV.length != 0 then
        puts " only takes two argument"
        exit
    end

    if (! File.file?(filename))
            puts "can't open file: #{filename}"
            exit
    end

    vm = VM.find(vmname)
    if ! vm.nil? then
        if ($options.force) then
            puts "Removing exsisting vm"
            vm.rm
        else
            puts "VM allready exsists"
            exit
        end
    end

    VM.import(filename, $options['config']['vms_path'], vmname)
end

# Only run code if executed directly.
if $0 === __FILE__ then
    require_relative "./xhyvevms.rb"
    $command = ''
    $options = Optparse.parse(ARGV, $localOptions)
    run()
end
