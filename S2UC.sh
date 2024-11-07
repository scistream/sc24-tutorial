docker run -v .:/scistream \
    --entrypoint s2uc castroflaviojr/scistream:latest inbound-request \
    --server_cert="/scistream/server.crt" \
    --remote_ip 172.31.92.192 \
    --s2cs 52.91.195.34:5000 \
    --receiver_ports 80 \
    --num_conn 1
