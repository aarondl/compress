require "test/unit"
require_relative "../huffmancoding"
require_relative "../memoryfile"

class TestHuffmanCoding < Test::Unit::TestCase

	def test_tree_insert
		h = HuffmanCoding.new()
		h.add('A', 2, 3)
		h.add('B', 3, 3)
		h.add('C', 4, 3)
		h.add('D', 5, 3)
		h.add('E', 6, 3)
		h.add('F', 0, 2)
		h.add('G', 14, 4)
		h.add('H', 15, 4)

		assert_equal('A', h.get( 2, 3))
		assert_equal('B', h.get( 3, 3))
		assert_equal('C', h.get( 4, 3))
		assert_equal('D', h.get( 5, 3))
		assert_equal('E', h.get( 6, 3))
		assert_equal('F', h.get( 0, 2))
		assert_equal('G', h.get(14, 4))
		assert_equal('H', h.get(15, 4))
	end

	def test_find
		h = HuffmanCoding.new()
		h.add('A', 2, 3)
		h.add('B', 3, 3)

		h.begin_find()
		bits = [0x0, 0x1, 0x0]
		bit = -1
		while (val = h.query(bit += 1)) == nil
		end
		assert_equal('A', val)
	end

	def test_generate_codes
		codes = HuffmanCoding.generate_codes(
			[3,3,3,3,3,2,4,4]
		)

		assert_equal([2,3,4,5,6,0,14,15], codes)
	end

	def test_lazy_fixed_tree
		assert_not_nil(HuffmanCoding.fixed_tree)

		# Check that a good one exists
		assert_equal(144, HuffmanCoding.fixed_tree.get(0x190, 9))
	end

	def test_length_extra_bits
		assert_equal(0, HuffmanCoding.length_extra_bits(260))
		assert_equal(0, HuffmanCoding.length_extra_bits(263))
		assert_equal(3, HuffmanCoding.length_extra_bits(276))
		assert_equal(5, HuffmanCoding.length_extra_bits(281))
		assert_equal(0, HuffmanCoding.length_extra_bits(285))
	end

	def test_get_length
		assert_equal(3, HuffmanCoding::get_length(257))
		assert_equal(4, HuffmanCoding::get_length(258))
		assert_equal(227, HuffmanCoding::get_length(284))
	end

	def test_distance_extra_bits
		assert_equal(0, HuffmanCoding::distance_extra_bits(2))
		assert_equal(2, HuffmanCoding::distance_extra_bits(7))
		assert_equal(7, HuffmanCoding::distance_extra_bits(17))
		assert_equal(12, HuffmanCoding::distance_extra_bits(27))
		assert_equal(13, HuffmanCoding::distance_extra_bits(28))
	end

	def test_get_distance
		assert_equal(7, HuffmanCoding::get_distance(5))
		assert_equal(1025, HuffmanCoding::get_distance(20))
		assert_equal(8193, HuffmanCoding::get_distance(26))
		assert_equal(12289, HuffmanCoding::get_distance(27))
	end

	def test_read_tree
		h = HuffmanCoding.new()
		h.read_tree(MemoryFile.new([
		0x57, 0x5B, 0xAE, 0xDB, 0x36, 0x10, 0xFD, 0x2F, 0x90,
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
		]), 0x8D, 3)
	end

	def test_transpose
		int = (0x1 << 3) | (0x1 << 2) | 0x1
		assert_equal(22, HuffmanCoding.binary_transpose(int, 5))
	end
end