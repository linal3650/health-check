#!/usr/bin/env python3

import shutil, psutil, requests, socket

def check_localhost():
    """ Translates a host name to IPv4 address format, pass the parameter localhost to function gethostbyname """
    localhost = socket.gethostbyname('localhost')
    if localhost == '127.0.0.1':
        return True

def check_connectivity():
    """ Check if computer can make successful calls to the internet """
    request = requests.get("http://www.google.com")
    if request.status_code == 200:
        return True

def check_disk_usage(disk):
    """Verifies that there's enough free space on disk"""
    du = shutil.disk_usage(disk)
    free = du.free / du.total * 100
    return free > 20

def check_cpu_usage():
    """Verifies that there's enough unused CPU"""
    usage = psutil.cpu_percent(1)
    return usage < 75

if not check_disk_usage('/') or not check_cpu_usage():
    print("ERROR!")
elif check_localhost() and check_connectivity():
    print("Everything ok")
else:
    print("Network checks failed")
 
