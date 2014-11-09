require "spec_helper"
require ::File.expand_path("../../../lib/cornucopia/util/generic_settings", File.dirname(__FILE__))

describe Cornucopia::Util::GenericSettings do
  let(:subject) { Cornucopia::Util::GenericSettings.new }

  class Object
    def method_missing(method_sym, *arguments, &block)
      if method_sym == :___stupid_missing_message
        "Missing message"
      else
        super
      end
    end

    def respond_to?(method_sym, include_private = false)
      if method_sym == :___stupid_missing_message
        true
      else
        super
      end
    end
  end

  it "responds_to? anything" do
    expect(subject.respond_to?(Faker::Lorem.word)).to be_truthy
  end

  it "calls the super implementation of somthing if it exists" do
    expect(subject.object_id).to be
  end

  it "looks for a value in a hash if it isn't recognized" do
    expect(subject.send(Faker::Lorem.word)).not_to be
  end

  it "will store a value in anything that isn't a base function" do
    stored_value = Faker::Lorem.paragraphs
    value_name   = Faker::Lorem.word

    subject.send("#{value_name}=", stored_value)
    expect(subject.send(value_name)).to be == stored_value
  end

  it "calls the super method" do
    expect(subject.___stupid_missing_message).to be == "Missing message"
  end
end