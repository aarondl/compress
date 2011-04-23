require "test/unit"
require_relative "../huffmancoding"

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
		assert_equal(3, HuffmanCoding.get_length(257))
		assert_equal(4, HuffmanCoding.get_length(258))
		assert_equal(227, HuffmanCoding.get_length(284))
	end

	def test_distance_extra_bits
		assert_equal(0, HuffmanCoding.distance_extra_bits(2))
		assert_equal(2, HuffmanCoding.distance_extra_bits(7))
		assert_equal(7, HuffmanCoding.distance_extra_bits(17))
		assert_equal(12, HuffmanCoding.distance_extra_bits(27))
		assert_equal(13, HuffmanCoding.distance_extra_bits(28))
	end

	def test_get_distance
		assert_equal(7, HuffmanCoding.get_distance(5))
		assert_equal(1025, HuffmanCoding.get_distance(20))
		assert_equal(8193, HuffmanCoding.get_distance(26))
		assert_equal(12289, HuffmanCoding.get_distance(27))
	end

end