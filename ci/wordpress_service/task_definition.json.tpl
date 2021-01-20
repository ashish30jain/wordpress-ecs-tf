[
  {
    "name": "${service_name}",
    "image": "${container_image}",
    "memory": ${container_memory},
    "memoryReservation": ${container_memory_reservation},
    "privileged": false,
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": 0,
        "protocol": "tcp"
      }
    ],
    "essential": true,
    "environment": [
      { "name": "DATABASE_HOST", "value": "${database_host}" },
      { "name": "AWS_REGION", "value": "${aws_region}" }



    ],
    "logConfiguration": {
      "logDriver": "gelf",
      "options": {
        "gelf-address": "udp://${logstash_address}:${logstash_gelf_udp_port}",
        "tag": "${service_name}"
      }
    }

  }
]
