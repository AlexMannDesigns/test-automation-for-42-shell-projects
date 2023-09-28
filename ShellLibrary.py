from robot.api.logger import info, debug, trace, console
from subprocess import run, PIPE, Popen, TimeoutExpired
from os import path

#### GLOBAL SCOPE VARIABLES ####

# timeout in seconds for tests
TIMEOUT = 5
# echo command being used to write command-line to pipe
ECHO = "echo"
# name of reference shell
REF_SHELL = "bash"
# files used in redirections
INPUT_REDIRECTION_FILES = {
        "input_file": "./redirection_files/input_file",
        "input_big_file": "./redirection_files/input_big_file",
        "missing": "./redirection_files/missing",
        "input12345": "./redirection_files/input""1""2""3""4""5",
        "file name with spaces": "./redirection_files/file name with spaces"
    }
OUTPUT_REDIRECTION_FILES = {
        "outfile01": "./redirection_files/output_files/outfile01",
        "outfile02": "./redirection_files/output_files/outfile02",
        "outfile_spaces": "./redirection_files/output_files/outfile with spaces",
        "invalid_permission" : "./redirection_files/output_files/invalid_permission",
        "outfile12345": "./redirection_files/output_files/""1""2""3""4""5"
    }


#### FUNCTIONS ####

def error_message_handling(error_output: str):
    """
        Placeholder for now. Will edit out the start of the error
        message text so that the pertinent part of the message
        can be properly compared to the ref shell.
    """
    return ""


def result_dict_constructor(case: str = None,
                            output: str = None,
                            error_output: str = None,
                            return_value: int = None) -> dict:
    """
        Standardising the returned object from test cases.
        Implementing it this way allows for use of default values.
    """
    # error message handling should probably go here, just returning an empty string for now
    editted_error_output = error_message_handling(error_output)
    return dict(
        case=case,
        output=output,
        error_output=editted_error_output,
        return_value=return_value
    )


def redirection_set_up(command_line: str, shell_path: str) -> str:
    """
        Checks the string for redirection file names, replaces them with
        file paths and returns the updated string

        Given that strings are immutable in python, we have to create
        copies in a loop.
    """
    file_name_end = REF_SHELL if REF_SHELL in shell_path else "test"

    for key in INPUT_REDIRECTION_FILES.keys():
        file = INPUT_REDIRECTION_FILES[key]
        command_line = command_line.replace(key, file)

    for key in OUTPUT_REDIRECTION_FILES.keys():
        file = f"{OUTPUT_REDIRECTION_FILES[key]}_{file_name_end}"
        command_line = command_line.replace(key, file)

    return command_line


def run_redirection_command(command_line: str, shell_path: str) -> dict:
    """
        Wrapper function for run_command, which handles the set up for redirection
        tests.
        Command line will differ after it has been expanded with the actual file
        paths - so the original case is saved and added to the result for ease of
        reference.
    """
    original_command_line = command_line
    command_line = redirection_set_up(command_line, shell_path)
    result = run_command(command_line, shell_path)
    result["case"] = original_command_line

    return result


def run_command(command_line: str, shell_path: str) -> dict:
    """
        Runs the given "command_line" in the shell identified by "shell_path"

        Popen executes a child process. For our purposes, we are echo-ing the
        test case specified in command_line onto a pipe, which can then be read
        by the shell.

        run function: https://docs.python.org/3/library/subprocess.html#subprocess.run
        Run returns a class instance from which we can access the necessary
        outputs and return values for the purposes of testing.
    """
    ps = Popen((ECHO, command_line), stdout=PIPE)

    try:
        result = run(
            shell_path,
            capture_output=True,
            stdin=ps.stdout,
            #text=True, # True returns a string, False returns byte-code
            timeout=TIMEOUT,
            )
    except TimeoutExpired:
        console(f"case: {command_line}: Timeout expired, please review")
        return result_dict_constructor(case=command_line)

    # These are just here for safety, but will almost always never be needed.
    # ps is only being used to run "echo", so should exit before run()
    # but just in case, we ensure it gets a SIGPIPE and then we wait for it to finish
    ps.stdout.close()
    ps.wait(timeout=TIMEOUT)

    # debugging
    console(f'\ncase: {command_line} | shell = {shell_path}')
    console(f"return = {result.returncode}")
    console(f"output = {result.stdout}")
    console(f"error = {result.stderr}")

    return result_dict_constructor(
        case=command_line,
        output=result.stdout,
        # just for testing while better error message comparison has not been implemented
        error_output=result.stderr,
        return_value=result.returncode
        )


def file_exists(file_path: str) -> bool:
    """
        Takes a file path and returns true if it exists.
    """
    return path.isfile(file_path)
