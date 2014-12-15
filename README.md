# colorado_voter_information_processor

The list of Colorado voters for 2014 is [available for download](http://coloradovoters.info/download.html).

This script takes care of downloading the files and combining them into a
single, usable dataset.

## Usage

```
ruby colorado_voter_information_processor.rb [options]
```

### Options

Several options are available to make running this script easier.

- `-d`, `--skip-zip-downloads`: Skip downloading the zip files from the web,
  because they are already saved locally. Useful with the `-e` option.
- `-x`, `--skip-zip-extracts`: Skip extracting the zip files, because they
  have already been extracted.
- `-e`, `--skip-zip-deletes`: Skip deleting the zip files, because you want to
  keep them saved locally. Useful with the `-d` option.
- `-c`, `--skip-combining-files`: Skip combining the individual txt files into
  a single csv file.

## License

MIT

