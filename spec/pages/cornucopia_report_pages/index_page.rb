module CornucopiaReportPages
  class IndexPage < SitePrism::Page
    class IndexContentsPage < SitePrism::Page
      class ReportBlock < SitePrism::Section
        element :name, "h4"
        elements :reports, ".index-list li a"
      end

      sections :reports, ReportBlock, ".report-block"
    end

    set_url "{/base_folder}/index.html"

    iframe :contents, IndexContentsPage, "#base-contents"
  end
end