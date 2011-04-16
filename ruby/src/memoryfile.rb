# Fakes being a file in order to test header reads.
class MemoryFile

	# Creates a Memory File with bytes inside it.
	def initialize(bytes)
		@bytes = bytes
	end

	# Reads length bytes from the internal bytes.
	#
	# @param [Length] How many bytes to read
	# @param [Buffer] If not nil, will be filled with the bytes.
	# @return [Array] If buffer is not defined returns an array
	def read_bytes(length = 0, buffer = nil)
		if (length == 0)
			return nil
		end

		if (length == nil)
			length = @bytes.count
		elsif (length > @bytes.count)
			length = @bytes.count
		end

		arr = @bytes[0..length-1]
		@bytes = @bytes[length..@bytes.count]

		if (buffer != nil)
			buffer.concat(arr.pack('C*'))
		else
			return arr
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
		if (buffer != nil)
			buffer.concat(buf)
		else
			return buf
		end
	end
end