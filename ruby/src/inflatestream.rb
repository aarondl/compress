require_relative 'huffmancoding'

# This class provides read-only access to a deflate stream.
class InflateStream
	BufferSize = 32768

	# Initializes the deflate stream.
	def initialize(stream)
		@stream = stream
		@buffer = nil
		@curbyte = nil
	end

	# Reads the blocks of the compressed file
	#
	# @param [Outstream] A stream to write the uncompressed data to.
	def read(outstream)

		# Read first byte
		byte = @stream.read(1).ord
		
		isfinal = byte & 0x1 == 0x1
		while (true)
			compression = (byte >> 1) & 0x3

			block_data = nil

			case compression
				when HuffmanCoding::Uncompressed
					block_data = read_uncompressed_block()
				when HuffmanCoding::FixedHuffman
					block_data = read_fixed_block(byte, 4)
				when HuffmanCoding::DynamicHuffman
					block_data = read_dynamic_block(byte, 4)
				when HuffmanCoding::Illegal
					throw 'Illegal Compression method'
			end

			if block_data != nil
				outstream.write(block_data)
			end

			break if isfinal
			isfinal = byte & 0x1 == 0x1
		end
	end

	private

	# Reads the data for the uncompressed block
	#
	# @return [String] The decompressed block data.
	def read_uncompressed_block
		lengths = @stream.read(4).unpack('vv')
		length = lengths[0]
		if (length & ~length)
			throw 'Uncompressed length check failed.'
		end
		return @stream.read(length)
	end

	# Reads the data encoded by a huffman tree.
	#
	# @param [Tree] The huffman tree structure to use to decode.
	# @param [Byte] The last byte used by the calling methods.
	# @param [Offset] The offset into the byte to start reading at.
	# @return [String] The decompressed block data.
	def read_huffman_block(tree, byte, offset)
		if (tree == nil)
			tree = HuffmanCoding::FixedHuffman
		end
		throw 'Not implemented'
	end


end