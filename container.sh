#!/bin/bash
read -p "Input total container: " my_var
read -p "Input directory save uuid (ex: /root) default is $HOME: " dir

if [ -z "$dir" ];
then 
    HOME_DIR=${HOME}
else
    HOME_DIR=${dir}
fi

echo ${my_var}
echo ${HOME_DIR}

echo -e "Open the link below via a browser that is logged in to your EarnApp account...\n" > ${HOME_DIR}/link-uuid-generated.txt

for i in $(seq 1 $my_var); 
    do 
        # echo $i; 
        if [ -d "${HOME_DIR}/earnapp-data" ]; 
            then rm -Rf ${HOME_DIR}/earnapp-data; 
        fi
        # Use printf to format numbers with leading zeros
        number=`printf "%02d\n" "$i"`
        echo $number
        docker container rm --force earnapp

        echo -e "Running container earnapp-master...\n"
        # Running reguler earnapp container
        docker run -d --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ${HOME_DIR}/earnapp-data:/etc/earnapp --name earnapp fazalfarhan01/earnapp

        sleep 30
        echo "sleep 30 seconds...."
        echo -e "Generate UUID...\n"
        # Generate uuid
        CHECK_UUID=$(docker container exec -it earnapp earnapp showid | tr -d '\r')
        # docker container exec earnapp earnapp showid

        echo ${CHECK_UUID}

        echo -e "Remove container regular...\n"
        # Remove container regular earnapp
        docker container rm --force earnapp

        echo -e "Remove directory earnapp-data...\n"
        # remove directory earnapp-data
        rm -rf ${HOME_DIR}/earnapp-data

        echo -e "Running container earnapp-lite...\n"
        # Running earnapp lite container
        docker run -d --restart=always -e EARNAPP_UUID="${CHECK_UUID}"  --name earnapp$number fazalfarhan01/earnapp:lite

        echo -e "Generate Link with UUID...\n"
        # Generate link with uuid
        echo -e "https://earnapp.com/dashboard?link_device=${CHECK_UUID}" >> ${HOME_DIR}/link-uuid-generated.txt

done
echo -e "View generated link with UUID in this file ${HOME_DIR}/link-uuid-generated.txt"
