
<h1> *********** Devops Notes ***********</h1>


<p>Devops is a culture that promotes collaboration between development and operations team to deploy code to production faster in an automated & repeatable way.

Some Advantages of Devops: predictability in terms of lower failure rate of new releases, Reproducibility (version everything so that earlier version can be restored anytime), maintainability (Effortless process of recovery if new release crashes)  

Devops Life Cycle : Development, Testing, Integration, Deployment, Monitoring

Devops Flow: Developers push/commit code to Git, jenkins will build the code and will push it/ log it to ansible which will run a playbook to deploy the code to kubernetes cluster.

Difference between Devops and Agile?


Code (from the developers) to Build my devops pipeline (all the file/codes in git to install the pipeline) 


Version control system : github 

Build tool, integraction tool or CI tool: Jenkins

Deployment tool or CD tool or configuration tool: Ansible 

Container Orchesatration tool :  Kubernetes (K8S)



*******************************************
- Get Code (from the developers) to Build my devops pipeline (all the file/codes in git to install the pipeline), we got it from the school website by creating our folder in git and copying all file from the school server and then pushed it to github on which we already created the folder and (which was cloned to our git so we can add the file and commit) 
-Run script to install jenkins
-IPaddress:8080  will take us to the "unlock Jenkins" windows, which will give you a link to find the passwd on ur terminal
- Change the password, manage jenkins > manage users > admin > configure


SET UP JENKINS MANUALLY 
      + On EC2 (jenkins server) setup SG when launching the server to allow 8080 
      + Install Java : yum install java-1.8*
      + find /usr/lib/jvm/java-1.8* | head -n 3  & copy the 3rd line
      + vim .bash_profile & set the java path JAVA_HOME=CopiedLink & add ":$JAVA_HOME" at the end of         PATH=..../bin (on the next line) & save the file and source .bash_profile
      + Install jenkins:  
		1- sudo wget link (in instructions in code on github)
	        2- sudo rpm --import link (in instructions in code on github)
                3- yum -y install jenkins
                4- systemctl start jenkins & systemctl enable jenkins(service start jenkins & chkconfig jenkins on)


- Configure Git plugin on jenkins : yum install git -y ,in jenkins add plugins: github, Manage jenkins > global tool   configuration    name git from default to Github (not mandatory)

- Configure Java (JDK) in global tool configuration as well : De-select "Install automatically" , enter the name    "JAVA_HOME" and   add the link (copied from the head -n 3 above)

- Configure Maven (which is used to build jobs): 
	+ go to maven link and copy the link for the version with bin.tar.gz
        + cd /opt and wget link to download maven here
	+ tar -xf apache.......tar.gz to decompress 
	+ rm -rf apache.......tar.gz  to remove the compressed one & mv the new file to a new directory maven (just so it's clean)
        + Set up the path for maven : vim .bash_profile and add on top of JAVA_HOME line : 
		++ M2_HOME=/opt/maven
		++ M2=/opt/maven/bin
	  And on PATH=$PATH:$HOME/bin:$JAVA_HOME:$M2_HOME:$M2 (we added :$M2_HOME to this line on which we added in the past           $JAVA_HOME)  and source .bash_profile, mvn -version to confirm maven is working 
	+ Set it up in jenkins console : install Maven Invoker & Maven Integration plugins / go on global tool configuration and           deselect "install automatically" add maven, in name enter M2_HOME, and under it add path /opt/maven

-Create a maven project> new item, name it and select maven project and next. THEN for "Source Code Management" select GIT and enter the git url (for the project). In the build section => Goals and options add "clean install package" those are instructions for maven.

Jenkins with maven will create a folder with all files from our git repository (project files) and will put it here : var/lib/jenkins/workspace/projectName(from when creating the job in jenkins)

It also create a war file (the artifact) in the folder target (exple: webapp.war), Why? It got the instructions from the pom file in the the project files (webapp folder in git contains a pom file with instructions) which looks like: 
  <artifactId>webapp</artifactId> 
  <packaging>war</packaging>
  <name>webapp</name>
  <description>webapp.</description>

-TOMCAT
      +Install Java and set the path (like with jenkins installation) 
      +cd /opt and download tomcat: wget link and tar -xf name and move to tomcat(new folder)
      +In tomcat/bin chmod +x startup.sh and shutdown.sh (if they are not executable)
      + Start tomcat by executing the /opt/tomcat/bin/startup.sh script
      + check browser IP:8080 to confirm tomcat started
      + find / -name context.xml and vim into the 2 files that have webapps (this is different from the exple project from prof's git) and command out <!--    --> under "context <valve class"
      + ./shutdown.sh and ./startup.sh 
      + Update users information information in the tomcat/conf/tomcat-users.xml :copy code from installation file in git to that file and put it before last line. => ./shutdown.sh and ./startup.sh
Tomcat should be fully working now
 
--Set up jenkins so it can deploy the war file to the tomcat server--
      + Add plugin "deploy to container" 
      + Manage jenkins => Credentials => jenkins & global credentials => Add credential : username "deployer" passwd "deployer" ID TomcatID  description "deploy to tomcat user" (These are the users details that we copied early to the file) 
      + Create a new project "deployTomcat", we can selection "copy from" and use another project like 'mavenproject or test" 
       Description: deploy to tomcat    (exple)
       Post Build Action: Deploy war/ear to a container, type in **/*.war which means any war file (we don't know where is at) 
       containers select tomcat 8.x Remote, add crendials (created earlier), add the tomcat address IPaddress:8080
       + Use git bash, to clone the project, modify the index.jsp file and commit it to see the change on the tomcat server IP:8080/webapp . Rebuild job in jenkins to see changes (deploy new code)

       + Set Build Triggers: select "poll SCM" enter */2 **** (cron: every two minutes, everyday, everymonth, everyday of the month, everyday of the week) it will check every two minutes for changes on the github repository and if any will trigger build
       + Make changes again with gitbash, and wait to witness the autobuild



- DOCKER INTEGRATION   "For a uniform environment, we use a docker engine."

       + use Dockerfile (in the helloword19) or create Dockerfile it and addl to git file must include " COPY ./webapp/target/webapp.war /usr/local/tomcat/webapps " /usr/local/tomcat is where the war file needs to go here so we change it 
       + Create a new project "docker image" & fill it out (git, pollSCM, clean package install)
       + Install Docker on the jenkins server and start the daemon and enable it
       + usermod -aG docker jenkins   (authorise user jenkins to use docker) & restart jenkins (systemctl restart jenkins)
       + In shell script  we can add docker cmd like docker pull tomcat (exple)
       + Pre-Build step set "Docker build and publish"
       + Install docker plugin (cloudBees Docker Build and Publish)
       + Post steps "Run only if build succeeds" and docker build and publish
         Repository Name : dockerUsername/development, TAG:  ${BUILD_NUMBER} jenkins default variable to set build # as tag IF this is not set it will just show as latest
         Registry Credentials Add: enter dockerhub username and password  "for iD: DockerID"

PS: 

If you are using the Docker package supplied by Red Hat / CentOS, the dockerroot group is automatically added to the system. $$$$You will need to edit (or create) /etc/docker/daemon.json $$$$$  to include the following:

{
    "group": "dockerroot"
}

***Ansible*****

Ansible is an automation tool used to deploy many servers, it can be used to deploy cloud infrastructure or on premice servers. It can also be use to automate network device configuration. It is written in python.
Ansible is agentless
Ansible is push base
Learning curve very easy

     + yum install ansible -y 
     + set up Target servers : docker run -itd kserge2001/centos7-ssh or ubuntu-ssh or centos_ssh , docker ps, docker inspect containerID
      IPs 172.17.0.5  / 172.17.0.4   / 172.17.0.3   / 172.17.0.2
     + cd /etc/ansible/   (ansible.cfg sets up behavior, host (inventory file it configures ansible with the target servers) 
     + Go in the host file and add 
       [web]
       172.17.0.5    
       172.17.0.4

       [dbserver]
       172.17.0.3
       172.17.0.2
       
     + ansible web -m ping 
       ansible dbserver -m ping      (we can use all)
     + set up passwords and stuff : 

       [web]
       target1 ansible_host=172.17.0.5 ansible_ssh_user=root ansible_ssh_pass=school1                 target2 ansible_host=172.17.0.4 ansible_ssh_user=root ansible_ssh_pass=school1
       
       [dbserver]
       db1 ansible_host=172.17.0.3 ansible_ssh_user=root ansible_ssh_pass=school1 
       db2 ansible_host=172.17.0.2 ansible_ssh_user=root ansible_ssh_pass=school1

Ps: run => export ANSIBLE_HOST_KEY_CHECKING=False , if you get key error message when you run ansible web (random name or all) -m ping

--With ansible, we can run adhoc command which consist of running one single command on the target servers, or we can run playbooks and roles. 

ansible all -a "cat /etc/os-release"   (command between "") (will run on all the servers)
ansible all -m shell -a "cat /etc/*release" (run it as a shell cmd to avoid errors)

-- Run playbooks
Playbook is used to run many commands on the hosts (YAML formatt, says "yamo")
    + touch name.yml and vim in it and enter: 
	---
	- hosts: web
	  remote_user: root
          ignore_errors: yes
	  tasks: 
	  	- name: Create a user        (google the module for next)
		  user: 
	   	  	name: u2020
			comment: Carlos Monte

		- name: Create file on target host
		  file: 
			path: /tmp/ansiblefile (path to create file)
                        state : touch
		- name: Crearte a directory 
		  file: 
			path: /opt/directory_ansible (path to create directory)
			state: directory
	        - name: Install Apache
		  yum:
			name: httpd
			state: present 
		- name: Start Apache service    (search install dameon module ansible)
		  service:
			name: httpd
			state: started

ansible-playbook firstplay.yml --syntax-check
(DON'T USE TAB IN THIS, IT DOESN'T ACCEPT TAB) 

Run the playbook : ansible-playbook firstplay.yml

publish over ssh is a jenkins plugin needed to log in ansible 

AWS as a code: Tools used
 - Terraform
 - Ansible (that's what we use at Data Services for AWS as a code)
 - Cloudformation

******Use Ansible to deploy EC2*********
        + Use ubuntu ec2 instance
	+ apt install ansible python-pip
	+ pip install boto
	+ cd /etc/ansible & vim in ansible.cfg , uncomment host key checking
	+ vim in hosts add "localhost" at the top of the file (not needed)
	+ touch ec2.yml and add: 
	  ---
	   - hosts: localhost
	     connection: local 
	     tasks: 
		  - name: Create ec2 instance 
		    ec2: 
			key_name: mykey 
			instance_type: t2.micro 
			image: ami-123456
			wait: yes	      (wait til the server lunch)
			#group: webserver      (security group) using defaults
			count:1               (number of instance)
                        #vpc_subnet_id: subnet-29e63245  using defaults
			assign_public_ip: yes
			region: us-east-2

	+ Set up login for ansible, go in IAM > add users > ansible > programmatic access > group admin > tag name ansible > create user 
PS: IMPORTANT "Download.csv"

Actual working example: 
---
- hosts: localhost
  connection: local
  task:
      - name: Create ec2 instance
        ec2:
             key_name: devops1
             instance_type: t2.micro
             image: ami-027cab9a7bf0155df
             wait: yes
             # group: webserver
             count: 1
             # vpc_subnet_id: subnet-29e63245
             # assign_public_ip: yes
             region: us-east-2


Another exemple: 

---
 - hosts: localhost
   connection: local
   tasks:
       - name: Create ec2 instance
         ec2:
              key_name: devops1
              instance_type: t2.micro
              image: ami-027cab9a7bf0155df
              wait: yes
              group: ansible
              count: 1
              #     vpc_subnet_id: subnet-29e63245
              #     assign_public_ip: yes
              region: us-east-2

              instance_tags:
                             name: ansible-lunch


run: ansible-playbook ec2.yml

--Hide aws_secret_key and aws_secret_key  (desactive/delete them in the yaml file)
	+ create a .boto file IN /root (we can also create aws-config file but we will need to install the aws-cli first with apt aws-cli) 
	+ add: 
[Credentials]    (important must be capital C)



-- Set up jenkins for auto ecs deployment with ansible

	+ on the Ansible server create user ansible: useradd ansible -d /home/ansible -s /bin/bash -m
	+ Set up password 
	+ vim /etc/ssh/sshd_config (we need to enable ssh key since AWS uses keys for login)  change PasswordAuthentification to "yes" and restart sshd daemon 
	+ Install ssh plugin in jenkins
	+ manage jenkins > ssh sites > add  > hostname: ansible server ip , port: 22, credentials: go create  credentials (manage credentials > global > add credentials  > ansible and school1 andibleID & description)
        + create new item, Add Build step:Execute shell script on remote host using ssh , enter command: ansible-playbook /etc/ansible/ec2.yml. Make sure you copy the .boto file from /root/ to /home/ansible/.boto (.boto has to be in the user ansible home directory as that's where the system will look for it in this case) 
chown ansible:ansible /home/ansible/.boto  (must be owned by ansible and in group ansible, doing this just because we initially created this in /root/ for demo purposes, so was owned by root.
	+ Build the job


--Set parameters (job with parameters)---
 
Explanation : We want to be able to defines what AMI for each server, wht region, etc...) 
	+ Insert variable in the .yml file: "{{.....}}" are the variables

---
 - hosts: localhost
   connection: local
   tasks:
       - name: Create ec2 instance
         ec2:
              key_name: "{{ KEYNAME }}"
              instance_type: "{{ INSTANCE_TYPE }}"
              image: "{{ IMAGE }}"
              wait: yes
              group: "{{ SG_GROUP }}"
              count: "{{ COUNT }}"
              #     vpc_subnet_id: subnet-29e63245
              #     assign_public_ip: yes
              region: "{{ REGION }}"

              instance_tags:
                             name: "{{ TAG }}"

To run it: ansible-playbook ec2.yml -e "KEYNAME=devops1 IMAGE=ami-027cab9a7bf0155df ..."  (must include all tags) -e means extra variables

SET IT UP IN JENKINS: 

	+ Go to project's configuration > this project is parameterized > add parameters > choice/string parameter > Name must match the variable (REGION ETC...), enter default value & description 
        + Under the build step now, command will be :
ansible-playbook /etc/ansible/ec2.yml -e "KEYNAME=$KEYNAME IMAGE=$IMAGE INSTANCE_TYPE=$INSTANCE_TYPE SG_GROUP=$SG_GROUP COUNT=$COUNT REGION=$REGION TAG=$TAG "


Add post-build action > email notification   (to get emails when a job build fails) 


Inventory file: the defaults is host

ansible dbserver -m setup (inventory of a all servers under dbserver)
****************************************


****Git revision******
git init

git clone url

git branch branchName to create a branch 

git checkout branchName to switch branch

git status

git add . 

git commit -m "release branch"    

git push origin release 

git revert <name of bad commit> 

git log    (will show all the commit ID)

git remote -v (to see if we have any github repository plugged in) 

****Git Conflict*********

Sometimes when we use git we can run into conflict, this is due to the fact that other developers are constantly modifying and pushing the code. Git wants us to always have the latest copy before accepting our changes. 
To solve this conflict we can use the git pull command to pull the latest copy of the file or copy of the code before making our changes 

git pull origin master (master can be replace by any branch name) 

Practice: 
1- Make a change in Github and try to push a new change done in git bash.


*****Jenkins*********
Open source software used for continious integration, it has many plugins and enables user to combine jenkins with any other tools or software.

example: 
   github : enables jenkins to communicate with github
   maven invoker: enables jenkins to use maven tool for job build
   docker: enable jenkins to run docker commands
   container: enable jenkins to deploy war and ear file to a tomcat server 
   pipeline: enable creation of declarative and scripted pipeline in jenkins.

This is making jenkins a very powerful tools because it can fit anywhere. 

Ant can be uused as well instead of maven to build a job

var/lib/jenkins/workspace/mavenproject
opt/maven 
opt/maven/bin 

mvn clean install package
PATH=$PATH:$HOME/bin:$JAVA_HOME:$M2_HOME:$M2
source /root/.bash_profile

maven, ant, graddle




====Kubernetes clusters======

3.235.63.122

"3.237.3.16"

school1
 kubectl get nodes

34.204.185.128 (Master server)

touch & vim my.cnf and enter   (/etc/ansible)

[client]
user=root
password=''

touch & vim info.php and enter 

<?php
phpinfo();
?>

ansible handlers 

github ====> jenkins ====> docker registry (Private) ====> Pull the docker image to build containers



Kunernetes master => Image registry and nodes (1,2,3,4 ....)

A pod is a collection of one or more containers It serves as kubernetes core unit management

Alternative to Kubernetes is DOCKER SWARM
replicas set (how many pods)

kubectl get nodes
kuctl get pods -o wide
kubectl get deployment
kubectl get pods --all-namespaces

kubectl run cnt-app --image=horacegbenou/development --replicas=2 --port=8080
kubectl delete pod cnt-app (cnt-app is just the name, image is the docker image, replicas is the number of pods and port 8080 since we deploying tomcat here)

kubectl create -f cnt-deploy.yml
kubectl apply -f cnt-deploy.yml (after updating the yaml file)
kubectl describe pod podID
kubectl get service
kubectl get pods -o wide | grep horace

Kops (Kubernetes ops)  (Kubernetes deployment in enteprises)

kops validate cluster
kops delete cluster demo.k8s.valaxy.net --yes

Tell us a situation where you troubleshoot an issue in Kubernetes? 
Load selector?

Kubernetes desire state : self-heal, recreate pods if deleted

How do we do a rollback : change the tag in the app.yml file</p>
