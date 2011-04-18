# Huffman encoding Tree
class HuffmanTree
	
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
end