require "test/unit"
require_relative "../memoryfile"

class TestMemoryFile < Test::Unit::TestCase

	def test_read_bytes
		memfile = MemoryFile.new(
			[61, 62, 63, 64, 65, 66, 67]
		)

		assert_equal([61, 62, 63], memfile.read_bytes(3))
		buf = ''
		memfile.read_bytes(5, buf) #Test Overflow
		assert_equal([64, 65, 66, 67], buf.unpack('C*'))
	end

	def test_read
		memfile = MemoryFile.new(
			[48, 49, 50, 51, 52, 53, 54, 55, 56, 57]
		)
		assert_equal('0123456', memfile.read(7))
		assert_equal('789', memfile.read())
	end

	def test_seek
		memfile = MemoryFile.new(
			[48, 49, 50, 51, 52, 53, 54, 55, 56, 57]
		)

		memfile.seek(7, IO::SEEK_CUR)
		assert_equal('789', memfile.read())
	end

	def test_double_length_bug
		memfile = MemoryFile.new(
			[48, 49, 50, 51, 52, 53, 54, 55, 56, 57]
		)

		memfile.read(7)
		memfile.read(1)
		assert_equal(8, memfile.pos)
	end

	def test_write
		memfile = MemoryFile.new()
		assert_equal(memfile.pos, 0)
		assert_equal(memfile.size, 0)
		
		str = 'here are some bytes'
		memfile.write(str)
		assert_equal(str.length, memfile.size)
		assert_equal(memfile.size, memfile.pos)

		memfile.seek(0, IO::SEEK_SET)
		assert_equal(str, memfile.read())
	end
end