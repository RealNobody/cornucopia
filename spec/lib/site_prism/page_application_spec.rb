require "spec_helper"
require ::File.expand_path("../../../lib/cornucopia/site_prism/page_application", File.dirname(__FILE__))

describe Cornucopia::SitePrism::PageApplication do
  class SimpleTestApplicationClass < Cornucopia::SitePrism::PageApplication
  end

  class TestApplicationClass < Cornucopia::SitePrism::PageApplication
    def pages_module
      TestModule
    end
  end

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

  module TestModule
    class TestClassPage < ::SitePrism::Page
      set_url "https://www.google.com"
    end

    module SubTestModule
      class TestClassPage < ::SitePrism::Page
        set_url "https://www.facebook.com"
      end
    end
  end

  it "returns a memoized instance of the derived class" do
    class_instance = TestApplicationClass.current_instance
    expect(class_instance.object_id).to be == TestApplicationClass.current_instance.object_id
    expect(class_instance).to be_a(TestApplicationClass)
  end

  it "should return #pages_module" do
    expect(TestApplicationClass.pages_module).to be == TestModule
  end

  it "does not recognize non instance or class functions that are not pages" do
    expect { TestApplicationClass.send(Faker::Lorem.word) }.to raise_error(NoMethodError)
  end

  it "does return a simple page object" do
    expect(TestApplicationClass.test_class_page).to be_a(TestModule::TestClassPage)
  end

  it "does return a sub_module page object" do
    expect(TestApplicationClass.sub_test_module__test_class_page).to be_a(TestModule::SubTestModule::TestClassPage)
  end

  it "has a default #page_module" do
    expect(SimpleTestApplicationClass.pages_module).to be == Object
  end

  it "calls respond_to? of the parent" do
    expect(SimpleTestApplicationClass.respond_to?(:yaml_tag)).to be_truthy
  end

  it "calls respond_to? of the instance" do
    expect(SimpleTestApplicationClass.respond_to?(:to_yaml)).to be_truthy
  end

  it "calls method_missing of the instance" do
    expect(TestApplicationClass.___stupid_missing_message).to be == "Missing message"
  end
end