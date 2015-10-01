class VM
    attr_accessor :path
    attr_accessor :name
    attr_accessor :status

    def initialize(vm_dir)
        self.path = vm_dir
        self.name = File.basename(vm_dir)
    end

    def config
        if config_file.nil? then
            $logger.error("can't find config file: #{self.config_file}")
            exit
        end

        return YAML.load_file(config_file)
    end

    def start
        xhyve_wrapper = File.expand_path( File.dirname(__FILE__) + "/../xhyve_wrapper.sh" )

        $logger.debug("changing path")
        Dir.chdir(self.path){
            $logger.debug("DEBUG: run xhyve_wrapper thougth dtach")
            $logger.debug("arguments: #{self.start_string}")

            exec "dtach -n console.tty -z #{xhyve_wrapper} #{self.start_string}"
        }
    end

    def destroy
        $logger.debug("deleting VM folder")
        $logger.debug("changing path")
        Dir.chdir(self.path){
            exec "rm -r '#{self.path}'"
        }
    end

    def start_string
        vmconfig = self.config

        start_string = ""

        #ACPI
        if vmconfig['vm']['acpi'] then
            start_string += "-A"
        end

        #Memory
        start_string += " -m #{vmconfig['vm']['memory']}"

        #SMP
        if ! vmconfig['vm']['smp'].nil? then
            $logger.error("no support for SMP, sorry")
            exit
        end

        #PCI_DEV
        vmconfig['vm']['pci'].each do |pci|
                start_string += " -s #{pci}"
        end

        #LPC_DEV
        vmconfig['vm']['lpc'].each do |lpc|
                start_string += " -l #{lpc}"
        end

        #NET
        if ! vmconfig['vm']['net'].nil? then
            $logger.error("no support for network, sorry")
            exit
        end

        #IMG_CD
        if ! vmconfig['vm']['iso'].nil? then
            $logger.error("error: no support for iso, sorry")
            exit
        end

        #IMG_HDD
        if ! vmconfig['vm']['hdd'].nil? then
            vmconfig['vm']['hdd'].each do |hdd|
                    start_string += " -s #{hdd}"
            end
        end

        #UUID
        # start_string += " -U #{UUID}"
        if ! vmconfig['uuid'].nil? then
            start_string += " -U #{vmconfig['uuid']}"
        end

        #EXTRA_ARGS
        if ! vmconfig['EXTRA_ARGS'].nil? then
            start_string += " #{vmconfig['EXTRA_ARGS']}"
        end

        #boot
        kernel = vmconfig['boot']['kernel']
        initrd = vmconfig['boot']['initrd']
        cmdline = vmconfig['boot']['cmdline']

        start_string += " -f kexec,#{kernel},#{initrd},#{cmdline}"

        return start_string
    end

    def attach
        $logger.debug("changing path to: #{self.path}")
        Dir.chdir(self.path){
            exec "read -p 'Attaching to #{self.name}...\nTo detach from VM again, press (Ctrl-\\) at any time\n\nPress any key to continue... \n' && dtach -a console.tty"
        }
    end

    def size
        $logger.debug("changing path")
        Dir.chdir(self.path){
            size = `du -sh .`

            return size.strip.gsub(/\s+.+/,"") #show only size
        }
    end

    def clean
        if ! (pid_file.nil?) then
            File.delete(pid_file)
        end

        if ! (console_file.nil?) then
            File.delete(console_file)
        end
    end

    def export(archivePath, compress)
        if $compress then
            compress = "-z"
        else
            compress = ""
        end

        vmdir  = File.basename(self.path)
        parrentdir =  File.dirname(self.path)
        exec "tar #{compress} -C '#{parrentdir}' -cf '#{archivePath}' '#{vmdir}/'"
    end

    def kill
        $logger.debug("sending kill signal to VM")
        Dir.chdir(self.path){
            `kill -9 #{self.pid}`
        }
    end

    def status
        if pid_file.nil? then
            return "no running"
        end

        if running? then
            return "running"
        end

        return "dead"
    end

    def pid
        if pid_file.nil? then
            return nil
        end
        Dir.chdir(self.path){
            return `cat '#{pid_file}'`.to_i
        }
    end

    def running?
        if pid_file.nil? then
            return false
        end

        begin
          Process.getpgid( self.pid )
          return true
        rescue Errno::ESRCH
          return false
        end
    end

    #Class methods
    def self.find_all
        vmspath = File.expand_path($options['config']['vms_path'])

        if (! File.exist?(vmspath)) then
            $logger.error("can't open vmspath: #{vmspath}, check your config")
            exit
        end
        vms = []

        Dir.glob(vmspath + '/*').each do |f|
            if File.directory?(f)
                vms.push(VM.new(f))
            end
        end

        return vms
    end

    def self.find(vm_name)
        vms = self.find_all()
        index = vms.index { |vm| vm_name == vm.name }

        index.nil? ? nil : vms[index]
    end

    def self.import(filename, vms_path, vmname)
        vmname_old = filename.gsub(/\..+$/,"")
        vms_path = File.expand_path(vms_path + "/" + vmname)

        #extrant tmp place
        tmpPath = "/tmp/xhyvevms/"
        if File.exist?(tmpPath) then
            $logger.debug("tmp folder allready exsists, deleting")
            print `rm -r '#{tmpPath}'`
        end

        $logger.debug("creating tmp folder")
        print `mkdir '#{tmpPath}'`

        $logger.debug("extracting VM")
        print `tar -xf '#{filename}' -C '#{tmpPath}'`

        $logger.debug("moving VM to vms_path")
        print `mv '#{tmpPath}#{vmname_old}' '#{vms_path}'`

        $logger.debug("deleting tmp folder")
        print `rm -r '#{tmpPath}'`
    end

    def self.valid_archive?(filename)
        system("tar -tzf #{filename} >/dev/null")
        if $?.exitstatus == 0 then
            return true
        end

        return false
    end

    private
    def config_file
        config_file = File.expand_path(self.path + '/config.yml')

        return File.file?(config_file) ? config_file : nil
    end

    def console_file
        console_file = File.expand_path(self.path + "/console.tty")

        return File.file?(console_file) ? console_file : nil
    end

    def pid_file
        pid_file = File.expand_path(self.path + "/xhyve_wrapper.pid")

        return File.file?(pid_file) ? pid_file : nil
    end
end
