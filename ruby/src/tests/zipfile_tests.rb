require 'test/unit'
require 'date'
require_relative '../zipfile'

class TestZipFile < Test::Unit::TestCase

	@@filename = "S:\\zip.zip"

	def test_read
		z = ZipFile.new(@@filename)

		assert_not_nil(z)
		assert_equal(@@filename, z.filename)

		z.read_file()
	end
end