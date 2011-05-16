require_relative 'huffmancoding'

# This class provides read-only access to a deflate stream.
class InflateStream
	BufferSize = 32768

	# Initializes the deflate stream.
	def initialize(stream)
		@stream = stream

		#Bit level state ===============
		#Offset into the stream
		@offset = 0
		#Last byte read.
		@byte = nil
		#The bit offset into the last byte read
		@bit = 0

		#Block level state ==============
		#Compression
		@compression = 0x3
		#Is this the final block?
		@finalblock = false
		#Uncompressed length of the block
		@uncompressed_length = nil

		#Block operation level state ==============
		#Offset into buffer where to copy from
		@repeatoffset = nil
		#The remaning bytes to copy from the offset.
		@repeatlength = nil

		#Buffer for storing BufferSize bytes during decompression (for backrefs)
		@buffer = ''
		@bufferoffset = 0
		#The tree being used currently for decoding.
		@tree = nil
		#The buffer to write to
		@userbuffer = nil
		#The length remaining to write to the buffer
		@length = nil
		#The number of bytes written to the user's buffer.
		@byteswritten = 0
	end

	# Reads the blocks of the compressed file
	#
	# @param [Length] The number of bytes to read.
	# @param [Buffer] The buffer to store things in.
	# @return [String|Fixnum] A string if no buffer was supplied or n chars read
	def read(length = nil, buffer = nil)
		@length = length
		@userbuffer = buffer
		@byteswritten = 0
		@bufferoffset = @buffer.length

		#Check if we ended reading in a repeat, if so continue writing.
		if @repeatoffset != nil
			write_repeat()
		end #Otherwise read in more blocks

		while true
			if @compression == 0x3
				@finalblock = 0x1 == next_bit()
				@compression = read_compression()
			end

			case @compression
				when HuffmanCoding::Uncompressed
					read_uncompressed_block()
				when HuffmanCoding::FixedHuffman
					read_huffman_block()
				when HuffmanCoding::DynamicHuffman
					if (@tree == nil)
						read_tree()
					end
					read_huffman_block(@tree)
				else
					throw 'Illegal compression method'
			end

			break if @finalblock || @byteswritten == @length
		end

		return @userbuffer != nil ?
			@byteswritten :
			@buffer[@bufferoffset..@buffer.length]
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
	def read_uncompressed_block()
		if @uncompressed_length == nil || @uncompressed_length == 0
			lengths = @stream.read(4).unpack('vv')
			length = lengths[0]
			rubyshortcomings = ((2 ** 16)-1) << 16
			if (length == ~(lengths[1] | rubyshortcomings))
				throw 'Uncompressed length check failed.'
			end
			@uncompressed_length = length
		end

		if @uncompressed_length == 0
			@compression = 0x3
			return
		end

		buf = ''
		nBytes = @length > @uncompressed_length ? @uncompressed_length : @length
		@stream.read(nBytes, buf)
		@buffer.concat(buf)
		@uncompressed_length -= buf.length
		@byteswritten += buf.length

		if @userbuffer != nil
			@userbuffer.concat(buf)
		end

		#This tells us we're no longer in a block
		if @uncompressed_length == 0
			@compression = 0x3
		end
	end

	# Reads a huffman coding tree in from the stream.
	#
	def read_tree
		@tree = HuffmanCoding.new()
		@tree.read_tree(@stream, @byte, @bit)
	end

	# Reads the data encoded by a huffman tree.
	#
	# @param [Tree] The huffman tree structure to use to decode.
	def read_huffman_block(tree = nil)
		if (tree == nil)
			tree = HuffmanCoding::fixed_tree()
		end
		
		while @byteswritten != @length
			tree.begin_find()
			nextvalue = nil
			while (nextvalue = tree.query(next_bit())) == nil
			end

			puts "Byte #{nextvalue}"

			if nextvalue < 256
				@buffer += nextvalue.chr
				@byteswritten += 1
				if @userbuffer != nil
					@userbuffer.concat(nextvalue.chr)
				end
			elsif nextvalue == 256
				@tree = nil
				@compression = 0x3
				break
			else
				write_repeat(read_length(nextvalue, tree), read_distance(tree))
			end
		end

	end

	# Writes bytes to the buffer based on a length and offset.
	#
	# @param [CopyLength] The length to copy from:
	# @param [Distance] The offset into the buffer to copy from.
	def write_repeat(copylength = nil, distance = nil)
		if copylength != nil
			@repeatlength = copylength
		end
		if distance != nil
			@repeatoffset = distance
		end

		str = ''
		@repeatlength.times { |i|
			byte = @buffer[@buffer.length-@repeatoffset]
			@buffer += byte
			if @userbuffer != nil
				@userbuffer.concat(byte)
			end
			@byteswritten += 1
			@repeatlength -= 1

			break if @byteswritten == @length
		}

		#Make sure state represents finished.
		if @repeatlength == 0
			@repeatlength = nil
			@repeatoffset = nil
		end
	end

	# Reads in a full length code.
	#
	# @param [Value] The discovered length code.
	# @param [Tree] The huffman tree to get the length from.
	# @return [Fixnum] The actual length.
	def read_length(value, tree)
		extrabits = HuffmanCoding::length_extra_bits(value)
		extra = 0
		if extrabits > 0
			(0..extrabits-1).each { |i|
				extra |= next_bit() << i
			}
		end

		return HuffmanCoding::get_length(value) + extra
	end

	# Reads in a full distance code.
	#
	# @param [Tree] The huffman tree to get the distance from.
	# @return [Fixnum] The actual distance.
	def read_distance(tree)
		distance_code = 0
		(0..4).each { |i|
			distance_code |= next_bit() << (4-i)
		}
		extrabits = HuffmanCoding::distance_extra_bits(distance_code)
		extra = 0
		if extrabits > 0
			(0..extrabits-1).each { |i|
				extra |= next_bit() << i
			}
		end

		return HuffmanCoding::get_distance(distance_code) + extra
	end
end