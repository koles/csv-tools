csv-tools
=========

CSV exploration and manipulation tools.

An overview of help screens follows. If you need an RFC-4180 compliant alternative of the `cut` unix command, scroll down to the `reshuffle` tool.

Prerequisite: `perl -MCPAN -e "install Text::CSV"`

aggregate
---------

    $ ./aggregate --help
    Usage:
         aggregate [options] < file.csv > aggregated_file.csv
    
         #
         # The examples below suppose a test/test.csv file containing the content as follows:
         #    User,Browser,Date,Hour,DataTransfer
         #    Jane,Firefox,2010-02-01,01:00,100
         #    John,IE,2010-02-01,01:00,100
         #    Jane,Firefox,2010-02-01,02:00,100
         #    John,Firefox,2010-02-01,02:00,50
         #    Kim,Chrome,2010-02-01,02:00,100
         #
    
         #
         # Aggregate the DataTransfer fact in the input CSV by the Date and Hour columns
         # Expected output:
         #   Date,Hour,DataTransfer,Count
         #   2010-02-01,01:00,200,2
         #   2010-02-01,02:00,250,3
         #
         aggregate --by=Date,Hour --fact=DataTransfer < test/test.csv > tranfer_by_time.csv
    
         #
         # No fact declared implies it's possible to group by any combination of fields.
         # Only the Count aggregation will be created.
         # This example aggregates only the count of lines in the input CSV by all
         # fields except Date and Hour.
         # Expected output:
         #   User,Browser,DataTransfer,Count
         #   Jane,Firefox,100,2
         #   John,IE,100,1
         #   John,Firefox,50,1
         #   Kim,Chrome,100,1
         #
         aggregate --by-all-except=Date,Hour < test/test.csv > aggregated.csv
    
    Options:
         --help, -h               short help screen
         --man                    slightly more detailed documentation
         --input-file=path        input file (STDIN by default)
         --fact=list              list of fields to be treated as facts. Sum of each of these
                                  fields will be computed. If not provided, only the count of
                                  rows will be provided
         --by=list                comma separated list to aggregate by. Either 'by' or
                                  'by-all-except' option must be specified.
         --by-all-except=list     facts will be aggregated by all field except those specified
                                  using this or --fact options          
         --no-escape              signifies the values in the input CSV do not cantain
                                  the separator so a simple 'split' function can be
                                  used instead of a complete CSV implementation
         --debug                  prints some debug information and progress by tens of
                                  thousands processed input lines
         --in-separator=char      field separator in the source file ("," by default)
         --out-separator=char     output field separator ("," by default)
    

check_mapping
-------------

    $ ./check_mapping --help
    Usage:
         check_mapping [options] pk_column_name referenced_csv_file \
                                 fk_column_name processed_csv_file
         check_mapping [options] fk_column_name referenced_csv_file \
                                 pk_column_name < processed_csv_file
    
         Example:
    
         #
         # list 'Employee ID' values in salaries.csv that don't match a value of
         # 'ID' in employees.csv
         #
         check_mapping salaries.csv 'Employee ID' employees.csv 'ID'
    
    Options:
         --help, -h               short help screen
         --man                    slightly more detailed documentation
         --in-separator=char      field separator in the source file ("," by default)
         --out-separator=char     output field separator ("," by default)
    

clean_mapping
-------------

    $ ./clean_mapping --help
    Usage:
         clean_mapping [options] pk_column_name referenced_csv_file \
                                 fk_column_name processed_csv_file
         clean_mapping [options] pk_column_name referenced_csv_file \
                                 fk_column_name < processed_csv_file
    
         Example:
    
         #
         # filter out rows of salaries.csv that contain an 'Employee ID' value with
         # no matching value of 'ID' in employees.csv
         # 
         check_mapping salaries.csv 'Employee ID' employees.csv 'ID'
    
    Options:
         --help, -h               short help screen
         --man                    slightly more detailed documentation
         --keep                   keeps the violating lines but replaces offending
                                  foreign keys with blanks
         --join=list              comma separated list of the fields from the referenced 
                                  CSV file to be added to output stream. An equivalent 
                                  of performing an inner join (or an outer join if the
                                  --keep switch is used)
         --in-separator=char      field separator in the source file ("," by default)
         --out-separator=char     output field separator ("," by default)
    

extract_fields
--------------

    $ ./extract_fields --help

list_headers
------------

    $ ./list_headers --help
    Usage:
         list_headers [options] file.csv
         list_headers [options] < file.csv
    
    Options:
         --help, -h           short help screen
         --man                slightly more detailed documentation
         --max-lenth          print maximal length for each column
         --in-separator=char  field separator in the source file ("," by default)
    

reshuffle
---------

    $ ./reshuffle --help
    Usage:
         reshuffle [options] file [field ... ]
    
         # drop second field and swap third and fourth using field names
         reshuffle data.csv column_name1 column_name3 column_name2
    
         # The same using indexes + read pipe separated and dump hash separated fields
         reshuffle --numbers --in-separator='|' --out-separator='#' data.csv 0 3 2
    
         # Insert 'N/A' before the first output field and after 6th field
         reshuffle --insert-fields=N/A --insert-before=0 --insert-after=5 data.csv
    
    Options:
         --help, -h               short help screen
         --man                    slightly more detailed documentation
         --numbers                specify output fields by indexes rather than by
                                  numbers starging from 0.
         --insert-field=string    string to be used by --insert-before and
                                  --insert-after ("N/A" by default)
         --insert-after=indexes   comma separated list of indexes after which an
                                  extra string should be inserted
         --insert-before=indexes  comma separated list of indexes before which an
                                  extra string should be inserted
         --skip-first             drop the first line
         --in-separator=char      field separator in the source file ("," by default)
         --out-separator=char     output field separator ("," by default)
    
    Arguments:
         First argument            The following cases are handled especially for the sake of
                                   backward compatibility unless the --input-file option is
                                   provided:
                                   1) If a so named file exist, it is treated as the input
                                   file name.
                                   2) If equal to '-' the input is expceted on STDIN.
         Following arguments       Identify fields present in the output stream.
                                   By default, field names as defined in the CSV header
                                   are expected. If the --numbers option is used, numeric
                                   indexes are expected instead.
                                   Using no fields is a shortcut for enumerating all fields.
    

surrogate
---------

    $ ./surrogate --help
    Usage:
         surrogate [options] lookups
    
         # Generate keys for first two fields and store [ generated key, orig value]
         # pairs in out/dim_name.csv and out/dim_industry.csv lookup files.
         # All fields except for the first two are dumped unchanged.
         surrogate --input-file=data.csv \
             output-dir=out dim_name dim_industry \
             > out/data.csv
    
         # copy previously generated lookup files into an extra folder
         cp out/dim_*.csv lookups_cache/
    
         # Preload lookups from the lookups_cache folder before processing. Don't generate
         # keys for values that has their keys already stored in corresponding files within
         # the lookups_cache/ folder.
         surrogate --input-file=data.csv --input-lookups-dir=lookups_cache \
              output-dir=out dim_name dim_industry \
              > out/data.csv
    
         # The same as above except for the processing exits if a non-resolved value
         # is found in the second field
         surrogate --input-file=data.csv --input-lookups-dir=lookups_cache \
              --read-only=dim_industry \
              output-dir=out dim_name dim_industry \
              > out/data.csv
    
         # Process a file with hierarchical attributes (a GEO dimension is used in this
         # example). The --attr-group option tells to distinguish e.g. Albany, NY, USA from
         # Albany, OR, USA or Albany, WA, Australia.
         surrogate --input-file=data.csv --input-lookups-dir=my_geo_dir --output-dir=out \
              --attr-group=dim_city,dim_state,dim_country \
              dim_city dim_state dim_country > out/data.csv
    
    Options:
         --help, -h               short help screen
         --man                    slightly more detailed documentation
         --ignore-dups            by default, a column marked as a primary key
                                  using the --primary-key option is required to hold
                                  unique values. The --ignore-dups switch removes this
                                  constrain.
         --input-file=path        input file with values to be replaced with keys
                                  (STDIN is used by default)
         --input-lookups-dir=path folder containing already existing lookup files
                                  (i.e. files hodling key-value pairs)
         --output-dir=path        folder where the key-value pairs accumulated during
                                  processing will be dumped. Each file's name will be
                                  based on the given lookup name (see ARGUMENTS below)
                                  with the 'csv' suffix.
                                  If some lookups has been preloaded from the folder
                                  specified via --input-lookup-dir, the dumped lookup
                                  files will contain the preloaded key-value pairs as
                                  well as those generated during this processing.
         --primary-key=name       the field marked as 'primary-key' is not replaced, 
                                  the generated key is inserted before the primary key
                                  instead. Only first field may be marked as primary
                                  key.
         --primary-key-name=name  the name of column of the original primary key
                                  ('Original Id' by default). This option is ignored
                                  unless --primary-key is specified.
         --skip-first             to silently discard the first row
         --keep-header            to keep fields of the first row that correspond to 
                                  fields to be dumped
         --read-only=list         comma separated list of fields that are not expecged
                                  to contain other values that those preloaded from 
                                  input-lookups-dir. The processing fails if such an
                                  unknown value occurs.
         --rename=list            comma separated list of colon separated pairs of
                                  old and new column names. Defines how the original
                                  names should be renamed in the output file. 
         --skip-new               skip records with unresolved lookups (TODO doesn't work
                                  properly yet)
         --default=pairs          list of lookups specific default values for new
                                  values, use key correspnding to the given value
                                  rather than generating a new values. 
                                  Useful for garbage workarounds
                                  Example: --default=company:1,industry:1
         --debug                  Print some possibly interesting processing info
         --attr-group=list        Values of the first field of the group list are
                                  replaced with keys specified to the whole value
                                  groups rather than to the first field's value only.
                                  Useful for processing hierarchical attributes
         --in-separator=char      field separator in the source file ("," by default)
         --out-separator=char     output field separator ("," by default)
    
    Arguments:
        The script arguments represent lookup files corresponding to each column
        of the input file. The number of arguments must be smaller or equal to
        the number of columns.
    
        Special lookup names: - prefixed with 'UNUSED' - these columns will be
        discarded silently - prefixed with 'KEEP' - the original value will be
        printed to output without any processing
    

