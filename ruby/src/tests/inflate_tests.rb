require 'test/unit'
require_relative '../inflate'
require_relative '../memoryfile'

class TestInflate < Test::Unit::TestCase

	def test_read_block
		memfile = MemoryFile.new([
			0x4B,0xCC,0x4F,0x4D,0x84,0xA0,0x54,0x00
		])

		outmemfile = MemoryFile.new()

		i = Inflate.new(memfile)
		i.read_blocks(outmemfile)

		outmemfile.seek(0, IO::SEEK_SET)
		assert_equal('aoeaoeaoeae', outmemfile.read())
		#assert_equal(0x2, i.read_block())

	end
end