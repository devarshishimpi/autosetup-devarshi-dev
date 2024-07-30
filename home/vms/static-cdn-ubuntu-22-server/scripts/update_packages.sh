#!/bin/bash

# Update the package list

update_packages() {
    SOURCES_LIST="/etc/apt/sources.list"
    rm -rf $SOURCES_LIST
    touch $SOURCES_LIST
    sudo apt update
    sudo apt upgrade -y
    sudo apt install git curl wget zip unzip -y
}

update_packages