#!/usr/bin/env ruby
#/ Usage: xhyvevm-start <vmname> [options]
#/ Start VM


# Local Options
$localOptions = Proc.new { |opts|
    opts.banner = SubScript.grep_head_description(__FILE__)
    opts.on("--force", "Use force")   { options.force = true }
}

def run
    if ARGV.length !=1 then
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
        puts "this VM is allready running"
        exit
    end

    $options.verbose ? (puts "DEBUG: changing path") : ()
    Dir.chdir(vm.path){
      $options.verbose ? (puts "DEBUG: run xhyve_wrapper thougth dtach") : ()
      $options.verbose ? (puts "#{vm.start_string}") : ()

      vm.start
    }
end

# Only run code if executed directly.
if $0 === __FILE__ then
    require_relative "./xhyvevms.rb"
    $command = ''
    $options = Optparse.parse(ARGV, $localOptions)
    run()
end
