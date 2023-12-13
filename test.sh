set -x
# we start with some clean-up
ip netns del n1
ip netns del n2
ip netns del n3
ip link del veth0
ip link del veth1
ip link del veth2
ip link del veth3
ip link del veth4
ip link del veth5
systemctl stop theserver
systemctl stop theserver6
systemctl stop thehaproxy
rm /etc/haproxy/haproxy2.cfg
set -e
set -o pipefail
ip netns add n1
ip netns add n2
ip netns add n3
sysctl net.ipv6.conf.all.forwarding=1
# remove "Time Exceeded" bit from icmp_ratemask
ip netns exec n1 sysctl net.ipv6.conf.all.forwarding=1 net.ipv4.icmp_ratemask=4120 net.ipv6.icmp.ratemask=0-1,4-127
ip netns exec n2 sysctl net.ipv6.conf.all.forwarding=1 net.ipv4.icmp_ratemask=4120 net.ipv6.icmp.ratemask=0-1,4-127
ip netns exec n3 sysctl net.ipv6.conf.all.forwarding=1 net.ipv4.tcp_fastopen=3
ip link add type veth
ip link add type veth
ip link add type veth
ip link set veth1 netns n1
ip link set veth2 netns n1
ip link set veth3 netns n2
ip link set veth4 netns n2
ip link set veth5 netns n3
ip link set veth0 up
ip addr add 192.168.100.1/24 dev veth0
ip addr add fd00:1::1/64 dev veth0 nodad
ip netns exec n1 ip addr add 192.168.100.2/24 dev veth1
ip netns exec n1 ip addr add fd00:1::2/64 dev veth1 nodad
ip netns exec n1 ip addr add 192.168.101.1/24 dev veth2
ip netns exec n1 ip addr add fd00:2::1/64 dev veth2 nodad
ip netns exec n2 ip addr add 192.168.101.2/24 dev veth3
ip netns exec n2 ip addr add fd00:2::2/64 dev veth3 nodad
ip netns exec n2 ip addr add 192.168.102.1/24 dev veth4
ip netns exec n2 ip addr add fd00:3::1/64 dev veth4 nodad
ip netns exec n3 ip addr add 192.168.102.2/24 dev veth5
ip netns exec n3 ip addr add fd00:3::2/64 dev veth5 nodad
ip netns exec n1 ip link set veth1 up
ip route add 192.168.100.0/22 via 192.168.100.2
ip -6 route add fc00::/7 via fd00:1::2
ip netns exec n1 ip link set veth2 up
ip netns exec n1 ip route add default via 192.168.100.1
ip netns exec n2 ip link set veth3 up
ip netns exec n2 ip link set veth4 up
ip netns exec n3 ip link set veth5 up
ip netns exec n3 ip link set lo up
ip netns exec n1 ip route add 192.168.102.0/24 via 192.168.101.2
ip netns exec n2 ip route add default via 192.168.101.1
ip netns exec n3 ip route add default via 192.168.102.1
ip netns exec n1 ip -6 route add default via fd00:2::2
ip netns exec n2 ip -6 route add default via fd00:2::1
ip netns exec n3 ip -6 route add default via fd00:3::1

# customize a bit for our tests
ip netns exec n1 ip link set veth2 mtu 1400
ip netns exec n2 ip link set veth3 mtu 1400
ip netns exec n1 iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN SYN -o veth2 -j TCPMSS --set-mss 8765
ip netns exec n1 ip6tables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN SYN -o veth2 -j TCPMSS --set-mss 9999

# run some servers
systemd-run  --collect --unit theserver -p NetworkNamespacePath=/var/run/netns/n3 -- nc -4 -l 12345 -k
systemd-run  --collect --unit theserver6 -p NetworkNamespacePath=/var/run/netns/n3 -- nc -6 -l 12346 -k
# TODO use some systemd magic to provide the file to the unit
cp haproxy2.cfg /etc/haproxy/
systemd-run  --collect  --unit thehaproxy -p NetworkNamespacePath=/var/run/netns/n3 -- haproxy -Ws  -f /etc/haproxy/haproxy2.cfg

# unfortunately it takes 2s to connect the first time, don't know why yet
# TODO remove these pings
ip netns exec n2 ping -c 1 fd00:3::2 && ip netns exec n2 ping -c 1 fd00:1::2 && time nc -zv fd00:3::2 12346

# test traceroute
traceroute -T -O mss=12000,info 192.168.102.2 --port=12345 -n | tee res
traceroute -T -O mss=12000,info fd00:3::2 --port=12346 --max-hops=5 -n | tee -a res
traceroute 192.168.102.2 --mtu -O info -n | tee -a res
traceroute fd00:3::2 --mtu -O info -n | tee -a res
traceroute -T -O ${fastopen}info 192.168.102.2 --port=5000 -n | tee -a res
traceroute -T -O ${fastopen}info fd00:3::2 --port=5000 -n | tee -a res
sed -i 's/[0-9]*\.[0-9]* ms//g' res && diff -w expected res
