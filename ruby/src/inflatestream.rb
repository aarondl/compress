require_relative 'huffmancoding'

# This class provides read-only access to a deflate stream.
class InflateStream
	BufferSize = 32768

	# Initializes the deflate stream.
	def initialize(stream)
		@stream = stream

		#Buffer for storing bytes during decompression
		@buffer = ''
		#Offset into the stream
		@offset = 0
		#Last byte read.
		@byte = nil
		#The bit offset into the last byte read
		@bit = 0
		#Is this the final block?
		@finalblock = false
		#The tree being used currently for decoding.
		@tree = nil
		#The compression method currently being used.
		@compression = 0x3
		#The uncompressed length of the stream (for multiple reads)
		@uncompressed_length = nil

		@in_block = false

		@repeatoffset = nil
		@repeatlength = nil
	end

	# Reads the blocks of the compressed file
	#
	# @param [Length] The number of bytes to read.
	# @param [Buffer] The buffer to store things in.
	# @return [String|Fixnum] A string if no buffer was supplied or n chars read
	def read(length = nil, buffer = nil)
		while true
			if !@inblock
				@finalblock = 0x1 == next_bit()
				@compression = read_compression()
			end

			case @compression
				when HuffmanCoding::Uncompressed
					ret = read_uncompressed_block(length, buffer)
				when HuffmanCoding::FixedHuffman
					ret = read_huffman_block(nil, length, buffer)
				when HuffmanCoding::DynamicHuffman
					ret = read_huffman_block(read_tree(), length, buffer)
				else
					throw 'Illegal compression method'
			end

			break if @finalblock
		end

		return ret
	end

	private

	# Gets the next bit from the stream.
	def next_bit
		if @byte == nil || @bit == 8
			@byte = @stream.read(1).ord
			@bit = 0
		end

		bit = (@byte >> @bit) & 0x1
		@bit += 1
		return bit
	end

	# Reads the next compression type
	def read_compression
		return next_bit() | next_bit() << 0x1
	end

	# Reads the data for the uncompressed block
	#
	# @param [Length] The number of bytes to read.
	# @param [Buffer] The buffer to store things in.
	# @return [String|Fixnum] A string if no buffer was supplied or n chars read
	def read_uncompressed_block(length = nil, buffer = nil)
		if @uncompressed_length == nil
			lengths = @stream.read(4).unpack('vv')
			length = lengths[0]
			if (length & ~length)
				throw 'Uncompressed length check failed.'
			end
			@uncompressed_length = length
		end

		if @uncompressed_length == 0
			if buffer != nil
				0
			else
				nil
			end
		end

		if length == nil || length > @uncompressed_length
			length = @uncompressed_length
		end

		readbytes = @stream.read(length, buffer)
		@uncompressed_length -= readbytes.length

		if buffer != nil
			readbytes.length
		else
			readbytes
		end
	end

	# Reads a huffman coding tree in from the stream.
	#
	def read_tree
		throw 'Not implemented'
	end

	# Reads the data encoded by a huffman tree.
	#
	# @param [Tree] The huffman tree structure to use to decode.
	# @param [Length] The number of bytes to read.
	# @param [Buffer] The buffer to store things in.
	# @return [String|Fixnum] A string if no buffer was supplied or n chars read
	def read_huffman_block(tree, length = nil, buffer = nil)
		if (tree == nil)
			tree = HuffmanCoding::fixed_tree()
		end
		
		written = 0
		bufferoffset = @buffer.length
		while length == nil || written < length
			
			tree.begin_find()
			nextvalue = nil
			while (nextvalue = tree.query(next_bit())) == nil
			end

			if nextvalue < 256
				@buffer += nextvalue.chr
				written += 1
			elsif nextvalue == 256
				@in_block = false
				break
			else
				ret = write_repeat(length, buffer,
					read_length(nextvalue), read_distance())
				if buffer != nil
					written += ret
				else
					written += ret.length
				end
			end
		end

		write = @buffer[bufferoffset..(bufferoffset+written)]
		if buffer != nil
			buffer += write
			written
		else
			write
		end
	end

	# Writes bytes to the buffer based on a length and offset.
	#
	# @param [Length] The length of bytes to copy as a maximum.
	# @param [Buffer] The optionally supplied buffer.
	# @param [CopyLength] The length to copy from:
	# @param [Distance] The offset into the buffer to copy from.
	# @return [String|Fixnum] A string if no buffer was supplied or n chars read
	def write_repeat(length = nil, buffer = nil, copylength, distance)
		@repeatlength = copylength
		@repeatoffset = distance

		str = ''
		@repeatlength.times { |i|
			byte = @buffer[@buffer.length-@repeatoffset]
			@buffer += byte
			str += byte
		}
		if buffer != nil
			buffer += str
			str.length
		else
			str
		end
	end

	# Reads in a full length code.
	#
	# @param [Value] The discovered length code.
	# @return [Fixnum] The actual length.
	def read_length(value)
		extrabits = HuffmanCoding.length_extra_bits(value)
		extra = 0
		if extrabits > 0
			(0..extrabits-1).each { |i|
				extra |= next_bit() << i
			}
		end

		return HuffmanCoding.get_length(value) + extra
	end

	# Reads in a full distance code.
	#
	# @return [Fixnum] The actual distance.
	def read_distance()
		distance_code = 0
		(0..4).each { |i|
			distance_code |= next_bit() << (4-i)
		}
		extrabits = HuffmanCoding.distance_extra_bits(distance_code)
		extra = 0
		if extrabits > 0
			(0..extrabits-1).each { |i|
				extra |= next_bit() << i
			}
		end

		return HuffmanCoding.get_distance(distance_code) + extra
	end
end