require "test/unit"
require_relative "../deflatealg"

class TestDeflateAlg < Test::Unit::TestCase

	def test_generate_codes
		codes = DeflateAlg.generate_codes(
			[3,3,3,3,3,2,4,4]
		)

		assert_equal([2,3,4,5,6,0,14,15], codes)
	end

	def test_fixed_tree
		# This tests the generation of the fixed huffman tree in DEFLATE
		stuff = (0..143).collect { 8 }
		stuff.concat( (144..255).collect { 9 } )
		stuff.concat( (256..279).collect { 7 } )
		stuff.concat( (280..287).collect { 8 } )

		codes = DeflateAlg.generate_codes(stuff)
		
		(0..143).each { |i|
			assert_equal(48 + i, codes[i])
		}
		(144..255).each { |i|
			assert_equal(400 + (i-144), codes[i])
		}
		(256..279).each { |i|
			assert_equal(0 + (i-256), codes[i])
		}
		(280..287).each { |i|
			assert_equal(192 + (i-280), codes[i])
		}
	end

end