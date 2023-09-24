*** Settings ***
Documentation    A Unix Shell test suite
Library          ShellLibrary.py
Library          String
Library          Collections
Library          OperatingSystem

*** Variables ***
# shell_name should be the name of the binary being tested.
# shell should be the relative path to that binary
# bash can be changed to the name of another reference shell
${shell_name}        42sh
${shell}             .././${shell_name}
${bash}              /bin/bash
${diff_OK}           ${0}

${TEMP_DIR}          temp
${echo_file_path}    test_cases/echo_test_cases.txt
${redir_file_path}    test_cases/redirection_test_cases.txt

# TODO
# Good beginner tasks
# (let Alex know if you want to work on something and he'll allocate it to you.
# Or if you want to help out with a task that's already been taken, you can just
# reach out to that student directly):

# Add more test case files and implement with new test cases - Linh

# skip cases if the line begins with a # symbol

# errors will need to be handled differently due to differences in text of err message
#  - Using python to chop out the relevant part of the message text might be the best way forward

# Find a minishell implementation that works with existing bash script to test this on

# add some basic tests for norminette and Makefile/compiling without errors

# exit tests will need to be handled slightly differently because of how bash prints 'exit'

# the hard-coded path to the bash binary in the ${bash} variable may not work on some
# systems. There should be a function to locate the ref shell when assigning that
# variable

# More advanced stuff, or stuff that is either lower priority or bottle-necked:
# Come up with a better process for task allocation
# add a bit of visual pizazz to the console logs, now are a bit stale and hard to read
# A different testing process will be required to check redirections are working properly - Alex
# env argument of run() can be used to test environment and variable things
# Move keywords to a separate resources file
# To look into:
# how to run specific test cases in rfw
# how to run all tests, not stopping when a case fails.
*** Test Cases ***
Test Builtin Echo
    [Documentation]    Testing for the builtin function 'echo'
    @{ECHO}=           Get test cases    ${echo_file_path}
    Simple command test loop             @{ECHO}

Test Redirections
    [Documentation]    Testing redirection functionality
    @{REDIR}=          Get test cases    ${redir_file_path}
    redirection test loop                @{REDIR}

*** Keywords ***
# TODO
# add a test step which compares the contents of the output files
# change permissions of invalid_permission files
Redirection test loop
    [Documentation]    Creates files to receive redirected output during set-up
    ...                then deletes them after they have been checked.
    ...                Simple command keyword is used to execute the test case
    [Arguments]        @{CASES}

    # just for debugging readability
    log                \n    console=yes

    FOR    ${case}    IN    @{CASES}
        Simple Command    ${case}
        # check files
        Delete redirection files
    END

Simple command test loop
    [Documentation]    Takes a list of test cases and runs them using Simple Command
    [Arguments]        @{CASES}

    # just for debugging readability
    log                \n    console=yes

    FOR    ${case}    IN    @{CASES}
        Simple Command    ${case}
    END

Get test cases
    [Documentation]    Reads test case file given as argument and returns them
    ...                in list format
    [Arguments]        ${path}
    ${cases}=          Get file          ${path}
    @{case_list}=      Split to lines    ${cases}
    RETURN             @{case_list}

Simple command
    [Documentation]    Sends a command to the test shell and compares its output and
    ...                return values with the reference shell
    [Arguments]        ${test_case}
    ${shell_result}    Command            ${test_case}       ${shell}
    ${bash_result}     Command            ${test_case}       ${bash}
    Dictionaries should be equal          ${shell_result}    ${bash_result}

Command
    [Documentation]    Takes a command line string and runs it in the specified shell
    ...                Returns a dictionary containing any outputs and the return value.
    # rename arg_string to command_line for clarity
    [Arguments]        ${arg_string}      ${target_shell}
    ${result}          run command        ${arg_string}      ${target_shell}
    RETURN             ${result}

Delete redirection files
    [Documentation]    Removing files containing redirected outputs
    Remove File        redirection_files/output_files/outfile01_bash
    Remove File        redirection_files/output_files/outfile01_test
    Remove File        redirection_files/output_files/outfile02_bash
    Remove File        redirection_files/output_files/outfile02_test
    Remove File        redirection_files/output_files/12345_bash
    Remove File        redirection_files/output_files/12345_test