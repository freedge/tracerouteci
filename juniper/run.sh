set -x
dnf -y install dosfstools
virsh destroy vjunos-sw1
virsh undefine vjunos-sw1
ip link del ge-000
ip link del ge-001
virsh net-destroy private
virsh net-undefine private
rm -f /srv/vms/junos.qcow2
rm -f /srv/vms/config.qcow2

set -e
test -f /srv/vms/make-config-23.2R1.14.sh
test -f /srv/vms/vJunos-switch-23.2R1.14.qcow2
virsh net-define leprivate.xml
virsh net-start private

# creating as per doc
ip link add ge-000 type bridge
ip link add ge-001 type bridge
ip link set ge-000 up
ip link set ge-001 up
ip addr add 192.168.80.1/24 dev ge-000
ip addr add fd00::1/64 dev ge-000

/srv/vms/make-config-23.2R1.14.sh ./juniper.conf /srv/vms/config.qcow2
cp /srv/vms/vJunos-switch-23.2R1.14.qcow2 /srv/vms/junos.qcow2
virsh define vjunos-23.2R1.14.xml
virsh start vjunos-sw1

echo access with telnet localhost 8610
