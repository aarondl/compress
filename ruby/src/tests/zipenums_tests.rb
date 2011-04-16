require 'test/unit'
require_relative '../zipenums'

class TestZipEnums < Test::Unit::TestCase

	def test_compression_method_enum
		assert_equal('Shrunk', 
			CompressionMethod.stringify(CompressionMethod::Shrunk))
	end

	def test_general_flags_enum
		assert_equal('Enhanced Deflation, Language Encoding',
			GeneralFlags.stringify(
				GeneralFlags::EnhancedDeflation | GeneralFlags::LanguageEncoding
			)
		)
	end

	def test_zip_version_enum
		assert_equal('CP/M', ZipVersion.stringify(ZipVersion::CP_M))
	end

	def test_internal_file_attribs_enum
		assert_equal('Apparent ASCII/text file, Reserved',
			InternalFileAttributes.stringify(
				InternalFileAttributes::ApparentASCII | 
				InternalFileAttributes::Reserved
			)
		)
	end

end