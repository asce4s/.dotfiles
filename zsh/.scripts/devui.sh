#!/bin/bash


devui() {
  uwsm app -- cursor
  uwsm app -- firefox-developer-edition
  uwsm app -- slack
}

# Create shorter alias
alias devui='devui'

