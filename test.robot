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
${SHELL_NAME}              42sh
${SHELL}                   .././${SHELL_NAME}
${BASH}                    /bin/bash

${ECHO_FILE_PATH}          test_cases/echo_test_cases.txt
${REDIR_FILE_PATH}         test_cases/redirection_test_cases.txt
${REDIR_PIPE_FILE_PATH}    test_cases/redirection_test_cases_with_pipes.txt
${REDIR_AGGR_FILE_PATH}    test_cases/file_descriptor_aggregation_tests.txt

@{OUTPUT_FILES}=           outfile01    outfile02    outfile03    outfile04    outfile05    outfile with spaces    12345
${OUTPUT_FILE_PATH}        ./redirection_files/output_files

${INVALID_FILE_BASH}       ./redirection_files/output_files/invalid_permission_bash
${INVALID_FILE_TEST}       ./redirection_files/output_files/invalid_permission_test


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

# the hard-coded path to the bash binary in the ${BASH} variable may not work on some
# systems. There should be a function to locate the ref shell when assigning that
# variable

# Git does not fully track file permissions (chmod) only the execution rights.
# Add a step to redirection testing to set the permissions of invalid_permission files
# in output to read-only (444)

# More advanced stuff, or stuff that is either lower priority or bottle-necked:
# Come up with a better process for task allocation
# add a bit of visual pizazz to the console logs, now are a bit stale and hard to read
# env argument of run() can be used to test environment and variable things
# Move keywords to a separate resources file
# To look into:
# how to run specific test cases in rfw
# how to run all tests, not stopping when a case fails.
*** Test Cases ***
Test Builtin Echo
    [Documentation]    Testing for the builtin function 'echo'

    @{echo_case_list}=          Get test cases    ${ECHO_FILE_PATH}

    Simple command test loop    @{echo_case_list}


Test Redirections
    [Documentation]    Testing redirection functionality

    @{redir_case_list}=      Get test cases    ${REDIR_FILE_PATH}

    Redirection test loop    @{redir_case_list}


Test Redirections with Pipes
    [Documentation]    Testing redirection functionality again, but these require pipes
    ...                to have been implemented correctly in the tested shell

    @{redir_pipe_case_list}=    Get test cases    ${REDIR_PIPE_FILE_PATH}

    Redirection test loop       @{redir_pipe_case_list}


Test Redirections and File Descriptor Aggregation
    [Documentation]    Testing redirection functionality yet again, but these cases
    ...                include file descriptor aggregation '>&'

    @{redir_aggr_case_list}=    Get test cases    ${REDIR_AGGR_FILE_PATH}

    Redirection test loop      @{redir_aggr_case_list}


*** Keywords ***
Redirection test loop
    [Documentation]    Runs commands using the underlying redirection wrapper.
    ...                The created output files are then checked for equality and
    ...                then deleted in each iteration.
    ...                Finally, the output file directory is checked for any files
    ...                created in error.
    [Arguments]        @{case_list}

    # just for debugging readability
    log                \n    console=yes

    FOR    ${case}    IN    @{case_list}
        
        sleep                      ${0.1}
        Redirection Command        ${case}
        Check output files
        Delete redirection files
        Check output directory

    END


Check output directory
    [Documentation]    After the redirection test files have been deleted, there should
    ...                only be the two permission files remaining in that directory.

    ${Number_of_files}    Count items in directory    ${OUTPUT_FILE_PATH}
    Should be equal       ${Number_of_files}          ${2}


Check output files
    [Documentation]    Loops through the files in the output_files directory and checks
    ...                the content of the bash files matches that of the test shell files

    FOR    ${file}    IN    @{OUTPUT_FILES}

        ${bash_output_path}=    Set Variable      ${OUTPUT_FILE_PATH}/${file}_bash
        ${test_output_path}=    Set Variable      ${OUTPUT_FILE_PATH}/${file}_test

        ${bash_exists}=         file exists       ${bash_output_path}
        ${test_file_exists}=    file exists       ${test_output_path}

        Should be equal         ${bash_exists}    ${test_file_exists}

        Run Keyword if          ${bash_exists}    Check file contents    ${bash_output_path}    ${test_output_path}

    END

    Check file contents    ${INVALID_FILE_BASH}    ${INVALID_FILE_TEST}


Check file contents
    [Documentation]    Checks that a corresponding test file was created by the redirection
    ...                and that both files have identical contents
    [Arguments]        ${bash_output_path}    ${test_output_path}

    ${bash_file}=    Get file     ${bash_output_path}
    ${test_file}=    Get file     ${test_output_path}

    Should be equal as strings    ${bash_file}    ${test_file}


Simple command test loop
    [Documentation]    Takes a list of test cases and runs them using Simple Command
    [Arguments]        @{case_list}

    # just for debugging readability
    log                \n    console=yes

    FOR    ${case}    IN    @{case_list}

        Simple Command    ${case}

    END


Get test cases
    [Documentation]    Reads test case file given as argument and returns them
    ...                in list format
    [Arguments]        ${path}

    ${cases}=          Get file          ${path}
    @{case_list}=      Split to lines    ${cases}

    RETURN    @{case_list}


Simple command
    [Documentation]    Sends a command to the test shell and compares its output and
    ...                return values with the reference shell
    [Arguments]        ${test_case}

    ${shell_result}    run command    ${test_case}       ${SHELL}
    ${bash_result}     run command    ${test_case}       ${BASH}

    Dictionaries should be equal    ${shell_result}    ${bash_result}


Redirection command
    [Documentation]    Sends a command to the test shell via the redirection wrapper
    ...                function and compares its output and return values with the
    ...                reference shell
    [Arguments]        ${test_case}

    ${shell_result}    run redirection command    ${test_case}       ${SHELL}
    ${bash_result}     run redirection command    ${test_case}       ${BASH}

    Dictionaries should be equal    ${shell_result}    ${bash_result}


Delete redirection files
    [Documentation]    Removing files containing redirected outputs
    ...                The Remove File keyword does nothing if the file does not
    ...                exist. So we can safely loop through all OUTPUT_FILES,
    ...                without the need for extra checks.

    FOR    ${file}    IN    @{OUTPUT_FILES}

        Remove File    ${OUTPUT_FILE_PATH}/${file}_bash
        Remove File    ${OUTPUT_FILE_PATH}/${file}_test

    END
