# SciStream SuperComputing 24 Hands-on Tutorial

This tutorial guides you through setting up and running SciStream using Docker containers. At the end of the tutorial you should be able to reach a streaming application hidden in a private network.

In this tutorial we are going to first make a Scistream request to an existing Scistream Control Server setup at AWS. Then we are going to setup our own Scistream Control Server at a local machine.

Next we are going to make a Scistream Client request towards the Scistream Control Server that we created. Finally we are going to stream data from the producer to the consumer.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation Steps](#installation-steps)
- [Troubleshooting](#troubleshooting)

## Prerequisites
- Docker understanding
- Docker installed on your system
- OpenSSL for certificate generation
- Access to required ports (22, 5000, 5074, 5080)

## Installation Steps

### 1. Pull Tutorial
```
git clone git@github.com:scistream/sc24-tutorial.git
```

### 2. Pull SciStream Docker Image
```bash
docker pull castroflaviojr/scistream
```

### 3. Setup docker volume for Certificates

First let's setup a docker volume to be used by our docker container. This is important because the public certificates used for control channel encryption is required.

### 4. Run SciStream User Client (S2UC)

The goal for this part of the tutorial is to get the user started with the Scistream User Client. For this purpose we are going to make requests against a remote Scistream Control Server at AWS as demonstrated in the figure below.

This is a client request for an inbound connection to a private server at ip address 172.31.92.192:

```bash
docker run -v /vagrant/sc24/certificates:/scistream \
    --entrypoint s2uc castroflaviojr/scistream:latest inbound-request \
    --server_cert="/scistream/server.crt" \
    --remote_ip 172.31.92.192 \
    --s2cs 52.91.195.34:5000 \
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
```

### 5. Recap, first part

Now after this is setup we are able to make a scistream client request to open an inbound connection at a scistream control server at AWS forwarding the connection to a private streaming application(producer).

## Second Part

At this second part of the tutorial our goal is to setup a Scistream Control Server at your local machine.

### 3. Generate Public Certificates

The first part that is required is the Public certificate generation.

```bash
openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout server.key -out server.crt \
    -subj "/CN=192.168.10.10" \
    -addext "subjectAltName=IP:192.168.10.10"
```

Notice that this assumes that in your docker setup the ip address 192.168.10.10 is locally reachable.

The most common issue we face at this step of the tutorial is this ip address not being reachable.

### 4. Run Local SciStream Control Server

```bash
docker run -v /vagrant/scistream-proto/deploy/certificates:/scistream \
    -p 2222:22 -p 5000:5000 -p 5080:5074 \
    castroflaviojr scistream:latest \
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
