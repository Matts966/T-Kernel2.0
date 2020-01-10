# e.g.)
# 100.1
# 123.2
# 124.2
# 122.2
# 121.2
import sys

sum = 0.0
count = 0

for line in sys.stdin:
    count += 1
    sum += float(line)

sys.stdout.write(str(sum / count))
