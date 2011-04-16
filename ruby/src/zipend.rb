# A struct containing the zip end of central directory header information.
class ZipEnd
	Header = 0x06054b50

	# Creates a new ZipEnd from a stream.
	#
	# @param [Stream] The stream that contains the header.
	def initialize(stream = nil)
		if (stream != nil)
			read_from_stream(stream)
		end
	end

	# Reads in the end of central directory from a stream object.
	#
	# @param [Stream] The stream that contains the end of central directory.
	# @return [ZipEnd] Self
	def read_from_stream(stream)
		headers = stream.read(22).unpack('VvvvvVVv')

		@header = headers[0]
		@disk_num = headers[1]
		@disk_cdir = headers[2]
		@num_cdir = headers[3]
		@total_cdir = headers[4]
		@size_cdir = headers[5]
		@offset_cdir = headers[6]
		@comment_len = headers[7]
		
		@comment = @comment_len > 0 ? stream.read(@comment_len) : nil

		return self
	end

	# Checks if the header read in is valid
	#
	# @return [bool] Is valid?
	def is_valid?
		return @header == Header
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