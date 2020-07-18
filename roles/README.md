OCP Prerequisite Installer
=========

This role installs all external services required to install OpenShift using the Baremetal UPI deployment:
* DNS
* Load Balancer
* DHCP
* PXE
* HTTP server

It also configures a NFS server to provide Persisten Volumes to OpenShift and prepares the node with all OpenShift artifacts (OC client, openshift-installer, openshift images, ignition files, etc)

Requirements
------------

CentOS/RHEL 8, probably working with latests Fedora fedora releases. In case of RHEL, subscriptions must be active.

The role has been tested with OpenShift 4.4 (I'm not sure about backwards compatibility).

The role can install a DNS server. Users that want to access the cluster and the applications running could either configure this DNS in their systems, configure their DNS to delegate the subdomain (clustername.basedomain) to the deployed DNS, or just have the api.clustername.basedomain and the *.apps.clustername.basedomain entries included in their DNS (probably the easiest option). In case that you don't have access to a DNS server wher you can configure those entries, you could use a nip.io domain (<kvm public ip>.nip.io) since it has a wildcard configured by default and both api and apps must point to the same entry point, the public KVM interface where the load balancer will be listening.

You don't need an OpenShift install-config.yaml file to run this role but it could take some values from it in case you provide one (variable ocp_install_config_path), such DNS values. If you provide a install-config.yaml file you can also take the opportunity to create the ignition files (variable ocp_inject_user_ignition).

The install-config.yaml need to be prepared for the baremetal UPI deployment, something like this:

```
apiVersion: v1
baseDomain: <basedomain>
compute:
- architecture: amd64
  hyperthreading: Enabled
  name: worker
  platform: {}
  replicas: < number of workers>
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: < number of masters (1 or 3)>
metadata:
  creationTimestamp: null
  name: < cluster name >
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr: 192.168.126.0/24
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
platform:
  none: {}
publish: External
pullSecret: '<pull secret from cloud.redhat.com>'
sshKey: |
  < key >

```


Role Variables
--------------

The role has default variables that would work in your environment, but you still would need to fill at least these vars (`dns` values only if you want to configure DNS using the role, so `ocp_prereq_dns` = "true", that is the default value):

* srv_interface

      description: Interface where the services will be published. This must be the name of the interfaces as it appears when running `nmcli con show` (for example, sometimes you will find something like `System eno1` instead just `eno1`)

      default value:

        srv_interface: eth0

* dns

      description: Values for DNS server configuration. You will need to setup at least dns.domain and dns.subdomain. Those values can be get from install-config.yaml file if you provide one.

      default value:

        dns:
          domain: "127.0.0.1.nip.io"
          subdomain: "ocp"
          forwarder1: "8.8.8.8"
          forwarder2: "8.8.4.4"      


* nodes

      description: This variable contains information used by multiple services (DNS, DHCP, PXE) deployed by this role. You probably will need to setup the right MAC address and, if you want to customize it, the network details (if you are not using VirtIo dirvers the disk will be named diferent, same for the interface names).

      default value:

          nodes:
            bootstrap:
              name: "bootstrap"
              ipaddr: "192.168.126.10"
              netmask: "255.255.255.0"
              gw: "192.168.126.1"
              macaddr: "52:54:60:11:11:11"
              disk: "vda"
            masters:
              - name: "master0"
                ipaddr: "192.168.126.11"
                netmask: "255.255.255.0"
                gw: "192.168.126.1"
                macaddr: "52:54:60:00:00:0a"
                disk: "vda"
              - name: "master1"
                ipaddr: "192.168.126.12"
                netmask: "255.255.255.0"
                gw: "192.168.126.1"
                macaddr: "52:54:60:00:00:0b"
                disk: "vda"
              - name: "master2"
                ipaddr: "192.168.126.13"
                netmask: "255.255.255.0"
                gw: "192.168.126.1"
                macaddr: "52:54:60:00:00:0c"
                disk: "vda"
            workers:
              - name: "worker0"
                ipaddr: "192.168.126.15"
                netmask: "255.255.255.0"
                gw: "192.168.126.1"
                macaddr: "52:54:60:00:01:0a"
                disk: "vda"
              - name: "worker1"
                ipaddr: "192.168.126.16"
                netmask: "255.255.255.0"
                gw: "192.168.126.1"
                macaddr: "52:54:60:00:01:0b"
                disk: "vda"
              - name: "worker2"
                ipaddr: "192.168.126.17"
                netmask: "255.255.255.0"
                gw: "192.168.126.1"
                macaddr: "52:54:60:00:01:0c"
                disk: "vda"
              - name: "worker3"
                ipaddr: "192.168.126.18"
                netmask: "255.255.255.0"
                gw: "192.168.126.1"
                macaddr: "52:54:60:00:01:0d"
                disk: "vda"
              - name: "worker4"
                ipaddr: "192.168.126.19"
                netmask: "255.255.255.0"
                gw: "192.168.126.1"
                macaddr: "52:54:60:00:01:0e"
                disk: "vda"
              - name: "worker5"
                ipaddr: "192.168.126.20"
                netmask: "255.255.255.0"
                gw: "192.168.126.1"
                macaddr: "52:54:60:00:01:0f"
                disk: "vda"


There are some other variables that you can modify to configure the environment as per your needs:

* ocp_prereq_lb

      description: If "true" the Load Balancer service is configured

      default value:

        ocp_prereq_lb: "true"



* ocp_prereq_http

      description: If "true" the HTTP service is configured

      default value:

        ocp_prereq_http: "true"

* http

      description: Variable to configure parameters of the HTTP service

      default value:

        http:
          port: "8080"

* ocp_prereq_nfs

      description: If "true" the NFS service is configured

      default value:

        ocp_prereq_nfs: "true"

* ocp_prereq_dns

      description: If "true" the DNS service is configured

      default value:

        ocp_prereq_dns: "true"

* ocp_prereq_dhcp

      description: If "true" the DHCP service is configured

      default value:

        ocp_prereq_dhcp: "true"

* dhcp

      description: Variable to configure parameters of the DHCP service. The values must be setup according to the `nodes` variable settings if default network (192.168.126.0/24) is changed.

      default value:

        dhcp:
          router: "192.168.126.1"
          bcast: "192.168.126.255"
          netmask: "255.255.255.0"
          poolstart: "192.168.126.10"
          poolend: "192.168.126.30"
          ipid: "192.168.126.0"
          netmaskid: "255.255.255.0"
          dns: "{{ dnsipaddr }}"
          domainname: "{{ dns.subdomain }}.{{ dns.domain }}"

* nodes_subnet24

      description: If defined, it will be used to setup the `nodes` and `dhcp` network variables (change the default 192.168.126 for the value of the variable). It only supports /24 networks. The value must be something like '192.168.15'. This variable could be useful if a /24 network will be used and you don't want to configure the other variables one-by-one.

      default value: Not defined

* ocp_prereq_pxe

      description: If "true" the PXE service is configured

      default value:

        ocp_prereq_pxe: "true"

* pxe

      description: Variable to configure parameters of the HTTP service

      default value:

        pxe:
          http_port: "{{ http.port }}"

* ocp_prereq_artifacts

      description: If "true" the OCP artifacts (oc client and openshift-installer) are downloaded and images uploaded to the HTTP server. If a install-config.yaml file is provided and the variable `ocp_create_ignition` is set to "true", it will also create the ignition files and upload them to the HTTP server

      default value:

        ocp_prereq_artifacts: "true"


* ocp_install_config_path

      description: Relative path to the install-config.yaml file. If provided it will be used to gather information like DNS values and to create ignition files if `ocp_create_ignition` variable is set to "true"

      default value:

        ocp_install_config_path: ""


* ocp_inject_user_ignition

      description: If "true" the role will create local users on the nodes. This could be useful to perform troubleshooting while installing the platform (local users don't need network access).

      default value:

        ocp_inject_user_ignition: "false"

* ocp_local_username

      description: In case that `ocp_inject_user_ignition` is set to "true", the role will use this value as the username of the created local user

      default value:

        ocp_local_username: "redhattrouble"

* ocp_local_userpass

      description: In case that `ocp_inject_user_ignition` is set to "true", the role will use this value as the password of the created local user

      default value:

        ocp_local_userpass: "redhatfix"

* ocp_release

      description: OpenShift release to be used during the deployment. This variable will be only used if `ocp_prereq_artifacts` is set to "true"

      default value:

        ocp_release: "4.4.3"

* ocp_create_ignition

      description: If set to "true" the role will create and upload to HTTP server the ignition files needed for the deployment. In that case, `ocp_prereq_artifacts` must set to "true" and `ocp_install_config_path` must point to a install-config.yaml file. Probably you will also need to check the `ocp_release` to be used

      default value:

      ocp_create_ignition: "true"



Example Playbook
----------------

The playbook that calls the role could be like the one shown below if you are using a install-config.yaml file (We keep the `nodes` variable default values and create the VMs using default MAC addresses):

```
- hosts: all
  roles:
    - role: luisarizmendi.ocp_prereq_role
      vars:
        srv_interface: "System eno1"
        ocp_install_config_path: "install-config.yaml"
        ocp_inject_user_ignition: "true"
        ocp_release: "4.4.3"

```

Or this could be one file example with the bare-minimum variable setup in case that there is no install-config.yaml file:

```
- hosts: all
  roles:
    - role: luisarizmendi.ocp_prereq_role
      vars:
        srv_interface: "System eno1"
        dns:
          domain: "80.34.55.22.nip.io"
          subdomain: "ocp"
```


Inventory file does not need any fancy stuff, this is an example:

```
kvm-node ansible_host=1.2.3.4 ansible_port=22 ansible_user=larizmen
```

So one probably directory structure (without install-config.yaml) that you could have to support the playbook (`ocp-prereq.yaml` in this example shown above) would be this one:

```
.
├── ansible.cfg
├── inventory
├── ocp-prereq.yaml
```

After the playbook and the inventory files are created you can use them to install (`tags` = `install`) and configure OpenShift prerequisites:

```
ansible-playbook -vv -i <path to inventory> --tags install <path to playbook>
```

Or to remove (`tags` = `remove`) OpenShift prerequisites and clean up the node:

```
ansible-playbook -vv -i <path to inventory> --tags remove <path to playbook>
```


[If you still have doubts, you can find an example of all files here.](https://github.com/luisarizmendi/ocp-kvm-bm-upi)




Author Information
------------------

Luis Javier Arizmendi Alonso
