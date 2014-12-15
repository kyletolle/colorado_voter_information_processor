require 'logger'
require 'optparse'

class ColoradVoterInformationProcessor
  def initialize
    create_logger
    parse_cli_options
  end

  NUMBER_OF_FILES = 11

  def prepare_dataset
    download_zip_files
    extract_zip_files
    delete_zip_files
    combine_txt_files_to_csv_file

    self
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

      opts.on('-c', '--skip-combining-files', "Skip combining the individual txt files into a single csv file") do |scf|
        @options[:skip_combining_files] = scf
      end
    end.parse!
  end

  def each_file(&block)
    file_numbers = NUMBER_OF_FILES.times.map{|i| i+1}

    if block
      file_numbers.each do |file_number|
        block.call file_number
      end

    else
      file_numbers
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

  def combine_txt_files_to_csv_file
    if @options[:skip_combining_files]
      logger.info "Skipping combining the individual txt files into a single csv file."

    else
      logger.info "Combining the individual txt files into a single csv file..."

      files_list = each_file.map do |file_number|
        "part#{file_number}.txt"
      end

      files_string = files_list.join(' ')

      `cat #{files_string} > #{local_csv_file}`
    end
  end

  def local_csv_file
    'entire_dataset.csv'
  end
end

processor = ColoradVoterInformationProcessor.new.prepare_dataset

