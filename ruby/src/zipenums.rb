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

	NoCompression = 0
	Shrunk = 1
	ReducedCompFactor1 = 2
	ReducedCompFactor2 = 3
	ReducedCompFactor3 = 4
	ReducedCompFactor4 = 5
	Imploded = 6
	Reserved = 7
	Deflated = 8
	EnhancedDeflated = 9
	PKWareDCLImploded = 10
	CompressedUsingBZIP2 = 12
	LZMA = 14
	CompressedUsingIBMTERSE = 18
	IBMLZ77z = 19
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

	EncryptedFile = 0x0
	CompressionOption = 0x1
	CompressionOption2 = 0x2
	DataDescriptor = 0x4
	EnhancedDeflation = 0x8
	CompressedPatchedData = 0x10
	StrongEncryption = 0x20
	LanguageEncoding = 0x40
	Reserved = 0x80
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

	MSDOS = 0
	Amiga = 1
	OpenVMS = 2
	UNIX = 3
	VMCMS = 4
	AtariST = 5
	OS2HPFS = 6
	Macintosh = 7
	ZSystem = 8
	CP_M = 9
	WindowsNTFS = 10
	MVS = 11
	VSE = 12
	AcornRisc = 13
	VFAT = 14
	AlternateMVS = 15
	BeOS = 16
	Tandem = 17
	OS_400 = 18
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

	ApparentASCII = 0x1
	Reserved = 0x2
	ControlFieldPrecedeRecords = 0x4

	@@stringtable = {
		0x1 => 'Apparent ASCII/text file',
		0x2 => 'Reserved',
		0x4 => 'Control Field Records Precede Logical Records'
	}
end
