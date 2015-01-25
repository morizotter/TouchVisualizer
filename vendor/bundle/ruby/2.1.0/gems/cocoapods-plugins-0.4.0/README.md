# Cocoapods plugins

[![Build Status](https://img.shields.io/travis/CocoaPods/cocoapods-plugins/master.svg?style=flat)](https://travis-ci.org/CocoaPods/cocoapods-plugins)
[![Coverage](https://img.shields.io/codeclimate/coverage/github/CocoaPods/cocoapods-plugins.svg?style=flat)](https://codeclimate.com/github/CocoaPods/cocoapods-plugins)
[![Code Climate](https://img.shields.io/codeclimate/github/CocoaPods/cocoapods-plugins.svg?style=flat)](https://codeclimate.com/github/CocoaPods/cocoapods-plugins)

CocoaPods plugin which shows info about available CocoaPods plugins or helps you get started developing a new plugin. Yeah, it's very meta.

## Installation

    $ gem install cocoapods-plugins

## Usage

#####List plugins

    $ pod plugins

List all known plugins (according to the list hosted on github.com/CocoaPods/cocoapods-plugins)

#####Search plugins

    $ pod plugins search QUERY

Searches plugins whose name contains the given text (ignoring case). With --full, it searches by name but also by author and description.

#####Create a new plugin

    $ pod plugins create NAME [TEMPLATE_URL]

Creates a scaffold for the development of a new plugin according to the CocoaPods best practices.
If a `TEMPLATE_URL`, pointing to a git repo containing a compatible template, is specified, it will be used in place of the default one.

## Get your plugin listed

The list of plugins is in the cocoapods-plugins repository at [https://github.com/CocoaPods/cocoapods-plugins/blob/master/plugins.json](https://github.com/CocoaPods/cocoapods-plugins/blob/master/plugins.json).

To have your plugin listed, submit a pull request that adds your plugin details.

