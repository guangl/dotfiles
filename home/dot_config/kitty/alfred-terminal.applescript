on alfred_script(query)
	set homeDirectory to POSIX path of (path to home folder)
	set launchCommand to "/usr/bin/open -n -a /Applications/kitty.app --args --single-instance --start-as=maximized --directory " & quoted form of homeDirectory
	if query is not "" then
		-- Keep the command's working directory in the interactive shell.
		set shellCommand to query & linefeed & "exec /bin/zsh -il"
		set launchCommand to launchCommand & " -- /bin/zsh -ilc " & quoted form of shellCommand
	end if
	do shell script launchCommand
end alfred_script
