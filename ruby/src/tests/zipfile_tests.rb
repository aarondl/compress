require 'test/unit'
require 'date'
require_relative '../memoryfile'
require_relative '../zipfile'

class TestZipFile < Test::Unit::TestCase
	@@filename = "S:\\zip.zip"

	def test_init
		z = ZipFile.new(@@filename)

		assert_not_nil(z)
		assert_equal(@@filename, z.filename)
	end

	def test_extract
		z = ZipFile.new(@@filename)
		z.read_file(MemoryFile.new(@@zipfile))

		memfile = MemoryFile.new()
		z.extract_to_file(0, memfile)
		memfile.seek(0, IO::SEEK_SET)
		assert_equal('text goes here', memfile.read())
	end

	def test_find_descriptor
		memfile = MemoryFile.new(@@altered_zipfile)

		z = ZipFile.new(@@filename)
		z.read_file(memfile)
		header = z.local_headers[0]

		assert_equal('262bcca8', header.zip_descriptor.crc)
		assert_equal(14, header.zip_descriptor.compressed_size)
		assert_equal(14, header.zip_descriptor.uncompressed_size)
	end

	def test_read
		# This may or may not be an actual zip file.
		memfile = MemoryFile.new(@@zipfile)

		z = ZipFile.new(@@filename)
		z.read_file(memfile)

		#Test first local header
		header = z.local_headers[0]
		assert(header.is_valid?)
		assert_equal(20, header.version_needed)
		assert_equal(0, header.bitflag)
		assert_equal(0, header.compression_method)
		assert_equal(0, header.last_modified_date.second)
		assert_equal(20, header.last_modified_date.minute)
		assert_equal(19, header.last_modified_date.hour)
		assert_equal(13, header.last_modified_date.day)
		assert_equal(4, header.last_modified_date.month)
		assert_equal(2011, header.last_modified_date.year)
		assert_equal('262bcca8', header.zip_descriptor.crc)
		assert_equal(14, header.zip_descriptor.compressed_size)
		assert_equal(14, header.zip_descriptor.uncompressed_size)
		assert_equal(8, header.filename_len)
		assert_equal(0, header.extra_field_len)
		assert_equal('text.txt', header.filename)

		#Test second local header
		header = z.local_headers[1]
		assert(header.is_valid?)
		assert_equal(20, header.version_needed)
		assert_equal(0, header.bitflag)
		assert_equal(8, header.compression_method)
		assert_equal(8, header.last_modified_date.second)
		assert_equal(39, header.last_modified_date.minute)
		assert_equal(21, header.last_modified_date.hour)
		assert_equal(13, header.last_modified_date.day)
		assert_equal(4, header.last_modified_date.month)
		assert_equal(2011, header.last_modified_date.year)
		assert_equal('3d761e90', header.zip_descriptor.crc)
		assert_equal(8, header.zip_descriptor.compressed_size)
		assert_equal(11, header.zip_descriptor.uncompressed_size)
		assert_equal(18, header.filename_len)
		assert_equal(0, header.extra_field_len)
		assert_equal('secondTextFile.txt', header.filename)

		#Test first Central Directory
		header = z.central_directories[0]
		assert(header.is_valid?)
		assert_equal(0, header.version_made_os)
		assert_equal(20, header.version_made_zip)
		assert_equal(0, header.comment_len)
		assert_equal(0, header.disk_num)
		assert_equal(1, header.internal_attribs)
		assert_equal(32, header.external_attribs)
		assert_equal(0, header.local_header_offset)
		assert_nil(header.comment)
		assert_equal(20, header.zip_header.version_needed)
		assert_equal(0, header.zip_header.bitflag)
		assert_equal(0, header.zip_header.compression_method)
		assert_equal(0, header.zip_header.last_modified_date.second)
		assert_equal(20, header.zip_header.last_modified_date.minute)
		assert_equal(19, header.zip_header.last_modified_date.hour)
		assert_equal(13, header.zip_header.last_modified_date.day)
		assert_equal(4, header.zip_header.last_modified_date.month)
		assert_equal(2011, header.zip_header.last_modified_date.year)
		assert_equal('262bcca8', header.zip_header.zip_descriptor.crc)
		assert_equal(14, header.zip_header.zip_descriptor.compressed_size)
		assert_equal(14, header.zip_header.zip_descriptor.uncompressed_size)
		assert_equal(8, header.zip_header.filename_len)
		assert_equal(0, header.zip_header.extra_field_len)
		assert_equal('text.txt', header.zip_header.filename)

		#Test second Central Directory
		header = z.central_directories[1]
		assert(header.is_valid?)
		assert_equal(0, header.version_made_os)
		assert_equal(20, header.version_made_zip)
		assert_equal(0, header.comment_len)
		assert_equal(0, header.disk_num)
		assert_equal(1, header.internal_attribs)
		assert_equal(32, header.external_attribs)
		assert_equal(52, header.local_header_offset)
		assert_nil(header.comment)
		assert_equal(20, header.zip_header.version_needed)
		assert_equal(0, header.zip_header.bitflag)
		assert_equal(8, header.zip_header.compression_method)
		assert_equal(8, header.zip_header.last_modified_date.second)
		assert_equal(39, header.zip_header.last_modified_date.minute)
		assert_equal(21, header.zip_header.last_modified_date.hour)
		assert_equal(13, header.zip_header.last_modified_date.day)
		assert_equal(4, header.zip_header.last_modified_date.month)
		assert_equal(2011, header.zip_header.last_modified_date.year)
		assert_equal('3d761e90', header.zip_header.zip_descriptor.crc)
		assert_equal(8, header.zip_header.zip_descriptor.compressed_size)
		assert_equal(11, header.zip_header.zip_descriptor.uncompressed_size)
		assert_equal(18, header.zip_header.filename_len)
		assert_equal(0, header.zip_header.extra_field_len)
		assert_equal('secondTextFile.txt', header.zip_header.filename)

		#Test Central Directory End
		header = z.central_directory_end
		assert(header.is_valid?)
		assert_equal(0, header.disk_num)
		assert_equal(0, header.disk_cdir)
		assert_equal(2, header.num_cdir)
		assert_equal(2, header.total_cdir)
		assert_equal(118, header.size_cdir)
		assert_equal(108, header.offset_cdir)
		assert_equal(0, header.comment_len)
		assert_equal(nil, header.comment)
	end

	@@altered_zipfile = [
		#Local File Thing
		0x50,0x4B,0x03,0x04,0x14,0x00,0x04,0x00,0x00,0x00,0x00,0x9A,0x8D,
		0x3E,0xA8,0xCC,0x2B,0x26,0x0E,0x00,0x00,0x00,0x0E,0x00,0x00,0x00,
		0x08,0x00,0x00,0x00,0x74,0x65,0x78,0x74,0x2E,0x74,0x78,0x74,0x74,
		0x65,0x78,0x74,0x20,0x67,0x6F,0x65,0x73,0x20,0x68,0x65,0x72,0x65,
		#Descriptor
		0x50,0x4B,0x07,0x08,0xA8,0xCC,0x2B,0x26,0x0E,0x00,0x00,0x00,0x0E,
		0x00,0x00,0x00,
		#Central Dir
		0x50,0x4B,0x01,0x02,0x14,0x00,0x14,0x00,0x00,
		0x00,0x00,0x00,0x80,0x9A,0x8D,0x3E,0xA8,0xCC,0x2B,0x26,0x0E,0x00,
		0x00,0x00,0x0E,0x00,0x00,0x00,0x08,0x00,0x00,0x00,0x00,0x00,0x00,
		0x00,0x01,0x00,0x20,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x74,0x65,
		0x78,0x74,0x2E,0x74,0x78,0x74,
		#Central Dir End
		0x50,0x4B,0x05,0x06,0x00,0x00,0x00,0x00,
		0x02,0x00,0x02,0x00,0x76,0x00,0x00,0x00,0x6C,0x00,0x00,0x00,0x00,
		0x00
	]

	@@zipfile = [
		0x50,0x4B,0x03,0x04,0x14,0x00,0x00,0x00,0x00,0x00,0x80,0x9A,0x8D,
		0x3E,0xA8,0xCC,0x2B,0x26,0x0E,0x00,0x00,0x00,0x0E,0x00,0x00,0x00,
		0x08,0x00,0x00,0x00,0x74,0x65,0x78,0x74,0x2E,0x74,0x78,0x74,0x74,
		0x65,0x78,0x74,0x20,0x67,0x6F,0x65,0x73,0x20,0x68,0x65,0x72,0x65,
		0x50,0x4B,0x03,0x04,0x14,0x00,0x00,0x00,0x08,0x00,0xE4,0xAC,0x8D,
		0x3E,0x90,0x1E,0x76,0x3D,0x08,0x00,0x00,0x00,0x0B,0x00,0x00,0x00,
		0x12,0x00,0x00,0x00,0x73,0x65,0x63,0x6F,0x6E,0x64,0x54,0x65,0x78,
		0x74,0x46,0x69,0x6C,0x65,0x2E,0x74,0x78,0x74,0x4B,0xCC,0x4F,0x4D,
		0x84,0xA0,0x54,0x00,0x50,0x4B,0x01,0x02,0x14,0x00,0x14,0x00,0x00,
		0x00,0x00,0x00,0x80,0x9A,0x8D,0x3E,0xA8,0xCC,0x2B,0x26,0x0E,0x00,
		0x00,0x00,0x0E,0x00,0x00,0x00,0x08,0x00,0x00,0x00,0x00,0x00,0x00,
		0x00,0x01,0x00,0x20,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x74,0x65,
		0x78,0x74,0x2E,0x74,0x78,0x74,0x50,0x4B,0x01,0x02,0x14,0x00,0x14,
		0x00,0x00,0x00,0x08,0x00,0xE4,0xAC,0x8D,0x3E,0x90,0x1E,0x76,0x3D,
		0x08,0x00,0x00,0x00,0x0B,0x00,0x00,0x00,0x12,0x00,0x00,0x00,0x00,
		0x00,0x00,0x00,0x01,0x00,0x20,0x00,0x00,0x00,0x34,0x00,0x00,0x00,
		0x73,0x65,0x63,0x6F,0x6E,0x64,0x54,0x65,0x78,0x74,0x46,0x69,0x6C,
		0x65,0x2E,0x74,0x78,0x74,0x50,0x4B,0x05,0x06,0x00,0x00,0x00,0x00,
		0x02,0x00,0x02,0x00,0x76,0x00,0x00,0x00,0x6C,0x00,0x00,0x00,0x00,
		0x00
	]
end