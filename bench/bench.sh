#!/bin/bash -eu
tmpD=$(mktemp -d)

mkdir -p $tmpD/with-cache/full
mkdir -p $tmpD/with-cache/kernel
mkdir -p $tmpD/with-cache/user
mkdir -p $tmpD/with-cache/middleware
mkdir -p $tmpD/simple/full
mkdir -p $tmpD/simple/kernel
mkdir -p $tmpD/simple/user
mkdir -p $tmpD/simple/middleware
TIMEFORMAT=%R
ITERATION=20

# warmup
for ((i=1; i<=$ITERATION; i++)); do
    (cd .. && make build-without-cache)
done

# simple
for ((i=1; i<=$ITERATION; i++)); do
    docker builder prune -af

    git checkout 8ed83ee1ba89e7a46a6b5d7a3e59d4d16e48281e
    dir=$tmpD/simple/full
    (cd .. && { time make build-without-cache ; } 2> $dir/$i \
        && cat $dir/$i | tail -n1 >> $dir/result.txt)

    git checkout 24b1ec306ca4a8a488c7843d1ba5af74a4b32257
    dir=$tmpD/simple/kernel
    (cd .. && { time make build ; } 2> $dir/$i \
        && cat $dir/$i | tail -n1 >> $dir/result.txt)

    git checkout 530e81f4d886a8279e59be913afa7550abef8710
    dir=$tmpD/simple/middleware
    (cd .. && { time make build ; } 2> $dir/$i \
        && cat $dir/$i | tail -n1 >> $dir/result.txt)

    git checkout ff50e8edc3d24ac4ea48caf3b505df9cb814c768
    dir=$tmpD/simple/user
    (cd .. && { time make build ; } 2> $dir/$i \
        && cat $dir/$i | tail -n1 >> $dir/result.txt)
done

# with cache
for ((i=1; i<=$ITERATION; i++)); do
    docker builder prune -af

    git checkout 6d46c735b348ef56d60fe92df60f00bc9483d1a1
    dir=$tmpD/with-cache/full
    (cd .. && { time make build-without-cache ; } 2> $dir/$i \
        && cat $dir/$i | tail -n1 >> $dir/result.txt)

    git checkout 84e8eea59ac31e08d7a804758640abe388212a2f
    dir=$tmpD/with-cache/kernel
    (cd .. && { time make build ; } 2> $dir/$i \
        && cat $dir/$i | tail -n1 >> $dir/result.txt)

    git checkout 557213b177b55399746b44d73283df0c2eccf736
    dir=$tmpD/with-cache/middleware
    (cd .. && { time make build ; } 2> $dir/$i \
        && cat $dir/$i | tail -n1 >> $dir/result.txt)

    git checkout 2e8b71bf3eb52da9eaf2429c26e040887a0b5bc6
    dir=$tmpD/with-cache/user
    (cd .. && { time make build ; } 2> $dir/$i \
        && cat $dir/$i | tail -n1 >> $dir/result.txt)
done

echo "temporary directory: $tmpD"

get_average() {
    cat $tmpD/$1/$2/result.txt | awk 'ttt += $1  {print ttt/NR}'| tail -1
}

get_average_test() {
    cat sample.txt | awk 'ttt += $1  {print ttt/NR}'| tail -1
}

get_stdev() {
    # cat $tmpD/$1/$2/result.txt | awk 'ttt += $1  {print ttt/NR}'| tail -1
    python << EOF
with open("$tmpD/$1/$2/result.txt") as f:
    import statistics
    print(statistics.stdev(map(float, f.read().split())))
EOF
}

get_stdev_test() {
    # cat $tmpD/$1/$2/result.txt | awk 'ttt += $1  {print ttt/NR}'| tail -1
    python3 << EOF
with open("sample.txt") as f:
    import statistics
    print(statistics.stdev(map(float, f.read().split())))
EOF
}

echo "build average time, step cache, step stdev, file cache, file stdev" >> $tmpD/result.csv
echo "full, $(get_average simple full), $(get_stdev simple full), $(get_average with-cache full), $(get_stdev with-cache full)" >> $tmpD/result.csv
echo "kernel, $(get_average simple kernel), $(get_stdev simple kernel), $(get_average with-cache kernel), $(get_stdev with-cache kernel)" >> $tmpD/result.csv
echo "middleware, $(get_average simple middleware), $(get_stdev simple middleware), $(get_average with-cache middleware), $(get_stdev with-cache middleware)" >> $tmpD/result.csv
echo "user, $(get_average simple user), $(get_stdev simple user), $(get_average with-cache user), $(get_stdev with-cache user)" >> $tmpD/result.csv
echo

cat $tmpD/result.csv

# analysis url
# https://colab.research.google.com/drive/1uC00UApcrfsqooM7WtJht3u6xevcbapu

ls /var/folders/_q/1mwpxmn91wj5fs_c_f29mz3h0000gn/T/tmp.RWwzwLYD/
