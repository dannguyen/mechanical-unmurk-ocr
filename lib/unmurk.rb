module Unmurk
  ROOT  = File.expand_path(File.dirname(__FILE__) + '/..')
  ROOT_LIB = File.join(ROOT, 'lib')
  DIR_PATHS = {
    'unmurk_lib' => File.join(ROOT_LIB, 'unmurk')
  }
  
end

require 'fileutils'
require 'shellwords'