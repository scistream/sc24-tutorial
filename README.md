# SciStream SuperComputing 24 Hands-on Tutorial

This tutorial guides you through setting up and running SciStream using Docker containers. At the end of the tutorial you should be able to reach a streaming application hidden in a private network.

This tutorial has 2 parts, in the first part we focus on using the docker environment to use the Scistream CLI too to make a request to an existing Scistream Control Server setup at AWS.

In the second part we are going to setup our own Scistream Control Server at a local machine. Next, we are going to make a Scistream Client request towards the Scistream Control Server that we created. Finally we are going to stream data from the producer to the consumer.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation Steps](#installation-steps)
- [Troubleshooting](#troubleshooting)

## Prerequisites
- Docker understanding
- Docker installed on your system.
  ```
  https://docs.docker.com/engine/install/
  ```
- OpenSSL for certificate generation
- Access to required ports (22, 5000, 5074, 5080)

## Installation Steps

### 1.1 Pull Tutorial
```
git clone https://github.com/scistream/sc24-tutorial.git
cd sc24-tutorial
```

### 1.2 Pull SciStream Docker Image

```bash
docker pull castroflaviojr/scistream
```

Now let's start a scistream docker container and access using it's backdoor by setting the entrypoint as /bin/bash.

```
docker run -it -v ./certificates:/scistream    --entrypoint /bin/bash castroflaviojr/scistream:latest
```

### 1.3 Start

### 1.3 Run SciStream User Client (S2UC)

The goal for this part of the tutorial is to get the user started with the Scistream User Client. For this purpose we are going to make requests against a remote Scistream Control Server at AWS as demonstrated in figure 1 below. TODO figure 1

This is a client request for an inbound connection to a private server at ip address 172.31.92.192:

```bash
s2uc inbound-request \
    --server_cert="/scistream/server.crt" \
    --remote_ip 172.31.92.192 \
    --s2cs 52.23.209.2:5000 \
    --receiver_ports 80 \
    --num_conn 1
```

What is the address of the control server?

What is the ip and port of the producer application?

Why is server_cert required?

**Important Notes:**
- Requires public certificates for the SciStream control server
- Control server must be running
- This uses an unauthorized SciStream control server (no Globus Auth required)

Expected output:

```
sending client request message
started client request
waiting for hello message
sending for hello message
sending for hello message
Hello message sent successfully
listeners: "52.23.209.2:5200"
```
Now let's try accessing the resource.
```
curl 52.23.209.2:5200
```

### 1.4 Globus Auth

At this second part of the tutorial our goal is to use S2UC with Globus Auth.

```
s2uc logout
```
```
s2uc login --scope "26c25f3c-c4b7-4107-8a25-df96898a24fe"
```
After you follow the instructions you should get a globus auth token
```
s2uc inbound-request \
    --server_cert="/scistream/server.crt" \
    --remote_ip 172.31.92.192 \
    --s2cs 52.23.209.2:5001 \
    --receiver_ports 80 \
    --num_conn 1 \
    --scope 26c25f3c-c4b7-4107-8a25-df96898a24fe
```
To finish let's try accessing the new resource
```
wget 52.23.209.2:5200
```
### 1.5 Recap, first part

We have seen how we can make a scistream client request to open an inbound connection at a scistream control server at AWS forwarding the connection to a private streaming application(producer).

## Second Tutorial

Now we are going to learn how to configure the Scistream Control Server.

We are going to create a Scistream Control server and run it at your local machine. We then will use S2UC to configure it as a outbound proxy. This outbound proxy will establish a secure tunnel between your machine and a secure tunnel at a remote location. As described in figure 2 below. #TODO

### 2.1 Start docker container

```
docker run -it -v ./certificates:/scistream -p 5000:5000 -p 5100-5110:5100-5110  --entrypoint /bin/bash castroflaviojr/scistream:latest
```

Our first challenge is identifying what is the reachable ip address of your docker installation.

This is important because we will need it to generate security certificates.

One way to do this is by running `ip address` from inside the docker container.

```
root@f7a58f9814d3:/# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
48: eth0@if49: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

In this case the ip address is "172.17.0.2".

Also notice that we are mapping ports 5000 and port range 5100-5100 at the host to the container.

### 2.2 Generate Public Certificates

The next step is the public certificate generation.

```
mkdir certificates
cd certificates
openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout server.key -out server.crt \
    -subj "/CN=172.17.0.2" \
    -addext "subjectAltName=IP:172.17.0.2"
```

Notice that this assumes that in your docker setup the ip address 172.17.0.2 is locally reachable. You might need to replace this.

The most common issue we face at this step of the tutorial is this ip address not being reachable.

### 2.3. Run Local SciStream Control Server

```bash
    s2cs
    --server_crt="/scistream/server.crt" \
    --server_key="/scistream/server.key" \
    --type="StunnelSubprocess" \
    --verbose
```

### 5. Configure Outbound Proxy
Run SciStream User Client for outbound configuration:

```bash
docker run -v /vagrant/scistream-proto/:/scistream \
    -p 2223:22 --entrypoint s2uc \
    castroflaviojr/scistream:latest outbound-request \
    --server_cert="/scistream/server.crt" \
    --remote_ip 52.91.195.34 \
    --s2cs 192.168.10.10:5000 \
    --receiver_ports 5074 \
    --num_conn 1 \
    4f8583bc-a4d3-11ee-9fd6-034d1fcbd7c3 52.91.195.34:5074
```

## Troubleshooting

To access the SciStream Control Server's interactive terminal:
```bash
docker exec -it  /bin/bash
```
