Rally-Move-TestCases
====================

- Configuring and Using the Move Test Cases Script

- Create directory for script and associated files:

- C:\Users\username\Documents\Rally Move Test Cases\ 

- Download the move_test_cases.rb script and the move_test_cases.csv file to the above directory
 

- Create your Test Case file. It must be a plain text CSV file with the following fields/format:
<pre>
Test Case FormattedID,Test Case Name, Target Test Folder FormattedID, Target Test Folder Name
TC327,TC07-012-006,TF11,Couloir Wind Raster Load Tests
</pre>
- The script will move the Test Case with the Formatted ID matching that in the first comma-separated column, to the Test Folder with Formatted ID matching that in the third comma-separated column. If the script lookup against Rally for either the Test Case or Target Test Folder fails to find the object of interest in Rally, it will skip that row and move on.

- Using a text editor, customize the code parameters in the my_vars.rb file for your environment.
 <pre>
	my_vars.rb:
	
	$my_base_url                     = "https://rally1.rallydev.com/slm"
	$my_username                     = "user@company.com"
	$my_password                     = "topsecret"
	$my_workspace                    = "My Workspace"
	$my_project                      = "My Project"
	$wsapi_version                   = "1.40"
	$filename                        = "move_test_cases.csv"
</pre>


- Run the script.
<pre>
C:\> ruby move_test_cases.rb
Test Case TC327 successfully moved to TF8
Test Case TC328 successfully moved to TF8
Test Case TC329 successfully moved to TF8
Test Case TC330 successfully moved to TF8
Test Case TC331 successfully moved to TF8
Test Case TC332 successfully moved to TF8
Test Case TC333 successfully moved to TF8
Test Case TC334 successfully moved to TF8
</pre>

This will update the Test Folder for ALL TEST CASES listed in the move_test_cases.csv file.

Please Note: Please be CAUTIOUS WHEN USING THIS SCRIPT. We recommend testing any critical changes 
in a sandbox environment first, before running against a production server!