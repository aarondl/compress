require_relative 'zipdescriptor'

# A struct containing the local file header information.
class ZipHeader
	@@header_value = 0x04034b50

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
		end

		@version_needed = headers[n += 1]
		@bitflag = headers[n += 1]
		@compression_method = headers[n += 1]
		@last_modified_time = headers[n += 1]
		@last_modified_date = headers[n += 1]

		@zip_descriptor = ZipDescriptor.new().read_from_stream(stream, false)

		headers = stream.read(4).unpack('vv')
		@filename_len = headers[0]
		@extra_field_len = headers[1]

		if (read_vars)
			read_vars_from_stream(stream)
		end

		return self
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
		return @header == @@header_value
	end

	attr_reader :header
	attr_reader :version_needed
	attr_reader :bitflag
	attr_reader :compression_method
	attr_reader :last_modified_time
	attr_reader :last_modified_date
	attr_reader :zip_descriptor
	attr_reader :filename_len
	attr_reader :extra_field_len
	attr_reader :filename
	attr_reader :extra_fields
end