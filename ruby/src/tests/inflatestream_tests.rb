require 'test/unit'
require_relative '../inflatestream'
require_relative '../memoryfile'

class TestInflateStream < Test::Unit::TestCase

	def setup
		memfile = MemoryFile.new([
			0x4B,0xCC,0x4F,0x4D,0x84,0xA0,0x54,0x00
		])

		@i = InflateStream.new(memfile)
	end

	def test_read_fixed
		assert_equal('aoeaoeaoeae', @i.read())
	end

	def test_read_with_lengths
		assert_equal('a', @i.read(1))
		assert_equal('oe', @i.read(2))
		assert_equal('aoe', @i.read(3))
		assert_equal('aoea', @i.read(4))
		assert_equal('e', @i.read(5))
	end

	def test_read_with_buffers
		buf = ''
		assert_equal(1, @i.read(1, buf))
		assert_equal(2, @i.read(2, buf))
		assert_equal(3, @i.read(3, buf))
		assert_equal(4, @i.read(4, buf))
		assert_equal(1, @i.read(5, buf))
		assert_equal('aoeaoeaoeae', buf)
	end

	def test_uncompressed
		mem = MemoryFile.new([
			0x1, 0xD, 0x0, ~0xD, ~0x0
		].concat('hello friends'.unpack('c*')))
		
		@i = InflateStream.new(mem)
		assert_equal('hello ', @i.read(6))
		assert_equal('friends', @i.read(256))
	end

	def test_next_bit
		expected = 0xCC4B
		(0..15).each { |j|
			assert_equal((expected >> j) & 0x1, @i.send(:next_bit))
		}
	end

	def test_read_compression
		@i.send(:next_bit)
		assert_equal(1, @i.send(:read_compression))
	end

	def test_read_length
		assert_equal(22, @i.send(:read_length, 269))
	end

	def test_read_distance
		assert_equal(11875, @i.send(:read_distance))
	end
end