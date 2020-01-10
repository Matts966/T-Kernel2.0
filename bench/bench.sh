#!/bin/bash
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

# with cache
for ((i=1; i<=5; i++)); do
    git checkout c5281879a7d784713bbe08b774ff79bd48b90d28
    dir=$tmpD/with-cache/full
    (cd .. && { time make build-without-cache ; } 2> $dir/$i \
        && cat $dir/$i | tail -n1 >> $dir/result.txt)

    git checkout 2d8154b7133e23f589c6ea24fa517ce0c6970041
    dir=$tmpD/with-cache/kernel
    (cd .. && { time make build ; } 2> $dir/$i \
        && cat $dir/$i | tail -n1 >> $dir/result.txt)

    git checkout be890ae9628f3e2273152e1c98ea721831aa0b3d
    dir=$tmpD/with-cache/middleware
    (cd .. && { time make build ; } 2> $dir/$i \
        && cat $dir/$i | tail -n1 >> $dir/result.txt)

    git checkout f05b37494f4e80a17693c5145ab3bfee7b3c88d5
    dir=$tmpD/with-cache/user
    (cd .. && { time make build ; } 2> $dir/$i \
        && cat $dir/$i | tail -n1 >> $dir/result.txt)
done

# simple
for ((i=1; i<=5; i++)); do 
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

echo "temporary directory: $tmpD"

get_average() {
    $(cat $tempD/$1/$2/result.txt | python -c "import sys; \
        sum = 0.0 \
        count = 0 \
         \
        for line in sys.stdin: \
            count += 1 \
            sum += float(line) \
         \
        sys.stdout.write(str(sum / count))" \
    )
}

get_average() {
    cat $tmpD/$1/$2/result.txt | awk 'ttt += $1  {print ttt/NR}'| tail -1
}

get_average_test() {
    cat sample.txt | awk 'ttt += $1  {print ttt/NR}'| tail -1
}

echo "build average time, normal, with cache" >> $tmpD/result.csv
echo "full build, $(get_average simple full), $(get_average with-cache full)" >> $tmpD/result.csv
echo "change in kernel source, $(get_average simple kernel), $(get_average with-cache kernel)" >> $tmpD/result.csv
echo "change in middleware source, $(get_average simple middleware), $(get_average with-cache middleware)" >> $tmpD/result.csv
echo "change in user source, $(get_average simple user), $(get_average with-cache user)" >> $tmpD/result.csv
