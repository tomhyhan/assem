s = set()
lines = open("input.txt").read().split('\n')
from functools import lru_cache

class Directory:
  def __init__(self, name, parent=None):
    self.parent = parent
    self.childdirs = {}
    self.name = name
    self.size = 0
  
  def add_childdir(self, name, parentdir):
    self.childdirs[name] = Directory(name, parentdir)
  
  def get_childdir(self, name):
    return self.childdirs[name] 
  
  def add_size(self, size):
    self.size += size
  
  def __repr__(self):
    return f"{self.name} {self.size} {self.childdirs}"

  @lru_cache(maxsize=None)
  def get_total_size(self):
    return self.size + sum([c.get_total_size() for c in self.childdirs.values()])


class FileSystem:
  def __init__(self, lines):

    curr_dir = Directory('/')
    self.root = curr_dir
        
    for line in lines[1:]:
      ins = line.split(' ')
      if ins[0] == '$':
        if ins[1] == "cd":
          dirname = ins[2]
          curr_dir = curr_dir.get_childdir(dirname) if dirname != ".." else curr_dir.parent
        elif ins[1] == "ls":
          pass
      else:
        if ins[0] == "dir":
          curr_dir.add_childdir(ins[1], curr_dir)
        elif ins[0].isdigit():
          curr_dir.add_size(int(ins[0]))
  
  def sum_total_size_lt_100000(self):
    size = 0    
    current = [self.root]
    while current:
      curr = current.pop()
      for c in curr.childdirs.values():
        sz = c.get_total_size()
        print(sz)
        if sz <= 100000:
          size += sz
        current.append(c)
    return size

  def delete(self):
    # 30000000
    total_size = self.root.get_total_size()
    size = float('inf')    
    current = [self.root]
    while current:
      curr = current.pop()
      for c in curr.childdirs.values():
        sz = c.get_total_size()
        if 70000000 - (total_size - sz) > 30000000:
          size = min(size, sz)
        current.append(c)
    return size

fs = FileSystem(lines)
print(fs.sum_total_size_lt_100000())
print(70000000)
print(fs.delete())

# print(f"Cache Info: {fs.root.get_total_size.cache_info()}") 