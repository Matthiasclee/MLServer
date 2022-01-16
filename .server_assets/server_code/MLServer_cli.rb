loop do
	print "MLServer> "
	full_command = CSV::parse_line(gets.chomp, col_sep: ' ')
	command = full_command[0].downcase
	if command == "exit"
		exit
	elsif command == "start"
		if full_command[1]
			if File.directory?(full_command[1])
				if File.exist?(full_command[1] + "/main.rb")
					require full_command[1] + "/main.rb"
				else
					puts "Error: '#{full_command[1] + "/main.rb"}' does not exist"
				end
			else
				puts "Error: '#{full_command[1]}' is not a directory"
			end
		else
			puts "Invalid syntax: command 'start' requires (1) argument: directory of program"
		end
	else
		puts "Invalid command '#{command}'"
	end
end