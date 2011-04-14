require "test/unit"
require "date"
require_relative "../zipfile"

class TestZipFile < Test::Unit::TestCase

	@@filename = "S:\\zip.zip"

	def test_init
		z = ZipFile.new(@@filename)
		assert_not_nil(z)
		assert_equal(@@filename, z.filename)
	end

	def test_read_headers
		z = ZipFile.new(@@filename)
		assert_not_nil(z)
		z.read_file()
		assert_equal(0x04034b50, z.headers[:header])
		assert_not_nil(z.length)
		z.close()
	end

	def test_unpack_date
		date = ZipFile.unpack_date(16013)
		assert_equal(2011, date.year)
		assert_equal(4, date.month)
		assert_equal(13, date.day)
	end

	def test_unpack_time
		time = ZipFile.unpack_time(39552)
	end

	def test_combine_date_time
		date = Date.civil(1999, 12, 20)
		time = DateTime.civil(0, 1, 1, 23, 22, 21)

		datetime = ZipFile.combine_date_time(date, time)
		assert_equal(1999, datetime.year)
		assert_equal(12, datetime.month)
		assert_equal(20, datetime.day)
		assert_equal(23, datetime.hour)
		assert_equal(22, datetime.minute)
		assert_equal(21, datetime.second)
	end
end