# frozen_string_literal: true

module GooglePages
  class EmailSection < SitePrism::Section
    # include GalaxyPages::SimpleElements

    # indexed_elements "td:nth-child(%{element_index})",
    #                  :left_padding,
    #                  :select,
    #                  :star,
    #                  :from,
    #                  :padding_2,
    #                  :subject,
    #                  :padding_3,
    #                  :time
  end

  class EmailPage < SitePrism::Page
    set_url "https://mail.google.com/mail/#inbox"

    # sections :emails, EmailSection, "#:3a tr"
    sections :emails, EmailSection, ".F.cf.zt tr"
  end
end