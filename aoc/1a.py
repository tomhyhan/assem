
with open("./input.txt") as f:
  data = f.read().split('\n\n')

max_num = 0

for line in data:
  print(line.split('\n'))

ret = max([sum(map(int, line.split('\n'))) if line else 0 for line in data])
print(ret, hex(ret))
  