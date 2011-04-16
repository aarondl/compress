require 'test/unit'
require_relative '../memoryfile'
require_relative '../zipdescriptor'

class TestZipDescriptor < Test::Unit::TestCase

	def test_read
		memfile = MemoryFile.new([
			80, 75, 7, 8,
			5, 15, 7, 12,
			2, 0, 0, 0,
			3, 0, 0, 0,
		])

		z = ZipDescriptor.new()
		z.read_from_stream(memfile)
		assert(z.is_valid?)
		assert_equal('0c070f05', z.crc)
		assert_equal(2, z.compressed_size)
		assert_equal(3, z.uncompressed_size)
	end

end