see [vjunos-switch doc](https://www.juniper.net/documentation/us/en/software/vjunos/vjunos-switch-kvm/topics/deploy-and-manage-vjunos-switch-onkvm.html)

from libvirt xml file:
```
<!-- Copyright (c) 2023, Juniper Networks, Inc. -->
<!--  All rights reserved. -->
```
modified for my needs

root toto42

ssh 192.168.152.2 -l root cli show configuration > juniper.conf
