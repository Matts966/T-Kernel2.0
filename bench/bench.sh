#!/bin/bash
tmpD=$(mktemp -d)

# with cache
git checkout master
mkdir -p $tmpD/with-cache/full
for ((i=1; i<=5; i++)); do 
    (cd .. && make build-without-cache > $tmpD/with-cache/full/$i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/with-cache/full/$i >> $tmpD/with-cache/full/result.txt
done
git checkout b1c7b3c2fb6bf5297bbbb4b5e75a23b0bc8d7c24
mkdir -p $tmpD/with-cache/kernel
for ((i=1; i<=5; i++)); do 
    (cd .. && make build > $tmpD/with-cache/kernel/$i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/with-cache/kernel/$i >> $tmpD/with-cache/kernel/result.txt
done
git checkout 40ebad368553e1798dbaa56802ecfe44c0130402
mkdir -p $tmpD/with-cache/user
for ((i=1; i<=5; i++)); do 
    (cd .. && make build > $tmpD/with-cache/user/$i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/with-cache/user/$i >> $tmpD/with-cache/user/result.txt
done
git checkout 9c524750a3cbfbfedd1d86629280c35d4402af5e
mkdir -p $tmpD/with-cache/middleware
for ((i=1; i<=5; i++)); do 
    (cd .. && make build > $tmpD/with-cache/middleware/$i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/with-cache/middleware/$i >> $tmpD/with-cache/middleware/result.txt
done

# simple
git checkout 2af8f14ec2cafa1e40ec665ae9e538279ec8ba1d
mkdir -p $tmpD/with-cache/full
for ((i=1; i<=5; i++)); do 
    (cd .. && make build-without-cache > $tmpD/simple/full/i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/simple/full/$i >> $tmpD/simple/full/result.txt
done
git checkout d08937d85754fd7fb3f8f75ba3f29ac95b9a99c8
mkdir -p $tmpD/with-cache/kernel
for ((i=1; i<=5; i++)); do 
    (cd .. && make build > $tmpD/simple/kernel/$i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/simple/kernel/$i >> $tmpD/simple/kernel/result.txt
done
git checkout dd9e64b44c6dd937e737f789b9672bd732e3edc2
mkdir -p $tmpD/with-cache/user
for ((i=1; i<=5; i++)); do 
    (cd .. && make build > $tmpD/simple/user/$i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/simple/user/$i >> $tmpD/simple/user/result.txt
done
git checkout 8ed83ee1ba89e7a46a6b5d7a3e59d4d16e48281e
mkdir -p $tmpD/with-cache/middleware
for ((i=1; i<=5; i++)); do 
    (cd .. && make build > $tmpD/simple/middleware/$i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/simple/middleware/$i >> $tmpD/simple/middleware/result.txt
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
        sys.stdout.write(str(sum / count))");
}

echo "build average time, normal, with cache" >> $tmpD/result.csv
echo "full build, $(get_average simple full), $(get_average with-cache full)" >> $tmpD/result.csv
echo "change in kernel source, $(get_average simple kernel), $(get_average with-cache kernel)" >> $tmpD/result.csv
echo "change in middleware source, $(get_average simple middleware), $(get_average with-cache middleware)" >> $tmpD/result.csv
echo "change in user source, $(get_average simple user), $(get_average with-cache user)" >> $tmpD/result.csv
