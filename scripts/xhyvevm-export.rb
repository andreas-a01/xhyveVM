#!/usr/bin/env ruby
#/ Usage: xhyvevm-export <vmname> [options]
#/ Export VM to tarball


# Local Options
$localOptions = Proc.new { |opts, options|
    opts.banner = SubScript.grep_head_description(__FILE__)
    opts.on("-z", "--gzip", "Compress with gzip", String)   { options.compress = true }
    opts.on("-f", "--file=archive", "Sets filename of tarball", String)   { |archive| options.archivePath = archive }

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

    if (vm.status != "no running") && (! $options.force) then
        puts "can only export VM that's not running"
        puts $options.force
        exit
    end

    archivePath = $options.archivePath
    if $options.archivePath.nil? then
        if $options.compress then
            archivePath = "#{vm.name}.tgz"
        else
            archivePath = "#{vm.name}.tar"
        end
    end

    if helper_sanitize_filename(archivePath) != archivePath then
        puts "bad file name"
        exit
    end

    if (File.file?(archivePath)) && (! $options.force) then
        puts "#{archivePath} allready exsistens"
        exit
    end

    vm.export(archivePath, $options.compress)
end

# Only run code if executed directly.
if $0 === __FILE__ then
    require_relative "./xhyvevms.rb"
    $command = ''
    $options = Optparse.parse(ARGV, $localOptions)
    run()
end
