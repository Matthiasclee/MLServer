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