# README #

This is the repository of [CistromeDB](http://cistrome.org/db/) for browser-side codes.

### Install Dependencies ###


```
#!shell

npm install
bower install

```

### Serve Development Version ###


```
#!shell

grunt serve

```

### Serve Producton Version ###


```
#!shell

grunt serve:build
```

### Deploy to Web Server ###

Change host and port to your own ones, change dest key to your deployed server path, then run,
```
#!shell

grunt sftp-deploy
```
