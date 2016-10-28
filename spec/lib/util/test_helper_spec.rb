# frozen_string_literal: true

require "rails_helper"

class FakeFeature
  attr_accessor :feature_name

  def initialize(feature_name)
    @feature_name = feature_name
  end

  def name
    feature_name
  end

  def title
    feature_name
  end
end

class OtherFakeScenario
  attr_accessor :scenario_title
  attr_accessor :line_number

  def initialize(line_number, scenario_title)
    @line_number    = line_number
    @scenario_title = scenario_title
  end

  def line
    line_number
  end
end

class FakeScenario
  attr_accessor :scenario_title
  attr_accessor :feature

  def initialize(feature_name, scenario_title)
    @feature        = FakeFeature.new(feature_name)
    @scenario_title = scenario_title
  end

  def full_description
    scenario_title
  end

  def name
    scenario_title
  end

  def title
    scenario_title
  end
end

RSpec.describe Cornucopia::Util::TestHelper do
  let(:test_name) { Faker::Lorem.sentence }

  describe "#cucumber_name" do
    it "uses the name Unknown if the name cannot be determined" do
      expect(Cornucopia::Util::TestHelper.instance.cucumber_name("fred")).to eq "Unknown"
    end

    it "uses the feature title and scenario title if known" do
      feature_name  = Faker::Lorem.sentence
      scenario_name = Faker::Lorem.sentence
      scenario      = FakeScenario.new(feature_name, scenario_name)

      expect(Cornucopia::Util::TestHelper.instance.cucumber_name(scenario)).to eq "#{feature_name}:#{scenario_name}"
    end

    it "uses the line number if the feature name is not known" do
      line_num      = rand(0..5_000_000_000_000)
      scenario_name = Faker::Lorem.sentence
      scenario      = OtherFakeScenario.new(line_num, scenario_name)

      expect(Cornucopia::Util::TestHelper.instance.cucumber_name(scenario)).to eq "Line - #{line_num}"
    end
  end

  describe "#spinach_name" do
    it "uses the feature name and the scenario title" do
      feature_name  = Faker::Lorem.sentence
      scenario_name = Faker::Lorem.sentence
      scenario      = FakeScenario.new(feature_name, scenario_name)

      expect(Cornucopia::Util::TestHelper.instance.spinach_name(scenario)).to eq "#{feature_name} : #{scenario_name}"
    end
  end

  describe "#example_name" do
    it "uses the full_description" do
      feature_name  = Faker::Lorem.sentence
      scenario_name = Faker::Lorem.sentence
      scenario      = FakeScenario.new(feature_name, scenario_name)

      expect(Cornucopia::Util::TestHelper.instance.rspec_name(scenario)).to eq scenario_name
    end
  end

  describe "#record_test_start" do
    it "calls record_test with 'Start'" do
      test_name = Faker::Lorem.sentence
      expect(Cornucopia::Util::TestHelper.instance).to receive(:record_test).with("Start", test_name)

      Cornucopia::Util::TestHelper.instance.record_test_start(test_name)
    end
  end

  describe "#record_test_end" do
    it "calls record_test with 'End'" do
      expect(Cornucopia::Util::TestHelper.instance).to receive(:record_test).with("End", test_name)

      Cornucopia::Util::TestHelper.instance.record_test_end(test_name)
    end
  end

  describe "#record_test" do
    around(:each) do |example|
      orig_record_test_start_and_end_in_log = Cornucopia::Util::Configuration.record_test_start_and_end_in_log
      orig_record_test_start_and_end_format = Cornucopia::Util::Configuration.record_test_start_and_end_format

      begin
        example.run
      ensure
        Cornucopia::Util::Configuration.record_test_start_and_end_in_log = orig_record_test_start_and_end_in_log
        Cornucopia::Util::Configuration.record_test_start_and_end_format = orig_record_test_start_and_end_format
      end
    end

    context "record_test_start_and_end_in_log is false" do
      before(:each) do
        Cornucopia::Util::Configuration.record_test_start_and_end_in_log = false
      end

      it "does not log anything" do
        allow(Rails.logger).to receive(:error).and_call_original
        expect(Rails.logger).not_to receive(:error).with("******** Start: #{test_name}", )

        Cornucopia::Util::TestHelper.instance.record_test("Start", test_name)
      end
    end

    context "record_test_start_and_end_in_log is true" do
      before(:each) do
        Cornucopia::Util::Configuration.record_test_start_and_end_in_log = true
      end

      it "records a log message" do
        allow(Rails.logger).to receive(:error).and_call_original
        expect(Rails.logger).to receive(:error).with("******** Start: #{test_name}",)

        Cornucopia::Util::TestHelper.instance.record_test("Start", test_name)
      end

      it "uses a custom format" do
        some_text = Faker::Lorem.sentence

        Cornucopia::Util::Configuration.record_test_start_and_end_format = "%{start_end} #{some_text} %{test_name}"
        allow(Rails.logger).to receive(:error).and_call_original
        expect(Rails.logger).to receive(:error).with("Start #{some_text} #{test_name}",)

        Cornucopia::Util::TestHelper.instance.record_test("Start", test_name)
      end
    end
  end
end