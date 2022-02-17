
import re

def myfunc(n):
  return lambda a : a * n
  
def check(str, re_pattern):
	pattern = re.compile(re_pattern)
	# _matching the strings
	if re.search(pattern, str):
		print(f"str={str}, regex_pattern={re_pattern}: => Valid String")
	else:
		print(f"str={str}, regex_pattern={re_pattern}: => Invalid String")

if __name__ == '__main__':
    # _driver code
    re_pattern='^[1234]+$'
    pattern = re.compile(re_pattern)
    check('2134', re_pattern)
    check('349', re_pattern)

    mydoubler = myfunc(2)
    mytripler = myfunc(3)

    print(f"mydoubler(11)=> {mydoubler(11)}")
    print(f"mydoubler(11)=> {mytripler(11)}")

