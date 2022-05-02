require 'yaml'
require 'erb'

class CSA
  DETECTIONS_DIR = "#{File.dirname(File.dirname(__FILE__))}/src"
  BACKENDS_DIR = "#{File.dirname(File.dirname(__FILE__))}/backends"

  #
  # Returns a list of paths that contain Detections
  #
  def detection_paths
    Dir["#{DETECTIONS_DIR}/*/*.yaml"].sort
  end

  #
  # Returns a list of backends
  #
  def backends
    @backends ||= Dir.chdir("#{BACKENDS_DIR}") do
      Dir.glob('*').select { |f| File.directory? f }
    end.sort
  end

  #
  # Returns a map of backends and associated languages
  # Example: {"bigquery"=>["sql"], "chronicle"=>["yaral"], "log_analytics"=>["sql"]}
  #
  def formats
    @formats ||= backends.reduce({}) do | hash, backend |
      hash[backend] = []
      Dir.chdir("#{BACKENDS_DIR}/#{backend}") do
        Dir.glob('*').select { |f| File.directory? f }.each do | language |
          hash[backend] << language
        end
      end
      hash
    end
  end

  #
  # Returns a list of Detections (as Hashes from source YAML) 
  #
  def detections
    @detections ||= detection_paths.collect do |path| 
      detection_yaml = YAML.load(File.read path)
      detection_yaml['detection_yaml_path'] = path

      # Collect relative and absolute file paths of corresponding queries
      detection_yaml['query_rel_paths'] = {}
      detection_yaml['query_abs_paths'] = {}
      formats.each do | backend, languages|
        detection_yaml['query_rel_paths'][backend] = {}
        detection_yaml['query_abs_paths'][backend] = {}
        languages.each do | language |
          filename = "#{detection_yaml['id'].to_s.gsub(/\./,'_')}_#{detection_yaml['name']}.#{language}"
          query_relative_path = "../../backends/#{backend}/#{language}/" + filename
          query_absolute_path = "#{BACKENDS_DIR}/#{backend}/#{language}/" + filename
          if File.file?(query_absolute_path)
            detection_yaml['query_abs_paths'][backend][language] = query_absolute_path
            detection_yaml['query_rel_paths'][backend][language] = query_relative_path
          end
        end
      end

      detection_yaml
    end
  end
end
