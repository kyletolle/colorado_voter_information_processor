require 'logger'
require 'optparse'
require 'csv'

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
    combine_txt_files_into_one
    delete_part_txt_files

    self
  end

  def create_county_dataset
    logger.info "Creating a dataset for the voters and their counties..."
    File.open(county_dataset, 'w') do |file|
      # The Dec 1, 2014 txt files actually contain | delimited files not ,
      # delimited. And we set the quote char to one that's not used in the
      # data set so it can be read in properly.
      CSV.foreach(entire_dataset, {col_sep: '|', quote_char: '^'}) do |row|
        # We only want a subset of the data in the files.
        only_interesting_columns = row.values_at(0,1,2,7,29,30,34)
        csv_string               = only_interesting_columns.to_csv

        file << csv_string
      end
    end
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

      opts.on('-d', '--skip-zip-downloads', "Skip downloading zip files") do |szd|
        @options[:skip_zip_downloads] = szd
      end

      opts.on('-x', '--skip-zip-extracts', "Skip extracting zip files") do |szx|
        @options[:skip_zip_extracts] = szx
      end

      opts.on('-e', '--skip-zip-deletes', "Skip deleting zip files") do |sze|
        @options[:skip_zip_deletes] = sze
      end

      opts.on('-c', '--skip-combining-files', "Skip combining individual txt files into a single csv file") do |scf|
        @options[:skip_combining_files] = scf
      end

      opts.on('-t', '--skip-txt-deletes', "Skip deleting part#.txt files") do |ztd|
        @options[:skip_txt_deletes] = ztd
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

  def combine_txt_files_into_one
    if @options[:skip_combining_files]
      logger.info "Skipping combining the individual txt files into a single csv file."

    else
      logger.info "Combining the individual txt files into a single csv file..."

      files_list = each_file.map do |file_number|
        "part#{file_number}.txt"
      end

      files_string = files_list.join(' ')

      `cat #{files_string} > #{entire_dataset}`
    end
  end

  def entire_dataset
    'entire_dataset.txt'
  end

  def delete_part_txt_files
    if @options[:skip_txt_deletes]
      logger.info "Skipping deleting all txt files in the data set."

    else
      logger.info "Deleting all txt files in the data set..."

      each_file do |file_number|
        `rm #{local_txt_file(file_number)}`
      end
    end
  end

  def county_dataset
    "county_dataset.csv"
  end
end

processor = ColoradVoterInformationProcessor.new.prepare_dataset

processor.create_county_dataset
