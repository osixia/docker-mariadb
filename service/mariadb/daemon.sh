#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

exec /usr/bin/mysqld_safe
