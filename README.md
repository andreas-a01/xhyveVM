xhyveVM
========
A simpel wrapper about xhyve and a few unix tools, to simplify unsge.

**Script usage**

    Usage: xhyvevm [options] <command>

        -h, --help                       Show this message
            --version                    Show version

    Commands:
    	attach  		     Attach to running vm
    	clean   		     Clean up after dead VM
    	export  		     Export VM to tarball
    	import  		     Import VM from a tarball
    	inspect 		     See information on VM
    	kill    		     Kill running VM
    	list    		     List VMs
    	rm      		     Remove VM
    	start   		     Start VM

    	see <command> --help for usage


**Example**

    #Clone somewhere
    git clone https://github.com/andreas-a01/xhyveVM.git

    #Create executable
    cd xhyveVM/    
    mkdir bin   
    cd bin
    ln -s ../scripts/xhyvevm.rb xhyvevm
    chmod +x xhyvevm

    #Add executable to PATH
    PATH=$PATH:${PWD}

    #Test xhyvevm
    xhyvevm --help

    #Create VMs dir
    mkdir ~/xhyveVM/

    #Import tinycore (see release for file)
    xhyvevm import tinycore.tgz

    #Start & attach
    xhyvevm list
    xhyvevm start tinycore
    xhyvevm attach tinycore

feedback is highly appreciated


Changelog
---------
* 0.1  
    Initial release  
    working with tinycore VM  
    network is missing  


Roadmap
-------
* 0.2
    * better logging
    * validation of config files
    * validation of tarballs
    * code clean up


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
