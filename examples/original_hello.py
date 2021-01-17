
import sys
from collections import namedtuple
from datetime import datetime
from time import sleep
from rich import print

def hello():
    print('[bold][green]Hello world![/][/]')

if __name__ == "__main__":
    print("\n\n[bold][cyan] !!! ---- This is a Python application using the 'rich' library! ---- !!! [/][/]\n")
    hello()
    sleep(2)
    hello()
    print("\n[bold][cyan] !!! ---- This is a Python application using the 'rich' library! ---- !!! [/][/]\n\n")
