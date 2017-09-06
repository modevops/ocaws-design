#!/bin/bash

#oc login https://openshift-master.aws.sc.technology --token=XXXX


#new project

#oc new-project helloworld-msa


#hola (JAX-RS/Wildfly Swarm) microservice

git clone https://github.com/santiagoangel/hola
cd hola/
oc new-build --binary --name=hola -l app=hola
mvn package; oc start-build hola --from-dir=. --follow
oc new-app hola -l app=hola,hystrix.enabled=true
oc expose service hola


oc set probe dc/hola --readiness --get-url=http://:8080/api/health


#Deploy aloha (Vert.x) microservice

cd ..

git clone https://github.com/redhat-helloworld-msa/aloha
cd aloha/
oc new-build --binary --name=aloha -l app=aloha
mvn package; oc start-build aloha --from-dir=. --follow
oc new-app aloha -l app=aloha,hystrix.enabled=true
oc expose service aloha



oc env dc/aloha AB_ENABLED=jolokia; oc patch dc/aloha -p '{"spec":{"template":{"spec":{"containers":[{"name":"aloha","ports":[{"containerPort": 8778,"name":"jolokia"}]}]}}}}'
oc set probe dc/aloha --readiness --get-url=http://:8080/api/health


#Deploy ola (Spring Boot) microservice

cd ..

git clone https://github.com/santiagoangel/ola
cd ola/
oc new-build --binary --name=ola -l app=ola
mvn package; oc start-build ola --from-dir=. --follow
oc new-app ola -l app=ola,hystrix.enabled=true
oc expose service ola

#Deploy bonjour (NodeJS) microservice


cd ..
git clone https://github.com/redhat-helloworld-msa/bonjour
cd bonjour/
oc new-build --binary --name=bonjour -l app=bonjour
npm install; oc start-build bonjour --from-dir=. --follow
oc new-app bonjour -l app=bonjour
oc expose service bonjour

oc set probe dc/bonjour --readiness --get-url=http://:8080/api/health


oc env dc/ola AB_ENABLED=jolokia; oc patch dc/ola -p '{"spec":{"template":{"spec":{"containers":[{"name":"ola","ports":[{"containerPort": 8778,"name":"jolokia"}]}]}}}}'
oc set probe dc/ola --readiness --get-url=http://:8080/api/health


#Deploy api-gateway (Spring Boot)

cd ..

git clone https://github.com/redhat-helloworld-msa/api-gateway
cd api-gateway/
oc new-build --binary --name=api-gateway -l app=api-gateway
mvn package; oc start-build api-gateway --from-dir=. --follow
oc new-app api-gateway -l app=api-gateway,hystrix.enabled=true
oc expose service api-gateway



oc env dc/api-gateway AB_ENABLED=jolokia; oc patch dc/api-gateway -p '{"spec":{"template":{"spec":{"containers":[{"name":"api-gateway","ports":[{"containerPort": 8778,"name":"jolokia"}]}]}}}}'
oc set probe dc/api-gateway --readiness --get-url=http://:8080/health


#Deploy frontend (NodeJS/HTML5/JS)

cd ..

git clone https://github.com/redhat-helloworld-msa/frontend
cd frontend/
oc new-build --binary --name=frontend -l app=frontend
npm install; oc start-build frontend --from-dir=. --follow
oc new-app frontend -l app=frontend
oc expose service frontend


#Specify the OpenShift domain

oc env dc/frontend OS_SUBDOMAIN=apps.aws.sc.technology



oc set probe dc/frontend --readiness --get-url=http://:8080/


#Deploy Kubeflix

cd ..
oc process -f https://raw.githubusercontent.com/santiagoangel/ocaws-design/master/templates/kubeflix-1.0.17-28-kubernetes-template.yml | oc create -f -
oc expose service hystrix-dashboard --port=8080
oc policy add-role-to-user admin system:serviceaccount:helloworld-msa:turbine

#Enable the Hystrix Dashboard in the Frontend


oc env dc/frontend ENABLE_HYSTRIX=true


#Deploy Jaeger

oc process -f https://raw.githubusercontent.com/jaegertracing/jaeger-openshift/0.1.2/all-in-one/jaeger-all-in-one-template.yml | oc create -f -
oc env dc -l app JAEGER_SERVER_HOSTNAME=jaeger-all-in-one  # redeploy all services with tracing

#Enable the Jaeger Dashboard in the Frontend


oc env dc/frontend ENABLE_JAEGER=true


#Use a SSO server to secure microservices


oc new-project sso

git clone https://github.com/redhat-helloworld-msa/sso
cd sso/
oc new-build --binary --name keycloak
oc start-build keycloak --from-dir=. --follow
oc new-app keycloak
oc expose svc/keycloak

oc set probe dc/keycloak --readiness --get-url=http://:8080/auth

#Specify the OpenShift domain

oc env dc/keycloak OS_SUBDOMAIN=apps.aws.sc.technology


#Tell microservices where to find the Keycloak server
oc project helloworld-msa

# OS_SUBDOMAIN=apps.aws.sc.technology
oc env dc KEYCLOAK_AUTH_SERVER_URL=http://keycloak-sso.apps.aws.sc.technology/auth -l app

oc env dc/frontend ENABLE_SSO=true



