require 'test/unit'
require_relative '../memoryfile'
require_relative '../zipheader'

class TestZipHeader < Test::Unit::TestCase

	def test_read
		memfile = MemoryFile.new([
			0x50,0x4B,0x03,0x04,0x14,0x00,0x00,0x00,0x00,0x00,0x80,0x9A,0x8D,
			0x3E,0xA8,0xCC,0x2B,0x26,0x0E,0x00,0x00,0x00,0x0E,0x00,0x00,0x00,
			0x08,0x00,0x0D,0x00,0x74,0x65,0x78,0x74,0x2E,0x74,0x78,0x74,0x55,
			0x78,0x09,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
		])

		z = ZipHeader.new()
		z.read_from_stream(memfile)

		assert(z.is_valid?)

		assert_equal(20, z.version_needed)
		assert_equal(0, z.bitflag)
		assert_equal(0, z.compression_method)

		# Verify date time
		assert_equal(0, z.last_modified_date.second)
		assert_equal(20, z.last_modified_date.minute)
		assert_equal(19, z.last_modified_date.hour)
		assert_equal(13, z.last_modified_date.day)
		assert_equal(4, z.last_modified_date.month)
		assert_equal(2011, z.last_modified_date.year)

		assert_equal('262bcca8', z.zip_descriptor.crc)
		assert_equal(14, z.zip_descriptor.compressed_size)
		assert_equal(14, z.zip_descriptor.uncompressed_size)
		assert_equal(8, z.filename_len)
		assert_equal(13, z.extra_field_len)
		assert_equal('text.txt', z.filename)
		assert_equal(1, z.extra_fields.length)
		assert_equal([0,0,0,0,0,0,0,0,0], z.extra_fields[0x7855])
	end

end