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
    git checkout master
    dir=$tmpD/with-cache/full
    (cd .. && { time make build-without-cache ; } 2> $dir/$i \
        && cat $dir/i | tail -n1 | $dir/result.txt)

    git checkout b1c7b3c2fb6bf5297bbbb4b5e75a23b0bc8d7c24
    dir=$tmpD/with-cache/kernel
    (cd .. && { time make build ; } 2> $dir/$i \
        && cat $dir/i | tail -n1 | $dir/result.txt)

    git checkout 40ebad368553e1798dbaa56802ecfe44c0130402
    dir=$tmpD/with-cache/user
    (cd .. && { time make build ; } 2> $dir/$i \
        && cat $dir/i | tail -n1 | $dir/result.txt)

    git checkout 9c524750a3cbfbfedd1d86629280c35d4402af5e
    dir=$tmpD/with-cache/middleware
    (cd .. && { time make build ; } 2> $dir/$i \
        && cat $dir/i | tail -n1 | $dir/result.txt)
done

# simple
for ((i=1; i<=5; i++)); do 
    git checkout 2af8f14ec2cafa1e40ec665ae9e538279ec8ba1d
    dir=$tmpD/simple/full
    (cd .. && { time make build-without-cache ; } 2> $dir/$i \
        && cat $dir/i | tail -n1 | $dir/result.txt)

    git checkout d08937d85754fd7fb3f8f75ba3f29ac95b9a99c8
    dir=$tmpD/simple/kernel
    (cd .. && { time make build ; } 2> $dir/$i \
        && cat $dir/i | tail -n1 | $dir/result.txt)
    
    git checkout dd9e64b44c6dd937e737f789b9672bd732e3edc2
    dir=$tmpD/simple/user
    (cd .. && { time make build ; } 2> $dir/$i \
        && cat $dir/i | tail -n1 | $dir/result.txt)

    git checkout 8ed83ee1ba89e7a46a6b5d7a3e59d4d16e48281e
    dir=$tmpD/simple/middleware
    (cd .. && { time make build ; } 2> $dir/$i \
        && cat $dir/i | tail -n1 | $dir/result.txt)
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
