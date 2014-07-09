

Local location
/Users/johnfitzpatrick/Documents/Scratch/learnchefjune14/chef-repo

Cut/pastes
vagrant up
knife bootstrap localhost --sudo -x vagrant -P vagrant --ssh-port 2222 -N node1

knife bootstrap localhost --sudo -x vagrant -P vagrant --ssh-port 2222 -N node10 -r recipe[arr]

knife node run_list set node7 'recipe[arr]'

knife bootstrap uvo1n2g0am70waokpwk.vm.cld.sr --sudo -x opscode -P opscode -N node9 -r recipe[arr]




