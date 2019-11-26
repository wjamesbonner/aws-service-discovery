# AWS Service Management Example Framework
One of the challenge for new cloud customers looking to scale up their use of cloud resources is tracking services and service dependencies in your environment.  In higher education, we often have unique needs and constraints, giving rise to oddball projects.  One such project was my recent WordPress-as-a-Service project, which I built in AWS.

Presently, we have large multi-site WordPress servers at WSU.  However, this means that faculty are curtailed in the management and modification of their sites due to restrictions on the use of plugins and themes.  While these restrictions exist for good reason, it does curtail the ability for a motivated individual to bring about their creative vision in communicating with their stakeholders.  To address this we decided that if we didn't want to run a WordPress server with a thousand sites on it, then we should run a thousand WordPress instances.

My goal going into this was to design a process that could be fully delegated to the IT support team, and that oculd efficiently keep up with dozens to hundreds of requests for micro-WordPress platforms per week.  To solve this problem we an automation script that does the following (glossing over a lot of details):

* Generates a unique service id.
* Adds a listener to the ALB for a URL in the format of service-id.ou.example.edu
* Creates a database on a specified MariaDB RDS instance, named after the service ID
* Creates a db user with the appropiate permissions to the database, named after the service ID.
* Creates a security group allowing inbound NFS connections from the ECS cluster
* Creates a EFS volume to provide persistent storage for the WordPress instance's upload directory
* Creates a task definition using a pre-staged ECR image, and that maps the WordPress upload directory to the created EFS volume.
* Launches the container task definition

It is pretty clear from the above that even a simple service like a WordPress container requires a lot of little parts and pieces in the cloud.  To be able to run at scale, we need to be able to easily understand what cloud resources are being used for what services, which is the purpose of this library.

During the provisioning of services, we tag each service with tags named "service-id" and "service-family".  The service-id tag has a unique value that identified the specific service, such as a specific running micro-WordPress instance.  The service-family tag contains the family that the service runs under, which in the case of the WordPress containers is "wp-containers".

This library of scripts uses AWS Resource Groups to create resource groups based on service id and family, and to allow for easy service listing.  The hope is to make it easy to understand what services will be impacted by changes to any specific resource.

This library expects to be run on a system that has already been configured by running "AWS configure".  Additionally, this library in its current state is relatively simplistic, and doesn't support multiple values for service families.  However, there is also an argument to be made to keep your taxonomy simple enough that you don't need multi-valued service ID's and families, and instead build more, simpler, services.  However, I do plan on adding support for a "service-dependency" tag that will be multi-valued.

