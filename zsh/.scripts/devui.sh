#!/bin/bash

devui() {
  uwsm app -- cursor &
  sleep 1
  uwsm app -- firefox-developer-edition &
  sleep 1
  uwsm app -- slack &
}

