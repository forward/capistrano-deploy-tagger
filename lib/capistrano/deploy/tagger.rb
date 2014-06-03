require 'rubygems'
require 'capistrano'

def git(cmd, opts={:output => false})
  opts[:output] ? `git #{cmd} #{debug}`.chomp : system("git #{cmd} > /dev/null 2>&1")
end

Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :deploy do

    after "deploy", "deploy:tagger:tag"

    namespace :tagger do
      desc "Manage git tags to indicate current deployed codebase, and keep a history of the most recent deploys."

      task :tag do
        update_tag                    = fetch(:update_deploy_tags)           rescue true
        update_timestamp              = fetch(:update_deploy_timestamp_tags) rescue true

        tag_name                      = fetch(:latest_deploy_tag)                  rescue "inproduction"
        deploy_timestamp_tag_prefix   = fetch(:latest_deploy_timestamp_tag_prefix) rescue "deploy"

        # keep_deploy_tags = fetch(:keep_deploy_tags) rescue 10
        current_branch = fetch(:branch)

        is_automatic_deploy = fetch(:is_automatic_deploy) rescue false

        if update_tag
          
          user = git("config --get user.name", {:output => true})
          email = git("config --get user.email", {:output => true})

          latest_revision.strip!

          puts "[Capistrano-Deploy-Tagger] Updating deployment Git tags...\n"

          git "fetch --tags", {:output => true}

          if update_timestamp
            # Remove any existing deploy-branch-date tags first - this is in case of multiple deploys of the same revision,
            # we don't want multiple copies of those tags to start stacking up on the same revision.
            # git("tag -l --contains #{revision} deploy-#{current_branch}-*", {:output => true}).to_a.each do |tag|
            #   git "tag -d #{tag}"
            #   git "push origin :#{tag}"
            # end
            
            # Create a tag for the current deploy with time and date, we'll keep a few of these for history.
            deploy_tag_string = "#{deploy_timestamp_tag_prefix}-#{Time.now.strftime("%Y%m%d-%H%M%S")}"
            git "tag #{deploy_tag_string} #{latest_revision}"

            # Remove older deploy tags, ensuring we keep at least ':keep_deploy_tags' of the more recent deploy tags.
            # expired_deploy_tags = git("tag -l deploy-#{current_branch}-*", {:output => true}).to_a
            # expired_deploy_tags.pop(keep_deploy_tags)

            # expired_deploy_tags.each do |tag|
            #   git "tag -d #{tag}"
            #   git "push origin :#{tag}"
            # end
          end

          # Remove an existing 'latest_deploy_tag' tag, then recreate it at the current revision.
          # if git("tag -l #{tag_name}", {:output => true}) == tag_name
          #   git "tag -d #{tag_name}", {:output => true}
          #   git "push origin :#{tag_name}", {:output => true}
          # end

          # Trying to reduce the number of seperate requests out to Git to speed up the tagging step. Have to force push the tags to
          # ensure that the 'inproduction' tag is overwritten.
          git "tag -f #{tag_name} #{latest_revision}", {:output => true}
          git "push -f --tags", {:output => true}

          puts "[Capistrano-Deploy-Tagger] Tagging complete."
        else

          if is_automatic_deploy
            puts "[Capistrano-Deploy-Tagger] Automatic deployment - not updating deployment Git tags..."
          else
            puts "[Capistrano-Deploy-Tagger] Not updating deployment Git tags..."
            puts "To enable this behaviour, add the following to your deploy.rb: 'set :update_deploy_tags, true'."
          end

        end

      end
    end
  end

  task :automatic do
    # The EC2 autoscale self deploy tool calls 'bundle exec cap automatic deploy' to trigger this.
    # We set 'update_deploy_tags' to false so the 'latest_deploy_tag' tag isn't altered during autoscaling.
    # We also override the branch to deploy from to be the selfdeploy_tag.
    
    set :deploy_via, :export # Git + capistrano don't like switching to a tag from master
    set :update_deploy_tags, false
    set :is_automatic_deploy, true
    
    tag_name = fetch(:latest_deploy_tag) rescue "inproduction"
    set :branch, tag_name
  end

end
