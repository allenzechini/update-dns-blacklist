import argparse
import difflib

def do_diff(file1='', file2=''):
#   lines1 = ''
#   with open(file1) as f1:
#     for line in f1:
#       lines1 = lines1 + line
# 
#   lines2 = ''
#   with open(file2) as f2:
#     for line in f2:
#       lines2 = lines2 + line
  f1 = open(file1)
  f2 = open(file2)
  lines1 = f1.readlines()
  lines2 = f2.readlines()
  f2.close()
  f1.close()

  diff = difflib.HtmlDiff().make_file(lines1, lines2, 
                                      file1, file2,
                                      context=True, numlines=10)

  my_diff = "/tmp/named.conf.block.diff.html"
  with open(my_diff, 'w') as output:
    output.write(diff)
  output.close()

def main():
  parser = argparse.ArgumentParser()
  parser.add_argument('-f1', '--file1', help='First file to diff')
  parser.add_argument('-f2', '--file2', help='Second file to diff')
  args = parser.parse_args()

  if args.file1 == None or args.file2 == None:
    print('\nPlease pass two files to compare')
    return 1
  do_diff(args.file1, args.file2)

if __name__ == '__main__':
  main()

