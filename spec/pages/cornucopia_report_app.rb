require ::File.expand_path("../../lib/cornucopia/site_prism/page_application", File.dirname(__FILE__))
require ::File.expand_path("../../lib/cornucopia/site_prism/element_extensions", File.dirname(__FILE__))

Dir[File.expand_path("**/*.rb", File.dirname(__FILE__))].each { |require_file| require require_file }

class CornucopiaReportApp < Cornucopia::SitePrism::PageApplication
  def pages_module
    ::CornucopiaReportPages
  end
end