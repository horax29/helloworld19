# Pull base image 
From tomcat:8-jre8 

# Maintainer 
MAINTAINER "hgbenou29" 
COPY ./webapp/target/webapp.war /usr/local/tomcat/webapps
