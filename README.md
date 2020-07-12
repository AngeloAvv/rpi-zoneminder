# rpi-zoneminder

Docker container for [zoneminder v1.34.16][3]

"ZoneMinder the top Linux video camera security and surveillance solution. ZoneMinder is intended for use in single or multi-camera video security applications, including commercial or home CCTV, theft prevention and child, family member or home monitoring and other domestic care scenarios such as nanny cam installations. It supports capture, analysis, recording, and monitoring of video data coming from one or more video or network cameras attached to a Linux system. ZoneMinder also support web and semi-automatic control of Pan/Tilt/Zoom cameras using a variety of protocols. It is suitable for use as a DIY home video security system and for commercial or professional video security and surveillance. It can also be integrated into a home automation system via X.10 or other protocols. If you're looking for a low cost CCTV system or a more flexible alternative to cheap DVR systems then why not give ZoneMinder a try?"

This project is a Raspberry Pi porting of [docker-zoneminder][7] created by [QuantumObject][8]. The original Dockerfile and startup.sh files have been adapted to work with Raspberry Pi OS. Most instructions stay the same. So if you want, buy him a beer too.

## Install dependencies

- [Docker][2]

To install docker in Raspberry Pi OS use the commands:

```bash
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh

$ sudo usermod -aG docker $USER

```

## Usage

To run with MySQL in a separate container use the command below:

```bash
docker run -d -e TZ=Europe/Rome -e MYSQL_ROOT_PASSWORD=zmpass -e MYSQL_USER=zmuser -e MYSQL_PASSWORD=zmpass -e MYSQL_DATABASE=zm --net=host --name zoneminder_db jsurf/rpi-mariadb
docker run -d --shm-size=4096m -e TZ=Europe/Rome --net=host --name zoneminder angeloavv/rpi-zoneminder:latest
```

The shm size should be 1:1 with your RAM size.

## Set the timezone per environment variable

    -e TZ=Europe/London

Default value is Europe/Rome .

## Other environment variable that can be define at docker run command for zoneminder image

     -e ZM_DB_HOST=127.0.0.1
     
     -e ZM_DB_NAME=zm 
     
     -e ZM_DB_USER=zmuser
     
     -e ZM_DB_PASS=zmpass
     
     -e ZM_DB_PORT=3306
     
## Make sure that value for ZM_DB_  and MYSQL_ are the same : 

    ZM_DB_NAME ==> MYSQL_DATABASE
    ZM_DB_USER ==> MYSQL_USER
    ZM_DB_PASS ==> MYSQL_PASSWORD
    .......... ==> ........... 

## Volume for zoneminder container 
- /var/cache/zoneminder
- /etc/zm
- /var/log/zm

## Accessing the Zoneminder applications

After that check with your browser at addresses plus the port assigned by docker:

- <http://host_ip:port/zm/>

Then log in with login/password : admin/admin , Please change password right away and check on-line [documentation][6] to configure zoneminder.

and if you change System=> "Authenticate user logins to ZoneMinder" you at this moment need to change "Method used to relay authentication information " to "None" if this not done you will be unable to see live view. This only recommended if you are using https to protect password(This relate to a misconfiguration or problem with this container still trying to find a better solutions).

if timeline fail please check TimeZone at php.ini is the correct one for your server( default is America/New York).

To access the container from the server that the container is running :

$ docker exec -it container_id /bin/bash
## More Info

About zoneminder [www.zoneminder.com][1]

To help improve this container [angeloavv/rpi-zoneminder][5]

## License

rpi-zoneminder is available under the MIT license. See the LICENSE
file for more info.

[1]:http://www.zoneminder.com/
[2]:https://www.docker.com
[3]:http://www.zoneminder.com/downloads
[4]:http://docs.docker.com
[5]:https://github.com/AngeloAvv/rpi-zoneminder
[6]:http://www.zoneminder.com/wiki/index.php/Documentation
[7]:https://github.com/QuantumObject/docker-zoneminder
[8]:https://github.com/QuantumObject