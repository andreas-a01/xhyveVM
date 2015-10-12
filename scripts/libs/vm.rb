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
            $logger.error("can't find config file")
            exit
        end

        config = VMconfig.new(config_file)
        return config
    end

    def start
        start_string = config.start_string(self.uuid)

        has_network = config.hash['vm'].has_key?('net')

        if (has_network and mac_address.nil?) then
            $logger.warn("Need to setup mac adresse before running")
            create_mac_address
        end

        $logger.debug("changing path")
        Dir.chdir(self.path){
            $logger.debug("running xhyve_wrapper thougth dtach arguments:\n #{start_string}")

            if (has_network) then
                run_command("#{sudo_command_string} dtach -n .xhyvevm/console.tty -z #{xhyve_wrapper} #{start_string} && #{sudo_command_string} chmod 770 .xhyvevm/console.tty")
            else
                run_command("dtach -n .xhyvevm/console.tty -z #{xhyve_wrapper} #{start_string}")
            end

        }
    end

    def destroy
        $logger.debug("changing path")
        Dir.chdir(File.expand_path($options['config']['vms_path'])){
            $logger.debug("removing VM directory: #{self.path}")
            run_command( "rm -rf '#{self.path}'" )
        }
    end

    def attach
        $logger.debug("changing path to: #{self.path}")
        Dir.chdir(self.path){
            $logger.debug("Using detach to reattach")
            exec "read -p 'Attaching to #{self.name}...\nTo detach from VM again, press (Ctrl-\\) at any time\n\nPress any key to continue... \n' && dtach -a .xhyvevm/console.tty"
        }
    end

    def size
        $logger.debug("changing path")
        Dir.chdir(self.path){
            $logger.debug("getting size of VM with du")
            size = run_command('du -sh .')
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
        run_command(  "tar #{compress} -C '#{parrentdir}' -cf '#{archivePath}' '#{vmdir}/'" )
    end

    def kill
        $logger.debug("sending kill signal to VM")

        use_sudo = (! File.stat(pid_file).owned?)

        Dir.chdir(self.path){
            $logger.debug("sinding kill signal to process id: #{self.pid}")
            if use_sudo then
                run_command( "#{sudo_command_string} kill -INT -#{self.pid}" )
            else
                run_command( "kill -INT -#{self.pid}")
            end
        }
    end

    def status
        subfolder = File.expand_path( self.path + "/.xhyvevm/" )

        if (! File.exist?(subfolder)) then
            return :notinstalled
        end

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
            return File.read(pid_file).strip.to_i
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
        if (config.hash.has_key?('uuid') && uuid_file) then
            $logger.warn("UUID both in config and on file, using the one from config")
            return config.hash['uuid']
        end

        if config.hash.has_key?('uuid') then
            return config.hash['uuid']
        end


        if uuid_file then
            return File.read(uuid_file).strip
        end

        return create_uuid
    end

    def mac_address
        if mac_address_file.nil? then
            return nil
        end
        Dir.chdir(self.path){
            #$logger.debug("gettigg mac address with cat from: #{mac_address_file} ")
            return File.read(mac_address_file).strip
        }
    end

    def ip_address
        if (mac_address.nil?) then
            return nil
        end

        if (! self.running?) then
            return nil
        end

        dhcpd_leases = File.read("/var/db/dhcpd_leases")
        leases = dhcpd_leases.scan(/\{.*?\}/m)

        leases.each do |lease|

            lease_mac = lease.match(/hw_address=1,(.*?)\n/)
            if (lease_mac[1] == self.mac_address) then
                lease_ip = lease.match(/ip_address=(.*?)\n/)
                return lease_ip[1]
            end
        end

        return "fail"
    end


    def sudo_command_string
        askpass_path = File.expand_path( File.dirname(__FILE__) + "../../../deps/sudo-askpass" )
        askpass = "SUDO_ASKPASS='#{askpass_path}'"
        string = "#{askpass} sudo -A"

        return string
    end

    def run_command(command)
        output = `#{command}`
        if $?.exitstatus == 0 then
            return output
        end

        $logger.error("error: #{$?}")
        return false
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
            run_command("rm -r '#{tmpPath}'")
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
        system("tar -tzf #{filename} | grep 'xhyvevm.yml'")

        return $?.success?
    end

    private
    def xhyve_wrapper
        xhyve_wrapper = File.expand_path( File.dirname(__FILE__) + "/../../deps/xhyve_wrapper.sh" )
        return xhyve_wrapper
    end

    def create_mac_address
        uuid2mac = File.expand_path( File.dirname(__FILE__) + "/../../deps/uuid2mac" )
        Dir.chdir(self.path){
            run_command("#{sudo_command_string} #{uuid2mac} #{uuid} > .xhyvevm/mac_address")
        }
    end

    def create_uuid
        require "securerandom"
        uuid  = SecureRandom.uuid

        $logger.debug("Generating UUID and saving it in file: uuid")
        Dir.chdir(self.path){
            run_command("echo #{uuid} > .xhyvevm/uuid")
        }
        return uuid
    end

    def mac_address_file
        mac_address_file = File.expand_path(self.path + '/.xhyvevm/mac_address')

        return File.file?(mac_address_file) ? mac_address_file : nil
    end

    def uuid_file
        uuid_file = File.expand_path(self.path + '/.xhyvevm/uuid')

        return File.file?(uuid_file) ? uuid_file : nil
    end

    def config_file
        config_file = File.expand_path(self.path + '/xhyvevm.yml')

        return File.file?(config_file) ? config_file : nil
    end

    def console_file
        console_file = File.expand_path(self.path + "/.xhyvevm/console.tty")

        return File.file?(console_file) ? console_file : nil
    end

    def pid_file
        pid_file = File.expand_path(self.path + "/.xhyvevm/xhyve_wrapper.pid")

        return File.file?(pid_file) ? pid_file : nil
    end
end
