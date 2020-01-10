#!/bin/bash
tmpD=(mktemp -d)

# with cache
git checkout master
for ((i=1; i<=5; i++)); do 
    (cd .. && make build-without-cache > $tmpD/with-cache/full/$i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/with-cache/full/$i >> $tmpD/with-cache/full/result.txt
done
git checkout b1c7b3c2fb6bf5297bbbb4b5e75a23b0bc8d7c24
for ((i=1; i<=5; i++)); do 
    (cd .. && make build > $tmpD/with-cache/kernel/$i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/with-cache/kernel/$i >> $tmpD/with-cache/kernel/result.txt
done
git checkout 40ebad368553e1798dbaa56802ecfe44c0130402
for ((i=1; i<=5; i++)); do 
    (cd .. && make build > $tmpD/with-cache/user/$i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/with-cache/user/$i >> $tmpD/with-cache/user/result.txt
done
git checkout 9c524750a3cbfbfedd1d86629280c35d4402af5e
for ((i=1; i<=5; i++)); do 
    (cd .. && make build > $tmpD/with-cache/middleware/$i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/with-cache/middleware/$i >> $tmpD/with-cache/middleware/result.txt
done

# simple
git checkout 2af8f14ec2cafa1e40ec665ae9e538279ec8ba1d
for ((i=1; i<=5; i++)); do 
    (cd .. && make build-without-cache > $tmpD/simple/full/i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/simple/full/$i >> $tmpD/simple/full/result.txt
done
git checkout d08937d85754fd7fb3f8f75ba3f29ac95b9a99c8
for ((i=1; i<=5; i++)); do 
    (cd .. && make build > $tmpD/simple/kernel/$i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/simple/kernel/$i >> $tmpD/simple/kernel/result.txt
done
git checkout dd9e64b44c6dd937e737f789b9672bd732e3edc2
for ((i=1; i<=5; i++)); do 
    (cd .. && make build > $tmpD/simple/user/$i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/simple/user/$i >> $tmpD/simple/user/result.txt
done
git checkout 8ed83ee1ba89e7a46a6b5d7a3e59d4d16e48281e
for ((i=1; i<=5; i++)); do 
    (cd .. && make build > $tmpD/simple/middleware/$i)
    sed -n 's/\[\+\].Building.\([0-9]*\.[0-9]*\).*/\1/p' \
        $tmpD/simple/middleware/$i >> $tmpD/simple/middleware/result.txt
done

echo "temporary directory: $tmpD"

get_averate() {
    $(cat $tempD/$1/$2/result.txt | python bench/average.py)
}

echo "build average time, normal, with cache" >> $tmpD/result.csv
echo "full build, $(get_averate simple full), $(get_averate with-cache full)" >> $tmpD/result.csv
echo "change in kernel source, $(get_averate simple kernel), $(get_averate with-cache kernel)" >> $tmpD/result.csv
echo "change in middleware source, $(get_averate simple middleware), $(get_averate with-cache middleware)" >> $tmpD/result.csv
echo "change in user source, $(get_averate simple user), $(get_averate with-cache user)" >> $tmpD/result.csv
