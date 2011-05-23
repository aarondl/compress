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

	def test_read_dynamic
		memfile = MemoryFile.new(@@compressed)
		@i = InflateStream.new(memfile)
		assert_equal(@@uncompressed, @i.read())
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

	@@compressed = [0x8D, 0x57, 0x5B, 0xAE, 0xDB, 0x36, 0x10, 0xFD, 0x2F, 0x90,
	0x3D, 0x70, 0x01, 0x82, 0xF7, 0x10, 0xA4, 0x2D, 0x50, 0xA0, 0x2D, 0x52,
	0x04, 0xCD, 0x3F, 0x2D, 0xF1, 0xDA, 0x53, 0x50, 0xA2, 0xC2, 0x87, 0xD6,
	0xDF, 0x33, 0x43, 0x0E, 0x49, 0xFB, 0x2B, 0x40, 0x90, 0xC4, 0x32, 0xC5,
	0x79, 0x9C, 0xC7, 0x8C, 0xFF, 0x0C, 0xD1, 0xED, 0x86, 0xCE, 0x54, 0x76,
	0xB3, 0x05, 0x1F, 0xA2, 0x49, 0x94, 0x8D, 0xDD, 0x5D, 0x5E, 0xCC, 0x1A,
	0x8E, 0xE4, 0xD6, 0xEC, 0x72, 0x89, 0xC6, 0x6E, 0x74, 0x52, 0x5A, 0xE9,
	0x78, 0x18, 0xE7, 0x29, 0xDF, 0xCC, 0x5F, 0xD6, 0xAD, 0xEE, 0xB0, 0xC9,
	0x58, 0x63, 0xCB, 0xA3, 0x38, 0xE3, 0x1E, 0x2E, 0x9B, 0x1F, 0xC5, 0xEE,
	0xE6, 0xF4, 0x76, 0x75, 0xD1, 0x66, 0x93, 0x23, 0xA5, 0x4C, 0x3F, 0xF0,
	0xE5, 0xE1, 0x56, 0x63, 0x57, 0xE3, 0xE9, 0xEE, 0x62, 0xB8, 0x99, 0xAF,
	0x4F, 0x9B, 0x9C, 0xF7, 0x25, 0xD5, 0xB7, 0x72, 0x88, 0xF8, 0x63, 0x42,
	0x5C, 0xE9, 0x66, 0x7E, 0x0D, 0x7C, 0xF8, 0xEE, 0xED, 0xB1, 0x21, 0x93,
	0xB0, 0x51, 0x30, 0x97, 0xF3, 0xC6, 0xC6, 0xB5, 0xF4, 0xA7, 0xA9, 0x20,
	0x95, 0x93, 0xD3, 0xF8, 0xBB, 0x78, 0x8F, 0x90, 0x47, 0x38, 0xCC, 0x7F,
	0x25, 0xE5, 0x50, 0xFF, 0xBE, 0x99, 0x3F, 0x8E, 0x8C, 0xAB, 0xA3, 0x71,
	0xC5, 0x78, 0xD4, 0xC0, 0x91, 0xB2, 0x41, 0xEC, 0x64, 0x52, 0xD8, 0xAC,
	0x77, 0x69, 0xAE, 0x8E, 0x8F, 0x9B, 0x27, 0xF2, 0x7B, 0xDA, 0x3B, 0x65,
	0x9B, 0x92, 0xE3, 0x1A, 0xB2, 0xB3, 0x66, 0x23, 0xBC, 0xBB, 0x27, 0x0E,
	0xD4, 0xA2, 0x94, 0x78, 0x58, 0xBE, 0xAB, 0x46, 0xDB, 0xEC, 0x49, 0x77,
	0x5C, 0x9E, 0xDD, 0x7E, 0xE2, 0x1F, 0x3E, 0xD0, 0xFB, 0xF0, 0x33, 0xB7,
	0x7E, 0x45, 0x17, 0x1C, 0x52, 0x4D, 0xDC, 0x24, 0xBB, 0xAE, 0x78, 0x6A,
	0x0F, 0x13, 0x9F, 0xE1, 0x58, 0x71, 0x9D, 0xC4, 0xA2, 0xCD, 0xF8, 0x70,
	0x47, 0x87, 0x28, 0xDD, 0xCC, 0xBF, 0xA8, 0xDD, 0x6D, 0x86, 0xEC, 0x5A,
	0x3C, 0xA5, 0xD6, 0xB8, 0x9B, 0xF9, 0xC6, 0xCF, 0x36, 0x73, 0xD0, 0xFD,
	0x39, 0xBA, 0xCF, 0xED, 0x34, 0x99, 0x8E, 0x95, 0xB6, 0x72, 0x64, 0x73,
	0xE2, 0x6C, 0x26, 0x39, 0x2E, 0x4D, 0x33, 0x1F, 0x76, 0x25, 0x5C, 0x82,
	0x96, 0x7F, 0xA7, 0xCB, 0xEE, 0x85, 0xA1, 0x94, 0x77, 0x2E, 0x77, 0x00,
	0x59, 0xC4, 0x6B, 0x45, 0x6A, 0xB7, 0x8D, 0xF5, 0x54, 0x0B, 0x7B, 0x49,
	0x3B, 0xD9, 0x07, 0x65, 0x3E, 0x5D, 0xD1, 0x65, 0x9C, 0x2B, 0x23, 0x9E,
	0xEE, 0xD8, 0xA2, 0x8B, 0x78, 0xD1, 0x17, 0x86, 0xE0, 0xED, 0xBD, 0xA3,
	0x1C, 0xAB, 0xD9, 0x6D, 0x01, 0x49, 0x16, 0xF3, 0x88, 0xF6, 0xA2, 0xCD,
	0xD6, 0xEE, 0x25, 0x74, 0x53, 0xB0, 0x5B, 0xF8, 0x73, 0x42, 0xEF, 0xCC,
	0x1E, 0x3C, 0x17, 0xEC, 0x5D, 0xE8, 0xD5, 0x0A, 0x9A, 0x38, 0x5D, 0x83,
	0x29, 0x12, 0x67, 0x74, 0x99, 0x40, 0x66, 0xA5, 0xB1, 0x41, 0x27, 0x6A,
	0x90, 0xB7, 0xF0, 0xA3, 0xCA, 0x99, 0xE7, 0x15, 0xC8, 0xDB, 0xA7, 0x5F,
	0x3E, 0xFD, 0xF2, 0x4F, 0x21, 0x39, 0x48, 0xC0, 0x94, 0xFB, 0xC9, 0xB4,
	0x74, 0x07, 0xED, 0xF5, 0x3C, 0x1A, 0x91, 0x27, 0x55, 0xDC, 0xCC, 0x6F,
	0x99, 0x40, 0x11, 0xE2, 0xCC, 0x37, 0x62, 0xB2, 0x79, 0xCE, 0x60, 0xD5,
	0x1E, 0x72, 0xFE, 0x2B, 0xE5, 0xB2, 0xE1, 0xBA, 0x81, 0x67, 0x25, 0xBB,
	0xF0, 0x9B, 0x7B, 0xDB, 0x99, 0x53, 0x2F, 0xD3, 0xA6, 0x14, 0x0F, 0x25,
	0xAD, 0x04, 0xD2, 0x8A, 0xBE, 0x98, 0x01, 0x43, 0x01, 0x9F, 0x2B, 0x28,
	0xF8, 0xAA, 0x03, 0x86, 0xCC, 0x1A, 0x16, 0x1B, 0x3D, 0x0E, 0x4A, 0x69,
	0x4E, 0x5A, 0x48, 0xD4, 0x49, 0xA2, 0xFD, 0x75, 0x78, 0x7B, 0x0F, 0x5B,
	0x6D, 0x6E, 0x51, 0x7A, 0x1F, 0x42, 0x0F, 0x8D, 0xA0, 0x69, 0x77, 0x7E,
	0x8A, 0x26, 0x19, 0xEE, 0x46, 0x5C, 0xAD, 0x07, 0xB1, 0x2E, 0x2B, 0x78,
	0xA9, 0x60, 0xAF, 0xE2, 0xCF, 0x92, 0x41, 0xFE, 0xAE, 0xD8, 0xB4, 0x3A,
	0x0F, 0x6E, 0x48, 0x87, 0x77, 0x2B, 0xFC, 0xE9, 0x88, 0x48, 0x8A, 0x17,
	0x5D, 0x2E, 0xC6, 0xF7, 0xE2, 0x17, 0x46, 0xBE, 0xEA, 0xC7, 0x00, 0xDD,
	0x32, 0xF4, 0xCC, 0xF5, 0x0F, 0xDD, 0x8B, 0x1A, 0x12, 0x89, 0x22, 0x2B,
	0xFC, 0x13, 0x34, 0x67, 0x48, 0xC5, 0x45, 0xC7, 0xD6, 0x65, 0x1C, 0xCB,
	0xF0, 0x33, 0x22, 0x43, 0x77, 0x4D, 0xC5, 0x09, 0x54, 0x72, 0x07, 0x17,
	0xF6, 0x6A, 0x67, 0x73, 0xDF, 0x2B, 0xFB, 0xC0, 0x4A, 0xBC, 0x4F, 0x6E,
	0xC4, 0x6D, 0x59, 0x2F, 0xCD, 0x52, 0x39, 0x7D, 0x54, 0xBB, 0x86, 0xC8,
	0x84, 0xAE, 0xF7, 0x2F, 0x9A, 0x90, 0xA7, 0x47, 0x81, 0x0E, 0xD1, 0x87,
	0x1D, 0xAC, 0xC4, 0x69, 0xBE, 0x73, 0x11, 0x36, 0x74, 0x4D, 0xB5, 0xA3,
	0x12, 0x5F, 0x10, 0x3E, 0x4B, 0x64, 0x25, 0x7D, 0x2B, 0xE9, 0x84, 0xBC,
	0x88, 0x5D, 0x45, 0x73, 0x5A, 0xBA, 0x24, 0x94, 0x38, 0x8A, 0x98, 0xA6,
	0x23, 0x86, 0xF2, 0x11, 0xC1, 0x57, 0x62, 0x07, 0x90, 0xBB, 0x6A, 0xC0,
	0x73, 0x96, 0x46, 0xAD, 0xB6, 0x76, 0x81, 0x8B, 0x66, 0x5F, 0xA9, 0xCC,
	0x80, 0x32, 0x85, 0xD8, 0xCB, 0x64, 0x0A, 0xE6, 0x0E, 0xAE, 0x1D, 0x1B,
	0xE7, 0x8F, 0xE7, 0x03, 0x2E, 0x7E, 0x73, 0x9F, 0xE8, 0x63, 0x7B, 0x31,
	0x85, 0xB1, 0xF1, 0xCD, 0x15, 0x26, 0x5C, 0x6C, 0x95, 0x02, 0x1B, 0x43,
	0xC7, 0xE4, 0x95, 0x27, 0x29, 0x59, 0xD6, 0xA3, 0x18, 0xDD, 0xB0, 0x97,
	0x80, 0xB2, 0x22, 0x40, 0xF8, 0x1A, 0x03, 0x55, 0x14, 0x31, 0x4D, 0xCE,
	0xE2, 0x2F, 0xC2, 0x73, 0xE8, 0x16, 0xEF, 0x2E, 0x1C, 0xF5, 0x0A, 0xBE,
	0xE4, 0xD3, 0xB6, 0x31, 0xA5, 0x26, 0xEA, 0x0A, 0x4F, 0xB3, 0x8A, 0x08,
	0x2C, 0xF1, 0x20, 0xDB, 0xC5, 0xD8, 0x2E, 0x66, 0x37, 0x18, 0x23, 0x6B,
	0x1E, 0x85, 0x6C, 0x07, 0x38, 0x27, 0xE5, 0xA8, 0x2A, 0xBC, 0xC5, 0x4C,
	0x75, 0x93, 0x32, 0xA5, 0x9D, 0x1A, 0x9B, 0xB3, 0xB4, 0x2E, 0xA1, 0xD7,
	0xC6, 0x76, 0xF5, 0xC9, 0xE4, 0x9D, 0xC7, 0xE2, 0x65, 0x23, 0xB1, 0x99,
	0xCD, 0xA8, 0x6C, 0x6C, 0x09, 0xA8, 0xA2, 0x5B, 0x3A, 0xE4, 0xC6, 0x8C,
	0x10, 0xCB, 0xFC, 0x70, 0xB1, 0x91, 0x48, 0xCA, 0xAD, 0xF3, 0x4A, 0xCB,
	0xB0, 0xB8, 0xA2, 0x39, 0x6B, 0x03, 0x55, 0xC1, 0x13, 0x8C, 0x58, 0x3E,
	0xC5, 0x6E, 0x8D, 0x0F, 0x03, 0x8F, 0x9B, 0xF9, 0x1D, 0xE7, 0xDA, 0x9B,
	0x3B, 0x21, 0x86, 0x6F, 0xDA, 0x24, 0x5C, 0x18, 0x19, 0x71, 0x9D, 0x21,
	0x3C, 0x01, 0x39, 0xF1, 0x85, 0xBD, 0xE7, 0x7C, 0xA2, 0x69, 0x19, 0xD2,
	0x85, 0x5B, 0xAB, 0xB6, 0xD5, 0x8E, 0x7F, 0x66, 0x28, 0xEA, 0x38, 0x42,
	0x48, 0xCF, 0xEB, 0xC9, 0xA2, 0x83, 0xA7, 0x66, 0xD2, 0x81, 0xE5, 0x4F,
	0xAF, 0x5B, 0x4A, 0x37, 0xFD, 0xA6, 0x92, 0x41, 0xBD, 0x8A, 0x64, 0x73,
	0xD7, 0x3A, 0xFF, 0xC0, 0x2B, 0xFA, 0x00, 0x87, 0x96, 0xB6, 0xF8, 0x20,
	0xA9, 0x5E, 0x57, 0x13, 0x10, 0xBE, 0x2A, 0xD4, 0xDA, 0x32, 0x26, 0xA9,
	0x96, 0x0A, 0x9B, 0x7C, 0x51, 0x77, 0xDD, 0x62, 0xC0, 0x21, 0x26, 0x49,
	0x36, 0x20, 0x14, 0xE7, 0xF0, 0x9D, 0x1D, 0xE2, 0x5E, 0x7C, 0x99, 0x0C,
	0x74, 0x4C, 0x90, 0xE6, 0xB3, 0x70, 0x29, 0x2D, 0x4B, 0xD3, 0xBB, 0xDC,
	0x93, 0x56, 0xF6, 0x07, 0x69, 0x3B, 0xB3, 0xAC, 0x6A, 0x78, 0xC0, 0xF5,
	0xE1, 0xCA, 0x83, 0x98, 0x51, 0x75, 0x5A, 0x48, 0x3C, 0x91, 0xF8, 0x5B,
	0xC3, 0xC6, 0x10, 0x60, 0x07, 0x59, 0xA6, 0x4A, 0xD8, 0xAC, 0xEB, 0xD6,
	0xF5, 0x25, 0xDA, 0x4E, 0xFF, 0xA5, 0x5D, 0xC5, 0x5A, 0x6C, 0x62, 0x6A,
	0xD3, 0x75, 0x69, 0xC9, 0xB4, 0x52, 0xAF, 0x51, 0x9A, 0x3C, 0x5F, 0xA4,
	0x90, 0x9E, 0xB8, 0x8C, 0x87, 0xDA, 0x3C, 0xB1, 0xAE, 0xB7, 0xC5, 0xF1,
	0xFD, 0xED, 0x81, 0x9E, 0xC8, 0xBB, 0x45, 0xFE, 0xB0, 0x65, 0xE5, 0xD0,
	0x22, 0xC2, 0xD9, 0xF5, 0xBA, 0xEB, 0xF4, 0x78, 0xFC, 0xDA, 0x52, 0x43,
	0x8D, 0x55, 0x4A, 0x2A, 0xD1, 0x19, 0x81, 0xF4, 0xBA, 0xD6, 0xBB, 0xC5,
	0xCE, 0x18, 0xF2, 0xCC, 0x10, 0xAB, 0x18, 0x3D, 0x93, 0x64, 0x9A, 0x1E,
	0x2F, 0x50, 0xD6, 0xBD, 0xED, 0x11, 0x9D, 0xED, 0x0D, 0x8E, 0xB6, 0xAA,
	0x30, 0x8C, 0xD8, 0x6F, 0xFA, 0xF0, 0x00, 0xE4, 0x8F, 0x3E, 0xEA, 0xDE,
	0x37, 0x21, 0xDE, 0x2C, 0x52, 0xE6, 0x86, 0xB3, 0xB5, 0xF2, 0xC7, 0x21,
	0x2C, 0xE1, 0x93, 0x62, 0xDC, 0x46, 0x86, 0x1A, 0x77, 0x1B, 0x91, 0x53,
	0x27, 0x75, 0xE0, 0xD2, 0xB6, 0x4C, 0x2C, 0xD3, 0x05, 0x1A, 0xC5, 0x87,
	0x78, 0xA7, 0x01, 0x74, 0x45, 0x87, 0xBF, 0x8E, 0x25, 0x47, 0x9E, 0x10,
	0xA3, 0x19, 0x4B, 0x55, 0x9F, 0x64, 0x36, 0x26, 0x3A, 0x3E, 0xB5, 0x1E,
	0x4F, 0xAB, 0x4E, 0x12, 0x7F, 0xB0, 0x32, 0x7F, 0x44, 0xE1, 0xD5, 0x32,
	0xC4, 0xAE, 0xDB, 0xD4, 0x3E, 0xD4, 0x09, 0x5A, 0x3D, 0x5F, 0x78, 0x47,
	0x0B, 0x2B, 0xE1, 0x09, 0x66, 0x7E, 0x90, 0x4E, 0xCA, 0xF4, 0xBF, 0xD7,
	0x5D, 0x7D, 0xB7, 0x0C, 0x00, 0x70, 0x80, 0x0B, 0xDA, 0x08, 0x71, 0x13,
	0x5B, 0xE6, 0x1E, 0xB8, 0x67, 0x68, 0x91, 0x85, 0x31, 0xB1, 0xE2, 0x23,
	0x6D, 0x0C, 0x3E, 0xBB, 0x85, 0x2C, 0x98, 0xEA, 0xAD, 0x9C, 0x12, 0xEC,
	0x67, 0x99, 0xA6, 0x1D, 0xB7, 0x75, 0xCC, 0x0C, 0x81, 0x72, 0xD1, 0xBD,
	0x52, 0x76, 0xBC, 0xF0, 0xAA, 0xD6, 0x4E, 0x47, 0x94, 0x26, 0xF5, 0xB0,
	0x9D, 0xB5, 0x36, 0xB5, 0xD1, 0xC5, 0x0B, 0x54, 0x69, 0x9D, 0xE5, 0xF1,
	0x28, 0xF3, 0x40, 0x57, 0xDA, 0x31, 0x80, 0x78, 0x07, 0x69, 0x9B, 0xC2,
	0xF4, 0xF3, 0xAA, 0x2F, 0xE4, 0x5C, 0x6E, 0xEB, 0x8A, 0x18, 0x7A, 0x51,
	0x8B, 0xE1, 0x2F, 0x50, 0xE4, 0xC9, 0xBB, 0x91, 0x8E, 0x2E, 0x20, 0xB1,
	0x51, 0xB5, 0x7A, 0x91, 0x04, 0x9A, 0x3D, 0x4A, 0x6C, 0x56, 0x51, 0x9A,
	0xAD, 0xB4, 0x64, 0x95, 0xE9, 0x75, 0x28, 0x48, 0xE1, 0x4A, 0xA4, 0x89,
	0x39, 0x3A, 0x1A, 0xE6, 0x45, 0xB5, 0xB9, 0x26, 0xFE, 0x87, 0x9C, 0x84,
	0x0D, 0x4A, 0x44, 0x55, 0x94, 0x0E, 0xBD, 0x36, 0xC9, 0xE6, 0x19, 0x56,
	0xB9, 0x25, 0x99, 0x2C, 0x43, 0x25, 0x58, 0xCC, 0xA6, 0x31, 0xCC, 0x7D,
	0x1A, 0xFB, 0x0F, 0x23, 0x54, 0x77, 0x8D, 0x3A, 0xC9, 0xA7, 0xEC, 0xD6,
	0xB0, 0x63, 0x3D, 0x0D, 0x3A, 0x10, 0x04, 0x8F, 0xB5, 0x44, 0x16, 0x77,
	0x75, 0xEF, 0x6E, 0x07, 0x6C, 0x88, 0x8C, 0x45, 0xAB, 0xB0, 0xFE, 0xB3,
	0xF4, 0xDF, 0x05, 0xF2, 0xA6, 0x5A, 0x3F, 0x7C, 0x62, 0x7C, 0x53, 0x1B,
	0xA3, 0x3F, 0xA9, 0x26, 0x22, 0xE8, 0xA2, 0xF0, 0x32, 0x8D, 0x6B, 0xAB,
	0xE9, 0x65, 0x41, 0xB9, 0x19, 0xFD, 0xCD, 0x00, 0x08, 0x98, 0xC0, 0x56,
	0x7D, 0x11, 0xB3, 0xA5, 0x2E, 0x46, 0xB2, 0x17, 0xF5, 0x2E, 0xEA, 0xBE,
	0xA1, 0x11, 0xAA, 0x79, 0xE3, 0xD2, 0x97, 0x50, 0xD5, 0xC3, 0xFA, 0x8F,
	0xC2, 0x56, 0x9F, 0x2A, 0xBD, 0xD7, 0xA2, 0x01, 0x6E, 0xFF, 0x03]

	@@uncompressed = "Lorem ipsum dolor sit amet, consectetur adipiscing elit" +
	". Maecenas a augue eget quam placerat tristique nec ac libero. Phasellus" +
	" eget tortor orci. Donec blandit odio vel arcu blandit suscipit. Nullam " +
	"non justo justo. Integer eu lectus et eros sodales consectetur. In hac h" +
	"abitasse platea dictumst. Nam non urna et justo dapibus tempus non eget " +
	"quam. In hac habitasse platea dictumst. Pellentesque accumsan rhoncus ur" +
	"na id lobortis. Ut sed iaculis tortor. Sed id nibh placerat orci tincidu" +
	"nt porttitor. Nulla facilisi. Vivamus a orci venenatis justo suscipit al" +
	"iquam. Pellentesque sagittis libero ac augue hendrerit luctus. Pellentes" +
	"que nunc mauris, gravida eget semper eu, egestas mollis leo. Sed id eros" +
	" et augue dapibus pretium sit amet at mauris. Pellentesque venenatis con" +
	"sectetur tempus.\r\n\r\nQuisque in erat nec enim consequat adipiscing. E" +
	"tiam imperdiet elit ac justo sollicitudin lobortis. Donec vel aliquet qu" +
	"am. Etiam gravida ultricies quam sed suscipit. Aliquam quis justo at lib" +
	"ero dignissim consequat. Ut placerat egestas euismod. Sed ut justo nisi." +
	" Aliquam lobortis rhoncus arcu ac accumsan. Donec convallis blandit vulp" +
	"utate. Nullam scelerisque mattis venenatis. Ut viverra ultricies quam, i" +
	"d dictum metus sodales quis. Integer id nisi non mauris imperdiet posuer" +
	"e a a est. Aenean tempus sapien ac quam placerat sed suscipit eros moles" +
	"tie. Integer viverra, ipsum a ullamcorper tempus, mauris ligula elementu" +
	"m eros, vel sagittis mauris erat quis purus. Suspendisse suscipit, eros " +
	"et gravida lobortis, ipsum urna fringilla purus, vel pellentesque erat s" +
	"apien sed nibh. Sed sem elit, suscipit a bibendum et, ultricies sed mi. " +
	"Aliquam a mauris eu nisl luctus imperdiet ac vel nunc. Aenean scelerisqu" +
	"e massa in nibh hendrerit ornare. Proin tempor pulvinar neque, eu volutp" +
	"at quam iaculis eu. Mauris lacinia aliquet ornare.\r\n\r\nPhasellus adip" +
	"iscing enim et nisl rhoncus laoreet. Aliquam erat volutpat. Praesent a e" +
	"gestas dolor. Phasellus varius pellentesque diam eu tincidunt. Duis eget" +
	" fermentum neque. Nam aliquet ante eget sapien suscipit sed malesuada pu" +
	"rus imperdiet. Fusce eget mi felis. Ut interdum facilisis tellus, at pha" +
	"retra leo mattis sit amet. In hac habitasse platea dictumst. Vivamus mi " +
	"lorem, aliquam eget pulvinar eget, consectetur sit amet purus. Aliquam a" +
	" ornare quam. Nulla eleifend, dolor ac interdum gravida, dui purus tinci" +
	"dunt tellus, ut ullamcorper tortor lacus at risus. Vestibulum lobortis c" +
	"onsequat justo non pulvinar. Nulla vehicula felis et ipsum malesuada feu" +
	"giat. Etiam risus urna, aliquam eget dignissim quis, tincidunt nec orci." +
	" Cras lacinia, risus vel tempor dapibus, felis tortor vestibulum felis, " +
	"non vehicula arcu purus quis elit. Maecenas vestibulum felis sit amet ni" +
	"bh tempor faucibus.\r\n\r\nSuspendisse bibendum vehicula nibh, quis accu" +
	"msan risus sodales non. Mauris sagittis ullamcorper nisi, eu dignissim n" +
	"ibh varius vitae. Pellentesque pharetra feugiat mollis. Nunc placerat co" +
	"ngue mattis. Pellentesque nec est velit, nec facilisis lacus. Etiam ligu" +
	"la purus, viverra vestibulum blandit id, consequat vel arcu. Morbi lacin" +
	"ia, purus vel rutrum ullamcorper, lorem est convallis est, quis imperdie" +
	"t est mi a eros. In eget massa quam, in mattis lacus. Cum sociis natoque" +
	" penatibus et magnis dis parturient montes, nascetur ridiculus mus. Prae" +
	"sent est leo, fringilla nec hendrerit vitae, mollis in eros. Vestibulum " +
	"sit amet mi eget leo rutrum luctus at eu arcu. Sed enim mauris, pulvinar" +
	" non molestie sit amet, porttitor et lacus. Duis ut tellus et turpis vol" +
	"utpat condimentum.\r\n\r\nIn fringilla felis eu justo rutrum sagittis. N" +
	"am vitae ligula vestibulum sapien sollicitudin ornare in ut lorem. Etiam" +
	" sodales rhoncus egestas. Phasellus purus justo, pharetra id volutpat qu" +
	"is, elementum nec nibh. Proin vestibulum commodo lorem, eget cursus dolo" +
	"r bibendum at. Sed ligula ligula, pretium eget eleifend ac, pretium vita" +
	"e tortor. Vestibulum iaculis pellentesque felis in scelerisque. Quisque " +
	"eu magna felis, ac ultrices sem. Etiam lacinia iaculis urna, in pellente" +
	"sque risus rhoncus ut. Sed blandit eleifend ultrices."
end