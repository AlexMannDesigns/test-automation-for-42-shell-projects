# Test Automation Suite for 42 School Shell Projects

🚧 In progress 🚧

A test automation suite for Minishell and 42sh, implemented using modern, python testing tools. Namely [Robot Framework](https://robotframework.org/).

## Installation:

Please be VERY CAREFUL when installing python packages. It is rarely advisable to install python packages globally, as this can mess up python dependancies that other software on your machine is using.

For a nice overview of python virtual environments, I recommend you read [this article](https://realpython.com/python-virtual-environments-a-primer/). Or just [RTFM](https://docs.python.org/3/library/venv.html).

The tldr version of the command line you need (for mac and linux):

1. Set up your virtual environment (I suggest doing this in the root dir of the project):
```
$ python3 -m venv venv 
```
2. Activate your virtualenv - Hint: you should see `(venv)` before the command line prompt in the terminal after running this:
```
$ source venv/bin/activate
```
3. Install the Robot Framework (make sure your venv is DEFINITELY active, see the hint above):
```
(venv) $ python -m pip install robotframework
```
That's it! When you're done working on this project, deactivate the venv by using... deactivate:
```
(venv) $ deactivate
```
Check it installed properly by running the following command with your venv active and inactive. This command should not work when your venv is not active if you followed the above steps correctly:
```
(venv) $ robot --version
```
## Want to contribute to this project?

That's great! See the TODO list under tests.robot to check out what needs doing - or if you have another suggestion to improve the project, just let me know! (email: alex.mann.designs@gmail.com)

TODO: create a better system for managing contributions 😏
