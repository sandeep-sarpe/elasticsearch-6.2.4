# Scalable Graylog server cluster - now with working service volumes!


### Info:

 This template creates Graylog server cluster. It requires (for now) a load balancer and (for now) an external mongo database. Next versions will use Traefik or something similar
 
### Usage:

 Create an external mongo database and graylog user account (read the documentation) 
 
 Populate configuration details and link with an elastic instance + external mongo database.
 
 Click deploy.
 
 Set up load balancer for 514 and 12201 forwarding TCP and UDP
 
 If you use the default password and password secret, you will log in as admin/admin
 
 Enjoy!