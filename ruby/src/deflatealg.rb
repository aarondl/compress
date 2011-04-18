# Used to help in the deflate algorithm processes.
class DeflateAlg
	# The file is not compressed.
	Uncompressed = 0x0
	# The file is compressed with fixed huffman coding.
	FixedHuffman = 0x1
	# The file is compressed with dynamic huffman coding.
	DynamicHuffman = 0x2
	# Illegal mode, fail in some fashion.
	Illegal = 0x3

	# The maximum number of bits in a code
	MaxBits = 31

	# Generates codes based on the alphabet.
	#
	# @param [Lengths] Lengths of the codes.
	def self.generate_codes(lengths)
		codes = []

		# Step 1, count number of codes of each length.
		length_counts = []
		lengths.each { |len|
			length_counts[len] = lengths.count(len)
		}
		length_counts.collect! { |i| i == nil ? 0 : i }

		# Step 2, generate next_code values for all lengths.
		code = 0
		next_code = [0]
		length_counts[0] = 0

		1.upto(MaxBits + 1).each { |bit|
			break if bit >= length_counts.count
			code = (code + length_counts[bit-1]) << 1
			next_code[bit] = code
		}

		# Step 3, generate codes for all lengths.
		0.upto(lengths.count - 1).each { |n|
			len = lengths[n]
			if (len != 0)
				codes[n] = next_code[len]
				next_code[len] += 1
			end
		}

		return codes
	end
end