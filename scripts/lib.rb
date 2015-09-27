class VM
    attr_accessor :path
    attr_accessor :name
    attr_accessor :status

    def initialize(vm_dir)
        self.path = vm_dir
        self.name = File.basename(vm_dir)
    end

    def config
        @vmconfig = YAML.load_file(self.path + '/config.yml')
        return @vmconfig
    end

    def size
        size = `du -sh '#{self.path}'`
        size.strip.gsub(/\s+.+/,"") #show only size
    end

    def status
        return "Unknowed"
    end
end


class SubScript
    attr_accessor :path
    attr_accessor :command

    def initialize(file_path)
        self.path = file_path
        self.command = File.basename(file_path)
                    .gsub(/^xhyvevms-/, "") #remove xhyvevms-from filename
                    .gsub(/\.rb$/, "")      #remove .rb extention
    end

    def description
        #The third line of each subScript (after .../env ruby and usage),
        #is expected to be a definetion of what is script does
        description = grep_head_description(self.path).split("\n")[1]
        if description.nil? then
            return ""
        else
            return description
        end
    end
end


def grep_head_description(file_path)
    return `grep ^#/<'#{file_path}'|cut -c4-`
end


def load_vms()
    path =  File.expand_path($options['vms_path'])
    vms = []

    Dir.glob(path + '/*').each do |f|
        if File.directory?(f)
            vms.push(VM.new(f))
        end
    end

    return vms
end


def availableSubScripts
    subScripts = []
    Dir.glob("#{File.dirname(__FILE__)}/xhyvevms-*").each do |file_path|
        subScripts.push(SubScript.new(file_path))
    end

    return subScripts
end
