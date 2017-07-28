#!c:\python27\python.exe

import re
import sys
import os
from datetime import date

skipdir = { '.git', '.bzr', 'zlib', 'obj', 'bin', 'MySql.EMTrace', 'Samples', 'Message', 'v4.x' }
skipfile = { 'check_copyright.py' }
year = str(date.today().year)
error = False

def should_skip_dir(dir):
  lower_dir = dir.lower()
  for dir_to_skip in skipdir:
    if lower_dir.find(dir_to_skip.lower()) > -1:
      return True
  return False

def should_skip_file(file):
  lower_file = os.path.basename(file.lower())
  for file_to_skip in skipfile:
    if file_to_skip.lower() in lower_file:
      return True
  return False


#files = os.popen("git diff --name-only --diff-filter=ACMRTUXB").read().splitlines(True)
files = os.popen("git status -uno --porcelain").read().splitlines(True)
for file in files:
  status = file[0:2].strip()
  filename = file[2:].strip()
  if status == 'R' or status == 'D' or should_skip_file(filename) :
    continue

  with open(filename) as f:
    file_content = f.readlines()

  for line in file_content:
    if line.find("Copyright") == -1:
      continue
    if line.find(year) == -1:
      print filename + ' does not have an updated copyright date'
      error = True

if error:
  sys.exit(1)

sys.exit(0)
