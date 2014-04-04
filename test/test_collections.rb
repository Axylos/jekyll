require 'helper'

class TestCollections < Test::Unit::TestCase

  def fixture_site(overrides = {})
    Jekyll::Site.new(Jekyll.configuration(
      overrides.merge({
        "source"      => source_dir,
        "destination" => dest_dir
      })
    ))
  end

  context "an evil collection" do
    setup do
      @collection = Jekyll::Collection.new(fixture_site, "../../etc/password")
    end

    should "sanitize the label name" do
      assert_equal @collection.label, "etcpassword"
    end

    should "have a sanitized relative path name" do
      assert_equal @collection.relative_directory, "_etcpassword"
    end

    should "have a sanitized full path" do
      assert_equal @collection.directory, source_dir("_etcpassword")
    end
  end

  context "a simple collection" do
    setup do
      @collection = Jekyll::Collection.new(fixture_site, "methods")
    end

    should "sanitize the label name" do
      assert_equal @collection.label, "methods"
    end

    should "contain no docs when initialized" do
      assert_empty @collection.docs
    end

    should "know its relative directory" do
      assert_equal @collection.relative_directory, "_methods"
    end

    should "know the full path to itself on the filesystem" do
      assert_equal @collection.directory, source_dir("_methods")
    end
  end

  context "with no collections specified" do
    setup do
      @site = fixture_site
      @site.process
    end

    should "not contain any collections" do
      assert_equal @site.collections, Hash.new
    end
  end

  context "with a collection" do
    setup do
      @site = fixture_site({
        "collections" => ["methods"]
      })
      @site.process
    end

    should "create a Hash on Site with the label mapped to the instance of the Collection" do
      assert @site.collections.is_a?(Hash)
      assert_not_nil @site.collections["methods"]
      assert @site.collections["methods"].is_a? Jekyll::Collection
    end

    should "collects docs in an array on the Collection object" do
      assert @site.collections["methods"].docs.is_a? Array
      @site.collections["methods"].docs.each do |doc|
        assert doc.is_a? Jekyll::Document
        assert_include %w[
          _methods/configuration.md
          _methods/sanitized_path.md
          _methods/site/generate.md
          _methods/site/initialize.md
          _methods/um_hi.md
        ], doc.relative_path
      end
    end
  end

  context "in safe mode" do
    setup do
      @site = fixture_site({
        "collections" => ["methods"],
        "safe"        => true
      })
      @site.process
      @collection = @site.collections["methods"]
    end

    should "not allow symlinks" do
      assert !@collection.allowed_document?(File.join(@collection.directory, "um_hi.md"))
    end

    should "not include the symlinked file in the list of docs" do
      assert_not_include %w[_methods/um_hi.md], @collection.docs.map(&:relative_path)
    end
  end

end