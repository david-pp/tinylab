#!/bin/bash

hexo generate
rsync -arv public/ david@139.196.7.121:/var/www/html
