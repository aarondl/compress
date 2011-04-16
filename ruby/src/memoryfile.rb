# Fakes being a file in order to test header reads.
class MemoryFile

	# Creates a Memory File with bytes inside it.
	def initialize(bytes)
		@bytes = bytes
		@size = bytes.length
		@pos = 0
	end

	# Reads length bytes from the internal bytes.
	#
	# @param [Length] How many bytes to read
	# @param [Buffer] If not nil, will be filled with the bytes.
	# @return [Array] If buffer is not defined returns an array
	def read_bytes(length = 0, buffer = nil)
		if (length == 0 || @pos == @size)
			return nil
		end

		bytes_left = @size - @pos

		if (length == nil)
			length = bytes_left
		elsif ((@pos + length) > @size)
			length = bytes_left
		end

		arr = @bytes[@pos..@pos+length-1]
		@pos += length

		if (buffer != nil)
			buffer.concat(arr.pack('C*'))
		else
			return arr
		end
	end

	# Seeks to a point in the stream
	#
	# @param [Length] How much to seek
	# @param [Origin] The place in the stream to start.
	def seek(length, origin)
		case origin
			when IO::SEEK_SET
				@pos = 0
			when IO::SEEK_END
				@pos = @size
		end

		@pos += length

		if (@pos > @size)
			@pos = @size
		elsif (@pos < 0)
			@pos = 0
		end
	end

	# Reads length bytes from the internal bytes.
	#
	# @param [Length] How many bytes to read
	# @param [Buffer] If not nil, will be filled with the bytes.
	# @return [String] If buffer is not defined returns a string.
	def read(length = nil, buffer = nil)
		buf = ''
		read_bytes(length, buf)
		if (buf == '')
			return nil
		end

		if (buffer != nil)
			buffer.concat(buf)
		else
			return buf
		end
	end

	attr_reader :size
	attr_reader :pos
end