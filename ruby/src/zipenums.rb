# Static class to hold compression method enum values
class CompressionMethod

	# Turns the compression method given into a string.
	def self.stringify(num)
		if (@@stringtable.key?(num))
			return @@stringtable[num]
		else
			return nil
		end
	end

	# No compression
	NoCompression = 0
	# Shrunk
	Shrunk = 1
	# Reduced with Compression factor 1
	ReducedCompFactor1 = 2
	# Reduced with Compression factor 2
	ReducedCompFactor2 = 3
	# Reduced with Compression factor 3
	ReducedCompFactor3 = 4
	# Reduced with Compression factor 4
	ReducedCompFactor4 = 5
	# Imploded
	Imploded = 6
	# Reserved
	Reserved = 7
	# Deflated
	Deflated = 8
	# Enhanced Deflated
	EnhancedDeflated = 9
	# PKWare DCL Imploded
	PKWareDCLImploded = 10
	# BZIP2 Compression
	CompressedUsingBZIP2 = 12
	# LZMA Compression
	LZMA = 14
	# Compressed using IBM Terse
	CompressedUsingIBMTERSE = 18
	# IBM's LZ77 z
	IBMLZ77z = 19
	# PPMd version I, Rev 1
	PPMd = 98

	@@stringtable = {
		0 => 'No Compression',
		1 => 'Shrunk',
		2 => 'Reduced with compression factor 1',
		3 => 'Reduced with compression factor 2',
		4 => 'Reduced with compression factor 3',
		5 => 'Reduced with compression factor 4',
		6 => 'Imploded',
		7 => 'Reserved',
		8 => 'Deflated',
		9 => 'Enhanced Deflated',
		10 => 'PKWare DCL Imploded',
		11 => 'Reserved',
		12 => 'Compressed using BZIP2',
		13 => 'Reserved',
		14 => 'LZMA',
		15 => 'Reserved',
		16 => 'Reserved',
		17 => 'Reserved',
		18 => 'Compressed using IBM TERSE',
		19 => 'IBM LZ77 z',
		98 => 'PPMd version I, Rev 1'
	}
end

# Static class to hold general flag enum values
class GeneralFlags

	# Turns the general flags given into a string.
	def self.stringify(num)
		description = ''

		0.upto(15) { |i|
			bit = 1 << i
			flag = num & bit
			if (flag == bit && @@stringtable.key?(bit))
				if (description != '')
					description += ', '
				end
				description += @@stringtable[bit]
			end
		}

		if (description != '')
			return description
		else
			return nil
		end
	end

	# The file is encrypted.
	EncryptedFile = 0x0
	# An option for compression agents.
	CompressionOption = 0x1
	# An option for compression agents.
	CompressionOption2 = 0x2
	# Whether or not the data descriptor block is present.
	DataDescriptor = 0x4
	# Using enhanced deflation
	EnhancedDeflation = 0x8
	# Compressed patched data
	CompressedPatchedData = 0x10
	# Using string encryption
	StrongEncryption = 0x20
	# Using language encoding
	LanguageEncoding = 0x40
	# Reserved
	Reserved = 0x80
	# Mask Header Values
	MaskHeaderValues = 0x100
		
	@@stringtable = {
		0x0 => 'Encrypted File',
		0x1 => 'Compression Option',
		0x2 => 'Compression Option2',
		0x4 => 'Data Descriptor',
		0x8 => 'Enhanced Deflation',
		0x10 => 'Compressed Patched Data',
		0x20 => 'Strong Encryption',
		0x40 => 'Language Encoding',
		0x80 => 'Reserved',
		0x100 => 'Mask Header Values'
	}
end

# Static class to hold zip version enum values
class ZipVersion

	# Turns the zip version given into a string.
	def self.stringify(num)
		if (@@stringtable.key?(num))
			return @@stringtable[num]
		else
			return nil
		end
	end

	#MS-DOS and OS/2 (FAT / VFAT / FAT32 file systems)
	MSDOS = 0
	#Amiga
	Amiga = 1
	#OpenVMS
	OpenVMS = 2
	#UNIX
	UNIX = 3
	#VM/CMS
	VMCMS = 4
	#Atari ST
	AtariST = 5
	#OS/2 H.P.F.S.
	OS2HPFS = 6
	#Macintosh
	Macintosh = 7
	#Z-System
	ZSystem = 8
	#CP/M
	CP_M = 9
	#Windows NTFS
	WindowsNTFS = 10
	#MVS (OS/390 - Z/OS)
	MVS = 11
	#VSE
	VSE = 12
	#Acorn Risc
	AcornRisc = 13
	#VFAT
	VFAT = 14
	#Alternate MVS
	AlternateMVS = 15
	#BeOS
	BeOS = 16
	#Tandem
	Tandem = 17
	#OS/400
	OS_400 = 18
	#OS/X (Darwin)
	OS_XDarwin = 19

	@@stringtable = {
		0 => 'MS-DOS and OS/2 (FAT / VFAT / FAT32 file systems)',
		1 => 'Amiga',
		2 => 'OpenVMS',
		3 => 'UNIX',
		4 => 'VM/CMS',
		5 => 'Atari ST',
		6 => 'OS/2 H.P.F.S.',
		7 => 'Macintosh',
		8 => 'Z-System',
		9 => 'CP/M',
		10 => 'Windows NTFS',
		11 => 'MVS (OS/390 - Z/OS)',
		12 => 'VSE',
		13 => 'Acorn Risc',
		14 => 'VFAT',
		15 => 'Alternate MVS',
		16 => 'BeOS',
		17 => 'Tandem',
		18 => 'OS/400',
		19 => 'OS/X (Darwin)'
	}
end

# Static class to hold internal file attribute enum values
class InternalFileAttributes

	# Turns the internal file attributes given into a string.
	def self.stringify(num)
		description = ''

		0.upto(15) { |i|
			bit = 1 << i
			flag = num & bit
			if (flag > 0 && @@stringtable.key?(bit))
				if (description != '')
					description += ', '
				end
				description += @@stringtable[bit]
			end
		}

		if (description != '')
			return description
		else
			return nil
		end
	end

	# The file is apparently ASCII
	ApparentASCII = 0x1
	# Reserved
	Reserved = 0x2
	# Control Field Records Precede Logical Records
	ControlFieldPrecedeRecords = 0x4

	@@stringtable = {
		0x1 => 'Apparent ASCII/text file',
		0x2 => 'Reserved',
		0x4 => 'Control Field Records Precede Logical Records'
	}
end
