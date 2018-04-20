# Redis Cluster Docker Images for Rancher

This set of images and configurations is tailored to run a cluster of Redis instances for High Availability on Rancher.

The redis-server image (ahfeel/rancher-redis-cluster-node on Docker hub) is a simple Redis image with enough logic to safely determine itself as a master or slave on startup.

The redis-sentinel image (ahfeel/rancher-redis-cluster-sentinel on Docker hub) starts Redis Sentinel nodes that will automatically find the Redis instances, monitor them and most importantly, create/update automatically a "Rancher External Service" with the current IP of the Redis Master node. This allows to automatically target your traffic to the Redis Master Node without any additional software proxy.

*Warning: The Redis Instances are actually running in a Master/Slave mode, not a Multi Master Redis Cluster*

## Optional environment variables:

### Redis-Server

`REDIS_TIMEOUT=3600`
(0 by default)
`REDIS_APPENDONLY=yes`
(no by default)

### Redis-Sentinel

```
SENTINEL_DOWN_AFTER_MILLISECONDS=5000
SENTINEL_FAILOVER_TIMEOUT=60000
```
