require_relative 'zipdescriptor'
require_relative 'zipheader'
require_relative 'zipcentraldirectory'
require_relative 'zipend'

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
	# @return [ZipFile] Self
	def read_file
		open_file()
		@length = @file.size
		read()
		self
	end

	# Closes the file
	#
	# @return [nil]
	def close
		close_file()
	end

	attr_reader :filename
	attr_reader :length
	attr_reader :local_headers
	attr_reader :central_directories
	attr_reader :central_directory_end

	private	

	# Reads the headers from the file.
	#
	# @return [Hash] The header information.
	def read
		@local_headers = []

		

		@central_directories = []

		#@central_directory_end = ZipEnd.new(@file)
	end

	def get_next_header(bytes)
		case bytes
			when ZipHeader::Header
				return ZipHeader.new(@file)
			when ZipDescriptor::Header
				return ZipDescriptor.new().read_from_stream(@file)
			when ZipCentralDirectory::Header
				return ZipCentralDirectory.new(@file)
			when ZipEnd::Header
				return ZipEnd.new(@file)
		end
	end

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


end