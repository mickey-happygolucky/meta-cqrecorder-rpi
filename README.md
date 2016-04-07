meta-cqrecorder-rpi includes scripts which control the recorder board(own works).

the recorder board will be featured in the magazine "Interface(CQ Publishing) 12,2015".

Details for Interface see below URL(in JAPANESE).

http://interface.cqpub.co.jp/


This layer depends on:

URI: git://git.yoctoproject.org/poky.git
branch: fido
revision: HEAD

URI: git://git.yoctoproject.org/meta-raspberrypi
branch: master
revision: HEAD

URI: https://github.com/mickey-happygolucky/meta-ssm2603-rpi.git
branch: master
revision: HEAD


To use recorder board, add the line as follows in your local.conf.

```
IMAGE_INSTALL_append = " alsa-utils \
		     amixer-init \
		     cqrecorder \
		     "
```


Main layer maintainers:
  Yusuke Mitsuki <mickey.happygolucky@gmail.com>
