class VM
    attr_accessor :path
    attr_accessor :name
    attr_accessor :status

    def status
        return "Unknowed"
    end

    def to_s()
        return name
    end
end

class SubScript
    attr_accessor :path
    attr_accessor :command

    def initialize(file_path)
        self.path = file_path
        self.command = File.basename(file_path)
                    .gsub(/^xhyvevms-/, "") #remove xhyvevms-from filename
                    .gsub(/\.rb$/, "") #remove .rb extention
    end

    def to_s
        return name
    end

    def description()
        description =  grep_head_description(self.path).split("\n")[1]
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


def load_vms(directory)
    vms_folders = []
    Dir.glob(directory + '/*').each do |f|
        if File.directory?(f)
            vms_folders.push(f)
        end
    end

    vms = []
    vms_folders.each do |vms_folder|
        vm = VM.new
        vm.path = vms_folder
        vm.name = File.basename(vms_folder)

        vms.push(vm)
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
