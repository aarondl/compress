# Huffman encoding Tree
class HuffmanCoding
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

	# The fixed huffman tree
	@@fixed_tree = nil

	#The lengths for each length code
	@@lengths = { 257 => 3, 258 => 4, 259 => 5, 260 => 6, 261 => 7, 262 => 8, 
		263 => 9, 264 => 10, 265 => 11, 266 => 13, 267 => 15, 268 => 17, 
		269 => 19, 270 => 23, 271 => 27, 272 => 31, 273 => 35, 274 => 43, 
		275 => 51, 276 => 59, 277 => 67, 278 => 83, 279 => 99, 280 => 115, 
		281 => 131, 282 => 163, 283 => 195, 284 => 227, 285 => 258 }
	#The distances for each distance code
	@@distances = { 0 => 1, 1 => 2, 2 => 3, 3 => 4, 4 => 5, 5 => 7, 6 => 9,
		7 => 13, 8 => 17, 9 => 25, 10 => 33, 11 => 49, 12 => 65, 13 => 97, 
		14 => 129, 15 => 193, 16 => 257, 17 => 385, 18 => 513, 19 => 769, 
		20 => 1025, 21 => 1537, 22 => 2049, 23 => 3073, 24 => 4097, 25 => 6145,
		26 => 8193, 27 => 12289, 28 => 16385, 29 => 24577 }
	
	# Initializes the huffman tree.
	def initialize
		@head = Node.new(nil)
	end

	# Adds a code to the tree
	#
	# @param [Value] The value to store for this code.
	# @param [Code] The code to add.
	# @param [Length] The string length of the code.
	def add(value, code, length)
		curnode = @head

		length.times { |bit|
			isone = ( code >> (length-bit-1) ) & 0x1 == 0x1

			if isone
				if curnode.right_node == nil
					curnode.right_node = 
						Node.new(bit + 1 == length ? value : nil)
				end
				curnode = curnode.right_node
			else
				if curnode.left_node == nil
					curnode.left_node = 
						Node.new(bit + 1 == length ? value : nil)
				end
				curnode = curnode.left_node
			end
		}
	end

	# Retrieves a value from a code.
	#
	# @param [Code] The code to look up.
	# @param [Length] The length of the code.
	# @return [Value] Whatever value is stored.
	def get(code, length)
		curnode = @head

		(length).times { |bit|
			isone = ( code >> (length-bit-1) ) & 0x1 == 0x1

			if isone
				curnode = curnode.right_node
			else
				curnode = curnode.left_node
			end
		}

		return curnode.value
	end

	# Starts a code search
	def begin_find()
		@find_node = @head
	end

	# Searches for a value.
	#
	# @param [Bit] The next bit in the stream.
	# @return [Value] The value or nil if no value is found.
	def query(bit)
		if @find_node.value != nil
			throw 'Could not find value.'
		end

		if bit == 0x1
			@find_node = @find_node.right_node
		else
			@find_node = @find_node.left_node
		end

		return @find_node.value
	end

	# A node class for internal use.
	class Node
		# Initializes the node class
		#
		# @param [Value] The value to store in the node.
		def initialize(value)
			@value = value
			@left_node = nil
			@right_node = nil
		end
		attr_accessor :value
		attr_accessor :left_node
		attr_accessor :right_node
	end

	# Gets the fixed huffman coding tree.
	#
	def self.fixed_tree
		if @@fixed_tree == nil
			@@fixed_tree = HuffmanCoding.new()

			codelengths = (0..143).collect { 8 }
			.concat( (144..255).collect { 9 } )
			.concat( (256..279).collect { 7 } )
			.concat( (280..287).collect { 8 } )

			codes = HuffmanCoding.generate_codes(codelengths)

			(0..143).each { |i| @@fixed_tree.add(i, codes[i], 8) }
			(144..255).each { |i| @@fixed_tree.add(i, codes[i], 9) }
			(256..279).each { |i| @@fixed_tree.add(i, codes[i], 7) }
			(280..287).each { |i| @@fixed_tree.add(i, codes[i], 8) }
		end

		return @@fixed_tree
	end

	# Calculates the number of extra bits for a length code.
	#
	# @param [Code] The code to calculate extra bits for.
	# @return [Fixnum] The number of extra bits to use.
	def self.length_extra_bits(code)
		if code < 265 || code == 285
			return 0
		end

		return (code - 265) / 4 + 1
	end

	# Gets the length for a given code.
	#
	# @param [Code] The code to calculate the length for.
	# @return [Fixnum] The length value.
	def self.get_length(code)
		return @@lengths[code]
	end

	# Calculates the number of extra bits for a distance code.
	#
	# @param [Code] The code to calculate extra bits for.
	# @return [Fixnum] The numbef of extra bits to use.
	def self.distance_extra_bits(code)
		if code < 4
			return 0
		end

		return (code - 4) / 2 + 1
	end

	# Gets the distance for a given code.
	#
	# @param [Code] The code to calculate the distance for.
	# @return [Fixnum] The length value.
	def self.get_distance(code)
		return @@distances[code]
	end

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