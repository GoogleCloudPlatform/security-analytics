require 'yaml'
require 'erb'

class CSA
  DETECTIONS_DIR = "#{File.dirname(File.dirname(__FILE__))}/src"

  #
  # Returns a list of paths that contain Detections
  #
  def detection_paths
    Dir["#{DETECTIONS_DIR}/*/*.yaml"].sort
  end

  #
  # Returns a list of Detections (as Hashes from source YAML) 
  #
  def detections
    @detections ||= detection_paths.collect do |path| 
      detection_yaml = YAML.load(File.read path)
      detection_yaml['detection_yaml_path'] = path
      detection_yaml
    end
  end
end
