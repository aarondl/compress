require_relative 'zipheader'

# A struct containing the central directory header information.
class ZipCentralDirectory
	Header = 0x02014b50

	# Creates a new ZipCentralDirectory from a stream.
	#
	# @param [Stream] The stream that contains the header.
	# @param [Read_Header] Whether or not to read the header.
	def initialize(stream = nil, read_header = true)
		if (stream != nil)
			read_from_stream(stream, read_header)
		end
	end

	# Reads in the central directory from a stream object.
	#
	# @param [Stream] The stream that contains the central directory.
	# @param [Read_Header] Whether or not to read the header.
	# @return [ZipCentralDirectory] Self
	def read_from_stream(stream, read_header = true)
		bytes = 2 + (read_header ? 4 : 0)
		unpack = (read_header ? 'V' : '') + 'CC';
		headers = stream.read(bytes).unpack(unpack)

		n = -1
		if (read_header)
			@header = headers[n += 1]
		else
			@header = false
		end

		@version_made_zip = headers[n += 1]
		@version_made_os = headers[n += 1]

		@zip_header = ZipHeader.new().read_from_stream(stream, false, false)

		headers = stream.read(14).unpack('vvvVV')
		@comment_len = headers[0]
		@disk_num = headers[1]
		@internal_attribs = headers[2]
		@external_attribs = headers[3]
		@local_header_offset = headers[4]

		@zip_header.read_vars_from_stream(stream)

		@comment = @comment_len > 0 ? stream.read(@comment_len) : nil

		return self
	end

	# Checks if the header read in is valid
	#
	# @return [bool] Is valid?
	def is_valid?
		return @header === false || @header === Header
	end

	attr_reader :header
	attr_reader :version_made_zip
	attr_reader :version_made_os
	attr_reader :comment_len
	attr_reader :disk_num
	attr_reader :internal_attribs
	attr_reader :external_attribs
	attr_reader :local_header_offset
	attr_reader :zip_header
	attr_reader :comment
end