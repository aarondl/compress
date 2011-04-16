require 'test/unit'
require_relative '../memoryfile'
require_relative '../zipend'

class TestZipEnd < Test::Unit::TestCase

	def test_read
		memfile = MemoryFile.new([
			0x50,0x4B,0x05,0x06,0x00,0x00,0x00,0x00,0x02,0x00,0x02,0x00,0x76,
			0x00,0x00,0x00,0x6C,0x00,0x00,0x00,0x00,0x00
		])

		z = ZipEnd.new()
		z.read_from_stream(memfile)
		assert(z.is_valid?)

		assert_equal(0, z.disk_num)
		assert_equal(0, z.disk_cdir)
		assert_equal(2, z.num_cdir)
		assert_equal(2, z.total_cdir)
		assert_equal(118, z.size_cdir)
		assert_equal(108, z.offset_cdir)
		assert_equal(0, z.comment_len)
		assert_nil(z.comment)
	end
end
