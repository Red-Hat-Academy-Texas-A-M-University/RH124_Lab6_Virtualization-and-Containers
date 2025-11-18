# **Subject:** RE: Vitualization & Containers

Howdy team,

I was browsing through r/sysadmin the other day when I came across this new technology 
called "containers." From what I hear, they're supposed to make deployment of our services 
much quicker and painless! I want you to check out the differences between deploying our 
website on our traditional single host architecture vs containers. 

---
## **1. Deploy on bare metal**

### **1a. Install the necessary software**
Our application runs on the Apache2 web server, so you'll first need to install it using the 
distribution's package manager.
*Hint: Your host is a Red Hat Enterprise Linux server and the package you are looking for
is called "httpd"*

### **1b. Test that your server is running**
To save yourself a step in troubleshooting, make sure that the web server is up and running
before you go and install our web app onto the host.
*Hint: You may want to "curl" your server (localhost) to achieve this*

### **1c. Clone repository into correct directory**
To make our jobs easier, we keep all of our HTML related files in a single central repository
in GitHub. It is available at: 
- "https://github.com/Red-Hat-Academy-Texas-A-M-University/RH124_Lab5_Virtualization-and-Containers"
Go ahead and clone the repo into the default directory which Apache looks for your website:
- /var/www/html/
*Hint: How do you "git" a remote repository?*

### **1d. Check out your web app again**
Now that our application is on the host, verify that it is up and running once more.

---
## **2. Deploy Using Docker**

### **2a. Run web-app container remotely**
Our developer team has been kind of enough to pre-package the new version of our web-app
using a docker image. You can get it from:
- 
To run it on the remote host that we have, 10.2.0.103, you will require the flag to run on a different host
- docker -H tcp://10.2.0.103:2375 <command>
It will come out to look something like this. Remember the -d flag to detach immediately from the container
You will also need to run the web-app on an arbitrary port between 1000-65536, for this demonstration at least
- docker -H tcp://10.2.0.103:2375 run -d -p <port-of-your-choosing>:80 <image-name>

### **2b. Test your web-app**
Now that we have the container running, test the web-app once again, this time using the host IP address
and remote port in your curl command
- curl http://10.2.0.103:<port-you-chose>


---
Thanks and Gig 'em,  
**Kevin G.**  
Systems Administration Lead
