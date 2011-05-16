require_relative 'zipdescriptor'
require_relative 'zipheader'
require_relative 'zipcentraldirectory'
require_relative 'zipend'
require_relative 'zipenums'

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
	# @param [Stream] A stream to use as the reading file.
	# @return [ZipFile] Self
	def read_file(stream = nil)
		if (stream == nil)
			open_file()
		else
			@file = stream
		end

		@length = @file.size
		read()
		self
	end

	# Extracts the file and writes it to disk
	#
	# @param [Index] The index of the file to extract.
	# @param [Filename] The filename to write to.
	def extract_file(index, filename)
		file = File.new(filename, 'w+')
		extract_to_file(index, file)
		file.close()
	end

	# Extracts the file and writes it to the file object.
	#
	# @param [Index] The index of the file to extract.
	# @param [File] The file to write to.
	def extract_to_file(index, file)
		header = @central_directories[index]

		file_offset =
			header.local_header_offset +
			header.zip_header.filename_len +
			header.zip_header.extra_field_len +
			ZipHeader::StaticLength
		size = header.zip_header.zip_descriptor.compressed_size
		comp_method = header.zip_header.compression_method

		@file.seek(file_offset, IO::SEEK_SET)

		if (comp_method == CompressionMethod::NoCompression)
			size_left = size
			n = [size_left, 4096].min
			buffer = @file.read(n)
			while (buffer != nil && buffer != '')
				file.write(buffer)
				size_left -= n
				n = [size_left, 4096].min
				buffer = @file.read(n)
			end
		elsif (comp_method == CompressionMethod::Deflated)
			file.write(@file.read(10))
		end
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
		header_type = get_next_header_type()
		while (header_type == ZipHeader::Header)
			@local_headers.push(header = get_next_header(header_type))

			has_descriptor = header.bitflag & GeneralFlags::DataDescriptor
			if (has_descriptor == GeneralFlags::DataDescriptor)
				search_for_descriptor()
				header.read_descriptor(@file)
			else
				@file.seek(header.zip_descriptor.compressed_size, IO::SEEK_CUR)
			end

			header_type = get_next_header_type()
		end

		@central_directories = []
		while (header_type == ZipCentralDirectory::Header)
			@central_directories.push(header = get_next_header(header_type))
			header_type = get_next_header_type()
		end

		if (header_type != ZipEnd::Header)
			throw 'Bad zip format.'
		end

		@central_directory_end = ZipEnd.new(@file, false)
	end

	# Reads the next header type from the stream
	#
	# @return [Fixnum] The header type.
	def get_next_header_type
		return @file.read(4).unpack('V')[0]
	end

	# Reads the next header from the stream
	#
	# @param [Header_Type] The header bytes to check.
	# @return [Object] One of the header types.
	def get_next_header(header_type)
		case header_type
			when ZipHeader::Header
				return ZipHeader.new(@file, false)
			when ZipDescriptor::Header
				return ZipDescriptor.new().read_from_stream(@file, false)
			when ZipCentralDirectory::Header
				return ZipCentralDirectory.new(@file, false)
			when ZipEnd::Header
				return ZipEnd.new(@file, false)
			else
				throw 'Could not understand header bytes.'
		end
	end

	# Searches through the file for a descriptor (painful)
	#
	# return [Fixnum] The position it found the descriptor at
	def search_for_descriptor
		pos = -1
		str = @file.read(1)
		while (str != nil)

			byte = str.unpack('C')[0]
			if (byte == 0x50)
				potentialHeader = str + @file.read(3)
				if (ZipDescriptor::Header == potentialHeader.unpack('V')[0])
					pos = @file.pos
					break
				else
					@file.seek(-3, IO::SEEK_CUR)
				end
			end
			str = @file.read(1)
		end

		if (pos == -1)
			throw 'Could not find descriptor, bad file.'
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