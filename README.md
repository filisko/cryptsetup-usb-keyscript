# 🔐 Keyscript for LUKS LVM

![ci](https://github.com/filisko/cryptsetup-usb-keyscript/actions/workflows/main.yaml/badge.svg)

A robust and thoroughly tested Bash script to automatically unlock a LUKS LVM setup using a key inside a USB.

## 🔧 Setup


## ⚙️ Installation

```sh
wget https://raw.githubusercontent.com/filisko/cryptsetup-usb-keyscript/refs/heads/main/src/keyscript.sh
chmod +x keyscript.sh
```


### Clone the project:

```sh
git clone git@github.com:filisko/cryptsetup-usb-keyscript.git
```

### Install BashUnit:

```sh
./install_bashunit.sh
```

### Watch & Run the tests:

This watches for changes either on the code or in any of the tests.

```sh
# watch all tests
./watch.sh tests

# watch one specific test (probably what you want at first)
./watch.sh tests/run.test.sh
```

### Run all tests:

This script is used for the GitHub action. It runs all tests.

```sh
./tests.sh
```

## 🧾 License

This project is licensed under the MIT License (MIT). Please see [LICENSE](https://github.com/filisko/cryptsetup-usb-keyscript/blob/main/LICENSE)
 for more information.
