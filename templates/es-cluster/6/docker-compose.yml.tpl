version: '2'
services:
    es-master:
        labels:
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.container.hostname_override: container_name
            io.rancher.sidekicks: es-master-storage{{- if eq .Values.UPDATE_SYSCTL "true" -}},es-master-sysctl{{- end}}
        image: docker.elastic.co/elasticsearch/elasticsearch:6.2.4
        environment:
            - "cluster.name=${cluster_name}"
            - "node.name=$${HOSTNAME}"
            - "bootstrap.memory_lock=true"
            - "xpack.security.enabled=false"
            - "ES_JAVA_OPTS=-Xms${master_heap_size} -Xmx${master_heap_size}"
            - "discovery.zen.ping.unicast.hosts=es-master"
            - "discovery.zen.minimum_master_nodes=${minimum_master_nodes}"
            - "node.master=true"
            - "node.data=false"
        ulimits:
            memlock:
                soft: -1
                hard: -1
            nofile:
                soft: 65536
                hard: 65536
        mem_limit: ${master_mem_limit}
        mem_swappiness: 0
        cap_add:
            - IPC_LOCK
        volumes_from:
            - es-master-storage
        ports:
            - "9200:9200" 

    es-data:
        labels:
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.container.hostname_override: container_name
            io.rancher.sidekicks: es-data-storage{{- if eq .Values.UPDATE_SYSCTL "true" -}},es-data-sysctl{{- end}}
        image: docker.elastic.co/elasticsearch/elasticsearch:6.2.4
        environment:
            - "cluster.name=${cluster_name}"
            - "node.name=$${HOSTNAME}"
            - "bootstrap.memory_lock=true"
            - "xpack.security.enabled=false"
            - "discovery.zen.ping.unicast.hosts=es-master"
            - "ES_JAVA_OPTS=-Xms${data_heap_size} -Xmx${data_heap_size}"
            - "node.master=false"
            - "node.data=true"
        ulimits:
            memlock:
                soft: -1
                hard: -1
            nofile:
                soft: 65536
                hard: 65536
        mem_limit: ${data_mem_limit}
        mem_swappiness: 0
        cap_add:
            - IPC_LOCK
        volumes_from:
            - es-data-storage
        depends_on:
            - es-master

    es-client:
        labels:
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.container.hostname_override: container_name
            io.rancher.sidekicks: es-client-storage{{- if eq .Values.UPDATE_SYSCTL "true" -}},es-client-sysctl{{- end}}
        image: docker.elastic.co/elasticsearch/elasticsearch:6.2.4
        environment:
            - "cluster.name=${cluster_name}"
            - "node.name=$${HOSTNAME}"
            - "bootstrap.memory_lock=true"
            - "xpack.security.enabled=false"
            - "discovery.zen.ping.unicast.hosts=es-master"
            - "ES_JAVA_OPTS=-Xms${client_heap_size} -Xmx${client_heap_size}"
            - "node.master=false"
            - "node.data=false"
        ulimits:
            memlock:
                soft: -1
                hard: -1
            nofile:
                soft: 65536
                hard: 65536
        mem_limit: ${client_mem_limit}
        mem_swappiness: 0
        cap_add:
            - IPC_LOCK
        volumes_from:
            - es-client-storage
        depends_on:
            - es-master

    es-master-storage:
        labels:
            io.rancher.container.start_once: true
        network_mode: none
        image: rawmind/alpine-volume:0.0.2-1
        environment:
            - SERVICE_UID=1000
            - SERVICE_GID=1000
            - SERVICE_VOLUME=/usr/share/elasticsearch/data
        volumes:
            - es-storage-volume:/usr/share/elasticsearch/data

    es-client-storage:
        labels:
            io.rancher.container.start_once: true
        network_mode: none
        image: rawmind/alpine-volume:0.0.2-1
        environment:
            - SERVICE_UID=1000
            - SERVICE_GID=1000
            - SERVICE_VOLUME=/usr/share/elasticsearch/data
        volumes:
            - es-storage-volume:/usr/share/elasticsearch/data

    es-data-storage:
        labels:
            io.rancher.container.start_once: true
        network_mode: none
        image: rawmind/alpine-volume:0.0.2-1
        environment:
            - SERVICE_UID=1000
            - SERVICE_GID=1000
            - SERVICE_VOLUME=/usr/share/elasticsearch/data
        volumes:
            - es-storage-volume:/usr/share/elasticsearch/data

    {{- if eq .Values.UPDATE_SYSCTL "true" }}
    es-master-sysctl:
        labels:
            io.rancher.container.start_once: true
        network_mode: none
        image: rawmind/alpine-sysctl:0.1
        privileged: true
        environment:
            - "SYSCTL_KEY=vm.max_map_count"
            - "SYSCTL_VALUE=262144"
    {{- end}}
    {{- if eq .Values.UPDATE_SYSCTL "true" }}
    es-data-sysctl:
        labels:
            io.rancher.container.start_once: true
        network_mode: none
        image: rawmind/alpine-sysctl:0.1
        privileged: true
        environment:
            - "SYSCTL_KEY=vm.max_map_count"
            - "SYSCTL_VALUE=262144"
    {{- end}}
    {{- if eq .Values.UPDATE_SYSCTL "true" }}
    es-client-sysctl:
        labels:
            io.rancher.container.start_once: true
        network_mode: none
        image: rawmind/alpine-sysctl:0.1
        privileged: true
        environment:
            - "SYSCTL_KEY=vm.max_map_count"
            - "SYSCTL_VALUE=262144"
    {{- end}}
    
    {{- if eq .Values.INCLUDE_KIBANA "true" }}
    es-kibana:
        image: docker.elastic.co/kibana/kibana:6.2.4
        environment:
            - "ELASTICSEARCH_URL=http://es-client:9200"
            - "xpack.security.enabled=false"
        external_links:
            - es-client:es-client
        ports: 
            - "5601:5601"
    {{- end}}
    
    {{- if eq .Values.INCLUDE_CEREBRO "true" }}
    es-cerebro:
        image: yannart/cerebro:0.7.2
        external_links:
            - es-client:elasticsearch
    {{- end}}

volumes:
  es-storage-volume:
    driver: ${VOLUME_DRIVER}
    per_container: true
