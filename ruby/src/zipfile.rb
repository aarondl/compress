require 'date'

# Provides read-only access to zip files.
class ZipFile

	# Creates a new instance of a ZipFile object with a filename to open.
	#
	# @param [Filename] The filename of the file to open.
	def initialize(filename)
		@filename = filename
	end

	# Reads the file in, this includes header info and directory structure.
	#
	# @return [nil]
	def read_file
		open_file()
		@length = @file.size
		@headers = read_headers()
	end

	# Reads the headers from the file.
	#
	# @return [Hash] The header information.
	def read_headers
		if @file == nil
			return @file
		end

		headers = @file.read(30).unpack('VvvvvvH2H2H2H2VVvv')

		all_headers = {
			:header => headers[0],
			:version => headers[1],
			:bitflag => headers[2],
			:compression_method => headers[3],
			:last_modified_time => headers[4],
			:last_modified_date => headers[5],
			:crc => headers[9] + headers[8] + headers[7] + headers[6],
			:compressed_size => headers[10],
			:uncompressed_size => headers[11],
			:filename_len => headers[12],
			:extra_field_len => headers[13],
		}

		name_length = all_headers[:filename_len];
		if name_length > 0
			all_headers[:filename] = 
				@file.read(name_length).unpack('A' + name_length.to_s)[0]
		end

		return all_headers;
	end

	# Closes the file
	#
	# @return [nil]
	def close
		close_file()
	end

	attr_reader :filename
	attr_reader :headers
	attr_reader :length

	private	

	# Opens the file at a low level
	#
	# @return [nil]
	def open_file
		@file = File.new(@filename, 'rb')
	end

	# Closes the file at a low level
	#
	# @return [nil]
	def close_file
		@file.close()
	end

	# Unpacks a 16-bit MS-DOS packed time value.
	#
	# @param [Packed_Time] The 16-bit MS-DOS packed time value.
	# @return [DateTime] The date time object containing the time.
	def ZipFile.unpack_time(packed_time)
		return DateTime.civil(
			0, 1, 1,
			(packed_time >> 11) & 0xF, #Hour
			(packed_time >> 5) & 0x1F, #Minute
			(packed_time & 0xF) * 2, #Second Packed time has only 2s resolution
		)
	end

	# Unpacks a 16-bit MS-DOS packed date value.
	#
	# @param [Packed_Date] The 16-bit MS-DOS packed date value.
	# @return [Date] The date object containing the date.
	def ZipFile.unpack_date(packed_date)
		return Date.civil(
			((packed_date >> 9) & 0x3F) + 1980, #Year
			(packed_date >> 5) & 0x7, #Month
			packed_date & 0xF, #Day
		)
	end

	# Combines a date and time object.
	#
	# @param [Date] The date to combine.
	# @param [Time] The time to combine.
	# @return [DateTime] The full DateTime object.
	def ZipFile.combine_date_time(date, time)
		return DateTime.civil(
			date.year, date.month, date.day,
			time.hour, time.minute, time.second
		)
	end
end