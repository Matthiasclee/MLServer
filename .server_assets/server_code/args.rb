$AG_COMPAT_VER_0 = "x"
$AG_COMPAT_VER_1 = "x"
$AG_COMPAT_VER_2 = "x"
class Arg
	def initialize(argv, prefix = "--")
		@args = {}
		for arg in argv do
			if arg.match(/^#{prefix}/) && argv[argv.index(arg) + 1] && !argv[argv.index(arg) + 1].match(/^#{prefix}/)
				@args[arg.sub(/^#{prefix}/, "").to_sym] = argv[argv.index(arg) + 1]
			end
		end
	end
	def args()
		return @args
	end
end