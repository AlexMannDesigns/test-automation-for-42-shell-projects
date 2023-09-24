from robot.api.logger import info, debug, trace, console
from subprocess import run, PIPE, Popen, TimeoutExpired

# timeout in seconds for tests
TIMEOUT = 5
# echo command being used to write command-line to pipe
ECHO = "echo"
# name of reference shell
REF_SHELL = "bash"


def result_dict_constructor(case: str = None,
                            output: str = None,
                            error_output: str = None,
                            return_value: int = None) -> dict:
    """
        Standardising the returned object from test cases.
        Implementing it this way allows for use of default values.
    """
    return dict(
        case=case,
        output=output,
        error_output=error_output,
        return_value=return_value
    )

def redirection_set_up(command_line: str, shell_path: str) -> str:
    """
        Checks the string for redirection file names, replaces them with
        file paths and returns the updated string

        Given that strings are immutable in python, we have to create
        copied in a loop.
    """
    input_redirection_files = {
        "input_file": "./redirection_files/input_file",
        "input_big_file": "./redirection_files/input_big_file",
        "missing": "./redirection_files/missing",
        "input12345": "./redirection_files/input""1""2""3""4""5",
        "file name with spaces": "./redirection_files/file name with spaces"
    }
    output_redirection_files = {
        "outfile01" : "./redirection_files/output_files/outfile01",
        "outfile02" : "./redirection_files/output_files/outfile02",
        "invalid_permission" : "./redirection_files/output_files/invalid_permission",
        "outfile12345": "./redirection_files/output_files/""1""2""3""4""5"
    }
    for key in input_redirection_files.keys():
        command_line = command_line.replace(key, input_redirection_files[key])
    for key in output_redirection_files.keys():
        path = key in command_line
        if path and REF_SHELL in shell_path:
           command_line = command_line.replace(key, f"{output_redirection_files[key]}_{REF_SHELL}")
        elif path:
            command_line = command_line.replace(key, f"{output_redirection_files[key]}_test")
    return command_line

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
    # command line will differ slightly due to different redir file paths used
    original_command_line = command_line
    command_line = redirection_set_up(command_line, shell_path)

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
        console(f"case: {original_command_line}: Timeout expired, please review")
        return result_dict_constructor(case=original_command_line)

    # These are just here for safety, but will almost always never be needed.
    # ps is only being used to run "echo", so should exit before run()
    # but just in case, we ensure it gets a SIGPIPE and then we wait for it to finish
    ps.stdout.close()
    ps.wait(timeout=TIMEOUT)

    # debugging
    console(f'\ncase: {original_command_line} | shell = {shell_path}')
    console(f"return = {result.returncode}")
    console(f"output = {result.stdout}")
    console(f"error = {result.stderr}")

    return result_dict_constructor(
        case=original_command_line,
        output=result.stdout,
        error_output=result.stderr,
        return_value=result.returncode
        )
