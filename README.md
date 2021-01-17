# Privex PyScan

PyScan is a BASH shellscript is intended to be used within a **bi-lingual shellscript/python** file - which runs a self-contained
Python script with the latest available Python interpreter, auto-installs dependencies (DEPS), and auto-installs
multiple Python versions if the minimum version isn't available.

PyScan is designed to be used as a wrapper around an existing Python executable, generally the entrypoint (main executable)
to your Python application. It avoids the age old issue of an OS shipping with Python 3.6, but your application needs Python 3.7 or 3.8,
and you don't want to just set the shebang to `#!/usr/bin/env python3.8` since it will lock your executable to that version.

The script will try to guarantee that newer versions of Python will be available on the system during the first run, without needing
the user to manually install various Python versions, update the app's shebang, or run the app manually with a certain python version exe.

```yml
+===================================================+
|                 © 2021 Privex Inc.                |
|               https://www.privex.io               |
+===================================================+
|                                                   |
|        PyScan                                     |
|        License: X11/MIT                           |
|                                                   |
|        Core Developer(s):                         |
|                                                   |
|          (+)  Chris (@someguy123) [Privex]        |
|          (+)  Kale (@kryogenic) [Privex]          |
|                                                   |
+===================================================+

PyScan - A **bi-lingual shellscript/python** file - which runs a self-contained Python script with the latest available 
         Python interpreter, auto-installs dependencies (DEPS), and auto-installs multiple Python versions if the 
         minimum version isn't available.

Copyright (c) 2021    Privex Inc. ( https://www.privex.io )
```

## Quickstart

```sh
# Clone the repo
git clone https://github.com/Privex/pyscan.git
# Combine pyscan.sh with your Python script, ensuring that pyscan.sh is first,
# and your python script is appended to the BOTTOM of the new file.
cat pyscan/pyscan.sh my_script.py > wrapped.py
#######
# - Adjust 'DEPS' to contain a list of essential Python packages used by your application
#
# - Adjust MIN_VER to be the minimum version your script needs to run, e.g. 3070 for 3.7, 3080 for 3.8.
#
# - If your script uses Python 3.7 dataclasses, but is otherwise compatible with 3.6, then ensure
#   that USE_DATACLASSES is set to 1 - this will install the 'dataclasses' package only if 3.6 is the
#   only available Python interpreter version.
nano wrapped.py
#####
# Make your script executable and run it / distribute it :)
chmod +x wrapped.py
./wrapped.py
####
# If something seems to be going wrong with PyScan, set DEBUG=1 to enable debugging
# output, which verbosely outputs debug log messages, so you can track where it went wrong.
DEBUG=1 ./wrapped.py
```

## How it works

- Scans for the executables `python3.10`, `python3.9`, `python3.8`, `python3.7`, `python3.6` and `python3`
  to determine the current highest available python version

- If the latest installed version is older than `MIN_VER` (default: `3060` which is `3.6`), then it will
  detect the OS and package manager, and attempt to automatically install every Python version available,
  from Python 3.6 to Python 3.9 automatically using the package manager.

- Once the latest available interpreters are ready, it scans the executables again, and will auto-install any required dependencies
  (if not already installed) via `python3.x -m pip install DEP` for each dependency - using the latest available Python interpreter

- If the minimum Python version is met, and all required Python packages are installed, then it will re-execute itself with
  the latest available Python executable, automatically.

## Supported OS's for automatic interpreter installation

- Debian Based distros via `apt-get` or `apt`
  - Ubuntu 16.04 to 20.04
  - Debian 10
  - Other debian based distros, probably
- Redhat Based distros via `dnf` or `yum`
  - CentOS 8 (and probably 7 too)
  - Redhat Enterprise Linux (RHEL) 8 (and probably 7 too)
  - Fedora 33
  - Oracle Linux 8.3 (and probably 7 too)
- Alpine Linux via `apk`
- Mac OS X (macOS) via `brew`

## Experimenting with Docker

Included with the project is an example Python script, which is wrapped by `pyscan.sh`, at `examples/hello.py`

Inside of `docker` are several different containers that will compile the project into a docker container, using a certain
OS that you can test on.

For example, to build this project into an Ubuntu 20.04 image + container:

```sh
docker build -t pyscan -f docker/ubuntu/Dockerfile .
docker run --rm -it pyscan
```

To build this project into an CentOS 8 image + container:

```sh
docker build -t pyscan:centos -f docker/centos8/Dockerfile .
docker run --rm -it pyscan:centos
```

To build this project into an Oracle Linux 8 image + container:

```sh
docker build -t pyscan:oracle -f docker/oracle/Dockerfile .
docker run --rm -it pyscan:oracle
```

At the bash prompt, you'll be in the folder `/app` where the project is stored.

You can run the example script from there, on a mostly blank container, where it won't affect your running system:

```sh
./examples/hello.py
```

## License

Released under the X11 / MIT license


Please see the file `LICENSE.txt` or `LICENSE` for full license text.

## Thanks for reading!

**If this project has helped you, consider [grabbing a VPS or Dedicated Server from Privex](https://www.privex.io) -**
**prices start at as little as $0.99/mo USD (we take cryptocurrency!)**
