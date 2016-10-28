# frozen_string_literal: true

require "rails_helper"
require ::File.expand_path("../../../lib/cornucopia/util/report_table", File.dirname(__FILE__))

describe Cornucopia::Util::ReportTable::ReportTableException do
  let(:inner_error) { Exception.new("This is an error") }
  let(:subject) { Cornucopia::Util::ReportTable::ReportTableException.new(inner_error) }

  it "returns the #error" do
    expect(subject.error.to_s).to be == "This is an error"
  end

  it "passes the backtrace to the inner error" do
    expect(inner_error).to receive(:backtrace).and_call_original
    subject.backtrace
  end

  it "passes the to_s to the inner error" do
    expect(inner_error).to receive(:to_s).and_call_original
    subject.to_s
  end
end