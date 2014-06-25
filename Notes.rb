
/Users/johnfitzpatrick/Documents/Scratch/learnchefjune14/chef-repo

vagrant up
knife bootstrap localhost --sudo -x vagrant -P vagrant --ssh-port 2222 -N node1

knife bootstrap localhost --sudo -x vagrant -P vagrant --ssh-port 2222 -N node1 -r recipe[arr]
