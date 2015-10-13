xhyveVM
========
A command line tool, that simplifies running virtual machines in xhyve.

Please know that I am only tested this tool on El Capitan.  
Also you will need a 2010 or later Mac (i.e. a CPU that supports EPT) to use xhyve.


**Usage**

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

    #Clone
    git clone https://github.com/andreas-a01/xhyveVM.git

    #Setup xhyveVM
    cd xhyveVM/
    make setup

    #Check xhyvevm
    xhyvevm check

    #Import tinycore (see release for file)
    curl -OL https://github.com/andreas-a01/xhyveVM/releases/download/v0.3/tinycore.tar
    xhyvevm import tinycore.tar

    #Start & attach
    xhyvevm list
    xhyvevm start tinycore
    xhyvevm inspect tinycore
    xhyvevm attach tinycore


Feedback is highly appreciated!  
Please [create an issue](https://github.com/andreas-a01/xhyveVM/issues), if something is not working for you.


Changelog
---------
[See here](https://github.com/andreas-a01/xhyveVM/blob/master/CHANGELOG.md)


Credits
-------
This project draws code and inspiration from prior works:

* [mist64/xhyve](https://github.com/mist64/xhyve) for all the real work
* [ailispaw/docker-root-xhyve](https://github.com/ailispaw/docker-root-xhyve) using Makefile's to build VM
* [rimusz/coreos-xhyve-ui](https://github.com/rimusz/coreos-xhyve-ui) use detach to get a nice pty, to attach to

Thank you all!
