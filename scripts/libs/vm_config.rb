class VMconfig
    attr_accessor :config
    attr_accessor :file_path
    attr_accessor :hash

    def initialize(file_path)
        self.file_path = file_path
        self.hash = load
    end

    def load
        check
        return YAML.load_file(self.file_path)
    end

    def check
        require_keys = ['version', 'type', 'boot', 'vm']
        optionel_keys = ['uuid']

        # Check file is valie yaml
        begin
            self.config = YAML.load_file(self.file_path)
        rescue Exception => e
            $logger.error("VM config file is not valid YAML")
            $logger.debug(e)
            exit
          return false
        end

        check_keys(self.config, ['version'])
        # Check version
        if (Version[0].to_i != self.config['version']) then
            $logger.error("unsupported version")
            exit
        end

        check_keys(self.config, require_keys, delete: true, require: true)
        check_keys(self.config, optionel_keys, delete: true)

        if self.config.length != 0 then
            self.config.keys.each do |key|
                puts "unsupported key: #{key}"
            end
            exit
        end

        return true
    end

    def has_network?
        return self.hash['vm'].has_key?('net')
    end

    def has_uuid?
        if self.hash.has_key?('uuid') then
            return self.hash['uuid']
        end

        return nil
    end

    def uuid
        return self.hash['uuid']
    end

    def start_string(uuid)
        vmconfig = self.hash

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
        if (! vmconfig['vm']['net'].nil?) then
            vmconfig['vm']['net'].each do |net|
                start_string += " -s #{net}"
            end
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
        # UUID is needed to find mac and then if of VM,
        # if a UUID is not set in the config, asign a random and save to file
        if ( ! uuid.nil? ) then
            start_string += " -U #{uuid}"
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

    private
    def check_keys(config, require_keys, delete: false, require: false)
        require_keys.each do |require_key|
            if (! config.has_key?(require_key)) then
                if (require) then
                    $logger.error("missing key: #{require_key}")
                    exit
                end
            else
                if (delete) then
                    config.delete(require_key)
                end
            end
        end
        return true
    end
end
