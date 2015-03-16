require "rails_helper"
require "tempfile"
require ::File.expand_path("../../../lib/cornucopia/util/file_asset", File.dirname(__FILE__))

describe Cornucopia::Util::FileAsset do
  let(:asset) { Cornucopia::Util::FileAsset.new("index_contents.html") }

  around(:each) do |example|
    begin
      FileUtils.mkdir_p(File.join(File.dirname(__FILE__), "test_file_output"))

      example.run
    ensure
      FileUtils.rm_rf(File.join(File.dirname(__FILE__), "test_file_output"))
    end
  end

  it "returns the path to the default asset path" do
    expect(asset.path).to be == File.absolute_path(File.join(File.dirname(__FILE__), "../../../lib/cornucopia/source_files/index_contents.html"))
  end

  it "copies base files" do
    asset.create_file(File.join(File.dirname(__FILE__), "test_file_output/copy_file_test.html"))

    copy_file   = File.read(File.join(File.dirname(__FILE__), "test_file_output/copy_file_test.html"))
    source_file = File.read(asset.path)

    expect(copy_file).to be == source_file
  end

  it "allows for an overridden file asset" do
    asset.body = "This is a specialized asset"

    asset.create_file(File.join(File.dirname(__FILE__), "test_file_output/copy_file_test.html"))

    copy_file = File.read(File.join(File.dirname(__FILE__), "test_file_output/copy_file_test.html"))

    expect(copy_file).to be == "This is a specialized asset"
  end

  it "allows a separate file source" do
    alt_asset = Cornucopia::Util::FileAsset.new("report_base.html")

    asset.source_file = alt_asset.path

    asset.create_file(File.join(File.dirname(__FILE__), "test_file_output/copy_file_test.html"))

    copy_file   = File.read(File.join(File.dirname(__FILE__), "test_file_output/copy_file_test.html"))
    source_file = File.read(alt_asset.path)

    expect(copy_file).to be == source_file
  end

  it "adds files if they don't exist" do
    asset.add_file(File.join(File.dirname(__FILE__), "test_file_output/copy_file_test.html"))

    copy_file   = File.read(File.join(File.dirname(__FILE__), "test_file_output/copy_file_test.html"))
    source_file = File.read(asset.path)

    expect(copy_file).to be == source_file
  end

  it "does not add a file if it already exists" do
    alt_asset = Cornucopia::Util::FileAsset.new("report_base.html")

    alt_asset.add_file(File.join(File.dirname(__FILE__), "test_file_output/copy_file_test.html"))
    asset.add_file(File.join(File.dirname(__FILE__), "test_file_output/copy_file_test.html"))

    copy_file   = File.read(File.join(File.dirname(__FILE__), "test_file_output/copy_file_test.html"))
    source_file = File.read(alt_asset.path)

    expect(copy_file).to be == source_file
  end

  it "shares and caches file assets" do
    cached      = Cornucopia::Util::FileAsset.asset("index_contents.html")
    cached.body = "This is a specialized asset"

    alt_cached = Cornucopia::Util::FileAsset.asset("index_contents.html")

    alt_cached.add_file(File.join(File.dirname(__FILE__), "test_file_output/copy_file_test.html"))
    copy_file = File.read(File.join(File.dirname(__FILE__), "test_file_output/copy_file_test.html"))

    expect(copy_file).to be == "This is a specialized asset"
  end
end