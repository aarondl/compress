require 'date'

# A utility class vith various helper methods.
class Utility
	# Unpacks a 16-bit MS-DOS packed time value.
	#
	# @param [Packed_Time] The 16-bit MS-DOS packed time value.
	# @return [DateTime] The date time object containing the time.
	def self.unpack_time(packed_time)
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
	def self.unpack_date(packed_date)
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
	def self.combine_date_time(date, time)
		return DateTime.civil(
			date.year, date.month, date.day,
			time.hour, time.minute, time.second
		)
	end
end