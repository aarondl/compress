# A struct representing the data descriptor header.
class ZipDescriptor
	Header = 0x08074b50

	# Creates a ZipDescriptor for internal use, not read-in.
	#
	# @param [Crc] The cyclic redundancy check.
	# @param [Compressed_Size] The compressed size of the file.
	# @param [Uncompressed_Size] The uncompressed size of the file.
	def initialize(crc = 0, compressed_size = 0, uncompressed_size = 0)
		@crc = crc
		@compressed_size = compressed_size
		@uncompressed_size = uncompressed_size
	end

	# Reads in the header from a stream object.
	#
	# @param [Stream] The stream that contains the header.
	# @param [ReadHeader] Whether or not to read the header value.
	# @return [ZipDescriptor] Everyone loves fluent
	def read_from_stream(stream, read_header = true)
		bytes = 12 + (read_header ? 4 : 0)
		unpack = (read_header ? 'V' : '') + 'H2H2H2H2VV';

		headers = stream.read(bytes).unpack(unpack)
		n = 0
		if (read_header)
			@header = headers[n]
			n += 1
		end
		@crc = headers[n + 3] + headers[n + 2] + headers[n + 1] + headers[n]
		n += 4
		@compressed_size = headers[n]
		@uncompressed_size = headers[n += 1]

		return self
	end

	# Checks if the header read in is valid
	#
	# @return [bool] Is valid?
	def is_valid?
		return @header == Header
	end

	attr_reader :header
	attr_reader :crc
	attr_reader :compressed_size
	attr_reader :uncompressed_size
end