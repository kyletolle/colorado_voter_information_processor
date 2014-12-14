require 'logger'

class ColoradVoterInformationProcessor
  def initialize
    @logger       = Logger.new(STDERR)
    @logger.level = Logger::INFO
  end

  NUMBER_OF_FILES = 11

  def process
    download_zip_files
    extract_zip_files
    delete_zip_files
  end

private
  attr_reader :logger

  def each_file(&block)
    NUMBER_OF_FILES.times do |i|
      file_number = i + 1
      yield file_number
    end
  end

  def download_zip_files
    logger.info "Downloading all zip files in the data set..."

    each_file do |file_number|
      `wget #{remote_zip_file(file_number)} -O #{local_zip_file(file_number)}`
    end
  end

  def remote_zip_file(file_number)
    "http://coloradovoters.info/downloads/20141201/Registered_Voters_List_%20Part#{file_number}.zip"
  end

  def extract_zip_files
    logger.info "Extracting all zip files in the data set to txt files..."

    each_file do |file_number|
      `unzip -p #{local_zip_file(file_number)} > #{local_txt_file(file_number)}`
    end
  end

  def delete_zip_files
    logger.info "Deleting all zip files in the data set..."

    each_file do |file_number|
      `rm #{local_zip_file(file_number)}`
    end
  end

  def local_zip_file(file_number)
    "part#{file_number}.zip"
  end

  def local_txt_file(file_number)
    "part#{file_number}.txt"
  end
end

ColoradVoterInformationProcessor.new.process

