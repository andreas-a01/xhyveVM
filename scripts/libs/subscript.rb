class SubScript
    attr_accessor :path
    attr_accessor :command

    def initialize(file_path)
        self.path = file_path
        self.command = File.basename(file_path)
                    .gsub(/^xhyvevm-/, "") #remove xhyvevms-from filename
                    .gsub(/\.rb$/, "")      #remove .rb extention
    end

    def description
        description = SubScript.grep_head_description(self.path)

        return description.nil? ?  "" : description
    end

    def short_description
        #The third line of each subScript (after .../env ruby and usage),
        #is expected to be a definetion of what is script does
        short_description = description.split("\n")[1]

        return short_description.nil? ?  "" : short_description
    end

    #Class methods
    def self.grep_head_description(file)
        return `grep ^#/<'#{file}'|cut -c4-`
    end

    def self.find_all
        subScripts = []
        Dir.glob("#{File.dirname(__FILE__)}/../xhyvevm-*").each do |file_path|
            subScripts.push(SubScript.new(file_path))
        end

        return subScripts
    end

    def self.find(command)
        subScripts = self.find_all
        index = subScripts.index { |script| command == script.command }

        return index.nil? ? nil : subScripts[index]
    end
end
