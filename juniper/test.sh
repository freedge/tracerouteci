traceroute -e -n fd00::2 -m 1 -q 1 | tee res
traceroute -e -n 192.168.80.2 -m 1 -q 1 | tee -a res
sed -i 's/[0-9]*\.[0-9]* ms//g' res && diff -w expected res
