# roboshop-bash

In this repo, we will write bash script to do the configuration management for roboshop on linux redhat 9.

We also need to make sure that we are going to write the code keeping the multi-environment strategy in to consideration.

This is exepcted to run on the top of the component servers, to execute the script frontend.sh, we need to be on frontend server.

1) Login to frontend server
2) Do a git clone of your repo that has bash for roboshop
3) and then switch to the repo and then run
    $ bash frontend.sh

# Whenever we deal things that scale, we need an NFR that has to be followed across the board!
NFR: Non-Functional Requirement

    1) When we automate something, the re-run of that should work without any disruption.
    2) When you restart the compoments, apps should come up automatically.
    3) Code should always support multi-environment.
    4) When you see some value is repeated multiple times, make sure it's parameterized
    5) All the backend components should be accessed privately with private dns records

> Basics are important
1) If I say run the script test.sh
2) git clone or git pull the repo
3) Make sure that script is in the folder that you're running
4) ls -ltr
5) bash test.sh 

# We can buy domain in aws as well, but if we already have a domain, we can move it to AWS Route53 or buy a domain on Hostinger or GoDaddy and can be managed by AWS Route53 using Domain Transer

> Going forward
    1) We will create A Type DNS Record with Public IP Address for frontend and for rest of the components, we will create A Type records using the private ip address of the component.

> How can we manage a domain that we bought on HOSTINGER or GODADDY to be managed from Cloud ?
    1) To do that, create a Public Hosted zone with the domain you bought like sample.com on AWS Route53
    2) Then AWS offers you the nameservers, whch are the windows servers managed by the AWS.
    3) Then copy these nameservers on AWS and replace them with what you see on hostiner domain.

This way, requests related to your domain will be forwated to the hosted zone created by you on AWS Route53.
Once you update the Nameservers of AWS Route53 Hosted zone on your domain provider, it's going to take 1 to 24 hrs of time for them to work on AWS (for the first time )

# When you write a script or code, ensure the code is not duplicated. Always make sure the code is DRY!!!!

> DRY vs WET Code ?

DRY: Don't Repeat Yourself
Core Principle: Every piece of knowledge or logic must have a single, unambiguous, authoritative representation in a system.

Advantages: Makes code easier to maintain, test, and scale. 
Changes only need to be applied in one place.
Best Used For: Complex logic, database queries, API calls, and validation logic.

WET Code is a code that's Write Everything Twice.
