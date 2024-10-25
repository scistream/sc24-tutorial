Hands-on Tutorial

## Prerequisites / Step 1 - Install docker

## Step 2 - Download scistream docker image

docker pull castroflaviojr/scistream

## Step 3 - Run Scistream User Client (S2UC) via the docker image

```
docker run -v /vagrant/sc24/certificates:/scistream -p 2223:22 --entrypoint s2uc castroflaviojr/scistream:latest inbound-request --server_cert="/scistream/server.crt" --remote_ip 172.31.92.192 --s2cs 52.91.195.34:5000 
--receiver_ports 80 --num_conn 1 --mock True ```

Notice the public certificates of the Scistream control server need to exist

The Scistream control server need to exist

This is a unauthorized Scistream control server. Meaning it does not require Globus Auth.

## Step 4 - Generate public certificates for local Scistream Control Server

```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt -subj "/CN=192.168.10.10" -addext "subjectAltName=IP:192.168.10.10"
```

## Step 5 - Run local Scistream Control Server via docker image

docker run -v /vagrant/scistream-proto/deploy/certificates:/scistream -p 2222:22 -p 5000:5000 -p 5080:5074 castroflaviojr scistream:latest --server_crt="/scistream/server.crt" --server_key="/scistream/server.key" 
--type="StunnelSubprocess" --verbose

## Step 6 - Run Scistream User Client to configure outbound proxy

```
docker run -v /vagrant/scistream-proto/:/scistream -p 2223:22 --entrypoint s2uc castroflaviojr/scistream:latest outbound-request --server_cert="/scistream/server.crt" --remote_ip 52.91.195.34  --s2cs 192.168.10.10:5000 --receiver_ports 5074 --num_conn 1 4f8583bc-a4d3-11ee-9fd6-034d1fcbd7c3 52.91.195.34:5074
```

## Step 7 - Troubleshoot Scistream Control Server via docker interactive terminal

docker exec -it <container_id> /bin/bash
