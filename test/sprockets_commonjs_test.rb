require 'test/unit'
require 'tempfile'
require 'sprockets-commonjs'

class SprocketsCommonjsTest < Test::Unit::TestCase

  FIXTURE_DIR = File.expand_path('../fixtures', __FILE__)
  LIB_DIR  = File.expand_path('../../lib/assets/javascripts', __FILE__)

  attr_reader :output

  def setup
    env = Sprockets::Environment.new
    env.register_postprocessor 'application/javascript', Sprockets::CommonJS
    env.append_path FIXTURE_DIR
    env.append_path LIB_DIR
    outfile = Tempfile.new('sprockets-output')
    env['source.js'].write_to outfile.path
    @output = File.read outfile.path
  end

  def test_adds_commonjs_require
    assert_match %r[var require = function\(name, root\) \{], @output
  end

  def test_modularizes_modules
    assert_match %r[require.define\(\{\"foo\":function], @output
    assert_match %r["Foo!"], @output
  end

  def test_does_not_modularize_non_modules
    assert_no_match %r[require.define\(\{\"bar\":function], @output
  end

  def test_has_template_path_method
    assert_equal Pathname.new(LIB_DIR), Sprockets::CommonJS.template_path
  end

  def test_default_namespace
    assert_equal 'this.require', Sprockets::CommonJS.default_namespace
  end

  def test_default_mime_type
    assert_equal 'application/javascript', Sprockets::CommonJS.default_mime_type
  end

  def test_module_with_erb_evaluation
    assert_match /module\.exports = "Baz2!"/, @output
  end

end
