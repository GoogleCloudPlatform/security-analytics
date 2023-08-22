#! /usr/bin/env ruby
CSA_DIR = "#{File.expand_path("..", File.dirname(__FILE__))}"
CSA_LIB_DIR = "#{CSA_DIR}/lib"
CSA_DATAFORM_DIR = "#{CSA_DIR}/dataform/definitions/raw"

$LOAD_PATH << "#{CSA_LIB_DIR}" unless $LOAD_PATH.include? "#{CSA_LIB_DIR}"
require 'erb'
require 'fileutils'
require 'json'
require 'csv'
require 'csa'

class CSASqlx
  CSA = CSA.new

  #
  # Generates all SQLX queries for all CSA detections with Log Analytics SQL query
  #
  def generate_all_the_sqlx!
    oks = []
    fails = []

    CSA.detections.each do |detection|
      begin
        print "Generating sqlx for #{detection['id']}"

        query_filename = detection['query_abs_paths']['log_analytics']['sql'] || ''
        if not File.exist?(query_filename)
          puts " FAIL Source query does not exist."
          next
        end

        sqlx_filename = "#{detection['id'].to_s.gsub(/\./,'_')}_raw.sqlx"
        sqlx_filename = "#{CSA_DATAFORM_DIR}/#{sqlx_filename}"

        generate_detection_sqlx! query_filename, detection['name'], sqlx_filename

        oks << detection['id']
        puts " OK"
      rescue => ex
        fails << detection['id']
        puts " FAIL #{ex}\n#{ex.backtrace.join("\n")}"
      end
    end
    puts
    puts "Generated sqlx for #{oks.count} detections, #{fails.count} failures"

    return oks, fails
  end

  #
  # Generates SQLX query for a specific detection from its Log Analytics SQL query
  #
  def generate_detection_sqlx!(query_path, description, output_sqlx_path)
    sqlx_type = <<~EOF
    config {
      type: "view",
      description: "#{description}"
    }
    EOF

    # Replace FROM clause with data source reference defined in Dataform
    sqlx_query = File.read(query_path)
    sqlx_query = sqlx_query.gsub(
      '`[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`',
      '${ref("_AllLogs")}'
    )
    
    # Updated hardcoded timestamp condition from WHERE clause
    sqlx_query = sqlx_query.gsub(
      /timestamp >=? .*$/,
      'timestamp >=  TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL ${dataform.projectConfig.vars.raw_lookback_days} DAY)'
    )

    # Strip out copyrights comments
    sqlx_query = sqlx_query.gsub(/\/\*.*?\*\//m, "")

    print " => #{output_sqlx_path} =>"
    File.write output_sqlx_path, sqlx_type + sqlx_query
  end
end

#
# MAIN
#
oks, fails = CSASqlx.new.generate_all_the_sqlx!

exit fails.count