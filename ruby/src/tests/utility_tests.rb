require 'test/unit'
require 'date'
require_relative '../utility'

class TestZipFile < Test::Unit::TestCase

	def test_unpack_date
		date = Utility.unpack_date(16016)
		assert_equal(2011, date.year)
		assert_equal(4, date.month)
		assert_equal(16, date.day)
	end

	def test_unpack_time
		time = Utility.unpack_time(39552)
	end

	def test_combine_date_time
		date = Date.civil(1999, 12, 20)
		time = DateTime.civil(0, 1, 1, 23, 22, 21)

		datetime = Utility.combine_date_time(date, time)
		assert_equal(1999, datetime.year)
		assert_equal(12, datetime.month)
		assert_equal(20, datetime.day)
		assert_equal(23, datetime.hour)
		assert_equal(22, datetime.minute)
		assert_equal(21, datetime.second)
	end

end