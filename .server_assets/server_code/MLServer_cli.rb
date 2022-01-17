loop do
	print "MLServer> "
	full_command = CSV::parse_line(gets.chomp, col_sep: ' ')
	if full_command && full_command[0]
		command = full_command[0].downcase
	elsif full_command && !full_command[0] && full_command[1]
		command = ""
	else
		command = ""
	end
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
	elsif command == "ver"
		puts $ver
	elsif command == "update_check"
		path = "./#{$0}"
		puts "Fetching latest version"
		newver = Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/Matthiasclee/MLServer/main/server.rb"))
		if newver != File.read(path)
			print "A new version is available (#{eval Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/Matthiasclee/MLServer/main/server.rb")).split("\n")[0].sub("$", "new_")}) Confirming update (Y/n) "
			if gets.chomp.downcase == "y"
				print "Writing new version... "
				begin
					File.write(path, newver)
					puts "Done!"
				rescue
					puts "Fail"
					puts "Oops, something went wrong."
				end
				puts "Updated, please restart the program."
				exit
			else
				puts "Update cancelled"
			end
		else
			puts "You are using the latest version (#{$ver})"
		end
	elsif command == ""
	else
		puts "Invalid command '#{command}'"
	end
end