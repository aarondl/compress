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
	# The order of the dynamic tree length code lengths.
	@@length_code_order =
		[16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]
	
	# Initializes the huffman tree.
	# @param [Lengths] Optionally specify the lengths of the codes.
	# @param [Distances] Optionally specify the distance codes.
	def initialize(lengths = nil, distances = nil)
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

	# Reads a tree in from a stream
	#
	# @param [Stream] An IO to read from.
	def read_tree(stream, byte = nil, bitoffset = 8)
		offset = bitoffset
		bit = nil
		next_bit = lambda {
			if offset == 8
				byte = stream.read(1).ord
				offset = 0
			end

			bit = (byte >> offset) & 0x1
			offset += 1
			return bit
		}

		get_int = lambda { |i|
			int = 0
			i.times { |j| int |= next_bit.call << j }
			return int
		}

		nliterals = ndistances = ncodelengths = 0

		nliterals = get_int.call(5)
		ndistances = get_int.call(5)
		ncodelengths = get_int.call(4)

		nliterals += 257
		ndistances += 1
		ncodelengths += 4

		puts nliterals, ndistances, ncodelengths

		codelengthtree = create_dynamic_length_tree(ncodelengths, next_bit)

		lengths = 
			consume_code_length_codes(nliterals + ndistances,
				codelengthtree, get_int, next_bit)

		puts lengths.inspect

		codes = HuffmanCoding.generate_codes(lengths)

		for i in 0...nliterals
			if (codes[i] != nil && codes[i] != 0)
				puts "LENGTH Value: #{i} Code: #{codes[i]} Length: #{lengths[i]}"
				add(i, codes[i], lengths[i])
			end
		end

		for i in nliterals...ndistances
			if (codes[i] != nil && codes[i] != 0)
				puts "DISTANCE Value: #{i} Code: #{codes[i]} Length: #{lengths[i]}"
				add(i, codes[i], lengths[i])
			end
		end
	end

	# Creates the huffman coding tree that stores the codes for the lengths
	#  for the codes inside the dynamic tree.
	#
	# @param [ncodelengths] The number of code lengths to read.
	# @param [Get_Int] Lambda that allows getting the next n-bit int.
	# @return [HuffmanCoding] A huffman coding tree with the code lengths.
	def create_dynamic_length_tree(ncodelengths, next_bit)
		lengthcodelengths = []
		lengthlookup = {}
		(ncodelengths).times { |j|
			codelength = 0
			3.times { |i| codelength |= next_bit.call() << (i) }
			lengthcodelengths.push(codelength)
			if (codelength != 0)
				lengthlookup[@@length_code_order[j]] = codelength
			end
		}
		
		lengthcodes = HuffmanCoding.generate_codes(lengthcodelengths)

		used = []
		lengthcodes.each_index { |i|
			used[i] = false
		}

		codelengthtree = HuffmanCoding.new()
		for i in 0..18
			next if !lengthlookup.has_key? i
			len = lengthlookup[i]
			for j in 0..lengthcodes.length
				if !used[j] && lengthcodelengths[j] == len
					codelengthtree.add(i, lengthcodes[j], len)
					print "Value: #{i} "
					str = ''
					lengthcodelengths[j].times {
						|z|
						str += ((lengthcodes[j] >> z) & 0x1).to_s
					}
					print "Code: #{str} "
					puts "Length: #{len}"
					used[j] = true
					break
				end
			end
		end

		return codelengthtree
	end

	# Consumes the codes for lengths/literals into the tree.
	#
	# @param [Ncodes] The number of codes to read.
	# @param [Tree] The HuffmanCoding tree with the codes inside it.
	# @param [Get_Int] Lambda that allows getting the next n-bit int.
	# @param [Next_Bit] Lambda that allows getting the next bit.
	def consume_code_length_codes(ncodes, tree, get_int, next_bit)
		lengths = []
		while lengths.length < ncodes
			tree.begin_find()
			code = nil
			while (code = tree.query(next_bit.call())) == nil
			end
			translate_code_length_code(code, lengths, get_int)
		end
		return lengths
	end

	# Translates a code length code into an actual code length.
	#
	# @param [Code_length_code] The code length code
	# @param [Code_lengths] The code length array.
	# @param [Get_Int] Lambda that allows getting the next n-bit int.
	def translate_code_length_code(code_length_code, code_lengths, get_int)
		print "#{code_lengths.length}\t"
		if code_length_code < 16
			code_lengths.push(code_length_code)
			puts "Lit: #{code_length_code}"
			return
		end

		length = 0
		ncopy = 0
		length_bits = 0
		push = 3

		if code_length_code == 16
			length = code_lengths[code_lengths.length-1]
			length_bits = 2
			print "Copying #{code_lengths[code_lengths.length-1]} 3-6: "
		elsif code_length_code == 17
			length_bits = 3
			print "Copying 0 3-10: "
		elsif code_length_code == 18
			length_bits = 7
			push = 11
			print "Copying 0 11-138: "
		end

		ncopy = push + get_int.call(length_bits)
		puts ncopy

		ncopy.times { code_lengths.push(length) }
	end

	# Takes in a digit and transposes the binary digits in it.
	#
	# @param [Digit] The digit to transpose.
	# @param [N] The number of binary digits to use.
	# @return [Fixnum] The transposed binary digit.
	def self.binary_transpose(digit, n)
		outdigit = 0
		(n).times { |i|
			outdigit |= ((digit >> n-i-1) & 0x1) << i
		}
		return outdigit
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
	# @return [Array] The array of codes.
	def self.generate_codes(lengths)
		codes = []

		# Step 1, count number of codes of each length.
		length_counts = []
		lengths.each { |len|
			length_counts[len] = lengths.count(len)
		}
		length_counts.collect! { |i| i == nil ? 0 : i }

		puts length_counts.inspect

		# Step 2, generate next_code values for all lengths.
		code = 0
		next_code = [0]
		length_counts[0] = 0

		1.upto(MaxBits + 1).each { |nbits|
			break if nbits >= length_counts.length
			code = (code + length_counts[nbits-1]) << 1
			next_code[nbits] = code
		}

		# Step 3, generate codes for all lengths.
		0.upto(lengths.count - 1).each { |n|
			len = lengths[n]
			if (len != 0 && len != nil)
				codes[n] = next_code[len]
				next_code[len] += 1
			else
				codes[n] = nil
			end
		}

		return codes
	end
end