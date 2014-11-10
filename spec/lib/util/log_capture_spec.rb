require 'spec_helper'
require ::File.expand_path("../../../lib/cornucopia/util/log_capture", File.dirname(__FILE__))

describe Cornucopia::Util::LogCapture do
  let(:file_name) { Rails.root.join("sample_log.log") }

  around(:each) do |example|
    expect(File.directory?(Rails.root.join("cornucopia_report/"))).to be_falsey
    expect(File.directory?(Rails.root.join("spec/cornucopia_report/"))).to be_falsey
    expect(File.directory?(Rails.root.join("features/cornucopia_report/"))).to be_falsey
    expect(File.exists?(file_name)).to be_falsey

    begin
      example.run
    ensure
      if (Cornucopia::Util::ReportBuilder.class_variable_get("@@current_report"))
        Cornucopia::Util::ReportBuilder.current_report.close
      end

      FileUtils.rm_rf Rails.root.join("cornucopia_report/")
      FileUtils.rm_rf Rails.root.join("spec/cornucopia_report/")
      FileUtils.rm_rf Rails.root.join("features/cornucopia_report/")
      FileUtils.rm_rf Rails.root.join("features") if Dir[Rails.root.join("features/*")].empty?
      FileUtils.rm_rf file_name
    end
  end

  describe "#highlight_log_output" do
    it "should color error lines" do
      error_line = Cornucopia::Util::LogCapture.highlight_log_output("Completed 404 this is an error")
      expect(error_line).to be_html_safe
      expect(error_line).to match(/\>Completed 404 this is an error\</)
      expect(error_line).to match(/^\<span/)
      expect(error_line).to match(/\<\/span\>$/)
      expect(error_line).to match(/completed-error/)
    end

    it "should color success lines" do
      error_line = Cornucopia::Util::LogCapture.highlight_log_output("Completed 302 this is a redirect")
      expect(error_line).to be_html_safe
      expect(error_line).to match(/\>Completed 302 this is a redirect\</)
      expect(error_line).to match(/^\<span/)
      expect(error_line).to match(/\<\/span\>$/)
      expect(error_line).to match(/completed-other/)
    end

    it "should color both error and success lines" do
      error_line = Cornucopia::Util::LogCapture.highlight_log_output("Completed 404 this is an error\nCompleted 302 this is a redirect")
      expect(error_line).to be_html_safe
      expect(error_line).to match(/\>Completed 404 this is an error\</)
      expect(error_line).to match(/^\<span/)
      expect(error_line).to match(/\<\/span\>$/)
      expect(error_line).to match(/completed-error/)
      expect(error_line).to match(/\>Completed 302 this is a redirect\</)
      expect(error_line).to match(/^\<span/)
      expect(error_line).to match(/\<\/span\>$/)
      expect(error_line).to match(/completed-other/)
    end
  end

  describe "#output_log_file" do
    it "fetches the last 500 lines of a file" do
      lines = Faker::Lorem.sentences(rand(600..1000))
      File.open(file_name, "a:UTF-8") do |write_file|
        write_file.write(lines.join("\n"))
      end

      report_table = Cornucopia::Util::ReportTable.new do |table|
        Cornucopia::Util::LogCapture.output_log_file(table, file_name)
      end

      expect(report_table.full_table).to match /#{lines[-500..-1].join("\n")}/
      expect(report_table.full_table).to_not match /#{lines[-501..-1].join("\n")}/
    end

    it "fetches the last 500 lines of a file even if it has to fetch multiple times" do
      lines = (0..rand(600..1000)).to_a.map { Faker::Lorem.sentences(rand(5..10)).join(" ") }
      File.open(file_name, "a:UTF-8") do |write_file|
        write_file.write(lines.join("\n"))
      end

      report_table = Cornucopia::Util::ReportTable.new do |table|
        Cornucopia::Util::LogCapture.output_log_file(table, file_name)
      end

      expect(report_table.full_table).to match /#{lines[-500..-1].join("\n")}/
      expect(report_table.full_table).to_not match /#{lines[-501..-1].join("\n")}/
    end
  end

  describe "#capture_logs" do
    after(:each) do
      Cornucopia::Util::Configuration.remove_log_file("sample_log.log")
    end

    it "starts a new report if it is not passed a table" do
      expect(Cornucopia::Util::ReportBuilder).to receive(:current_report).and_call_original
      expect(Cornucopia::Util::LogCapture).to receive(:capture_logs).twice.and_call_original
      Cornucopia::Util::Configuration.add_log_file("sample_log.log")

      lines = Faker::Lorem.sentences(rand(600..1000))
      File.open(file_name, "a:UTF-8") do |write_file|
        write_file.write(lines.join("\n"))
      end

      Cornucopia::Util::LogCapture.capture_logs(nil)

      report_data = File.read(Rails.root.join("cornucopia_report/cornucopia_report/report_contents.html"))
      expect(report_data).to match /#{lines[-500..-1].join("\n")}/
      expect(report_data).to_not match /#{lines[-501..-1].join("\n")}/
    end

    it "goes up one level if you are in spec or features" do
      expect(Cornucopia::Util::ReportBuilder).to receive(:current_report).and_call_original
      expect(Cornucopia::Util::LogCapture).to receive(:capture_logs).twice.and_call_original
      Cornucopia::Util::Configuration.add_log_file("sample_log.log")

      lines = Faker::Lorem.sentences(rand(600..1000))
      File.open(file_name, "a:UTF-8") do |write_file|
        write_file.write(lines.join("\n"))
      end

      new_root = Rails.root.join(%w(features features).sample).to_s
      expect(Rails).to receive(:root).at_least(1).and_return(new_root)
      Cornucopia::Util::LogCapture.capture_logs(nil)

      report_data = File.read(File.join(new_root, "cornucopia_report/cornucopia_report/report_contents.html"))
      expect(report_data).to match /#{lines[-500..-1].join("\n")}/
      expect(report_data).to_not match /#{lines[-501..-1].join("\n")}/
    end

    it "does not require Rails" do
      expect(Cornucopia::Util::ReportBuilder).to receive(:current_report).and_call_original
      expect(Cornucopia::Util::LogCapture).to receive(:capture_logs).twice.and_call_original
      Cornucopia::Util::Configuration.add_log_file("sample_log.log")
      FileUtils.cd Rails.root.to_s
      expect(Object).to receive(:const_defined?).at_least(1).with("Rails").and_return(false)

      lines = Faker::Lorem.sentences(rand(600..1000))
      File.open(file_name, "a:UTF-8") do |write_file|
        write_file.write(lines.join("\n"))
      end

      Cornucopia::Util::LogCapture.capture_logs(nil)

      report_data = File.read(Rails.root.join("cornucopia_report/cornucopia_report/report_contents.html"))
      expect(report_data).to match /#{lines[-500..-1].join("\n")}/
      expect(report_data).to_not match /#{lines[-501..-1].join("\n")}/
    end
  end
end