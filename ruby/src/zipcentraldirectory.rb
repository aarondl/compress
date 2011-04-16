require_relative 'zipheader'

# A struct containing the central directory header information.
class ZipCentralDirectory
	@@header_value = 0x02014b50

	# Reads in the central directory from a stream object.
	#
	# @param [Stream] The stream that contains the central directory.
	# @return [ZipCentralDirectory] Self
	def read_from_stream(stream)
		headers = stream.read(6).unpack('Vv')

		@header = headers[0]
		@version_made = headers[1]

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
		return @header == @@header_value
	end

	attr_reader :header
	attr_reader :version_made
	attr_reader :comment_len
	attr_reader :disk_num
	attr_reader :internal_attribs
	attr_reader :external_attribs
	attr_reader :local_header_offset
	attr_reader :zip_header
	attr_reader :comment
end