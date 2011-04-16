# A struct containing the zip end of central directory header information.
class ZipEnd
	Header = 0x06054b50

	# Creates a new ZipEnd from a stream.
	#
	# @param [Stream] The stream that contains the header.
	# @param [Read_Header] Determines whether to read the initial header value
	def initialize(stream = nil, read_header = true)
		if (stream != nil)
			read_from_stream(stream, read_header)
		end
	end

	# Reads in the end of central directory from a stream object.
	#
	# @param [Stream] The stream that contains the end of central directory.
	# @param [Read_Header] Determines whether to read the initial header value
	# @return [ZipEnd] Self
	def read_from_stream(stream, read_header = true)
		bytes = 18 + (read_header ? 4 : 0)
		unpack = (read_header ? 'V' : '') + 'vvvvVVv';
		headers = stream.read(bytes).unpack(unpack)

		n = -1
		if (read_header)
			@header = headers[n += 1]
		else
			@header = false
		end

		@disk_num = headers[n += 1]
		@disk_cdir = headers[n += 1]
		@num_cdir = headers[n += 1]
		@total_cdir = headers[n += 1]
		@size_cdir = headers[n += 1]
		@offset_cdir = headers[n += 1]
		@comment_len = headers[n += 1]
		
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
	attr_reader :disk_num
	attr_reader :disk_cdir
	attr_reader :num_cdir
	attr_reader :total_cdir
	attr_reader :size_cdir
	attr_reader :offset_cdir
	attr_reader :comment_len
	attr_reader :comment
end