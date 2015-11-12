require File.expand_path("cornucopia_report_test_contents_page", File.dirname(__FILE__))

module CornucopiaReportPages
  class CornucopiaReportHolderPage < SitePrism::Page
    class CornucopiaReportHolderIndexPage < SitePrism::Page
      iframe :contents, CornucopiaReportPages::CornucopiaReportTestContentsPage, "#report-base-contents"
    end

    set_url "{/base_folder}{/report_name}/index.html"

    elements :tests, ".report-index-list li a"
    iframe :displayed_test, CornucopiaReportHolderIndexPage, "#report-display-document"
  end
end