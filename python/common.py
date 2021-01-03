import os
import sys
import json
import subprocess

from cf import C

def queit():
  return C['queit']

def verbose():
  return C['verbose']

def dry():
  return C['dry']

def shell(s):
  if dry():
    print(s)
    return

  if verbose():
    print(f"+ CMD: {s}")
  os.system(s)

sh = shell

def cmd(*kv):
  if verbose():
    print(f"+ CMD: {' '.join(kv)}")
  return subprocess.run(kv)

def buildah_run(cname):
  def runner(args):
    sh(f'buildah run {cname} {args}')
  return runner

def command_line():
  argv = sys.argv[1:]
  while argv:
    arg = argv.pop(0)
    if arg == 'dry':
      C['dry'] = True

# vim: ts=2 sts=2 ai expandtab
