module Internet
  def self.download(command)
    match = command.match(/^download\s+([^\s]{3,})(?:\s+to\s+(.+))?$/i)
    
    if match
      where = match[1].strip
      output = match[2]
      output = output.strip if output
      
      {
        :command => "curl#{ output ? ' -o ' + output : ''} #{ where }".strip,
        :explanation => "Downloads the contents of the URL#{ output ? ' to ' + output : '' }."
      }
    end
  end

  def self.uncompress(command)
    match = command.match(/^(?:unzip|unarchive|untar|uncompress|expand)\s+([^\s]+)(?:\s+(?:to\s+)?(.+))?$/i)
    
    if match
      what_file = match[1].strip
      where = match[2]
      if where.nil?
        where = what_file.split(".").first
      end
      in_same_directory = where == '.' || where.downcase.match(/^((?:this|same)\s+)?(?:dir(?:ectory)|folder|path)?$/)
      
      {
        :command => "#{ in_same_directory ? '' : 'mkdir ' + where + ' && ' } tar -zxvf #{ what_file } #{ in_same_directory ? '' : '-C ' + where }".strip,
        :explanation => "Uncompresses the contents of the file #{ what_file }, outputting the contents to #{ in_same_directory ? 'this directory' : where }."
      }
    end
  end

  def self.compress(command)
    match = command.match(/^(zip|archive|tar gzip|gzip tar|tar bzip|bzip tar|tar bzip2|bzip2 tar|compress|tar)\s+([^\s]+)(?:\s+(?:directory|dir|folder|path))?(?:\s+(?:to\s+)?(.+))?$/i)

    if match
      how = match[1]
      what_file = match[2].strip
      where = match[3]

      case how
      when "zip"
        operation = "zip"
        if where.nil?
          where = what_file + ".zip"
        end
      when "tar bzip", "bzip tar", "tar bzip2", "bzip2 tar"
        operation = "tar -cjvf"
        if where.nil?
          where = what_file + ".tar.bz"
        end
      else
        operation = "tar -czvf"
        if where.nil?
          where = what_file + ".tar.gz"
        end
      end

      {
        :command => "#{ operation } #{ where } #{ what_file }",
        :explanation => "Compress the contents of #{ what_file } directory, outputting the compressed file to #{ where ? where : 'this directory'}"
      }
    end
  end
  
  def self.interpret(command)
    responses = []
    
    download_command = self.download(command)
    responses << download_command if download_command
    
    uncompress_command = self.uncompress(command)
    responses << uncompress_command if uncompress_command

    compress_command = self.compress(command)
    responses << compress_command if compress_command
    
    responses
  end

  def self.help
    commands = []
    commands << {
      :category => "Internet",
      :description => 'Download files from \033[34mInternet\033[0m, uncompress/compress them',
      :usage => ["download http://www.mysite.com/something.tar.gz to something.tar.gz",
      "uncompress something.tar.gz",
      "unarchive something.tar.gz to somedir",
      "(You can use unzip, unarchive, untar, uncompress, and expand interchangeably.)",
      "compress /path/to/dir",
      "(You can use archive, compress, and star interchangeably.)",
      "(You can also specify to archive using zip, bzip tar, or gzip tar; the default is gzipped tar.)",
      "compress /path/to/dir to something.tar.gz"]
    }
    commands
  end
end

$executors << Internet
