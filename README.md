xhyveVM
========
A command line tool, that simplifies running virtual machines in xhyve.

I am only tested this script in El Capitan and you will need a 2010 or later Mac (i.e. a CPU that supports EPT).


**Script usage**

    Usage: xhyvevm [options] <command>
        -h, --help                       Show this message
            --version                    Show version

    Commands:
    	attach			     Attach to running vm
    	check			     Check config, dependences and VMs
    	clean			     Clean up after dead VM
    	export			     Export VM to tarball
    	import			     Import VM from a tarball
    	inspect			     See information on VM
    	kill			     Kill running VM
    	list			     List VMs
    	rm  			     Remove VM
    	start			     Start VM

    	see <command> --help for usage





**Example**

    #Clone somewhere
    git clone https://github.com/andreas-a01/xhyveVM.git

    #Setup xhyveVM
    cd xhyveVM/    
    make setup

    #Check xhyvevm
    xhyvevm check

    #Import tinycore (see release for file)
    xhyvevm import tinycore.tar

    #Start & attach
    xhyvevm list
    xhyvevm start tinycore
    xhyvevm attach tinycore


Feedback is highly appreciated


Changelog
---------

* 0.1  
    Initial release  
    working with tinycore VM  
    network is missing  

* 0.2
    New commands
        * Check: Check config, dependences and VMs

    Changes to commands
        * Kill: Does not run clean
        * Import: Checks archive before import

    General
        * Logger now handler most message
        * Better messages from script in general
        * Debug messages before every system command.
        * VM Class extended for
        * New VMconfig class, now handles config for VM
        * Config is checked before being used
        * some code clean up.

    Bugfixs
        Fix error in handling for aguments
        Fix error in localOptions


Roadmap
-------

* 0.4
    * network
    * ssh
    * Halt
    * Port forward

    test against boot2boster and CoreOS.

* 0.6
    * nfs_mounts
    * build vm with script.rb or MakeFile

    test against debian, arch
    add to homebrew


* 0.8
    * VM build script repo
    * search repo
    * get VM (from repo)


* 1.0
    * code clean up
    * documentation
    test against ubuntu
