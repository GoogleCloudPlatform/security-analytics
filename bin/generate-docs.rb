#! /usr/bin/env ruby
CSA_DIR = "#{File.expand_path("..", File.dirname(__FILE__))}"
CSA_LIB_DIR = "#{CSA_DIR}/lib"
CSA_FIXTURES_DIR = "#{CSA_DIR}/test/fixtures"

$LOAD_PATH << "#{CSA_LIB_DIR}" unless $LOAD_PATH.include? "#{CSA_LIB_DIR}"
require 'erb'
require 'fileutils'
require 'json'
require 'csv'
require 'csa'

class CSADocs
  CSA = CSA.new

  #
  # Generates all the documentation used by CSA
  #
  def generate_all_the_docs!
    oks = []
    fails = []

    CSA.detections.each do |detection|
      begin
        print "Generating docs for #{detection['detection_yaml_path']}"

        generate_detection_docs! detection, detection['detection_yaml_path'].gsub(/.yaml/, '.md')

        oks << detection['detection_yaml_path']
        puts "OK"

        detection['query_abs_paths'].each do |backend, languages|
          languages.each do |language, path|
            puts "  Found #{path}"
          end
        end
      rescue => ex
        fails << detection['detection_yaml_path']
        puts "FAIL\n#{ex}\n#{ex.backtrace.join("\n")}"
      end
    end
    puts
    puts "Generated docs for #{oks.count} detections, #{fails.count} failures"

    generate_index!  "#{CSA_DIR}/index.md"

    return oks, fails
  end

  #
  # Generates Markdown documentation for a specific detection from its YAML source
  #
  def generate_detection_docs!(detection, output_doc_path)
    samples = []
    sampleFilenames = detection.fetch('samples') || []
    sampleFilenames.each do |filename|
      samples.push({
        'title' => filename,
        'payload' => JSON.parse(File.read("#{CSA_FIXTURES_DIR}/#{filename}.json"))
      })
    end

    query_paths = detection['query_rel_paths'] || {}
    
    template = ERB.new(File.read("#{CSA_LIB_DIR}/doc_template.md.erb"), trim_mode:"-")
    generated_doc = template.result(binding)

    print " => #{output_doc_path} => "
    File.write output_doc_path, generated_doc
  end

  #
  # Generates Markdown table for all detections
  #
  def generate_index!(output_doc_path)
    result = ''
    result += "## Security Analytics Use Cases\n"
    
    result += "| # | Cloud Security Threat | Log Source | Audit | Detect | ATT&CK&reg; Techniques |\n"
    result += "|---|---|---|:-:|:-:|:-:|\n"

    categoryId = 0
    CSA.detections.each do |detection|
      
      detectionCategoryId = detection['id'].to_s.split('.')[0].to_i
      if (detectionCategoryId != categoryId)
        categoryId = detectionCategoryId
        htmlElementId, htmlElementEmoji = case categoryId
          when 1 then ['login-access-patterns', ':vertical_traffic_light:']
          when 2 then ['iam-keys-secrets-changes', ':key:']
          when 3 then ['cloud-provisioning-activity', ':building_construction:']
          when 4 then ['cloud-workload-usage', ':cloud:']
          when 5 then ['data-usage', ':droplet:']
          when 6 then ['network-activity', ':zap:']
          else ['', '']
        end
        result += "| <div id=\"#{htmlElementId}\">#{categoryId}</div> | #{htmlElementEmoji} **#{detection['category']}**\n"
      end

      result += "| #{detection['id']}"
      result += "| [#{detection['display_name']}](./src/#{detection['id']}/#{detection['id']}.md)"
      result += "| #{detection['sources'].join(', ')}"
      result += "| " + ((detection['use_cases'].include? 'Audit') ? ':white_check_mark:' : '')
      result += "| " + ((detection['use_cases'].include? 'Detect') ? ':white_check_mark:' : '')
        
      attack_technique_links = []
      if (detection['attack_mapping'] != nil && detection['attack_mapping'].count > 0)
        attack_technique_links = detection['attack_mapping'].map do |technique|
          "[#{technique['technique']}](#{technique['link']} \"#{technique['title']}\")"
        end
      end
      result += "| #{attack_technique_links.join(', ')} |\n"
    end

    File.write output_doc_path, result

    puts "Generated index at #{output_doc_path}"
  end
end

#
# MAIN
#
oks, fails = CSADocs.new.generate_all_the_docs!

exit fails.count