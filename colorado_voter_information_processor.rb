require 'logger'
require 'optparse'

class ColoradVoterInformationProcessor
  def initialize
    create_logger
    parse_cli_options
  end

  NUMBER_OF_FILES = 11

  def process
    download_zip_files
    extract_zip_files
    delete_zip_files
  end

private
  attr_reader :logger

  def create_logger
    @logger       = Logger.new(STDERR)
    @logger.level = Logger::INFO
  end

  def parse_cli_options
    @options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: ruby colorado_voter_information_processor.rb [options]"

      opts.on('-d', '--skip-zip-downloads', "Skip downloading the zip files") do |szd|
        @options[:skip_zip_downloads] = szd
      end

      opts.on('-x', '--skip-zip-extracts', "Skip extracting the zip files") do |szx|
        @options[:skip_zip_extracts] = szx
      end

      opts.on('-e', '--skip-zip-deletes', "Skip deleting the zip files") do |sze|
        @options[:skip_zip_deletes] = sze
      end
    end.parse!
  end

  def each_file(&block)
    NUMBER_OF_FILES.times do |i|
      file_number = i + 1
      yield file_number
    end
  end

  def download_zip_files
    if @options[:skip_zip_downloads]
      logger.info "Skipping downloading all zip files in the data set."

    else
      logger.info "Downloading all zip files in the data set..."

      each_file do |file_number|
        `wget #{remote_zip_file(file_number)} -nv -O #{local_zip_file(file_number)}`
      end
    end
  end

  def remote_zip_file(file_number)
    "http://coloradovoters.info/downloads/20141201/Registered_Voters_List_%20Part#{file_number}.zip"
  end

  def extract_zip_files
    if @options[:skip_zip_extracts]
      logger.info "Skipping extracting all zip files in the data set."

    else
      logger.info "Extracting all zip files in the data set to txt files..."

      each_file do |file_number|
        `unzip -p #{local_zip_file(file_number)} > #{local_txt_file(file_number)}`
      end
    end
  end

  def delete_zip_files
    if @options[:skip_zip_deletes]
      logger.info "Skipping deleting all zip files in the data set."

    else
      logger.info "Deleting all zip files in the data set..."

      each_file do |file_number|
        `rm #{local_zip_file(file_number)}`
      end
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

