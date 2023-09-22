from robot.api.logger import info, debug, trace, console
from subprocess import run, PIPE, Popen, TimeoutExpired

# timeout in seconds for tests
TIMEOUT = 5
# echo command being used to write command-line to pipe
ECHO = "echo"

def result_dict_constructor(case: str = None, output: str = None,
                            error_output: str = None, return_value: int = None) -> dict:
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
        error_output=result.stderr,
        return_value=result.returncode
        )
