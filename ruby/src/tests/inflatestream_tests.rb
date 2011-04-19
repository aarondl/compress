require 'test/unit'
require_relative '../inflatestream'
require_relative '../memoryfile'

class TestInflateStream < Test::Unit::TestCase

	def test_read
		memfile = MemoryFile.new([
			0x4B,0xCC,0x4F,0x4D,0x84,0xA0,0x54,0x00
		])

		outmemfile = MemoryFile.new()

		i = InflateStream.new(memfile)
		n = 1
		while n > 0
			n = i.read()
		end

		outmemfile.seek(0, IO::SEEK_SET)
		assert_equal('aoeaoeaoeae', outmemfile.read())
	end
end