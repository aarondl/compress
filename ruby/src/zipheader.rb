require_relative 'zipdescriptor'
require_relative 'utility'
require_relative 'zipenums'

# A struct containing the local file header information.
class ZipHeader
	# The header at the beginning of the block.
	Header = 0x04034b50
	# The static length of the local file header.
	StaticLength = 30

	# Creates a new ZipHeader from a stream.
	#
	# @param [Stream] The stream that contains the header.
	# @param [Read_Header] Determines whether to read the initial header value
	def initialize(stream = nil, read_header = true)
		if (stream != nil)
			read_from_stream(stream, read_header)
		end
	end

	# Reads in the header from a stream object.
	#
	# @param [Stream] The stream that contains the header.
	# @param [Read_Header] Determines whether to read the initial header value
	# @param [Read_Lengths] Reads the filename and extra fields in.
	# @return [ZipHeader] Self
	def read_from_stream(stream, read_header = true, read_vars = true)
		bytes = 10 + (read_header ? 4 : 0)
		unpack = (read_header ? 'V' : '') + 'vvvvv';

		headers = stream.read(bytes).unpack(unpack)
		n = -1
		if (read_header)
			@header = headers[n += 1]
		else
			@header = false
		end

		@version_needed = headers[n += 1]
		@bitflag = headers[n += 1]
		@compression_method = headers[n += 1]
		time = Utility.unpack_time(headers[n += 1])
		date = Utility.unpack_date(headers[n += 1])
		@last_modified_date = Utility.combine_date_time(date, time)

		read_descriptor(stream)

		headers = stream.read(4).unpack('vv')
		@filename_len = headers[0]
		@extra_field_len = headers[1]

		if (read_vars)
			read_vars_from_stream(stream)
		end

		return self
	end

	# Reads in the file descriptor section
	#
	# @param [Stream] The stream to read from
	# @return [Nil]
	def read_descriptor(stream)
		@zip_descriptor = ZipDescriptor.new().read_from_stream(stream, false)
	end

	# Reads in the header's variable length args from a stream.
	#
	# @param [Stream] The stream that contains the header information.
	# @return [nil]
	def read_vars_from_stream(stream)
		@filename = stream.read(@filename_len)

		@extra_fields = {}
		n = @extra_field_len
		while (n > 0)
			headers = stream.read(4).unpack('vv')
			id = headers[0]
			len = headers[1]
			@extra_fields[id] = stream.read(len).unpack('C' + len.to_s)
			n -= (4 + len)
		end
	end

	# Checks if the header read in is valid
	#
	# @return [bool] Is valid?
	def is_valid?
		return @header === false || @header === Header
	end

	attr_reader :header
	attr_reader :version_needed
	attr_reader :bitflag
	attr_reader :compression_method
	attr_reader :last_modified_date
	attr_reader :zip_descriptor
	attr_reader :filename_len
	attr_reader :extra_field_len
	attr_reader :filename
	attr_reader :extra_fields
end