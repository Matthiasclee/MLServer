# MLServer

## What is MLServer?
MLserver is a simple, easy to use webserver that allows for infinite flexibility.

## How to install
To use MLServer in your project, either download the [current script](https://raw.githubusercontent.com/Matthiasclee/MLServer/main/server.rb), or download the [latest release](https://github.com/Matthiasclee/MLServer/releases/latest), which will come with all of its respective assets. After downloading the current script, if you choose to do so, put this line of code above the ```require``` statement that requires MLServer:

```rb
$SRV_SETTINGS = {:check_for_assets => true}
```
That makes MLServer check and see if it has all of its necessary assets. You can either leave it there and check for assets every time you run your program, in case of an accident, or remove it after the first time in order to speed up your program.

The rest of the documentation can be found [here](https://raw.githubusercontent.com/Matthiasclee/MLServer/docs/docs.md).