#! /usr/bin/env ruby
TDAC_DIR = "#{File.dirname(File.dirname(__FILE__))}"
TDAC_LIB_DIR = "#{TDAC_DIR}/lib"
TDAC_FIXTURES_DIR = "#{TDAC_DIR}/test/fixtures"

$LOAD_PATH << "#{TDAC_LIB_DIR}" unless $LOAD_PATH.include? "#{TDAC_LIB_DIR}"
require 'erb'
require 'fileutils'
require 'json'
require 'csv'
require 'tdac'

class TdacDocs
  Tdac = Tdac.new

  #
  # Generates all the documentation used by TDaC
  #
  def generate_all_the_docs!
    oks = []
    fails = []

    Tdac.detections.each do |detection|
      begin
        print "Generating docs for #{detection['detection_yaml_path']}"
        generate_detection_docs! detection, detection['detection_yaml_path'].gsub(/.yaml/, '.md')

        oks << detection['detection_yaml_path']
        puts "OK"
      rescue => ex
        fails << detection['detection_yaml_path']
        puts "FAIL\n#{ex}\n#{ex.backtrace.join("\n")}"
      end
    end
    puts
    puts "Generated docs for #{oks.count} detections, #{fails.count} failures"
    return oks, fails
  end

  #
  # Generates Markdown documentation for a specific detection from its YAML source
  #
  def generate_detection_docs!(detection, output_doc_path)
    samples = []
    detection.fetch('samples', []).each do |sample|
      samples.push({
        'title' => sample,
        'payload' => JSON.parse(File.read("#{TDAC_FIXTURES_DIR}/#{sample}.json"))
      })
    end

    queryPaths = {}
    if (File.file?("#{TDAC_DIR}/sql/#{detection['id'].to_s.gsub(/\./,'_')}_#{detection['name']}.sql"))
      queryPaths['sql'] = "../../sql/#{detection['id'].to_s.gsub(/\./,'_')}_#{detection['name']}.sql"
    end

    template = ERB.new File.read("#{TDAC_LIB_DIR}/doc_template.md.erb"), nil, "-"
    generated_doc = template.result(binding)

    print " => #{output_doc_path} => "
    File.write output_doc_path, generated_doc
  end
end

#
# MAIN
#
oks, fails = TdacDocs.new.generate_all_the_docs!

exit fails.count