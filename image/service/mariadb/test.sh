#!/bin/bash -e

# Copy testing data to their respective directories on an as-needed basis
mkdir -p /var/lib/mysql
cp -rf /container/test/database/* /var/lib/mysql/ || true
