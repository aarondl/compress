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

end