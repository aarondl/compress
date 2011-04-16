require 'test/unit'
require_relative '../memoryfile'
require_relative '../zipcentraldirectory'

class TestZipCentralDirectory < Test::Unit::TestCase

	def test_read
		memfile = MemoryFile.new([
			0x50,0x4B,0x01,0x02,0x14,0x00,0x14,0x00,0x00,0x00,0x00,0x00,0x80,
			0x9A,0x8D,0x3E,0xA8,0xCC,0x2B,0x26,0x0E,0x00,0x00,0x00,0x0E,0x00,
			0x00,0x00,0x08,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x20,
			0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x74,0x65,0x78,0x74,0x2E,0x74,
			0x78,0x74
		])

		z = ZipCentralDirectory.new()
		z.read_from_stream(memfile)
		assert(z.is_valid?)

		# Verify all local header information
		assert_equal(20, z.zip_header.version_needed)
		assert_equal(0, z.zip_header.bitflag)
		assert_equal(0, z.zip_header.compression_method)
		
		# Verify date time
		assert_equal(0, z.zip_header.last_modified_date.second)
		assert_equal(20, z.zip_header.last_modified_date.minute)
		assert_equal(3, z.zip_header.last_modified_date.hour)
		assert_equal(13, z.zip_header.last_modified_date.day)
		assert_equal(4, z.zip_header.last_modified_date.month)
		assert_equal(2011, z.zip_header.last_modified_date.year)

		assert_equal('262bcca8', z.zip_header.zip_descriptor.crc)
		assert_equal(14, z.zip_header.zip_descriptor.compressed_size)
		assert_equal(14, z.zip_header.zip_descriptor.uncompressed_size)
		assert_equal(8, z.zip_header.filename_len)
		assert_equal(0, z.zip_header.extra_field_len)
		assert_equal('text.txt', z.zip_header.filename)
		assert_equal(0, z.zip_header.extra_fields.length)

		# Verify central directory information
		assert_equal(0, z.version_made_os)
		assert_equal(20, z.version_made_zip)
		assert_equal(0, z.comment_len)
		assert_equal(0, z.disk_num)
		assert_equal(1, z.internal_attribs)
		assert_equal(32, z.external_attribs)
		assert_equal(0, z.local_header_offset)
		assert_nil(z.comment)
	end
end