## Capistrano-Deploy-Tagger

### About

Capistrano-Deploy-Tagger creates and updates certain tags in Git each time you perform a deploy.

There are two types of tag, the first defaults to 'inproduction', and is always updated to refer to the revision that was just deployed. This gives you a tag which always points to the latest release to production. This can be used in many ways, for example, in an autoscaling environment, to clone the correct release of software.

The second type of tag is a timestamp, and is applied to every revision that is deployed to production, giving you an easy way to see exactly which revisions have been deployed to production in the past. This is helpful if attempting to diagnose issues that may not have become immediately apparent.

### Installing

  - gem install capistrano-deploy-tagger

In your deploy.rb:

  - require 'capistrano/deploy/tagger'

Now when you run a standard 'cap deploy', upon success you will see the following line in your output:

  - [Capistrano-Deploy-Tagger] Updating deployment git tags...

### Overriding Defaults

By default, the first tag which represents the latest deploy is named 'inproduction'. You can change this globally, or for certain cap tasks by setting the following in your deploy.rb:
  
  - set :latest_deploy_tag, "your_tag_name_here"

You can also disable updating tags, again globally or for specific cap tasks, by setting the following in your deploy.rb:

  - set :update_deploy_tags, false

You can also disable timestamp type tags by setting the following in your deploy.rb:

  - set :update_deploy_timestamp_tags, false

### Special Usage

You can force Capistrano to deploy from the 'inproduction' tag, and prevent Capistrano-Deploy-Tagger from updating any tags by running your deployment like so:

  - cap automatic deploy

The 'automatic' task overrides :branch to set it to the value of :latest_deploy_tag, then sets :update_deploy_tags to false.

This becomes useful if you have an automated deployment system, for example AWS Autoscaling, and need to clone the revision currently in production, rather than just pulling HEAD.

### Notes

Originally I wanted to allow the timestamp tags to be deleted, keeping only a configurable amount of the most recent, however there are problems with this. When another user pulls the repository, they pull down the tags. If one of those tags is then deleted, they retain their local copy of it, and things then become confusing for everyone. If you update the revision a tag refers to, this doesn't seem to be an issue however. If this changes in the future I'll take another look.