module Blocky
  class AdminGenerator < Rails::Generators::Base
    source_root File.expand_path("../../../blocky/admin", __FILE__)

    def generate_config_file
      if Gem.loaded_specs.has_key?('activeadmin')
        template 'content_block.rb', 'app/admin/content_block.rb'
      else
        raise StandardError, 'Could not generate activeadmin page without activeadmin installed.'
      end
    end
  end
end

