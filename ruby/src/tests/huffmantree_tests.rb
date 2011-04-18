require "test/unit"
require_relative "../huffmantree"

class TestHuffmanTree < Test::Unit::TestCase

	def test_tree_insert
		h = HuffmanTree.new()
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
		h = HuffmanTree.new()
		h.add('A', 2, 3)
		h.add('B', 3, 3)

		h.begin_find()
		bits = [0x0, 0x1, 0x0]
		bit = -1
		while (val = h.query(bit += 1)) == nil
		end
		assert_equal('A', val)
	end

end