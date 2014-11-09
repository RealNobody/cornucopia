require 'spec_helper'
require ::File.expand_path("../../../lib/cornucopia/util/report_formatters", File.dirname(__FILE__))

describe Cornucopia::Util::CucumberFormatter do
  describe "#format_location" do
    it "formats the passed in object as #file.#line" do
      file_location = double(:file_location, file: Faker::Lorem.sentence, line: rand(1..500))
      expect(Cornucopia::Util::ReportBuilder).to receive(:pretty_format).and_call_original
      expect(Cornucopia::Util::CucumberFormatter.format_location(file_location)).
          to eq "#{file_location.file}:#{file_location.line}"
    end
  end
end