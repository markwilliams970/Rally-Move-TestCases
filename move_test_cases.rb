# Copyright 2002-2012 Rally Software Development Corp. All Rights Reserved.

require 'rally_api'
require 'csv'

$my_base_url       = "https://rally1.rallydev.com/slm"
$my_username       = "user@company.com"
$my_password       = "password"
$my_workspace      = "My Workspace"
$my_project        = "My Project"
$wsapi_version     = "1.40"
$filename          = 'move_test_cases.csv'

# Load (and maybe override with) my personal/private variables from a file...
my_vars= File.dirname(__FILE__) + "/my_vars.rb"
if FileTest.exist?( my_vars ) then require my_vars end

# Load (and maybe override with) my personal/private variables from a file...
my_vars= File.dirname(__FILE__) + "/my_vars.rb"
if FileTest.exist?( my_vars ) then require my_vars end

def move_testcase(header, row)
  test_case_formatted_id                   = row[header[0]].strip
  target_test_folder_formatted_id          = row[header[2]].strip

  # Lookup Target Test Folder
  target_test_folder_query = RallyAPI::RallyQuery.new()
  target_test_folder_query.type = :testfolder
  target_test_folder_query.fetch = "FormattedID,ObjectID,Name,Project,Name"
  target_test_folder_query.query_string = "(FormattedID = \"" + target_test_folder_formatted_id + "\")"

  target_test_folder_query_result = @rally.find(target_test_folder_query)

  if target_test_folder_query_result.total_result_count == 0
    puts "Target Test Folder: #{target_test_folder_formatted_id} not found. Target must exist before moving."
    puts "Skipping Test Case: #{test_case_formatted_id}."
    return nil
  end

  # Lookup test case to move
  test_case_query = RallyAPI::RallyQuery.new()
  test_case_query.type = :testcase
  test_case_query.fetch = "FormattedID,ObjectID,TestFolder,Project,Name"
  test_case_query.query_string = "(FormattedID = \"" + test_case_formatted_id + "\")"

  test_case_query_result = @rally.find(test_case_query)

  if test_case_query_result.total_result_count == 0
    puts "Test Case #{test_case_formatted_id} not found...skipping"
  else
    begin
      test_case_toupdate = test_case_query_result.first()
      target_test_folder =   target_test_folder_query_result.first()

      target_project = target_test_folder["Project"]
      target_project_name = target_project["Name"]

      source_project = test_case_toupdate["Project"]
      source_project_name = source_project["Name"]

      # Test if the source project and target project are the same
      # if target project string is empty - assume that
      source_target_proj_match = source_project_name.eql?(target_project_name)

      # If the target Test Folder is in a different Project, we have to do some homework first:
      # "un-Test Folder" the project
      # Assign the Test Case to the Target Project
      # Assign the Test Case to the Target Test Folder
      if !source_target_proj_match then
        fields = {}
        fields["TestFolder"] = ""
        test_case_updated = @rally.update(:testcase, test_case_toupdate.ObjectID, fields) #by ObjectID
        puts "Test Case #{test_case_formatted_id} successfully dissociated from: #{target_test_folder_formatted_id}"

        # Get full object on Target Project and assign Test Case to Target Project
        target_project.read
        fields = {}
        fields["Project"] = target_project
        test_case_updated = @rally.update(:testcase, test_case_toupdate.ObjectID, fields) #by ObjectID
        puts "Test Case #{test_case_formatted_id} successfully assigned to Projects: #{target_project_name}"

      end

      # Change the Test Folder attribute on the Test Case
      fields = {}
      fields["TestFolder"] = target_test_folder
      test_case_updated = @rally.update(:testcase, test_case_toupdate.ObjectID, fields) #by ObjectID
      puts "Test Case #{test_case_formatted_id} successfully moved to #{target_test_folder_formatted_id}"


    rescue => ex
      puts "Test Case #{test_case_formatted_id} not updated due to error"
      puts ex
    end
  end
end

begin
  #==================== Making a connection to Rally ====================
  config                  = {:base_url => $my_base_url}
  config[:username]       = $my_username
  config[:password]       = $my_password
  config[:workspace]      = $my_workspace
  config[:project]        = $my_project
  config[:version]        = $wsapi_version

  @rally = RallyAPI::RallyRestJson.new(config)

  input  = CSV.read($filename)

  header = input.first #ignores first line

  rows   = []
  (1...input.size).each { |i| rows << CSV::Row.new(header, input[i]) }

  rows.each do |row|
    move_testcase(header, row)
  end
end