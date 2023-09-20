from robot.api.logger import info, debug, trace, console
from subprocess import run, PIPE, Popen

# timeout in seconds for tests
TIMEOUT = 5
ECHO = "echo"

def run_command(arg_string: str, shell_path: str) -> dict:
    """
        Runs the given "arg_string" in the shell identified by "shell_path"

        Popen executes a child process. For our purposes, we are echo-ing the
        test case specified in arg_string onto a pipe, which can then be read
        by the shell.

        run function: https://docs.python.org/3/library/subprocess.html#subprocess.run
        Run returns a class instance from which we can access the necessary
        outputs and return values for the purposes of testing.
    """
    ps = Popen((ECHO, arg_string), stdout=PIPE)

    result = run(
        shell_path,
        capture_output=True,
        stdin=ps.stdout,
        #text=True, # True returns a string, False returns byte-code
        timeout=TIMEOUT,
        )

    ps.wait(timeout=TIMEOUT)

    # debugging
    console(f'\ncase: {arg_string} | shell = {shell_path}')
    console(f"return = {result.returncode}")
    console(f"output = {result.stdout}")
    console(f"error = {result.stderr}")

    return dict(
        output=result.stdout,
        err_output=result.stderr,
        return_value=result.returncode
        )
