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

        config = VMconfig.new(config_file)
        return config
    end

    def start
        xhyve_wrapper = File.expand_path( File.dirname(__FILE__) + "/../xhyve_wrapper.sh" )

        use_sudo = config.hash['vm'].has_key?('net')

        $logger.debug("changing path")
        Dir.chdir(self.path){
            $logger.debug("running xhyve_wrapper thougth dtach arguments:\n #{self.config.start_string}")

            if use_sudo then
                exec "sudo dtach -n console.tty -z #{xhyve_wrapper} #{self.config.start_string} && sudo chmod 770 console.tty"
            else
                exec "dtach -n console.tty -z #{xhyve_wrapper} #{self.config.start_string}"
            end

        }
    end

    def destroy
        $logger.debug("changing path")
        Dir.chdir(self.path){
            $logger.debug("removing VM directory: #{file}")
            exec "rm -r '#{self.path}'"
        }
    end

    def attach
        $logger.debug("changing path to: #{self.path}")
        Dir.chdir(self.path){
            $logger.debug("Using detach to reattach")
            exec "read -p 'Attaching to #{self.name}...\nTo detach from VM again, press (Ctrl-\\) at any time\n\nPress any key to continue... \n' && dtach -a console.tty"
        }
    end

    def size
        $logger.debug("changing path")
        Dir.chdir(self.path){
            $logger.debug("getting size of VM with du")
            size = `du -sh .`
            return size.strip.gsub(/\s+.+/,"") #show only size
        }
    end

    def clean
        if ! (pid_file.nil?) then
            $logger.debug("removing pid file: #{pid_file}")
            File.delete(pid_file)
        end

        if ! (console_file.nil?) then
            $logger.debug("emoving console file: #{console_file}")
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
        $logger.debug("compressing console file: #{console_file}")
        exec "tar #{compress} -C '#{parrentdir}' -cf '#{archivePath}' '#{vmdir}/'"
    end

    def kill
        $logger.debug("sending kill signal to VM")

        use_sudo = (! File.stat(pid_file).owned?)

        Dir.chdir(self.path){
            $logger.debug("sinding kill signal to process id: #{self.pid}")
            if use_sudo then
                exec "sudo kill -9 #{self.pid}"
            else
                exec "kill -9 #{self.pid}"
            end
        }
    end

    def status
        if pid_file.nil? then
            return :stopped
        end

        if running? then
            return :running
        end

        return :dead
    end

    def pid
        if pid_file.nil? then
            return nil
        end
        Dir.chdir(self.path){
            $logger.debug("gettigg pid with cat from: #{pid_file} ")
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

    def uuid
        if config.hash.has_key?('uuid') then
            return config.hash['uuid']
        end

        if tmpuuid then
            return File.read(tmpuuid).to_s
        end

        return nil
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
    def tmpuuid
        tmpuuid = File.expand_path(self.path + '/tmpuuid')

        return File.file?(tmpuuid) ? tmpuuid : nil
    end

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
